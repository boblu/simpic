class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
    	t.string :name, :email, :null => false
    	t.text :content, :null => false
    	t.references :commentable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
