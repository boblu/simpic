class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
    	t.string :content_type, :null => false, :default => 'picture'
    	t.string :title
    	t.text :description
    	t.references :album
    	t.string :filename, :null => false
    	t.datetime :token_time
    	t.integer :read_level, :null => false, :default => 0
    	t.integer :display_order, :null => false, :default => 1
    	t.boolean :top_shown, :null => false, :default => false
    	t.decimal :rating_average, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end
