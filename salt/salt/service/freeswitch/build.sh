#!/bin/bash

# This isn't the cleanest place to put this, but it allows for also rebuilding
# verto communicator automatically in production installs.
rm -rf html5/verto/verto_communicator/bower_components/ html5/verto/verto_communicator/node_modules/

./bootstrap.sh -j
./configure -C

# Modify modules.conf.
/usr/bin/perl  -i -pe 's/#applications\/mod_av/applications\/mod_av/g' modules.conf
/usr/bin/perl  -i -pe 's/#formats\/mod_vlc/formats\/mod_vlc/g' modules.conf

# This was broken for me on build, and it shouldn't impact the video testing.
/usr/bin/perl  -i -pe 's/applications\/mod_spandsp/#applications\/mod_spandsp/g' modules.conf

make
make install
make sounds-install moh-install samples

