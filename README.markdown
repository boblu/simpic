##State##

Version 1.0.1

You can see some screenshots at the bottom of this page.

##What is it?##

SimPic is an personal album(photos and videos) display and management system which based on ruby on rails.

SimPic has the following main features:

1. Authority level control.

	with this feature, you can share photo or video between families, relatives, friends and colleges by using one system. You can give every user(or password) an authority level, and let let them see different contents at the same time. This is the reason that I am developing this system, 'cause I cannot find any album display systems having this feature.

2. Rating and commenting for album or picture

3. As many as possible ways to view albums.

	* [Cooliris](http://www.cooliris.com)
	* [Shadowbox](http://www.shadowbox-js.com/)
	* adding...

##Requirements##

Currently you need all of those things to get SimPic to run:

* Ruby 1.8.6
* Rails 2.3.2
* [image_science](http://seattlerb.rubyforge.org/ImageScience.html)
* [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool/index.html) and [miniexiftool](http://miniexiftool.rubyforge.org/)
* A mysql database.
* Ruby drivers for your database.
* Apache + mod_rails (aka Passenger) for fast and easy deployment along with speed.

##Installation##

1. install all the necessary packages described above

2. clone and checkout new local branch

		[some_directory]# git clone git://github.com/boblu/simpic.git
		[some_directory]# cd simpic
		[some_directory/simpic]# git checkout -b deploy v1.0.1
		[some_directory/simpic]# git submodule init
		[some_directory/simpic]# git submodule update

3. modify database configuration file

		[some_directory/simpic]# cp config/database.yml.example config/database.yml

	and write database information in that new file

4. generate database

		[some_directory/simpic]# RAILS_ENV='production' rake db:create
		[some_directory/simpic]# RAILS_ENV='production' rake db:migrate

5. config apache and passenger, and good to go

##Bugs##

Please report bugs to [here](http://boblu.lighthouseapp.com/projects/24454-simpic/overview) or send mail to boblu@jiaeil.com

##screenshots

![simpic1](http://lh5.ggpht.com/_zwRrYMttoxo/SgbaK7WXcdI/AAAAAAAABME/cdX_6RvL0Eg/s720/Picture%202.png)
------------------------------------
![simpic2](http://lh4.ggpht.com/_zwRrYMttoxo/SgbaLMnxNnI/AAAAAAAABMI/tZQeX6QVJNE/s720/Picture%203.png)
------------------------------------
![simpic3](http://lh4.ggpht.com/_zwRrYMttoxo/SgbaLPx1SfI/AAAAAAAABMM/AMm9muTy3GY/s720/Picture%204.png)
------------------------------------
![simpic4](http://lh5.ggpht.com/_zwRrYMttoxo/SgbaLKMiGsI/AAAAAAAABMQ/XW3DJhC_Uig/s800/Picture%205.png)
------------------------------------
![simpic5](http://lh5.ggpht.com/_zwRrYMttoxo/SgbaLeY9qBI/AAAAAAAABMU/yvmiA7RpSzI/s800/Picture%206.png)