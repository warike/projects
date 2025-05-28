class Member < ActiveRecord::Base
  belongs_to :startup
  belongs_to :user

  scope :numero_miembros, -> { count }

  def self.teamLeader(startup_id)
  	where( "startup_id=? and role=?", startup_id, "Team Leader").first
  end

  def is_teamleader(startup_id)
    !Member.where( "startup_id=? and role=?", startup_id, "Team Leader").first.nil?
  end

  def self.isMember?(startup_id, user_id=nil, email=nil)
  	unless email.nil?
      if where( "startup_id=? and user_id=?", startup_id, user_id).first
        true
      else
        false
      end
    else
      if where("startup_id=? and user_id=?", startup_id, user_id).first
        true
      else
        false
      end
    end
  end

end
