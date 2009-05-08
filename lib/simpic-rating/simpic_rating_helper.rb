module SimpicRating # :nodoc:
  module Helper
    class MissingRateRoute < StandardError
      def to_s
        "Add :member => {:rate => :post} to your routes, or specify a custom url in the options."
      end
    end
  
    def ratings_for(rateable, *args)
      extract_options(rateable, *args)
      simpic_styles << %Q(
      .#{options[:class]} { width: #{rateable.class.max_rate_value * 25}px; }
      .#{options[:small_star_class]} { width: #{rateable.class.max_rate_value * 10}px; }
      )
      width = (rateable.rate_average(true, options[:dimension]) / rateable.class.max_rate_value.to_f) * 100
      ul = content_tag(:ul, options[:html]) do
        Range.new(1, rateable.class.max_rate_value).collect do |i|
          build_star rateable, i
        end.insert(0, content_tag(:li, current_average(rateable),
            :class => 'current-rating', :style => "width:#{width}%"))
      end
      if options[:wrap]
        content_tag(:div, ul, :id => "simpic-rating-#{!options[:dimension].blank? ?
          "#{options[:dimension]}-" : ''}#{rateable.class.name.downcase}-#{rateable.id}")
      else
        ul
      end
    end

    def simpic_rating_style
      stylesheet_link_tag('simpic_rating') + content_tag(:style, simpic_styles,
        :type => 'text/css') unless simpic_styles.blank?
    end
  
    private
  
    # Builds a star
    def build_star(rateable, i)
      a_class = "#{options[:link_class_prefix]}-#{i}"
      simpic_styles << %Q(
        .#{options[:class]} .#{a_class}{
            width: #{(i / rateable.class.max_rate_value.to_f) * 100}%;
            z-index: #{rateable.class.max_rate_value + 2 - i};
        }
      )
      star = link_to_remote(i, build_remote_options({:class => a_class, :title => pluralize_title(i, rateable.class.max_rate_value)}, i))
      content_tag(:li, star)
    end
  
    # Default options for the helper.
    def options
      @options ||= {
        :wrap => true,
        :class => 'simpic-rating',
        :link_class_prefix => :stars,
        :small_stars => false,
        :small_star_class => 'small-star',
        :html => {},
        :remote_options => {:method => :post}
      }
    end
  
    # Builds the proper title for the star.
    def pluralize_title(current, max)
      (current == 1) ? I18n.t('simpic_rating.stars.title.one', :max => max, :default => "1 star out of {{max}}") :
        I18n.t('simpic_rating.stars.title.other', :count => current, :max => max, :default => "{{count}} stars out of {{max}}")
    end
    
    # Returns the current average string.
    def current_average(rateable)
      I18n.t('simpic_rating.stars.current_average', :average => rateable.rate_average(true, options[:dimension]),
        :max => rateable.class.max_rate_value, :default => "Current rating: {{average}}/{{max}}")
    end
  
    # Temporary instance to hold dynamic styles.
    def simpic_styles
      @simpic_styles ||= ''
    end
  
    # Builds the default options for the link_to_remote function.
    def build_remote_options(html, i)
      options[:remote_options].reverse_merge(:html => html).merge(
        :url => "#{options[:remote_options][:url]}?#{{:stars => i, :dimension => options[:dimension]}.to_query}")
    end
  
    def extract_options(rateable, *args)
      options.merge!(args.last) if !args.empty? && args.last.is_a?(Hash)
      options[:remote_options][:url] ||= respond_to?(url = "rate_#{rateable.class.name.downcase}_path") ?
        send(url, rateable) : raise(MissingRateRoute)
      options[:html].reverse_merge!(:class => "#{options[:class]} #{options[:small_star_class] if options[:small_stars]}")
    end
  end
end
