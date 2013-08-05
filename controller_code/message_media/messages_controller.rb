class Marketing::MessageMedia::MessagesController < Marketing::MarketingBaseController

  before_filter :enabled_templates, only: [:new, :create, :edit, :update]
  before_filter :find_message, only: [:edit, :update, :destroy, :send_sms]
  
  def initialize
    @klass_associate_template = :marketing_message_media_templates
  end
  
  def index
    @messages = current_user.message_media_messages.paginate(page: params[:message_media_messages_page], per_page: 10,
                                              total_entries: current_user.message_media_messages.length)
  end

  def new
    @message = current_user.message_media_messages.build
  end
  
  def create 
    params[:marketing_message_media_message][:body] = "" unless params[:marketing_message_media_message][:template_id].blank?
    @message = current_user.message_media_messages.build(params[:marketing_message_media_message])
    if @message.save
      if params[:send_message_media_message] == "send"
        @error_msg = "Successfully created but not sent because any of your receiver does not have phone number."
        send_sms_to_receiver
      else    
        flash[:notice] = "Successfully created."
        redirect_to action: 'index', message_media_messages_page: params[:message_media_messages_page], status: 303
      end
    else
      error_msg = @message.errors.full_messages.blank? ? "Not created." : @message.errors.full_messages.first
      flash.now[:error] = error_msg
      render action: 'new', status: 303
    end
  end
  
  def edit
    unless @message
      flash[:error] = "You do not have permission to edit message."
      redirect_to action: :index, message_media_messages_page: params[:message_media_messages_page], status: 303
    end
  end
  
  def update 
    params[:marketing_message_media_message][:body] = "" unless params[:marketing_message_media_message][:template_id].blank?
      if @message.sent.blank? && @message.update_attributes(params[:marketing_message_media_message])
        if params[:send_message_media_message] == "send"
          @error_msg = "Successfully updated but not sent because any of your receiver does not have phone number."
          send_sms_to_receiver
        else    
          flash[:notice] = "Successfully updated."
          redirect_to action: :index, message_media_messages_page: params[:message_media_messages_page], status: 303
        end
      else
        error_msg = @message.errors.full_messages.blank? ? "Not created." : @message.errors.full_messages.first
        flash.now[:error] = error_msg
        render 'edit', status: 303
      end
    end
    
    def send_sms 
      @error_msg = "Not sent because any of your receiver does not have phone number."
      send_sms_to_receiver
    end
  
  def destroy
    if @message.try(:destroy)
      flash[:notice] = "Successfully deleted."
    else
      flash[:error] = "Not deleted."
    end
    redirect_to action: 'index', message_media_messages_page: params[:message_media_messages_page], status: 303
  end

  private
  
  def send_sms_to_receiver
    unless @message.receiver_numbers.blank?
      result = @message.send_sms
      if @message.reload.sent.present? && result 
        flash[:notice] = "SMS sent successfully."
      else
       flash[:error] = result.message || "Something is wrong with your sms sending."
      end
      redirect_to action: 'index', message_media_messages_page: params[:message_media_messages_page], status: 303
    else
      flash[:error] = @error_msg
      redirect_to action: 'index', status: 303
    end
  end
  
  def find_message
    @message = current_user.message_media_messages.where(id: params[:id]).first
  end

end
