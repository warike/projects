class User < ActiveRecord::Base
 before_save :set_default_role
 include Gravtastic
 gravtastic
 validates :email, uniqueness: true
 #  Un usuario puede seguir otro usuario
 #  acts_as_followable
 acts_as_follower

  
  before_save :set_default_role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
 devise :invitable, :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,:omniauth_providers => [:linkedin, :twitter]

 has_many :startups
 has_many :reviews
 has_many :members
 
 ROLES = %w[admin moderator author banned]
 

  def self.startups_by_member(id,deleted=false)
    (deleted)? Startup.joins(:members).where('members.user_id' => id) : Startup.joins(:members).where('members.user_id = :user_id AND startups.status != :status',{user_id: id, status: Startup::STATUS_DELETED})
  end 
  
  def set_default_role
    if self.new_record?
      self.role="author"
    end
  end


    def self.connect_to_linkedin(auth, signed_in_resource=nil)
      user = User.where(:provider => auth.provider, :uid => auth.uid).first
      if user
        return user
      else
        registered_user = User.where(:email => auth.info.email).first
        if registered_user
          return registered_user
        else
          user = User.create(username:auth.info.first_name,
                             lastname:auth.info.last_name,
                              provider:auth.provider,
                              uid:auth.uid,
                              email:auth.info.email,
                              password:Devise.friendly_token[0,20],
                            )
        end
      end
    end

   def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
     user = User.where(:provider => auth.provider, :uid => auth.uid).first
     if user
       return user
     else
       registered_user = User.where(:email => auth.uid + "@twitter.com").first
       if registered_user
         return registered_user
       else

         user = User.create(username:auth.extra.raw_info.name,
                                name:auth.extra.raw_info.name,
                                provider:auth.provider,
                                uid:auth.uid,
                                email:auth.uid+"@twitter.com",
                                password:Devise.friendly_token[0,20],
         )
       end

     end
   end

   def password_required?
     super && provider.blank?
   end

end
