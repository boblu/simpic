class AddAppTable < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|
      t.text :settings, :null => false
    end
  end

  def self.down
    drop_table :apps
  end
end
