class Management::SettingsController < Management::ApplicationController
  
  def index
    @setting = Setting
  end
  
  def update_settings
    Setting.hospital_email_address    = params[:setting][:hospital_email_address]
    Setting.public_display            = params[:setting][:public_display?]
    Setting.number_of_hospital_beds   = params[:setting][:number_of_hospital_beds]
    Setting.number_of_ed_beds         = params[:setting][:number_of_ed_beds]
    Setting.confirmation_threshold    = params[:setting][:confirmation_threshold]
    
    flash[:notice] = "Settings Updated"
    redirect_to :controller => "/management/admin"
  end
  
end
