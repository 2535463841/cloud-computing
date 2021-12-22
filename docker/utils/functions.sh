set -u

export WORKSPACE=$(pwd)

logInfo(){
    echo -e $(date +"%F %T") "\033[34mINFO:\033[0m" "$1" >&2
}

logError(){
    echo -e $(date +"%F %T") "\033[31mERROR:\033[0m" "$1" >&2
}

logWarn(){
    echo -e $(date +"%F %T") "\033[33mWARN:\033[0m" "$1" >&2
}

getOSType(){
    local osRelase=$(grep ^ID= /etc/os-release)
    echo ${osRelase##ID=} |sed 's|"||g'
}

rmExitedContainer(){
    docker ps -a |awk '/Exited \(.*\) .*/{print $1}' |xargs docker rm
}

rmImageWithNone(){
    docker image ls |awk '/<none> * <none>/{print $3}' |xargs docker image rm
}

getHostnameMapping(){
    local hostOpt=''
    while read line
    do
        [[ "${line}" =~ ^( *)$ ]] && continue
        [[ "${line}" =~ ^( *)# ]] && continue
        [[ "${line}" =~ 127.0.0.1 ]] && continue
        [[ "${line}" =~ localhost ]] && continue
        local ip=$(echo "${line}" |awk '{print $1}')
        local name=$(echo "${line}" |awk '{print $2}')
        hostOpt="${hostOpt} ${name}:${ip}"
    done < /etc/hosts
    echo ${hostOpt}
}

makeRunEnv(){
    env |egrep "^DOCKER_RUN_NETWORK=" > /dev/null
    if [[ $? -ne 0 ]]; then
        DOCKER_RUN_NETWORK=host
    fi
}

cleanUpBuild(){
    logInfo "clean up build trash"
     rm -rf *.repo
}

dockerRun(){
    local component=$1
    local version=$2
    local target="$(getBuildTarget ${component} ${version})"

    cd ./components/${componentName}
    logInfo "docker run ${target} ${version}"
    if [[ -f docker_run.sh ]]; then
        sh docker_run.sh ${target} ${version}
    else
        docker run -itd \
            --privileged=true \
            -v /etc/hosts:/etc/hosts \
            -v /sys/fs/cgroup:/sys/fs/cgroup \
            --name ${component}:${version} \
            $(getBuildTarget nova-conductor ${version})
    fi
    if [[ $? -ne 0 ]]; then
        logError "docker run failed!"
        return 1
    fi
    docker ps
}

dockerBuild(){
    local component=$1
    local version=$2
    local target="$(getBuildTarget ${component} ${version})"
    local buildOpts="-f ${DOCKER_FILE} -t ${target} "

    cd ./components/${componentName}
    prepareResources || return 1

    docker help build |grep add-host > /dev/null
    if [[ $? -eq 0 ]]; then
        for line in $(getHostnameMapping); do
            buildOpts="${buildOpts} --add-host ${line}"
        done
    else
        logInfo 'modify hosts for repo files'
        for line in $(getHostnameMapping); do
            local name=$(echo $line |awk -F : '{print $1}')
            local ip=$(echo $line |awk -F : '{print $2}')
            sed -i "s|${name}|${ip}|g" ./*.repo
        done
    fi
    local buildCmd="docker build ${buildOpts} ./"

    logInfo "buildCmd is: ${buildCmd}"
    ${buildCmd}
    local buildResult=$?
    if [[ ${buildResult} -ne 0 ]]; then
        logError "build ${component}:${version} failed"
    else
        logInfo "build ${component}:${version} success"
        logInfo "list images of ${target}"
        docker image ls ${target}
    fi
    cleanUpBuild
    return ${buildResult}
}

getRabbitmqTransportUrl(){
    local nodes=''
    for host in $(echo "${RABBITMQ_HOSTS}" |sed 's|,| |g')
    do
        if [[ "${nodes}" != "" ]]; then
            nodes="${nodes},"
        fi
        nodes="${nodes}${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@${host}:5672"
    done
    echo "rabbit://${nodes}"
    return 0
}

if [[ -f ~/.docker_openrc ]];then
    source ~/.docker_openrc
fi

getMemcachedServers(){
    local servers=''
    for host in $(echo "${MEMCACHED_HOSTS}" |sed 's|,| |g')
    do
        if [[ "${servers}" != "" ]]; then
            servers="${servers},"
        fi
        servers="${servers}${host}:11211"
    done
    echo "${servers}"
}

getIPByHostName(){
    local hostName=$1
    while read line
    do
        [[ "${line}" =~ ^( *)$ ]] && continue
        [[ "${line}" =~ ^( *#) ]] && continue

        local ip=$(echo ${line} |awk '{print $1}')
        local name=$(echo ${line} |awk '{print $2}')
        if [[ "${name}" == "${hostName}" ]]; then
            echo ${ip}
            break
        fi
    done < /etc/hosts
}

getDockerfile(){
    if [[ ! -f ${DOCKER_FILE} ]]; then
        logError "dockerfile: ${DOCKER_FILE} not exits"
        return 1
    else
        logInfo "${DOCKER_FILE}"
    fi
    echo "${DOCKER_FILE}"
}

getBuildTarget(){
    echo "${BUILD_REPOSITORY}/${BUILD_PROJECT}/${1}:${2}"
}

prepareResources(){
    local resourcePath="${WORKSPACE}/resource/${DOCKER_FILE}"
    if [[ -d ${resourcePath} ]]; then
        logInfo "prepare resources from ${resourcePath}"
        cp ${resourcePath}/* ./
    fi
}

withContainer(){
    export DOCKER_USE_CONTAINER=$1
}

exitContainer(){
    unset DOCKER_USE_CONTAINER
}

dockerExec(){
    logInfo "Run at ${DOCKER_USE_CONTAINER}: $*"
    docker exec -it ${DOCKER_USE_CONTAINER} $@
}

dockerRestart(){
    logInfo "restart container ${DOCKER_USE_CONTAINER}"
    docker restart ${DOCKER_USE_CONTAINER}
}

checkEnv(){
    if [[ ! -f ${DOCKER_FILE} ]]; then
        logError "dockerfile: ${DOCKER_FILE} not exits."
        return 1
    fi
}

getOvsOptionsForDockerBuild(){
    options=''
    for cmd in ovs-vsctl ovs-ofctl ovs-appctl
    do
        local cmdPath=$(which ${cmd})
        options="${options} -v ${cmdPath}:${cmdPath}"
    done
    for f in $(ls /usr/lib64/libofproto* /usr/lib64/libovn*   /usr/lib64/libovsdb* \
              /usr/lib64/libsflow* /usr/lib64/libvtep* /usr/lib64/libopenvswitch* \
              /usr/lib64/libssl* /usr/lib64/libcrypto* /usr/lib64/librte*)
    do
        options="${options} -v ${f}:${f}"
    done
    echo ${options}
}

dockerCleanup(){
    local component=$1
    local version=$2
    local target="$(getBuildTarget ${component} ${version})"

    logInfo "stop ${component}-${version}";
    docker stop ${component}-${version}

    logInfo "rm ${component}-${version}"
    docker rm ${component}-${version}

    logInfo "rm image ${target}"
    docker image rm ${target}
}