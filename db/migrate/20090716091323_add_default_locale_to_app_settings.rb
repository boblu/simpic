class AddDefaultLocaleToAppSettings < ActiveRecord::Migration
  class App < ActiveRecord::Base
    serialize :settings
  end
  
  def self.up
    app = App.first
    app.settings.update('default_locale' => 'cn')
    app.save!
  end

  def self.down
    app = App.first
    app.settings.delete('default_locale')
    app.save!
  end
end
