# Hello Plex

Configure nginx as a Reverse Proxy and SSL Secure your application with Certbot <br>
Cron Certbot certificates renewal and email your job results. <br>
The example use a dockerized Plex server as the reverse application.

## Prerequisites

* Docker and docker-compose has to be installed in your development environment.  (v1.0.0)

* You must own your own public domain and host where you going to build the application.<br>
Whatever DNS you use you need to point your domain name to the public server ip.  (v2.0.0)

* Your server needs ssh access to github. (v2.0.0) [^Nt1]

* Enable http and https traffic to the server.  (v2.0.0) [^Nt2]

* We going to use Gmail SMTP service to forward owr outgoing emails. For Gmail SMTP service to accept your credentials, you need to set up and use a Google app password. To use app passwords you need to set up 2-step-verification in your Google account. (v2.1.0)

## Usage

1) Use your own domain

We recomend you clone the repo in your own account and edit the files ```nginx/default.conf, nginx/nginx.conf, docker-compose-init.yml and docker-compose.yml``` to replace all etniapagana.com ocurrences with your domain name.

2) Login to your server and clone the repository 

In any folder run:

```bash
git clone https://github.com/MateoLa/hello-plex.git
```

3) HTTP access and Acme Chalenge

Configure nginx http access to your server and answer certbot's acme chalenge.<br>
The certbot container command will install initial SSL certificates into the nginx image to authenticate the domain. 

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

With initial certificates in place (in the nginx image) renew certificates and configure nginx SSH.[^Nt3]

Run:

```bash
docker compose up --build -d 
```

Reload the webserver to get the new certificates take effect.

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
sudo chmod +x server/certs-renew.sh
sudo cp server/cron-job /etc/cron.d
sudo service cron restart
sudo service cron reload
```

Email job results.<br>
A solution like ssmtp, sendmail, postfix or other has to be configured in your server.<br>
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
AuthPass= "google app password"
FromLineOverride=YES
```

## Versioning

v2.1.0 - Cron Certbot certificates renewal and email cron jobs results.

v2.0.0 - Secure a real domain with Certbot.

v1.1.0 - Use a different plex image: plexinc/pms-docker.

v1.0.0 - HTTPS for local development at ```https://localhost```.

## Useful Commands

* Generate your own fullchain.pem and privkey.pem (v1.0.0)
```sh
openssl req -x509 -newkey rsa:2048 -keyout privkey.pem -out fullchain.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=stateName/L=cityName/O=companyName/OU=companySectionName/CN=Hostname"
```

* Use openssl to create a dhparam.pem file:
```sh
sudo openssl dhparam -out /<absolute-path-to-your-app>/dhparam/dhparam-2048.pem 2048
```

* Server time/time-zone commands
```sh
timedatectl list-timezones
timedatectl set-timezone America/Montevideo
timedatectl
date
```

* Reboot your server
```sh
sudo shutdown -r now
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

[^Nt1]: In your server create an ssh key set for remote access:<br>
`ssh-keygen -f <path_to_home_directory>/.ssh/id_rsa -q -N ""`
(If you use the init-script /server/do-erver-setup.sh to build you server the key pair is already generated)<br>
Copy the public key (id_rsa.pub content) to your github account under `SSH and GPG keys` settings.

[^Nt2]: On Debian or Ubuntu `ufw allow http` and `ufw allow https`

[^Nt3]: When nginx has been configured as a reverse proxy, the reverse application has to be up and running to get up the nginx. Otherwise nginx fails and its container will fall.

[^Nt4]: You can directly access the Plex server at `http://your-domain:32400 or https://your-domain:32400` (with nginx service available or not). Although, for the sake of the example we configure nginx and `http://your-domain or https://your-domain` availability (without port specification) proves the correct web server configuration.

[^Nt5]: Putting your gmail app password in ssmtp.conf is not ideal. We recommend to use a separate Gmail account, not your main account, for this. If your Gmail account is secured with two-factor authentication, you need to generate a unique App Password to use in `ssmtp.conf`