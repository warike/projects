class Review < ActiveRecord::Base
  belongs_to :pivot
  belongs_to :user
  before_save :calculate_score
  
  def calculate_score
    self.score = (self.ratepitch + self.ratelogo + self.ratepitch + self.ratevideo + self.rateidea + self.ratename)/6
  end
  
  validates_uniqueness_of :pivot_id, :scope => [:user_id], :message => 'You have already reviewed this Pivots!'
  validates :ratelogo, :presence => {:message => "Must rate a logo"}
  validates :ratepitch, :presence => {:message => "Musst rate a pitch"}
  validates :rateidea, :presence => {:message => "Must rate a idea"}
  validates :ratevideo, :presence => {:message => "Must rate a video"}
  validates :ratename, :presence => {:message => "Must review a name"}

  validates_inclusion_of :ratelogo, :in => 1..5, :message => "Review must be between 1 and 5."
  validates_inclusion_of :ratepitch, :in => 1..5, :message => "Review must be between 1 and 5."
  validates_inclusion_of :rateidea, :in => 1..5, :message => "Review must be between 1 and 5."
  validates_inclusion_of :ratevideo, :in => 1..5, :message => "Review must be between 1 and 5."
  validates_inclusion_of :ratename, :in => 1..5, :message => "Review must be between 1 and 5."
end
