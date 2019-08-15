# Steam

[![Code Climate](https://codeclimate.com/github/locomotivecms/steam/badges/gpa.svg)](https://codeclimate.com/github/locomotivecms/steam) [![Dependency Status](https://gemnasium.com/locomotivecms/steam.svg)](https://gemnasium.com/locomotivecms/steam) [![Build Status](https://travis-ci.com/locomotivecms/steam.svg?branch=master)](https://travis-ci.com/locomotivecms/steam) [![Coverage Status](https://coveralls.io/repos/locomotivecms/steam/badge.svg?branch=master)](https://coveralls.io/r/locomotivecms/steam?branch=master) [![Gitter](https://img.shields.io/badge/gitter-join%20chat%20%E2%86%92-brightgreen.svg)](https://gitter.im/locomotivecms/steam)

The rendering stack used by both Wagon and Engine (WIP). It includes:

- the rack stack to serve assets (SCSS, Coffeescript, ...etc) and pages.
- the liquid drops/filters/tags libs to parse and render liquid templates.
- a Filesystem adapter which reads the source of a site written for Wagon.
- a MongoDB adapter which reads an existing site hosted by the Locomotive Engine.

**Note:** Steam passes all the specifications of both Wagon and Engine.

## Installation [WIP]

    gem install thin
    gem install locomotivecms_steam

## Usage

### Command line:

*Warning*: For now, Steam is not aimed to be run standalone. The following is just a proof of concept.

Display all the options:

    steam --help

Render a local Wagon site:

    steam --path=<PATH to a Wagon site>

Render a Engine site:

    steam --database=<NAME of the MongoDB database used by the Engine> --assets-path=<PATH to the public folder of the Locomotive>

Once launched, open your browser

    open localhost:8080

### Inside Engine / Wagon:

[https://github.com/locomotivecms/engine/blob/master/lib/locomotive/steam_adaptor.rb](https://github.com/locomotivecms/engine/blob/master/lib/locomotive/steam_adaptor.rb)
[https://github.com/locomotivecms/engine/blob/master/spec/dummy/config/routes.rb](https://github.com/locomotivecms/engine/blob/master/spec/dummy/config/routes.rb#L12)


[https://github.com/locomotivecms/wagon/blob/master/lib/locomotive/wagon/commands/serve_command.rb](https://github.com/locomotivecms/wagon/blob/master/lib/locomotive/wagon/commands/serve_command.rb#L65)
[https://github.com/locomotivecms/wagon/blob/master/lib/locomotive/wagon/commands/serve_command.rb](https://github.com/locomotivecms/wagon/blob/master/lib/locomotive/wagon/commands/serve_command.rb#L138)

## TODO

see the list in the issues section.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/locomotivecms/steam )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Running test with docker

A docker configuration is included in this repository, you can run all the tests with the following procedure

First run a bash shell inside the container

```
docker-compose run steam gosu ubuntu bash
```

Now you are inside the container you can

Init the database with demo data

```
rake mongodb:test:seed
```

Run all the test with

```
rake spec
```

Run specific test with rspec

```
rspec spec/unit/middlewares/locale_spec.rb

```

Note: you do not need to prefix with bundle exec as the docky-ruby image already add it automatically

## License

Copyright (c) 2019 NoCoffee. MIT Licensed, see MIT-LICENSE for details.
