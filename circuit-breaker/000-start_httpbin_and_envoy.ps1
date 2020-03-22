<#
.SYNOPSIS
#>

$NETWORK = "circuit-breaker-network"
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# create network
docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 $NETWORK

# start httpbin
docker run -itd --net=$NETWORK --ip 172.20.128.1 --name httpbin docker.io/kennethreitz/httpbin sh -c "gunicorn --access-logfile - -b 0.0.0.0:8080 httpbin:app"

# start envoy
docker run -itd --net=$NETWORK --ip 172.20.128.2 --env-file $scriptDir/http-client.env --name client -v $scriptDir/conf:/etc/envoy ceposta/http-envoy-client:latest 


### seperate run java command for testing
# docker exec -it client bash -c 'java -jar http-client.jar' 