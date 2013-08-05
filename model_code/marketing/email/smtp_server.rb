class Marketing::Email::SmtpServer < ActiveRecord::Base
  include Marketing::Email::MailServerStereotype
  include OwnedStereotype

  attr_accessor :password

  attr_encrypted :password, key:APP_CONFIG['encryption_key'], attribute:'crypted_password'

  attr_accessible :host, :owner_id, :ownership_id, :password, :port, :ssl, :username,
                  :address, :membership_id
  
  # Associations
  belongs_to :membership, :class_name => "Marketing::Membership"
  belongs_to :user, :foreign_key => :owner_id,:class_name => "Usage::User"

end
