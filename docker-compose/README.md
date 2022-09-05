# Deploy via Docker-compose

- [Deploy via Docker-compose](#deploy-via-docker-compose)
  - [Prerequisites](#prerequisites)
  - [Prepare env](#prepare-env)
    - [Configs overview](#configs-overview)
    - [Volumes mount for anfisa](#volumes-mount-for-anfisa)
    - [Versions changes](#versions-changes)
    - [Reverse proxy](#reverse-proxy)
      - [Classic (dedicated domain)](#classic-dedicated-domain)
  - [Start anfisa](#start-anfisa)
  - [Insert demodata](#insert-demodata)
    - [Known issues](#known-issues)
      - [Demodata insert](#demodata-insert)
        - [Connection refused](#connection-refused)
      - [Druid cant using `druid-data`](#druid-cant-using-druid-data)

## Prerequisites

**Attention: Docker installation also installs Druid. Druid is required for
handling whole exome/genome datasets, but it takes a lot of memory. 
Minimum required memory is 8G and swap should be enabled.** 

**If you have 4G of memory, first adjust Druid parameters in environment.template file.**

**If you have less than 4G, you can install demo version without Druid. 
Update docker-compose.yml.template**

Ensure that the following packages are installed on your system:

  * curl
  * zip
  * unzip
  * Docker v20 or higher
  * Docker Compose v2.2.0 or higher

Click on the below appropriate tab to install the required packages on Ubuntu or Mac OS.

**<details><summary>Install prerequisites on Ubuntu</summary>**
<p>

Run the following command to install zip, unzip and curl packages:

       sudo apt update 
       sudo apt install zip unzip curl

Follow the link to install the latest version of Docker and Docker Compose 
on [Ubuntu](https://docs.docker.com/engine/install/ubuntu/). 
If you run script as non-root user, ensure that Docker has required rights 
according to the [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/).

Ensure that Docker version is 19.03.0 or higher and Docker Compose version is 2.0.0 or higher.

       docker -v
       docker compose version

</p>
</details>

**<details><summary>Install prerequisites on Mac OS</summary>**
<p>

Install [Homebrew Package Manager](https://brew.sh/), command can be used:
	
       /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Run the following command to install required packages:
	
       xcode-select --install
       brew update
       brew install curl
       brew install zip
       brew install unzip

Follow the link to install the latest version of Docker and Docker Compose on [Mac OS](https://docs.docker.com/desktop/mac/install/).

Ensure that Docker version is 19.03.0 or higher and Docker Compose version is 2.0.0 or higher.

       docker -v
       docker compose version

</p>
</details>

## Prepare env


Firstly you need clone this repository

```sh
git clone https://github.com/ForomePlatform/deploy.git
## And change directory to `docker-compose`
cd deploy/docker-compose
```

After that copy `example.env` to `.env` and configure if you needed
### Configs overview

`.env` - Anfisa configs  
`druid.env` - Druid configs  
`mongo.env` - Mongo configs  

### Volumes mount for anfisa

If you need configuration volumes for docker-compose using this [guid](https://docs.docker.com/compose/compose-file/compose-file-v3/#volume-configuration-reference)

Example with host path in `docker-compose.yml`
```yaml
volumes:
  anfisa-asetup:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/to/my/host
```

### Versions changes

If you want to update backend/frontend and etc you can set versions in `.env` file.
Recomendate versions set in `.env-example`

```env
ANFISA_BACKEND_VERSION=v.0.7.8
ANFISA_FRONTEND_VERSION=v0.8.43

DRUID_VERSION=0.19.0
MONGO_VERSION=6.0.1
ZOOKEEPER_VERSION=3.5
```

### Reverse proxy

#### Classic (dedicated domain)

For ex. `nginx`:

```nginx
server {
    listen 80;
    server_name dnsname.for.reversproxy.com;
    client_max_body_size 100M;

    location / {
       ## ANFISA_FRONT_PORT
       proxy_pass http://localhost:3000; 
    }
}
```
## Start anfisa

```sh
docker-compose pull
docker-compose up -d
```

## Insert demodata

```sh
./demodata.sh
```


### Known issues

#### Demodata insert


##### Connection refused

*Summary*: Druid uses arround `8-10Gib` for start and sometimes you can getting `OOM` killed for `druid` componnets.  
*How to Reproduce*: Just have not enought `RAM` for `druid`  
*How to fix*: Give more `ram`))  

#### Druid cant using `druid-data`
*Summary*: `Docker compose` create volume with `root:root` uid:gid and druid cant create files on them.
*How to Reproduce*: Just remove `user: root` from `docker-compose.yml`
*How to fix*: `user: root`
