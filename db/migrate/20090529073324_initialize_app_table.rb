class InitializeAppTable < ActiveRecord::Migration
  class App < ActiveRecord::Base
    serialize :settings
  end

  def self.up
    app = App.new
    app.settings = {"tmp_pic_dir" => "RAILS_ROOT+'/upload'",
                    "pic_dir" => "RAILS_ROOT+'/public/pictures'",
                    "normal_size" => [1000, 750],
                    "medium_size" => [400, 300],
                    "thumb_size" => [120, 90],
                    "app_name" => "SimPic",
                    "per_page" => 30,
                    "authority_name" => {"admin" => 0,
                                         "family" => 10,
                                         "relative" => 20,
                                         "friend" => 30,
                                         "reader" => 40,
                                         "guest" => 50
                                        }
                   }
    app.save!
  end

  def self.down
    App.delete_all
  end
end
