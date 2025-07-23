#!/usr/bin/env bash

WORKSPACE_DIR="$(pwd)"

if ! command -v docker >/dev/null 2>&1; then
    echo "##################################################################################"
    echo "# [Error] Docker binary was not found in the system. Please, consider installing #"
    echo "# the docker.io package with the following command or equivalent:                #"
    echo "# 'sudo apt-get update && sudo apt install docker.io'                            #"
    echo "##################################################################################"
    exit 1
fi

systemctl status docker | grep 'Active:' | awk '{print $2}' | grep 'active' > /dev/null

if [ $? -ne 0 ]; then
    echo "############################################################################################"
    echo "# [Error] Docker service failed starting or it was not started. Please, consider verifying #"
    echo "# the service status or restart the service with the following commands or equivalents:    #"
    echo "# 'sudo systemctl status docker' or 'sudo systemctl restart docker'                        #"
    echo "############################################################################################"
    exit 1
fi

groups ${USER} | grep -q "docker"

if [ $? -ne 0 ]; then
    echo "################################################################"
    echo "# [Error] User has not enough rights to docker binary. Please, #"
    echo "# consider running the following command or equivalent:        #"
    echo "# 'sudo usermod -aG docker ${USER}'                            #"
    echo "################################################################"
    exit 1
fi

./var-docker/run.sh -u 20.04 -a 15 -l -w "$WORKSPACE_DIR" -p

if [ $? -ne 0 ]; then
    echo "#################################################"
    echo "# [Error] Unable to start the docker container. #"
    echo "#################################################"
    exit 1
fi
