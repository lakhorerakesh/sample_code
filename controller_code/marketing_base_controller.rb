class Marketing::MarketingBaseController < ApplicationController
  before_filter :require_login, :has_membership
  before_filter :restrict_for_enable_false
  
  def links
    @container_to_be_replaced = '#main-container > div'
  end

  private
  
  def has_membership
    membership = current_user.marketing_membership
    if membership.blank?
      permission_denied
    end
  end
    
  def enabled_templates
    templates = current_user.try(@klass_associate_template)
    @templates = templates.where(enabled: true)
  end
  
end
