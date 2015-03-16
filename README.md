# Steam

[![Code Climate](https://codeclimate.com/github/locomotivecms/steam/badges/gpa.svg)](https://codeclimate.com/github/locomotivecms/steam) [![Dependency Status](https://gemnasium.com/locomotivecms/steam.svg)](https://gemnasium.com/locomotivecms/steam) [![Build Status](https://travis-ci.org/locomotivecms/steam.svg?branch=master)](https://travis-ci.org/locomotivecms/steam) [![Coverage Status](https://coveralls.io/repos/locomotivecms/steam/badge.svg?branch=master)](https://coveralls.io/r/locomotivecms/steam?branch=master) [![Gitter](https://img.shields.io/badge/gitter-join%20chat%20%E2%86%92-brightgreen.svg)](https://gitter.im/locomotivecms/steam)

The rendering stack used by both Wagon and Engine (WIP). It includes:

- the rack stack to serve assets (SCSS, Coffeescript, ...etc) and pages.
- the liquid drops/filters/tags libs to parse and render liquid templates.
- a Filesystem adapter which reads the source of a site written for Wagon.
- a MongoDB adapter which reads an existing site hosted by the Locomotive Engine.

**Note:** Steam passes all the specifications of both Wagon and Engine.

## Installation [WIP]

    gem install thin
    gem install locomotivecms_steam --pre

## Usage

### Command line:

Display all the options:

    steam --help

Render a local Wagon site:

    steam --path=<PATH to a Wagon site>

Render a Engine site:

    steam --database=<NAME of the MongoDB database used by the Engine> --assets-path=<PATH to the public folder of the Locomotive>

Once launched, open your browser

    open localhost:8080

### Inside a Rails application:

[TODO]

## TODO

see the list in the issues section.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/locomotivecms/steam )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2015 NoCoffee. MIT Licensed, see LICENSE for details.
