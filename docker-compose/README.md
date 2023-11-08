# Deploy via Docker-compose
- [Deploy via Docker-compose](#deploy-via-docker-compose)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Prepare environment](#prepare-environment)
  - [Start AnFiSA installation](#start-anfisa-installation)
  - [Install demo data](#install-demo-data)
    - [Small dataset (~5 mins to install)](#small-dataset-5-mins-to-install)
    - [Big dataset (~4-5 hrs to install)](#big-dataset-4-5-hrs-to-install)
      - [Background instal](#background-instal)
  - [Uninstalling AnFiSA](#uninstalling-anfisa)
  - [Custom configuration](#custom-configuration)
    - [Volumes mount for AnFiSA](#volumes-mount-for-anfisa)
    - [Update to specific version](#update-to-specific-version)
    - [Reverse proxy](#reverse-proxy)
      - [Classic (dedicated domain)](#classic-dedicated-domain)
    - [Custom images and parameters configuration](#custom-images-and-parameters-configuration)
  - [Docker tips](#docker-tips)
  - [Known issues](#known-issues)
    - [Demodata install](#demodata-install)
      - [Connection refused](#connection-refused)
    - [Druid cant using `druid-data`](#druid-cant-using-druid-data)
    - [Revers proxy](#revers-proxy)
      - [Behind subpath](#behind-subpath)
## Introduction
Installation via Docker is the easiest way to install AnFiSA. 
We strongly recommend to use this way unless you have some very specific requirements.

## Prerequisites
Ensure that the following packages are installed on your system:

  * curl
  * zip
  * unzip
  * Docker v20 or higher
  * Docker Compose v2.2.0 or higher

Click on the below appropriate tab to install the required packages on Ubuntu or MacOS.

**<details><summary>Install prerequisites on Ubuntu</summary>**
<p>

Run the following command to install zip, unzip and curl packages:
```commandline
sudo apt update 
sudo apt install zip unzip curl
```

Follow the link to install the latest version of Docker and Docker Compose 
on [Ubuntu](https://docs.docker.com/engine/install/ubuntu/). 

If you run script as non-root user, ensure that Docker has required rights 
according to the [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/).

</p>
</details>

**<details><summary>Install prerequisites on Mac OS</summary>**
<p>

Install [Homebrew Package Manager](https://brew.sh/), command can be used:
```commandline
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run the following command to install required packages:
```commandline
xcode-select --install
brew update
brew install curl
brew install zip
brew install unzip
```

Follow the link to install the latest version of Docker and Docker Compose on [Mac OS](https://docs.docker.com/desktop/mac/install/).

</p>
</details>

Ensure that Docker version is 19.03.0 or higher and Docker Compose version is 2.0.0 or higher.
```commandline
docker -v
docker compose version
```
## Prepare environment

Firstly you need to clone this repository and change directory to `docker-compose`

```sh
git clone https://github.com/ForomePlatform/deploy.git
cd deploy/docker-compose
```

After that copy `example.env` to `.env` and configure if you needed
```commandline
cp example.env .env
```

At this step you can configure your AnFiSa installation.
If you want to try default Anfisa installation, you can just skip any configuration
and proceed.

You need to make a custom configuration if you want to do the following:
 
* Use local folder for AnFiSA data
* Set up memory limits
* Set up WEB proxy or change WEB server parameters
* Modify AnFiSA components (for advance users, please use with caution).

**Attention: Default Docker installation also installs Druid. Druid is required for
handling whole exome/genome datasets, but it takes a lot of memory. 
Minimum required memory is 8Gb and swap should be enabled.** 

* If you have 4-8 Gb of memory, first adjust Druid parameters in environment.template file
* If you have less than 4Gb, you can install demo version without Druid. 
To do this edit `docker-compose.yml` template to exclude Druid.

## Start AnFiSA installation

Just run the following commands to compose and run AnFiSA^
```sh
docker-compose pull
docker-compose up -d
```

After successful running all containers AnFiSA will be available in your browser by address:
http://localhost:3000/

## Install demo data

To evaluate AnFiSA capabilities one can use two pre-defined data sets:
small and large

### Small dataset (~5 mins to install)
To install small demo data set, one just need to run corresponding script:
```sh
./demodata.sh
```
Wait about 5 minutes until script finishes and then reload AnFiSA UI.

### Big dataset (~4-5 hrs to install)

The big data set is useful to check AnFiSA performance on a real data,
or try to make a custom filter on a real data set. 

> You will need approximately 25G of space available to 
> experiment with a whole genome 

* First, download 
  [prepared dataset](https://forome-dataset-public.s3.us-south.cloud-object-storage.appdomain.cloud/pgp3140_wgs_nist-v4.2.tar.gz)
* Unpack the content into some directory (e.g. directory `data` 
  under your work directory)
* Run Anfisa ingestion process
                                     
Here are example commands that can do this:

```sh
    curl -fsSLO https://forome-data.s3.us.cloud-object-storage.appdomain.cloud/pgp3140/pgp3140_wgs_nist-v4.2.tar.gz

    docker cp pgp3140_wgs_nist-v4.2.tar.gz anfisa-backend:/anfisa/a-setup/data/examples/
    docker exec -it anfisa-backend sh -c 'cd /anfisa/a-setup/data/examples && tar -zxvf pgp3140_wgs_nist-v4.2.tar.gz'
    docker exec -it anfisa-backend sh -c 'PYTHONPATH=/anfisa/anfisa/ python3 -u -m app.storage -c /anfisa/anfisa.json -m create --reportlines 1000 -f -k xl -i /anfisa/a-setup/data/examples/pgp3140_wgs_nist-v4.2/pgp3140_wgs_nist-v4.2.cfg XL_PGP3140_NIST_V42'
```

#### Background instal

If you want to start installation in backgroung (useful for remote server) 
you can use `nohoup` and start installation script in background:

```sh
    nohup docker exec -i anfisa-backend sh -c 'PYTHONPATH=/anfisa/anfisa/ python3 -u -m app.storage -c /anfisa/anfisa.json -m create --reportlines 1000 -f -k xl -i /anfisa/a-setup/data/examples/pgp3140_wgs_nist-v4.2/pgp3140_wgs_nist-v4.2.cfg XL_PGP3140_NIST_V42' > insert.logs &
```

To ckech the progress you can check log file

```sh
tail insert.logs
```

## Uninstalling AnFiSA
To completely remove AnFiSA one need to stop and remove all AnFiSA containers:

```sh
docker stop anfisa-broker anfisa-router anfisa-historical anfisa-middlemanager anfisa-frontend anfisa-backend anfisa-mongo anfisa-zookeeper
docker rm   anfisa-broker anfisa-router anfisa-historical anfisa-middlemanager anfisa-frontend anfisa-backend anfisa-mongo anfisa-zookeeper
docker volume rm  anfisa-asetup anfisa-data druid-broker druid-middlemanager druid-coordinator druid-router druid-historical druid-data
```

## Custom configuration 

In this section one can find several most frequent example of installation configuration.

Most part of the AnFiSA configuration is performed in four files

* `.env` - Anfisa configs  
* `druid.env` - Druid configs  
* `mongo.env` - Mongo configs  
* `docker-compose.yml` - AnFisa components

### Volumes mount for AnFiSA

If you need configuration volumes for docker-compose using this 
[guide](https://docs.docker.com/compose/compose-file/compose-file-v3/#volume-configuration-reference)

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

### Update to specific version

If you want to update backend/frontend and other components to specific versions 
you can set versions in `.env` file.
Recommended versions are already set in `.env-example` file.

```env
ANFISA_BACKEND_VERSION=v.0.7.8
ANFISA_FRONTEND_VERSION=v0.10.0

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
       proxy_pass http://localhost:9994; 
    }
}
```

### Custom images and parameters configuration

If you want to create custom configuration for `anfisa.json` or `igv.dir` you can uncomment lines in `docker-compose.yml` 

```yaml
  anfisa-backend:
    user: root
    container_name: anfisa-backend
    <<: *common_parameters
    image: forome.azurecr.io/anfisa:${ANFISA_BACKEND_VERSION}
    volumes:
      - anfisa-asetup:/anfisa/a-setup
      # - ./anfisa.json:/anfisa/anfisa.json
      # - ./igv.dir:/anfisa/igv.dir
```

> More specific information about configuration file [here](https://foromeplatform.github.io/documentation/anfisa-dev.v0.7/adm/configuration.html)

## Docker tips

* For MacOS docker start vm and change every config must reload this vm.
* For CentOS often users using selinux in enforcing mod and docker-daemon with rootless configs - 
which do not allow start containers from root user.


## Known issues

### Demodata install
#### Connection refused
*Summary*: Druid uses arround `8-10Gib` for start and sometimes you can getting `OOM` killed for `druid` componnets.  
*How to Reproduce*: Just have not enought `RAM` for `druid`  
*How to fix*: Give more `ram`))  

### Druid cant using `druid-data`
*Summary*: `Docker compose` create volume with `root:root` uid:gid and druid cant create files on them.
*How to Reproduce*: Just remove `user: root` from `docker-compose.yml`
*How to fix*: `user: root`

### Revers proxy
#### Behind subpath
Unfortunalty right now our app cant work on `subpath` behind revers proxy but that WIP
