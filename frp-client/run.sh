#!/usr/bin/env bashio
WAIT_PIDS=()
CONFIG_PATH='/share/frpc.toml'
DEFAULT_CONFIG_PATH='/frpc.toml'

function stop_frpc() {
    bashio::log.info "Shutdown frpc client"
    kill -15 "${WAIT_PIDS[@]}"
}

bashio::log.info "Copying configuration."
cp $DEFAULT_CONFIG_PATH $CONFIG_PATH
sed -i "s/serverAddr = \"your_server_addr\"/serverAddr = \"$(bashio::config 'serverAddr')\"/" $CONFIG_PATH
sed -i "s/serverPort = 7000/serverPort = $(bashio::config 'serverPort')/" $CONFIG_PATH
sed -i "s/auth.token = \"your_secret_token\"/auth.token = \"$(bashio::config 'authToken')\"/" $CONFIG_PATH
sed -i "s/webServer.port = 7500/webServer.port = $(bashio::config 'webServerPort')/" $CONFIG_PATH
sed -i "s/webServer.user = \"admin\"/webServer.user = \"$(bashio::config 'webServerUser')\"/" $CONFIG_PATH
sed -i "s/webServer.password = \"your_another_secret_token\"/webServer.password = \"$(bashio::config 'webServerPassword')\"/" $CONFIG_PATH
sed -i "s/remotePort = 8123/remotePort = $(bashio::config 'remotePort')/" $CONFIG_PATH


bashio::log.info "Starting frp client"

cat $CONFIG_PATH

cd /usr/src
./frpc -c $CONFIG_PATH & WAIT_PIDS+=($!)

tail -f /share/frpc.log &

trap "stop_frpc" SIGTERM SIGHUP
wait "${WAIT_PIDS[@]}"
