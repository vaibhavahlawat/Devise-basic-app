class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  @@anonymous_user = nil
  def anonymous?
    self == User.anonymous
  end

  def self.find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(login) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
  end

  def self.anonymous(reload=false)
    @@anonymous_user = nil if reload
    if @@anonymous_user
      @@anonymous_user
    else
      anonymous_user = User.find_or_create_by_login(
        :login                 => "anonymous",
        #:first_name            => "Anonymous",
        #:last_name             => "User",
        :email                 => "anonymous@concord.org",
        :password              => "password",
        :password_confirmation => "password")
      
      #anonymous_user.add_role('guest')
      @@anonymous_user = anonymous_user
    end
  end

end
