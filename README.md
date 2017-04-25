# Vagrant Ruby

This is a Vagrant VM to run ruby projects. It includes:

- Ruby 2.3
- Postgres 9.4
- Nginx with Passenger

## Installation

1. Install [Vagrant](https://www.vagrantup.com/)
2. `cd path_to_vagrant_ruby`
3. `vagrant up`

## Setting up your project.

1. A suggestion is to create a new git branch to update configs for your project:

```
git checkout my-project
```

2. Update your Vagrantfile shared folders on the `Configure shared folder` section. This will make your host machine files enabled on the guest VM. If the default filesystem is too slow for you, you can try other [Vagrant options](https://www.vagrantup.com/docs/synced-folders).

3. For web projects, setup an Nginx config to load your site (see the Nginx details section below).

4. The Vagrant VM is configured to run on the private IP `192.168.68.8` by default. To access your site from the host machine, go to `http://192.168.68.8`. You can configure your `/etc/hosts` for a friendlier name, or check `dnsmasq` for more advanced setups (like automatic subdomain support).

## Postgres details

A `vagrant` superuser is created for Postgres with password `vagrant`.

## Nginx details

To add a Passenger site to Nginx, create a file like `/etc/nginx/sites-enabled/my-site`, with
the content from `scripts/templates/nginx/app.example.conf` adapted to your site, and restart nginx.
