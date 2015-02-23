# Steam

[![Code Climate](https://codeclimate.com/github/locomotivecms/steam/badges/gpa.svg)](https://codeclimate.com/github/locomotivecms/steam) [![Dependency Status](https://gemnasium.com/locomotivecms/steam.svg)](https://gemnasium.com/locomotivecms/steam) [![Build Status](https://travis-ci.org/locomotivecms/steam.svg?branch=master)](https://travis-ci.org/locomotivecms/steam) [![Coverage Status](https://coveralls.io/repos/locomotivecms/steam/badge.svg?branch=master)](https://coveralls.io/r/locomotivecms/steam?branch=master) [![Gitter](https://img.shields.io/badge/gitter-join%20chat%20%E2%86%92-brightgreen.svg)](https://gitter.im/locomotivecms/steam)

The rendering stack used by both Wagon and Engine (WIP). It includes:

- the rack stack to serve assets (SCSS, Coffeescript, ...etc) and pages
- the liquid drops/filters/tags libs to parse and render liquid templates
- a filesystem repository which reads the source of a site written for Wagon

**Note:** Steam passes all the specifications from Wagon.

## Installation [WIP]

    gem install thin
    gem install locomotivecms_steam --pre

## Usage

    steam <PATH to a Wagon site>

open your browser

    open localhost:8080

## TODO

see the list in the issues section.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/locomotivecms/steam )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
