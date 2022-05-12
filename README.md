# Run a simple* Minecraft server on Azure!

\* Might require containerisation, Flatcar/CoreOS knowledge, Terraform, Azure and general Linux/SSH proficiency.

When done, you'll have a Minecraft server that can be stopped and spun up again automatically to save money on the VM size, which you can also choose. You can also use `terraform destroy` to quickly get rid of it, if you only need a server for testing purposes.

## Requirements

- Azure account
- Azure CLI
- Terraform

## How to

*More on: [Running Flatcar Container Linux on Microsoft Azure
](https://www.flatcar.org/docs/latest/installing/cloud/azure/)*

### 1. Install `az`, set up an Azure account

```bash
az login
az account set --subscription <azure_subscription_id>
az ad sp create-for-rbac --name <service_principal_name> --role Contributor
az vm image terms accept --urn kinvolk:flatcar-container-linux:stable:<flatcar_stable_version>
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```

You can get `<flatcar_stable_version>` using:

```bash
curl -sSfL https://stable.release.flatcar-linux.net/amd64-usr/current/version.txt | grep -m 1 FLATCAR_VERSION_ID= | cut -d = -f 2
```

### 2. Set up your Terraform variables

```bash
vim terraform.tfvars
```

```js
cluster_name            = "minecraft"
machines                = ["bronze"]
ssh_keys                = ["ssh-rsa ..."]
flatcar_stable_version  = "<flatcar_stable_version>"
resource_group_location = "westeurope"
server_type             = "Standard_B2s"
os_disk_size_gb         = 64
create_ssh_hosts        = true
```

### 3. Change your deployed Minecraft server setup in [cl/machine-bronze.yaml.tmpl](cl/machine-bronze.yaml.tmpl)

*See more: [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server/blob/master/README.md)*

For example, run a 1.8.9 server instead of 1.14.4 and use 6 instead of 3 gigabytes of RAM:

```diff
-        ExecStart=/usr/bin/docker run -i -p 25565:25565 --pull always -e EULA=TRUE -e VERSION=1.14.4 -e MEMORY=3G -v /home/core/minecraft-data:/data --name mc itzg/minecraft-server
+        ExecStart=/usr/bin/docker run -i -p 25565:25565 --pull always -e EULA=TRUE -e VERSION=1.8.9 -e MEMORY=6G -v /home/core/minecraft-data:/data --name mc itzg/minecraft-server
```

### 4. Deploy to Azure

```bash
terraform init
terraform plan
terraform apply
```

You'll be given dynamic IP address(es) (changed every reboot) and FQDN(s) (doesn't change) to join the server(s). You can create CNAME record(s) to the FQDN(s) for custom domains.

## Work with worlds

You're provided with two scripts: `download_worlds.sh` and `upload_worlds.sh` in `backup/`.

The scripts expect the worlds (server configs) to be in `backup/worlds/${hostname}`. By default `${hostname}` is generated as `${cluster-name}-${machines.key}`.

As an example, in the provided README the hostname for the created machine will be `minecraft-bronze`. Thus you can put your world files (including `server.properties` and `world/`) to `backup/worlds/minecraft-bronze`, run

```bash
./upload_worlds.sh
```

and now your server will run from your uploaded world.