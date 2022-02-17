# Private Tailscale DERP Container

Tailscale runs DERP relay servers to help connect your nodes in cases where a direct connection isn't possible. 
In addition to using the Tailscale DERP servers, you can also run your own, so as to minimize latency.

However, this custom DERP server can then be used by anyone who knows its domain, which presents security concerns. To solve them, DERP can be configured to only accept connections from nodes on your specific tailnet, by reading the node list from a local Tailscale installation.

Therefore, this image combines [mchlwong's](https://github.com/mchlwong/derp) DERP Docker image with the official Tailscale image, so that the container can run both the DERP server and a Tailscale node, thereby allowing DERP to exclusively serve the nodes on your tailnet.

## Usage

### Generating a certificate with Let's Encrypt

First, install certbot by following the instructions on [this page](https://certbot.eff.org/instructions?ws=other&os=ubuntufocal)

Then, generate the certificate using the following command:
```bash
sudo certbot certonly --manual --preferred-challenges dns
```

### Generating a Tailscale auth key

Navigate to the [Auth section](https://login.tailscale.com/admin/settings/keys) of the Tailscale settings page and generate a reusable key.

### Configuring the Volume Maps and Environment Variables

Clone this repository on the machine where you want the DERP server to run
```
git clone https://github.com/RodrigoRosmaninho/tailscale-derp
```

And edit the DERP_DOMAIN, TAILSCALE_AUTH_KEY, and  TAILSCALE_HOSTNAME environment variables on the docker-compose.yml file.

Additionaly, replace 'your.domain.name' in the volumes section with the domain for which you setup the certificate.


### Running the Container

```
docker-compose up -d
```

### Editing the Tailscale ACLs

Finally, you must configure Tailscale to advertise your DERP server to the nodes on your tailnet.

Edit the following json appropriately and then add it to the configuration on [this page](https://login.tailscale.com/admin/acls), as another child of the root object.

```json
"derpMap": {
  //"OmitDefaultRegions": true,
  "Regions": { "900": {
    "RegionID": 900,
    "RegionCode": "myderp",
    "RegionName": "Custom DERP",
    "Nodes": [{
        "Name": "1",
        "RegionID": 900,
        "HostName": "your.domain.name",
        "DERPPort": 443
    }]
  }}
}
```

### Testing

To verify the DERP server is working, run the following command on one of your Linux tailscale nodes

```
tailscale netcheck
```

Your DERP server should be displayed on the resulting list, as well as the latency between it and the Linux node
If no latency information appears, then the connection wasn't successful. Please verify that you setup port forwarding on ports 443 (TCP) and 3478 (TCP & UDP) on your router correctly.
If the DERP server does not appear on the list, run the following command and try again

```
sudo tailscale down && sudo tailscale up
```


## Thanks

- The Tailscale team for these outstanding products
- [mchlwong](https://github.com/mchlwong)