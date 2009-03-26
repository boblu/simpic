class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
    	t.string :content_type, :null => false, :default => 'picture'
    	t.text :description
    	t.references :album
    	t.string :thumb_path
    	t.string :normal_path, :null => false
    	t.datetime :token_time, :null => false
    	t.integer :read_level, :null => false, :default => 0
    	t.integer :order, :null => false
    	t.integer :top_shown, :null => false, :default => 0
    	t.decimal :rating_average, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end
