class Email < Mailer
  
  def score_update(nedoc, user)
    recipients  client.email_address
    from        Setting.studio_email_address
    subject     subject
    
    # Email body substitutions go here
    @body['message'] = body
    
    client.add_note("Email sent to #{client.email_address}: (#{subject}) #{body}", user)
    
  end
  
end
