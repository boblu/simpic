class AddAlbumPathColumn < ActiveRecord::Migration
  def self.up
  	add_column :albums, :title_meta, :string
  end

  def self.down
  	remove_column :albums, :title_meta
  end
end
