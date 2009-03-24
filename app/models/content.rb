class Content < ActiveRecord::Base
	belongs_to :album
	has_many :comments, :as => :commentable
end
