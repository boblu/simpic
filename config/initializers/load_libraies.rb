require 'simpic-rating/simpic_rating'
require 'simpic-rating/simpic_rating_helper'
ActiveRecord::Base.send(:include, SimpicRating) unless ActiveRecord::Base.include?(SimpicRating)
ActionView::Base.send(:include, SimpicRating::Helper) unless ActionView::Base.include?(SimpicRating::Helper)