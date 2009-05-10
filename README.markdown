##State##

Version 1.0

You can see an actual deployment at [this site](http://pic.jiaeil.com:113)

##What is it?##

SimPic is an personal album(photos and videos) display and management system which based on ruby on rails.

SimPic has the following main features:

1 Authority level control.

with this feature, you can share photo or video between families, relatives, friends and colleges by using one system. You can give every user(or password) an authority level, and let let them see different contents at the same time. This is the reason that I am developing this system, 'cause I cannot find any album display systems having this feature.

2 As many as possible ways to view albums.

##Requirements##

Currently you need all of those things to get SimPic to run:

* Ruby 1.8.6
* Rails 2.3.2
* [image_science](http://seattlerb.rubyforge.org/ImageScience.html)
* [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool/index.html) and [miniexiftool](http://miniexiftool.rubyforge.org/)
* A mysql database.
* Ruby drivers for your database.
* Apache + mod_rails (aka Passenger) for fast and easy deployment along with speed.

##Bugs##

Please report bugs to [here](http://boblu.lighthouseapp.com/projects/24454-simpic/overview)