class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]

  # GET /entries
  # GET /entries.json
  def index
    @entries = Entry.all
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    @entry = Entry.new
  end

  # GET /entries/1/edit
  def edit
  end

  #Función que ordena las entradas, recibe como parametro un arreglo
  def sort
    params[:entry].each_with_index do |id, index|
      @entry = Entry.find(params[:entry][index])
      @entry.show_order = index + 1
      @entry.save!
    end
    render nothing: true
  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = Entry.new(entry_params)
    respond_to do |format|
      if @entry.save
        format.html { redirect_to dashboard_startup_path(@entry.startup_id), :flash => {:success => 'Congrats! You add a new Entry.'.html_safe } }
        format.json { head :no_content }
      else
        format.html { redirect_to dashboard_startup_path(@entry.startup_id) }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entries/1
  # PATCH/PUT /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to dashboard_startup_path(@entry.startup_id), :flash => {:success => 'Entry <b>successfully</b> updated.'.html_safe } }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_startup_path(@entry.startup_id), :flash => {:notice => {:text =>' Entry <b>successfully</b> removed.'.html_safe, :icon =>'trash'} } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.require(:entry).permit(:title, :entry_type, :url, :description, :show_order, :startup_id)
    end
end
