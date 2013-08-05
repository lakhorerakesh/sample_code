module Marketing::HasTemplateStereotype
  extend ActiveSupport::Concern

  included do
    before_save :infer_template_type
    belongs_to :template, polymorphic:true
  end

private

  # records: [email, email agent, phone dial, phone broadcast, sms, sms agent, letter]
  def infer_template_type
    self.template_type = Marketing::TemplateStereotype::template_type_for_task_type_id(task_type_id).to_s
  end

end