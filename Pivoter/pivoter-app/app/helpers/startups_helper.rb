module StartupsHelper
  CATEGORIES = {'ARTS'=>'glyphicon glyphicon-picture','BIGDATA'=>'glyphicon glyphicon-stats', 'COMICS'=>'glyphicon glyphicon-pencil','ECOMMERCE'=>'glyphicon glyphicon-shopping-cart','DANCE'=>'glyphicon glyphicon-play','DESIGN'=>'glyphicon glyphicon-heart-empty','FASHION'=>'glyphicon glyphicon-eye-open','FILM & VIDEO'=>'glyphicon glyphicon-film','FOOD'=>'glyphicon glyphicon-cutlery', 'GAMES'=>'glyphicon glyphicon-screenshot','JOURNALISM'=>'glyphicon glyphicon-info-sign', 'MUSIC'=>'glyphicon glyphicon-headphones','PHOTOGRAPHY'=>'glyphicon glyphicon-camera', 'PUBLISHING'=>'glyphicon glyphicon-bullhorn', 'TECHNOLOGY'=>'glyphicon glyphicon-phone','THEATER'=>'glyphicon glyphicon-facetime-video'}.invert
  
  def startup_review_form(startup= nil, user= nil)
    if user_signed_in? && startup.is_pivoting
      if startup.pivots.active.last.was_reviewed_by_user(user.id)
        @review = startup.pivots.active.last.get_review_by_user(current_user.id).attributes.to_hash
        concat render('reviews/show', :locals =>{:review => @review })
      else
        concat render('reviews/form')
      end
    end
  end
  
  def show_category(category=nil)
    concat (category.blank?) ? ("<span class='glyphicon glyphicon-flag'></span> N/A".html_safe) : ("<span class='#{CATEGORIES.key(category)}'></span> #{category.capitalize}".html_safe)
  end
  def show_country(country=nil, icon=true)
    country = (country.blank?)?"N/A":country
    if icon
      concat "<span class='glyphicon glyphicon-map-marker'></span> #{country}".html_safe
    end
    
  end
  def show_next_button
      concat "NEXT"
      concat content_tag(:span, ' ', :class =>'glyphicon glyphicon-chevron-right')
  end
    
end
