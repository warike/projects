class StartupsController < ApplicationController
  load_and_authorize_resource
  before_action :set_startup, only: [:show, :edit, :update, :destroy]

  # GET /startups/1
  # GET /startups/1.json
  def show
    @review = Review.new
    @review.pivot_id = Startup.find(params[:id]).currentPivot
    ahoy.track "user_visit_startup", user_id: !(current_user.nil?) ? "#{current_user.id}": nil, country_id: !(current_user.nil?) ? "#{current_user.country}" : "", pivot_id: "#{@review.pivot_id}", startup_id: "#{params[:id]}"

  end

  # GET /startups/new
  def new
    @startup = Startup.new
    if !user_signed_in?
      flash.now[:notice] = "Hey! remember to <b><u>create your account</u></b>.".html_safe
    end
  end

  def create_review
    @review = Review.new(review_params)
  end

  # GET /startups/1/edit
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
  # Refactorizar por una funcion que reciba el nombre del status de una startup que se desea ver EJEM. PUBLISHED/PIVOTING/LEARNING
  # Reutilizar la misma función
  
    
  # GET /startups
  # GET /startups.json
  def index
    @q = Startup.search(params[:q])
    @startups =  @q.result(distinct: true)
  end

  def published
    @q = Startup.search(params[:q])
    @startups = @startups.search(
        name_or_webpage_cont: params[:q]
    ).result
    @startups = Startup.published
  end
  
  def pivoting
    @startups = Startup.pivoting
  end

  # POST /startups
  # POST /startups.json
  def create
    @startup = current_user.startups.build(startup_params)
    @startup.set_initial_status
    @startup.pivot_counter = 0
    respond_to do |format|
      if @startup.save
        @member = current_user.members.build({:startup_id => @startup.id , :role =>'Team Leader'})
        @member.save
        flash[:success] ="Congrats! <b>#{@startup.name}</b> was successfully created.".html_safe
        format.html { redirect_to dashboard_startup_path @startup }
      else
        format.html { render action: 'new' }
        format.json { render json: @startup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /startups/1
  # PATCH/PUT /startups/1.json
  def update
    respond_to do |format|
      if @startup.update(startup_params)
        format.html { redirect_to @startup, notice: 'Startup was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @startup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /startups/1
  # DELETE /startups/1.json
  def destroy
    @startup.destroy
    respond_to do |format|
      format.html { redirect_to startups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_startup
      @startup = Startup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def startup_params
      params.require(:startup).permit(:name, :webpage, :pitch, :videopitch, :achievements, :logo, :country, :status, :category, :stage, :twitter_acc, :facebook_acc)
    end

    def review_params
      params.require(:startup).permit(:name, :webpage, :pitch, :videopitch, :achievements, :logo, :country, :status, :category, :stage, :twitter_acc, :facebook_acc)
    end
end
