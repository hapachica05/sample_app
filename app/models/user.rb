# == Schema Information
# Schema version: 20110310224748
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  attr_accessor :password   
  # creates a virtual attribute
  
  attr_accessible :name, :email, :password, :password_confirmation
  # list of accessible attributes
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, :presence => true,
                   :length => { :maximum => 50 }
  
  validates :email, :presence => true,
                    :format => { :with => email_regex },
		    :uniqueness => { :case_sensitive => false}
  
  validates :password, :presence => true,
                       :confirmation => true,
		       # creates a virtual password_confirmation attribute
		       # confirms the password and confirmation match
		       :length => { :within => 6..40}

  before_save :encrypt_password
  # before saving, registering a callback entitled "encrypt_password"
  
  # return true if the user's password matches the submitted password
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
  # defining the class method "self.authenticate"
    user = find_by_email(email)
    # selecting the user which possesses the email entered
    return nil if user.nil?
    # return nothing if no user matches the entered email address
    return user if user.has_password?(submitted_password)
    # return the user if the password enters the submitted password
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    # finds the user by unique id
    (user && user.salt == cookie_salt) ? user : nil
    # returns the user if user is not nil and the user salt matches
    # the cookie's salt
  end
  
  private
    
    def encrypt_password
      self.salt = make_salt if new_record?
      # creates a salt once user is first created
      self.encrypted_password = encrypt(password)
      # encrytpted_password variable = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
      # encrypt method (password) = secure_hash (salt + password)
    end

    def make_salt 
      secure_hash("#{Time.now.utc}--#{password}")
      # make_salt variable = secure_hash (timestamp + password)
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
