module Settings
  TMP_PIC_DIR = RAILS_ROOT+'/upload/'
  PIC_DIR = RAILS_ROOT+'/public/pictures/'
  NORMAIL_SIZE = [1000, 750]
  MEDIUM_SIZE = [400, 300]
  THUMB_SIZE = [120, 90]
  APP_NAME = 'SimPic'
  PER_PAGE = 30
  
	def authority_name
		{'admin' => 0, 'family' => 10, 'relative' => 20, 'friend' => 30, 'reader' => 40, 'guest' => 50}
	end
end