# Hello Plex

Nginx Reverse Proxy and Securing your application.

(The example is built using a dockerized Plex server as the reverse application)

## Versions

v2.0.0 - Secure a real domain with Certbot as CA.

v1.1.0 - Use a different plex image: plexinc/pms-docker.

v1.0.0 - HTTPS for local development at ```https://localhost```. The example use a dockerized plex server as a reverse application.

## Prerequisites

#### v1.0.0

* Docker and docker-compose has to be installed in your development environment.

#### v2.0.0

* You must own your own domain and a public host where you can build the application. Whatever DNS you use, point your domain to the server public ip address.

* Your server (public host) has to have ssh access to github. [^Nt1]

* Enable http and https traffic to the server

```
ufw allow http
ufw allow https
```

## Usage v2.0.0

1) Clone repository 

Into any folder run

```bash
git clone https://github.com/MateoLa/hello-plex.git
```

2) Use the right domain

Into hello-plex directory edit the files ```nginx/default.conf, nginx/nginx.conf, docker-compose-init.yml and docker-compose.yml``` replacing ```<your-domain>``` and ```<www.your-domain>``` with your domain name.

3) HTTP access and Acme Chalenge

Configure nginx http access and ask certbot to answer the acme chalenge (this will install initial certificates in nginx image) to authenticate the domain. 

Run
```bash
docker compose -f docker-compose-init.yml up --build
```
Test http access

4) Get down the containers. 

```bash
Cntl^ C
docker compose -f docker-compose-init.yml down
```

5) Enable HTTPS 

With initial certificates in place (within the nginx image) configure ssh and regenerate new certificates.[^Nt2]

Run

```bash
docker compose up --build -d 
```

You need to reload the webserver to load the new certificates

```bash
docker compose exec -it webserver nginx -s reload
```

6) Secure Connect to your Plex server. 

Then you can access the server at ```http://your-domain or https://your-domain``` [^Nt3]

(The first connection could be done to ```http://your-domain/manage or https://your-domain/manage```)

Enjoy your Plex server!

## Useful Commands

* Generate your own fullchain.pem and privkey.pem.
```sh
openssl req -x509 -newkey rsa:2048 -keyout privkey.pem -out fullchain.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=stateName/L=cityName/O=companyName/OU=companySectionName/CN=Hostname"
```

* Use openssl to create a dhparam.pem file:
```sh
sudo openssl dhparam -out /<absolute-path-to-your-app>/dhparam/dhparam-2048.pem 2048
```

## Notes

[^Nt1]: Create the server ssh key set ```ssh-keygen -f <path_to_home_directory>/.ssh/id_rsa -q -N ""```. Add the public key (content of file id_rsa.pub) to github ```SSH and GPG keys``` account settings.

[^Nt2]: With nginx configured as a reverse proxy, the reverse application has to be up and running in orther to get up the nginx. Otherwise the nginx container will fall.

[^Nt3]: You can directly access the Plex server at ```http://localhost:32400 or https://localhost:32400``` (with nginx service available or not). Although, for the sake of the example we configure nginx and the ```http://localhost or https://localhost``` availability (without port specification) proves the correct configuration.
