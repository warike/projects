class Pivot < ActiveRecord::Base
  STATUSES = [STATUS_ACTIVE = true, STATUS_INACTIVE = false]
  
  belongs_to :startup
  has_many :reviews
  after_save :change_startup_status
  
  
  validates :finish_date, :start_date , presence: true 
  validate :valid_range => {:message => "Finish date must be grater than start date"}

  scope :active, -> { where(status: Pivot::STATUS_ACTIVE) }

  def is_active?
    self.status
  end


  def change_startup_status
    self.startup.pivot_startup
    self.startup.save
  end 
  
  #Funcion que verifica si un pivot fue reviewed por un usuario
  def was_reviewed_by_user(user_id)
    !self.reviews.find(:last, :conditions => [ "user_id = ?", user_id ]).blank?   
  end 
  
  
  def valid_range
    self.finish_date <= Date.today ? false : true
  end

  def get_review_by_user user_id
    review = self.reviews.find(:last, :conditions => [ "user_id = ?", user_id ])
    review
  end
  
  
  
end

