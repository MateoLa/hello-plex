# Hello Plex

Nginx Reverse Proxy and Securing your application.

We use a dockerized Plex server (video server) as the reverse application to build the example.

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

* Allow http and https traffic to the server. [^Nt2]

## v2.0.0 Usage

1) cd into any folder and clone this repo:

```bash
git clone https://github.com/MateoLa/hello-plex.git
```

2) Go into hello-plex directory and edit the files ```nginx/default.conf, nginx/nginx.conf, docker-compose-init.yml and docker-compose.yml``` replacing <your-domain.com> and <www.your-domain.com> with the apropriate domain name.

3) Into hello-plex run

```bash
docker compose -f docker-compose-init.yml up --build
```

This initial compose file will configure nginx http access and ask certbot to answer the acme chalenge and get the initial certificates to authenticate the domain. 

4) Once initial certificates are in place (within nginx image) configure ssh access and regenerate the definitive certificates.

Run

```bash
docker compose up --build
```

5) Connect to your Plex server. 

The first connection must be done to ```http://localhost/manage or https://localhost/manage```

Then you can access the server at ```http://localhost or https://localhost``` [^Nt3]

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

[^Nt2]: Enable http and https traffic.
```sh
ufw allow http
ufw allow https
```

[^Nt3]: You can directly access the Plex server at ```http://localhost:32400 or https://localhost:32400``` (with nginx service available or not). Although, for the sake of the example we configure nginx and the ```http://localhost or https://localhost``` availability (without port specification) proves the correct configuration.
