class Email < Mailer
  
  def score_update(nedoc, template, addresses)
    # recipients  "noreply@harbor.nedocsonline.org"
    from        Setting.hospital_email_address
    subject     Master::Hospital.find_by_key(ENV["RAILS_HOSPITAL"]).name + " NEDOCS Alert: " + nedoc.nedocs_score.to_s
    bcc         addresses
    
    # Email body substitutions go here
    @body = template.content(nedoc.level)
    
    # Do Substitutions
    @body.gsub!("[HOSPITAL]", Master::Hospital.find_by_key(ENV["RAILS_HOSPITAL"]).name)
    @body.gsub!("[USER]", nedoc.user.username.upcase)
    @body.gsub!("[SCORE]", nedoc.nedocs_score.to_s)
    @body.gsub!("[SCORE_LEVEL]", nedoc.message)
    @body.gsub!("[DATE]", nedoc.created_at.strftime('%a %b %d, %Y'))
  end
  
end
