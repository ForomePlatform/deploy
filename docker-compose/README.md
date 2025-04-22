# Deploy via Docker-compose

<!-- toc -->

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Quickstart](#quickstart)
- [Prepare environment](#prepare-environment)
- [Start AnFiSA installation](#start-anfisa-installation)
- [Install demo data](#install-demo-data)
  * [Small dataset (~5 mins to install)](#small-dataset-5-mins-to-install)
  * [Big dataset (~4-5 hrs to install)](#big-dataset-4-5-hrs-to-install)
    + [Background install](#background-install)
- [Uninstalling AnFiSA](#uninstalling-anfisa)
- [Custom configuration](#custom-configuration)
  * [Volumes mount for AnFiSA](#volumes-mount-for-anfisa)
  * [Update to specific version](#update-to-specific-version)
  * [Reverse proxy](#reverse-proxy)
    + [Classic (dedicated domain)](#classic-dedicated-domain)
  * [Custom images and parameters configuration](#custom-images-and-parameters-configuration)
- [Docker tips](#docker-tips)
- [Known issues](#known-issues)
  * [Ingestion of demo whole genome](#ingestion-of-demo-whole-genome)
    + [Connection refused](#connection-refused)
  * [Druid cannot use `druid-data`](#druid-cannot-use-druid-data)
  * [Reverse proxy](#reverse-proxy-1)
    + [Behind subpath](#behind-subpath)

<!-- tocstop -->

## Introduction

This document describes installation of
[AnFiSA](https://github.com/ForomePlatform/anfisa). 

Installation via Docker is the easiest way to install AnFiSA. 
We strongly recommend using this method unless you have some 
very specific requirements.

## Prerequisites
Ensure that the following packages are installed on your system:

  * curl
  * zip
  * unzip
  * Docker v20 or higher
  * Docker Compose v2.2.0 or higher

Click on the below appropriate tab to install the required packages on Ubuntu or MacOS.

<details>
<summary>Install prerequisites on Ubuntu</summary>

Run the following command to install zip, unzip and curl packages:
```shell
sudo apt update 
sudo apt install zip unzip curl
```

Follow the link to install the latest version of Docker and Docker Compose 
on [Ubuntu](https://docs.docker.com/engine/install/ubuntu/). 

If you run script as non-root user, ensure that Docker has required rights 
according to the [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/).

</details>

<details>
<summary>Install prerequisites on Mac OS</summary>


Install [Homebrew Package Manager](https://brew.sh/), command can be used:
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run the following command to install required packages:
```shell
xcode-select --install
brew update
brew install curl
brew install zip
brew install unzip
```

Follow the link to install the latest version of Docker and Docker Compose on [Mac OS](https://docs.docker.com/desktop/mac/install/).

</details>

Ensure that Docker version is 20.10.12 or higher and Docker Compose version is 2.2.0 or higher.
```shell
docker -v
docker compose version
```

## Quickstart

Just run the following commands:
                                                                   
```shell
git clone https://github.com/ForomePlatform/deploy.git
cd deploy/docker-compose
cp example.env .env
docker compose pull
docker compose up -d                
./demodata.sh                      
```

## Prepare environment

Firstly you need to clone this repository and change directory to `docker-compose`

```sh
git clone https://github.com/ForomePlatform/deploy.git
cd deploy/docker-compose
```

After that copy `example.env` to `.env` and configure if you needed
```shell
cp example.env .env
```
                            
> You probably do not need to change any environment keys. In some cases
> you might want to change backend and frontend versions:

```
ANFISA_BACKEND_VERSION=0.8.2
ANFISA_FRONTEND_VERSION=0.11.4
``` 

At this step you can configure your AnFiSa installation.
If you want to try the default AnFiSA installation, you can just 
skip any configuration steps and proceed.

You need to make a custom configuration if you want to do any of the following:
 
* Use local folder for AnFiSA data
* Set up memory limits
* Set up WEB proxy or change WEB server parameters
* Modify AnFiSA components (for advanced users, please use with caution).

**Attention: Default Docker installation also installs Druid. Druid is required for
handling whole exome/genome datasets, but it takes a lot of memory. 
Minimum required memory is 8Gb and swap should be enabled.** 

* If you have 4-8 Gb of memory, first adjust Druid parameters in environment.template file
* If you have less than 4Gb, you can install demo version without Druid. 
To do this edit `docker-compose.yml` template to exclude Druid.

## Start AnFiSA installation

Just run the following commands to compose and run AnFiSA

```sh
docker compose pull
docker compose up -d
```

After successful running all containers AnFiSA will be available in your browser by address:
http://localhost:3000/

## Install demo data

To evaluate AnFiSA capabilities one can use two pre-defined data sets:
small and large

### Small dataset (~5 mins to install)
To install small demo data set, one just need to run corresponding script:
```shell
./demodata.sh
```
Wait about 5 minutes until script finishes and then reload AnFiSA UI.

### Big dataset (~4-5 hrs to install)

The big data set is useful to check AnFiSA performance on a real data,
or try to make a custom filter on a real data set. 

> You will need approximately 25G of space available to 
> experiment with a whole genome 

* First, download 
  [prepared dataset](https://zenodo.org/records/13906214/files/pgp3140_wgs_nist-v4.2-annotated.tgz)
* Unpack the content into some directory (e.g. directory `data` 
  under your work directory)
* Run AnFiSA ingestion process
                                     
Here are example commands that can do this:

```sh
    curl -fSLO https://zenodo.org/records/13906214/files/pgp3140_wgs_nist-v4.2-annotated.tgz

    docker cp pgp3140_wgs_nist-v4.2-annotated.tgz anfisa-backend:/anfisa/a-setup/data/examples/
    docker exec -it anfisa-backend sh -c 'cd /anfisa/a-setup/data/examples && tar -zxvf pgp3140_wgs_nist-v4.2-annotated.tgz'
    docker exec -it anfisa-backend sh -c 'PYTHONPATH=/anfisa/anfisa/ python3 -u -m app.storage -c /anfisa/anfisa.json -m create --reportlines 1000 -f -k xl -i /anfisa/a-setup/data/examples/pgp3140_wgs_nist-v4.2/pgp3140_wgs_nist-v4.2.cfg XL_PGP3140_NIST_V42'
```

#### Background install

If you want to start installation in background (useful for remote server) 
you can use `nohup` and start installation script in background:

```shell
nohup docker exec -i anfisa-backend sh -c 'PYTHONPATH=/anfisa/anfisa/ python3 -u -m app.storage -c /anfisa/anfisa.json -m create --reportlines 1000 -f -k xl -i /anfisa/a-setup/data/examples/pgp3140_wgs_nist-v4.2/pgp3140_wgs_nist-v4.2.cfg XL_PGP3140_NIST_V42' 2>&1 > insert.logs &
```

To check the progress you can check log file

```sh
tail insert.logs
```

## Uninstalling AnFiSA
To completely remove AnFiSA one needs to stop and remove all AnFiSA containers:

```sh
docker stop anfisa-broker anfisa-router anfisa-historical anfisa-middlemanager anfisa-frontend anfisa-backend anfisa-mongo anfisa-zookeeper
docker rm   anfisa-broker anfisa-router anfisa-historical anfisa-middlemanager anfisa-frontend anfisa-backend anfisa-mongo anfisa-zookeeper
docker volume rm  anfisa-asetup anfisa-data druid-broker druid-middlemanager druid-coordinator druid-router druid-historical druid-data
```
                                      
> ⚠️ WARNING: The latest command will permanently delete all 
> volumes associated with AnFiSA and Druid, 
> including dataset cache and MongoDB data. 
> Proceed only if you want a clean uninstall.

## Custom configuration 

In this section one can find several most frequent example of installation configuration.

Most part of the AnFiSA configuration is performed in four files

* `.env` - AnFiSA configs  
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
ANFISA_BACKEND_VERSION=0.8.2
ANFISA_FRONTEND_VERSION=0.11.4

DRUID_VERSION=0.19.0
MONGO_VERSION=6.0.1
ZOOKEEPER_VERSION=3.5
```

### Reverse proxy
                   
> This section describes configuration of web server (nginx)
> on the host, not in any of the containers.

#### Classic (dedicated domain)

For ex. `nginx`:

```nginx
server {
    listen 80;
    server_name dnsname.for.reveresproxy.com;
    client_max_body_size 100M;

    location / {
       ## ANFISA_FRONT_PORT
       proxy_pass http://localhost:3000; 
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

* On macOS, Docker runs in a Linux VM. Most app-level changes don’t 
  require restarting the VM, but platform-level changes (like shared 
  folder settings or resource limits) may.
* On CentOS, SELinux may be in enforcing mode, which together with 
  rootless Docker setups may prevent starting containers as the root user.


## Known issues

### Ingestion of demo whole genome

#### Connection refused
*Summary*: Druid typically requires 8–10 GiB of memory during startup. 
On low-memory systems, it may be killed due to out-of-memory (OOM) conditions.

*How to Reproduce*: How to reproduce: Start AnFiSA with insufficient memory 
(less than 8 GiB).
*How to fix*: Allocate more memory to the Docker VM or host system.  

### Druid cannot use `druid-data`

*Summary*: `Docker compose` create volume with `root:root` uid:gid 
and Druid cannot create files on the volume.
*How to Reproduce*: Just remove `user: root` from `docker-compose.yml`
*How to fix*: `user: root`

### Reverse proxy
#### Behind subpath

Currently, our app cannot work on `subpath` behind reverse proxy.

