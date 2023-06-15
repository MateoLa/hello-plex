# Hello Plex

Nginx Reverse Proxy and SSL Securing your application with Certbot

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

* Enable http and https traffic to the server  [^Nt12]

## Usage v2.0.0

1) Login to your server and clone the repository 

In any folder run:

```bash
git clone https://github.com/MateoLa/hello-plex.git
```

2) Use your own domain

Edit the files ```nginx/default.conf, nginx/nginx.conf, docker-compose-init.yml and docker-compose.yml``` replacing ```<your-domain>``` and ```<www.your-domain>``` with your domain name.

3) HTTP access and Acme Chalenge

Configure nginx http access to your server and answer certbot's acme chalenge. This will install initial SSL certificates into the webserver image to authenticate the domain. 

Run:

```bash
docker compose -f docker-compose-init.yml up --build
```

Test http access.

4) Get down the containers

```bash
Cntl^C
docker compose -f docker-compose-init.yml down
```

5) Enable HTTPS 

With initial certificates in place (in the nginx image) configure nginx SSH and generate new certificates.[^Nt2]

Run:

```bash
docker compose up --build -d 
```

You need to reload the webserver to load the new certificates

```bash
docker compose exec -it webserver nginx -s reload
```

6) Test HTTPS. Secure Connect to your Plex server. 

Go to ```https://your-domain``` [^Nt3]

(The first connection could be done to https://your-domain/manage```)

Enjoy your Plex server!

7) Certificates Renewal

Certbot certificates are valid for 6 month so we going to cron certificates renewal.


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

[^Nt1]: In your server create the ssh key set ```ssh-keygen -f <path_to_home_directory>/.ssh/id_rsa -q -N ""```. Copy the public key (id_rsa.pub content) to github account settings in ```SSH and GPG keys```

[^Nt12]: On Debian or Ubuntu:
```sh
ufw allow http
ufw allow https
```

[^Nt2]: With nginx configured as a reverse proxy, the reverse application has to be up and running to get up the nginx. Otherwise nginx fail and the container will fall.

[^Nt3]: You can directly access the Plex server at ```http://your-domain:32400 or https://your-domain:32400``` (with nginx service available or not). Although, for the sake of the example we configure nginx and ```http://your-domain or https://your-domain``` availability (without port specification) proves the correct web server configuration.
