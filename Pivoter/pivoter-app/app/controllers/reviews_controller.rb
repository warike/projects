class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.all
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
  end

  
  def create
    @review = current_user.reviews.build(review_params)
    user = User.find(@review.user_id)
    startup = Startup.find(Pivot.find(@review.pivot_id).startup_id)
    if(!user.following?(startup))
      user.follow(startup)
    end
    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: 'Review was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @review }
        format.js   { render :json => @review.to_json, status: :created, notice: 'Review was successfully created' }
      else
        format.html { render action: 'new' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
        # added:
        format.js   { render json: @review.errors.to_json, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:pivot_id, :user_id, :comment,  :ratelogo, :ratepitch, :ratevideo, :rateidea, :ratename)
    end
end
