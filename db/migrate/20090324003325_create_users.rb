class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
    	t.string :name, :email
    	t.integer :user_type, :null => false, :default => 0
    	t.string :hashed_password, :null => false
    	t.integer :read_level, :null => false, :default => 0
    	t.integer :span, :null => false, :default => 30
    	t.datetime :begin_time, :end_time
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
