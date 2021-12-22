. ./etc/docker_openrc.sh
. ./utils/functions.sh


main(){
    if [[ $# -ne 3 ]]; then
        echo "Usage: sh $0 <build|run> <COMPONENT_NAME> [VERSION] "
        return 1
    fi

    local action=$1
    local componentName=$2
    local version=$3
    if [[ $# -ge 3 ]]; then version=$3; else version='latest'; fi

    if [[ ! -d ./components/${componentName} ]]; then
        logError "Invalid component: ${componentName} !"
        return 1
    fi

    if [[ ${action} == 'build' ]]; then
        dockerBuild ${componentName} ${version}
    elif [[ ${action} == 'run' ]]; then
        dockerRun ${componentName} ${version}
    elif [[ ${action} == 'cleanup' ]]; then
        dockerCleanup ${componentName} ${version}
    else
        logError "error params ${action}"
        return 1
    fi
}

main $*
