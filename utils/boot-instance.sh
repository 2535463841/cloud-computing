# Default params

IMAGE=
NET=

FLAVOR=m1.nano
SIZE=10
NAME_PREFIX=zbw

main(){
    local az=''
    local securityGroup=''
    local bootVolume=''
    local noNic=false
    local bdm=false
    local flavor=${FLAVOR}
    local net=${NET}
    local size=${SIZE}
    local image=${IMAGE}

    while [[ true ]]
    do
        case "$1" in
        --az)       shift; az=$1 ; shift ;;
        --sg)       shift; securityGroup=$1 ; shift ;;
        --net)      shift; net=$1; shift ;;
        --port)     shift; port=$1; shift ;;
        --size)     shift; size=$1; shift ;;
        --image)    shift; image=$1 ; shift ;;
        --flavor)   shift; flavor=$1; shift ;;
        --bdm)  bdm=true; shift ;;
        --boot-volume) shift; bootVolume=$1; shift;;
        --no-nic)       noNic=true; shift ;;
        *) if [[ -z ${1} ]]; then break; else echo "ERROR: invalid arg $1"; exit 1; fi ;;
        esac
    done

    local opts="--flavor ${flavor} "
    if [[ ! -z ${az} ]]; then opts="${opts} --availability-zone ${az}"; fi
    if [[ ! -z ${securityGroup} ]]; then opts="${opts} --security-groups ${securityGroup}"; fi

    if [[ ${noNic} == true ]]; then
        opts="${opts} --nic none"
    else
        if [[ ! -z ${port} ]]; then
            opts="${opts} --nic port-id=${port}"
        elif [[ ! -z ${net} ]]; then
            opts="${opts} --nic net-id=${net}"
        fi
    fi

    if [[ ! -z ${bootVolume} ]]; then
        local vmName="${NAME_PREFIX}-vol-$(date +'%m%d-%T')"
        opts="${opts} --boot-volume ${bootVolume}"
    elif [[ ${bdm} == true ]]; then
        local vmName="${NAME_PREFIX}-vol-$(date +'%m%d-%T')"
        opts="${opts} --block-device source=image,dest=volume,id=${image},size=${size},bootindex=0,shutdown=remove"
    else
        local vmName="${NAME_PREFIX}-img-$(date +'%m%d-%T')"
        opts="${opts} --image ${image}"
    fi

    local bootCmd="nova boot ${opts} ${vmName}"
    echo ${bootCmd}
    ${bootCmd}

}

main $@
