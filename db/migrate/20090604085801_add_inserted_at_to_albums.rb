class AddInsertedAtToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :inserted_at, :timestamp
  end

  def self.down
    remove_column :albums, :inserted_at
  end
end
