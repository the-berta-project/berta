<p align="center">
  <img alt="Berta" src="http://i.imgur.com/tGCcsEU.png" width="500"/>
</p>

# Berta

[![Build Status](https://travis-ci.org/dudoslav/berta.svg?branch=master)](https://travis-ci.org/dudoslav/berta)
[![Coverage Status](https://coveralls.io/repos/github/dudoslav/berta/badge.svg?branch=master)](https://coveralls.io/github/dudoslav/berta?branch=master)
[![Code Climate](https://codeclimate.com/github/dudoslav/berta/badges/gpa.svg)](https://codeclimate.com/github/dudoslav/berta)
[![Inline docs](http://inch-ci.org/github/dudoslav/berta.svg?branch=master)](http://inch-ci.org/github/dudoslav/berta)
[![Dependency Status](https://gemnasium.com/badges/github.com/dudoslav/berta.svg)](https://gemnasium.com/github.com/dudoslav/berta)
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
git clone git://github.com/dudoslav/berta.git
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
