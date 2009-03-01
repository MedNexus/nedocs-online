require 'digest/sha1'

class User < ActiveRecord::Base

  attr_reader :password
  
  validates_presence_of [ :username, :password, :first_name, :last_name ], :message => 'is required'
  validates_length_of :password, :minimum => 4
  validates_uniqueness_of :username, :message => 'already in use'
  validates_confirmation_of :password
  validates_uniqueness_of :first_name, :scope => [:last_name, :active]
  
  has_one :email_template
  belongs_to :email_template
  
  def name ; [self.first_name, self.last_name].compact.join(" ") ; end
  
  SaltLength = 16 # :nodoc:
  
  def self.authenticate(login,pass)
    u=find(:first, :conditions=> ["username = ?", login])
    return nil if u.nil?
    return u if User.hash_password(pass) == u.password_hash
    nil
  end
  
  
  def password=(val) # :nodoc:
    @password = val
    self.password_hash = User.hash_password(val) if (val ||= "") != ""
  end
  
  def self.hash_password(val, salt = '') # :nodoc:
    # create the salt if we need to
    if salt.length != SaltLength
      salt = ''
      allowed_chars = (('a'..'f').to_a).concat(('0'..'9').to_a)
      SaltLength.times do
        salt << allowed_chars[rand(allowed_chars.length)]
      end
    end
    
    # now, let the hashing begin
    digest = Digest::SHA1.new
    digest << salt << val
    salt << digest.hexdigest
  end
  
  def before_validation_on_update # :nodoc:
    # if password is blank, user is not trying to change it.
    # just appease the validator by setting something valid
    if ((@password ||= "") == "")
      @password = "imapassword" 
      @password_confirmation = "imapassword" 
    end
  end
  
  def archive!
    self.update_attribute(:active, 0)
  end
  
  def restore!
    self.update_attribute(:active, 1)
  end
  
  def name
    return self.first_name + " " + self.last_name
  end
    
  def is_superuser?
    return (self.is_superuser == 1)
  end
  
  def send_notification?
    return (self.send_notifications == 1)
  end
  
  def self.list
    User.find(:all, :conditions => [ "active = 1" ], :order => 'last_name, first_name, username')
  end
  
  def self.list_inactive
    User.find(:all, :conditions => [ "active = 0" ], :order => 'last_name, first_name, username')
  end
  
end

