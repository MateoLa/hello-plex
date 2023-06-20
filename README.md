# Hello Plex

Configure nginx as a Reverse Proxy and SSL Secure your application with Certbot <br>
Cron certificates renewal and email job results. <br>
The example use a dockerized Plex server as the reverse application.

## Prerequisites

* Docker and docker-compose has to be installed in your development environment.  (v1.0.0)

* You must own your own domain and a public host where you can build the application. Whatever DNS you use, point your domain to the server public ip address.  (v2.0.0)

* Your server (public host) has to have ssh access to github. (v2.0.0) [^Nt1]

* Enable http and https traffic to the server.  (v2.0.0) [^Nt2]

* For Gmail SMTP service to accept your credentials, you will need to set up and use an app password. To use app passwords in your Google account, you will also need to set up 2-step-verification. (v2.1.0)

## Usage

1) Use your own domain

We recomend you clone the repo in your own account and edit the files ```nginx/default.conf, nginx/nginx.conf, docker-compose-init.yml and docker-compose.yml``` to replace all etniapagana.com ocurrences with your domain name.

2) Login to your server and clone the repository 

In any folder run:

```bash
git clone https://github.com/MateoLa/hello-plex.git
```

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

With initial certificates in place (in the nginx image) configure nginx SSH and generate new certificates.[^Nt3]

Run:

```bash
docker compose up --build -d 
```

You need to reload the webserver to load the new certificates

```bash
docker compose exec -it webserver nginx -s reload
```

6) Test HTTPS. Secure Connect to your Plex server. 

Go to ```https://your-domain``` [^Nt4]

(The first connection could be done to ```https://your-domain/manage```)

Enjoy your Plex server!

7) Certificates Renewal

Certbot certificates are valid for 90 days so we are going to cron certificates renewal.

```sh
sudo cp nginx/cron-job /etc/cron.d
sudo service cron restart
sudo service cron reload
```

Email cron-job results. A solution like ssmtp, sendmail, postfix or other has to be configured in your server.<br>
Ssmtp is the easiest.

Install ssmtp

```sh
sudo apt-get install ssmtp mailutils
```

Config ssmtp [^Nt5]

```sh
sudo nano /etc/ssmtp/ssmtp.conf

root=test@gmail.com
mailhub=smtp.gmail.com:587
hostname=smtp.gmail.com:587
UseSTARTTLS=YES
AuthUser=test@gmail.com
AuthPass=password
FromLineOverride=YES
```

## Versioning

v2.1.0 - Cron Certbot certificates renewal and email cron jobs results.

v2.0.0 - Secure a real domain with Certbot.

v1.1.0 - Use a different plex image: plexinc/pms-docker.

v1.0.0 - HTTPS for local development at ```https://localhost```.

## Useful Commands

* Generate your own fullchain.pem and privkey.pem.
```sh
openssl req -x509 -newkey rsa:2048 -keyout privkey.pem -out fullchain.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=stateName/L=cityName/O=companyName/OU=companySectionName/CN=Hostname"
```

* Use openssl to create a dhparam.pem file:
```sh
sudo openssl dhparam -out /<absolute-path-to-your-app>/dhparam/dhparam-2048.pem 2048
```

* Remove Containers, Images and Volumes
```sh
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
docker volume rm $(docker volume ls -q)
docker system prune --volumes
```

* Shell access to CertBot container
```sh
docker compose run --rm --entrypoint="/bin/sh" -it certbot
```

* Checking Certbot SSL certificates expiration date
```sh
docker compose run --rm --entrypoint="certbot certificates" -it certbot
```

* Check cron logs
```sh
/var/log/cron.log
```

## Notes

[^Nt1]: In your server create the ssh key set ```ssh-keygen -f <path_to_home_directory>/.ssh/id_rsa -q -N ""```. Copy the public key (id_rsa.pub content) to github account settings in ```SSH and GPG keys```

[^Nt2]: On Debian or Ubuntu ```ufw allow http``` and ```ufw allow https```

[^Nt3]: With nginx configured as a reverse proxy, the reverse application has to be up and running to get up the nginx. Otherwise nginx fail and the container will fall.

[^Nt4]: You can directly access the Plex server at ```http://your-domain:32400 or https://your-domain:32400``` (with nginx service available or not). Although, for the sake of the example we configure nginx and ```http://your-domain or https://your-domain``` availability (without port specification) proves the correct web server configuration.

[^Nt5] Putting your gmail app password in ssmtp.conf is not ideal. We recommend to use a separate Gmail account, not your main account, for this. If your Gmail account is secured with two-factor authentication, you need to generate a unique App Password to use in ssmtp.conf