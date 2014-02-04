# MissionHub

MissionHub is an online tool that makes it easier than ever for you to connect, communicate and track ministry relationships.

We're an open source project and always looking for more developers to help us expand MissionHub's features.  Contact support@missionhub.com to get involved.

http://missionhub.com

## Getting Started

### Requirements

* MySQL
* Redis
* Memcached

### Setup

Copy the example configuration files to active configuration files:

```bash
$ cd config
$ cp database.example.yml database.yml
$ cp config.example.yml config.yml
$ cp s3.travis.yml s3.yml
$ cp memcached.example.yml memcached.yml
```

### Install Gems

```bash
$ bundle install
```

### Create databases

```bash
$ bundle exec rake db:create:all
```

### Run migrations

```bash
$ bundle exec rake db:migrate
```

### Start Servers

```bash
$ redis-server
$ memcached
$ bundle exec rails s
```

## Running Tests

```bash
$ bundle exec rake test
```

## License

MissionHub is released under the MIT license:  http://www.opensource.org/licenses/MIT

## Latest Release

MissionHub's latest release was 7/24/2013