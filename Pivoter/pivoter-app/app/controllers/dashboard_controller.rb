class DashboardController < ApplicationController
before_action :validate_login, only: [:view, :index]
before_action :validate_member, only: [:view]
before_action :set_startup, only: [:view, :edit, :update]
before_action :startup_params, only: [:update]
before_action :validate_pivot, only: [:edit]
  
  def init
    self.layout = ''
  end
  def index
    flash.now[:notice] = "Hey! You must Select a Startup!."
  end
 
  def view
    
    #function que trae todos los registros de visitas agrupados por fecha para una startup_id
    visit_counts = Array.new
    visit_days = Array.new
    Ahoy::Event.select("date(time) as visit_day, count(*) as visit_count").where(startup_id: params[:id]).group("date(time)").order("date(time)").map do |t|
      visit_days.push t.visit_day
      visit_counts.push t.visit_count
    end



    #Funcion que trae todos los registros de visitas agrupados por country para una startup_id
    country_counts = Hash.new
    hash_countries = Startup.new.countries
    countries_result = Ahoy::Event.select("country, count(*) as country_count").where(startup_id: params[:id]).group("country")
   
    if !countries_result.blank?
      countries_result.map do |t|
        country_counts[hash_countries.key(t.country)]=t.country_count
      end
    end



    #Funcion que recolecta todas las Reviews del current pivot
    current_pivot_reviews = Hash.new
    current_pivot_startup = Pivot.where("startup_id = ? AND status = ?", params[:id], true).order(:created_at).take
    if !current_pivot_startup.nil?
      current_pivot_startup.reviews.select("SUM(ratelogo) AS ratelogo_sum, SUM(ratepitch) AS ratepitch_sum, SUM(ratevideo) AS ratevideo_sum, SUM(rateidea) AS rateidea_sum, SUM(ratename) AS ratename_sum, SUM(score) AS score_sum, Count(*) AS reviews_count").group(:pivot_id).map do |t|
        current_pivot_reviews.merge!(:logo => t.ratelogo_sum/t.reviews_count)
        current_pivot_reviews.merge!(:pitch => t.ratepitch_sum/t.reviews_count)
        current_pivot_reviews.merge!(:idea => t.rateidea_sum/t.reviews_count)
        current_pivot_reviews.merge!(:video => t.ratevideo_sum/t.reviews_count)
        current_pivot_reviews.merge!(:name => t.ratename_sum/t.reviews_count)
        #@current_pivot_reviews.merge!(:score => t.score_sum)
        #@current_pivot_reviews.merge!(:reviewscount => t.reviews_count) 
      end
    end
    review_chart = LazyHighCharts::HighChart.new('column') do |f|
      f.series(:name=>'Reviews Average',:data=> current_pivot_reviews.values)
      f.xAxis(:categories => current_pivot_reviews.keys )     
      f.title({ :text=>"Reviews Tracking"})
      f.options[:chart][:defaultSeriesType] = "column"
      f.plot_options({:column=>{:stacking=>"normal"}})
    end
    
    visit_chart = LazyHighCharts::HighChart.new('grapho') do |f|
      f.title({ :text=>"Visits tracking"})
      f.options[:xAxis][:categories] = visit_days
      f.labels(:items=>[:html=>"Visits/Day", :style=>{:left=>"40px", :top=>"8px", :color=>"black"} ]) 
      f.series(:type=> 'spline',:name=> 'Visits total', :data=> visit_counts)
      
     end
    
    countries_pie = LazyHighCharts::HighChart.new('pie') do |f|
          f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 200, 60, 170]} )
          series = {
                   :type=> 'pie',
                   :name=> 'Country distribution',
                   :data=> country_counts.to_a
          }
          f.series(series)
          f.options[:title][:text] = "Countries"
          f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
          f.plot_options(:pie=>{
            :allowPointSelect=>true, 
            :cursor=>"pointer" , 
            :dataLabels=>{
              :enabled=>true,
              #:color=>"black",
              :style=>{
                :font=>"13px Trebuchet MS, Verdana, sans-serif"
              }
            }
          })
    end
    @chart = {:reviews => review_chart, :countries => countries_pie, :visits => visit_chart}

    @member_leader = Member.teamLeader(@startup.id)
    @members = @startup.members.where.not(role: "Team Leader").order(role: :desc)
    @pivot = Pivot.new
    @pivot.startup_id = @startup.id
    @pivot.start_date = Date.today

    @entry = Entry.new
    @entry.startup_id = @startup.id
    @entry.show_order = last_entry(@startup.id)

    startups = Member.where("user_id=?", current_user.id).pluck("startup_id") #obtengo todas las startups del user
    @pivots = @startup.pivots
    @entries = @startup.entries
    
  end

  def edit
    
  end

  def update
    respond_to do |format|

      if @startup.update(startup_params)
        format.html { redirect_to  dashboard_startup_path, notice: 'Startup was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @startup.errors, status: :unprocessable_entity }
      end
    end
  end



  def validate_login
    if !user_signed_in?
      redirect_to root_path, notice: 'Invalid Access, login first!.'
    end
  end

  def validate_member
    if !Member.isMember?(params[:id], current_user.id)
      redirect_to dashboard_path, :flash => {:error => 'Invalid Access, you are not member in this startup!.'}
    end
  end

  def last_entry(startup_id)
    #obtengo el último orden, necesita refactor
    valor=(Entry.where(startup_id:startup_id).blank?) ? 1 :Entry.where(startup_id:startup_id).maximum("show_order")+1
  end

  def invite_user
    startup = Startup.find(params[:startup_id])
    user = User.where(email: params[:user][:email]).first

    if !user.nil?
      if !Member.isMember?(startup.id,user.id,params[:user][:email])
        UserMailer.invite_user(current_user, user, startup).deliver
        member = user.members.build({:startup_id => startup.id , :role =>'Member'})
        if member.save
          flash[:success] = "Good! your invitation to #{params[:user][:email]} has been sent!."
          redirect_to dashboard_startup_path(params[:startup_id])
        end
      else
        flash[:error] = "This email is already a member on the startup"
        redirect_to dashboard_startup_path(params[:startup_id])
      end
    else
      user = User.invite!(:email => params[:user][:email])
      flash[:success] = "Good! you are invite to #{params[:user][:email]} to participate on pivoter"
      redirect_to dashboard_startup_path(params[:startup_id])
    end
  end

  #validar si la startup tiene pivoter activos
  def validate_pivot
    if !@startup.pivots.where(status: true).blank?
      flash[:success] = "Sorry, but the pivot has to finish before edit your startup"
      redirect_to dashboard_startup_path(@startup)
    end
  end

  def set_startup
    @startup = Startup.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def startup_params
    params.require(:startup).permit(:name, :webpage, :description, :videopitch, :achievements, :logo, :country, :status, :category, :stage)
  end
end
