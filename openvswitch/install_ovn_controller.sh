. ovs_functions.sh
#                    +------------ ovn-remote host ip
#                    |      +----- ovn-encap-ip
#                    |      |
installOvnController $1 $(hostname -i)
