#!/bin/sh

echo 'Starting up tailscale...'

# --tun=userspace-networking --socks5-server=localhost:1055
tailscaled --port 41641  > /dev/null 2>&1 &
sleep 5
if [ ! -S /var/run/tailscale/tailscaled.sock ]; then
    echo "tailscaled.sock does not exist. exit!"
    exit 1
fi

until tailscale up \
    --authkey=${TAILSCALE_AUTH_KEY} \
    --hostname=${TAILSCALE_HOSTNAME}
do
    sleep 0.1
done

/app/derper --hostname ${DERP_DOMAIN} --certmode manual --certdir /cert --stun --verify-clients



