#!/bin/sh
echo 'America/Chicago' | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
sudo pip install docutils
date
