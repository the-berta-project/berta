<p align="center">
  <img alt="Berta" src="http://i.imgur.com/tGCcsEU.png" width="500"/>
</p>

# Berta

[![Build Status](https://travis-ci.org/the-berta-project/berta.svg?branch=master)](https://travis-ci.org/the-berta-project/berta)
[![Coverage Status](https://coveralls.io/repos/github/the-berta-project/berta/badge.svg?branch=master)](https://coveralls.io/github/the-berta-project/berta?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/561a29e682b0006b6f44/maintainability)](https://codeclimate.com/github/the-berta-project/berta/maintainability)
[![Gem Version](https://badge.fury.io/rb/berta.svg)](https://badge.fury.io/rb/berta)

Berta cleans cloud from unused vms. She sets expiration to all virtual machines
and when expiration is close she will notify owners. Berta is developed as ruby gem.

## Getting started

### Installation

From rubygems:

```bash
gem install berta
```

From source:

```bash
git clone git@github.com:the-berta-project/berta.git
cd berta
gem install bundler
bundle install
```

### Configuration

Config files can be located in:
* `~/.berta/berta.yml`
* `/etc/berta/berta.yml`
* `PATH_TO_GEM_DIR/config/berta.yml`

### Execution

Berta needs access to opennebula backend. To do that she needs to know opennebula
secret and endpoint. This can be specified in config file, as command line options or
by creating `one_auth` file in `~/.one`.
To run berta simply type:
```bash
berta
# or if backend and secret are not set
berta --opennebula-secret=<secret> --opennebula-endpoint=<endpoint>
```
