class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
    	t.string :title, :null => false
    	t.text :description
    	t.date :begin_on, :end_on, :null => false
    	t.integer :appearance, :null => false, :default => 0
    	t.integer :read_level, :null => false, :default => 0
    	t.decimal :rating_average, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
