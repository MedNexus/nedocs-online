class UserTemplates < HospitalMigration
  
  def self.up
    # add email_template_id to users table
    add_column :users, :email_template_id, :integer
    
    # create basic email template
    template_str = "The [HOSPITAL] NEDOCS score
has exceeded your notification threshold.

The current score is:

[SCORE]

Updated by [USER]"
    if EmailTemplate.find(:first)
      template = EmailTemplate.find(:first)
    else
      template = EmailTemplate.create(
        :name => "Basic Template",
        :content_0 => template_str,
        :content_1 => template_str,
        :content_2 => template_str,
        :content_3 => template_str,
        :content_4 => template_str,
        :content_5 => template_str)
    end
    
    # update all users to use basic email template
    execute "update users set email_template_id = #{template.id}"
  end
  
  def self.down
    remove_column :users, :email_template_id
  end
  
end