# Hello Plex

Nginx Reverse Proxy and Securing your application.

We use a dockerized Plex server (video server) as the reverse application to build the example.

## Versions

v1.0.0 - HTTPS for local development: https://localhost. The example use a dockerized plex server as a reverse application.

v1.1.0 

## Prerequisites

v1.0.0 - Docker and docker-compose has to be installed in your development environment.

## Usage

1) cd into any folder and clone this repo:

```bash
git clone https://github.com/MateoLa/hello-plex.git
```

2) cd into hello-plex and run:

```bash
docker-compose up --build
```

3) Connect to your Plex server. 

The first connection must be done to http://localhost/manage or https://localhost/manage.

Then you can access the server at http://localhost or https://localhost [^Nt1].

Enjoy your Plex server!

## Useful Commands

* Generate your own fullchain.pem and privkey.pem.
```sh
ssh -T git@github.com
```

## Notes

[^Nt1]: You can directly access the Plex server at http://localhost:32400 or https://localhost:32400 (without nginx, available or not). Although, for the sake of the example we configure nginx and the http://localhost or https://localhost availability (without port specification) proves the correct configuration.
