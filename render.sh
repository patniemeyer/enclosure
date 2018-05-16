#!/bin/sh

#~/MyApplications/OpenSCAD.app/Contents/MacOS/OpenSCAD  -o printer-enclosure.stl printer-enclosure.scad 
#file=$1
file=printer-enclosure.scad
noextension=`echo $file | sed 's/\.[^.]*$//'`  # sed doesn't have non-greedy
~/MyApplications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o "${noextension}.stl" $file
#/usr/local/bin/openscad -o "${noextension}.stl" $file
