class Email < Mailer
  
  def score_update(nedoc)
    recipients  nedoc.notify_list(true)
    from        Setting.hospital_email_address
    subject     Master::Hospital.find_by_key(ENV["RAILS_HOSPITAL"]).name + " NEDOCS Score Alert: " + nedoc.nedocs_score.to_s
    
    # Email body substitutions go here
    @body['score']  = nedoc.nedocs_score.to_s
    @body['user']   = nedoc.user.username
    @body['time']   = TimeZone.new(Setting.time_zone).local_to_utc(nedoc.created_at).strftime("%d %b %I:%M%p")
  end
  
end
