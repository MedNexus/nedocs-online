class Email < Mailer
  
  def score_update(nedoc)
    # recipients  "noreply@harbor.nedocsonline.org"
    from        Setting.hospital_email_address
    subject     Master::Hospital.find_by_key(ENV["RAILS_HOSPITAL"]).name + " NEDOCS Score Alert: " + nedoc.nedocs_score.to_s
    bcc         nedoc.notify_list(true)
    
    # Email body substitutions go here
    @body['score']  = nedoc.nedocs_score.to_s
    @body['user']   = nedoc.user.username
  end
  
end
