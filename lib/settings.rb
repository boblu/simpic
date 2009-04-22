module Settings
  TMP_PIC_DIR = RAILS_ROOT+'/upload/'
  PIC_DIR = RAILS_ROOT+'/public/pictures/'
  NORMAIL_SIZE = [1000, 750]
  MEDIUM_SIZE = [400, 300]
  THUMB_SIZE = [80, 60]
  APP_NAME = 'SimPic'
  
	def authority_name
		{'admin' => 0, 'family' => 10, 'relative' => 20, 'friend' => 30, 'reader' => 40, 'guest' => 50}
	end
end