##State##

Version 1.1.1

[Demo site](http://demo-simpic.jiaeil.com)

admin Password= jiaeil

guest Password= guest1

##What is it?##

There are a lot of good album web services(Flickr, picasa etc..) out there. Why bother to make another one?

* I do not want to upload my private pictures to a public server.
* I have a lot of pictures and I want to put them all on web(or my own server).
* I want different people to see different pictures based on their authority level.

If you have the same needs above like me, then Simpic is for you.

SimPic is an personal album display and management system which is based on ruby on rails.

The following are main features:

1. Frontend

> * Authority level control
>
>	with this feature, you can let different people view photo or video on different levels by giving them distinct passwords. You can also specify a time limit on each password and that password will be automatically deleted on time up.
>
> * Rating and commenting for album or picture
> * As many as possible ways to view albums.
>>
>>	* [Cooliris](http://www.cooliris.com)
>>	* [Embedded Cooliris](http://www.cooliris.com)
>>	* [Shadowbox](http://www.shadowbox-js.com/)
>>	* [JW Image Rotator](http://www.longtailvideo.com/players/jw-image-rotator/)
>>	* [Simple Viewer](http://www.airtightinteractive.com/simpleviewer/)
>>	* adding...

2. Backoffice

> * Album and picture management
>
>	add, modify, delete, sort, publish, cover albums and pictures. You can upload pictures either from your local machine or from web server. And you can upload multiple pictures at one time.
> 
> * Password management
> add, modify, delete password or time span on that password
>
> * Comment management

##Requirements##

Currently you need all of these tools to get SimPic running:

* Ruby 1.8.7
* Rails 2.3.2
* MySQL5 and ruby driver for mysql, use "gem install mysql" to install
* Apache + mod_rails (aka Passenger) for fast and easy deployment along with speed
* [FreeImage](http://sf.net/projects/freeimage)
* [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool/index.html)

##Installation##

1. install all the necessary packages described above

2. clone and checkout new local branch

		[some_directory]# git clone git://github.com/boblu/simpic.git
		[some_directory]# cd simpic
		[some_directory/simpic]# git checkout -b deploy v1.1.0
		[some_directory/simpic]# sudo RAILS_ENV='production' rake gems:install
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