# Deploy via Docker-compose

## Prepare env

You need copy `.env-example` to `.env` and configurate if you needed

### Hostpath mount for anfisa

Path on host wich using for store data

```env
ASETUP_WORKDIR="./a-setup"
DRUID_WORKDIR="./druid"
```
> Before using hostpath you need create that paths 
> ```sh
> ASETUP_WORKDIR=./a-setip
> mkdir -p $ASETUP_WORKDIR
> DRUID_WORKDIR="./druid"
> mkdir -p $DRUID_WORKDIR
> ```


### Versions changes

If you want update backend/frontend and etc you can set versions in `.env` file.
Recomendate versions set in `.env-example`

```env
ANFISA_BACKEND_VERSION=v.0.7.8
ANFISA_FRONTEND_VERSION=v0.8.43

DRUID_VERSION=0.19.0
MONGO_VERSION=6.0.1
ZOOKEEPER_VERSION=3.5
```

### Revers proxy

Frontend using static with preconfigured `REACT_APP_URL_BACKEND` so if you want using anfisa behind your revers proxy you need change this env.

For ex (nginx):

```sh
REACT_APP_URL_BACKEND="http://dnsname.for.reversproxy.com/app"
```

```nginx
server {
    listen 80;
    server_name dnsname.for.reversproxy.com;
    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:3000;
    }
}
```

Then anfisa-frontend start opening on `http://dnsname.for.reversproxy.com` and anfisa-backend `http://dnsname.for.reversproxy.com/app`

>if you using `https` you must using `https` in `REACT_APP_URL_BACKEND` ex `REACT_APP_URL_BACKEND="https://dnsname.for.reversproxy.com/app"`

## Start anfisa

```sh
docker-compose pull
docker-compose up -d
```

## Insert demodata

```sh
./demodata.sh
```
