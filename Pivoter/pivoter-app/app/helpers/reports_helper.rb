module ReportsHelper
  def pie_chart(hash=nil)
  end

  def line_chart(hash=nil)
  end

  def bar_chart(current_pivot_reviews=nil, average_pivot_reviews=nil)
    review_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.series(:type=>'column', :name=>'Average',:data=> current_pivot_reviews.values)
      if(!average_pivot_reviews.blank?)
        f.series(:type=>'spline',:color=>'green', :name=>'Reviews Average',:data=> average_pivot_reviews.values)
      end
      f.xAxis(:categories => current_pivot_reviews.keys )
      f.title({ :text=>"Your Review"})
      f.options[:chart][:defaultSeriesType] = "column"
      f.plot_options({:column=>{:stacking=>"normal"}})
    end
    concat high_chart("reviews_div_chart", review_chart)
  end
end