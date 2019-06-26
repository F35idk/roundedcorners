#!/bin/bash
cd ../..
patch < plugins/roundedcorners/diffs/meson.build.diff
patch -d data/ < plugins/roundedcorners/diffs/org.pantheon.desktop.gala.gschema.xml.in.diff 
patch -d src/ < plugins/roundedcorners/diffs/WindowManager.vala.diff