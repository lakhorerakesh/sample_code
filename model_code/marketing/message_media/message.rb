class Marketing::MessageMedia::Message < ActiveRecord::Base

  include Marketing::MessageStereotype
  include ActionView::Helpers::SanitizeHelper
  
  attr_accessible :body, :failed_attempts, :profile_id, :connection_id,
                  :recipient, :sender_id, :sent, :template_id, :user_id

  belongs_to :template
  belongs_to :crm_connection, :class_name => "Crm::Connection", :foreign_key => :connection_id
  belongs_to :profile, :class_name => "Usage::Profile"
  belongs_to :sender, :class_name => "Usage::User"
  belongs_to :user, :foreign_key => :user_id,:class_name => "Usage::User"
    
  validates :recipient, numericality: { only_integer: true }, length: { minimum: 10, maximum: 15 }, allow_blank: true
  
  def send_sms 
    message_body = get_message_content
    begin
      twilio_client = Twilio::REST::Client.new APP_CONFIG['twilio_sid'], APP_CONFIG['twilio_token']
      self.receiver_numbers.each do |number|
        twilio_client.account.sms.messages.create( 
          :from => APP_CONFIG['twilio_phone_number'],
          :to => number,
          :body => strip_tags(message_body).to_s.gsub("&nbsp;", "").gsub(/\r\n?/, "").try(:strip)
        )
      end
      self.sent = Time.now
      self.save!
    rescue Exception => e
      Rails.logger.error e.inspect
      return e
    end
  end
end
