class PivotsController < ApplicationController
  #load_and_authorize_resource
  before_action :set_pivot, only: [:show, :edit, :update, :destroy]

  # GET /pivots
  # GET /pivots.json
  def index
    @pivots = Pivot.all
  end

  # GET /pivots/1
  # GET /pivots/1.json

  def user_pivots

    startups = Member.where("user_id=?", current_user.id).pluck("startup_id") #obtengo todas las startups del user
    @pivots = Pivot.find_all_by_startup_id(startups)

  end
  
  def show
  end

  # GET /pivots/new
  def new
    @pivot = Pivot.new
  end

  # GET /pivots/1/edit
  def edit
  end

  # POST /pivots
  # POST /pivots.json
  def create
  
  @pivot = Pivot.new(pivot_params)
  @pivot.start_date = Date.today 
  @pivot.status = true
  #raise @pivot.inspect
  # es miembro?
  
  @member = Member.where( "startup_id=? and user_id=?", @pivot.startup_id, current_user.id).first  
   if @member.is_teamleader(@pivot.startup_id)
      respond_to do |format|
        if @pivot.save
          format.html { redirect_to dashboard_startup_path(@pivot.startup_id), :flash => {:success => 'Congrats! Your StartUp is Pivoting right <b>NOW!</b>.'.html_safe } }
          format.json { head :no_content }
        else
          format.html { redirect_to dashboard_startup_path(@pivot.startup_id), :flash => {:error => @pivot.errors.full_messages.map(&:inspect).join(', ')} }
          format.json { render json: @pivot.errors, status: :unprocessable_entity }
        end
      end
      #redirect_to , :flash => {:success => 'Congrats! Your StartUp is Pivoting right <b>NOW!</b>.'.html_safe}

  else
    redirect_to dashboard_path, :flash => {:error => 'Invalid Access, you are not team leader in this startup!.'}
  end

  
  end

  # PATCH/PUT /pivots/1
  # PATCH/PUT /pivots/1.json
  def update
    respond_to do |format|
      if @pivot.update(pivot_params)
        format.html { redirect_to @pivot, notice: 'Pivot was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @pivot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pivots/1
  # DELETE /pivots/1.json
  def destroy
    @pivot.destroy
    respond_to do |format|
      format.html { redirect_to pivots_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pivot
      @pivot = Pivot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pivot_params
      params.require(:pivot).permit(:startup_id, :start_date, :finish_date)
    end
end
