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
    Setting.time_zone                 = params[:setting][:time_zone]
    session[:time_zone]               = params[:setting][:time_zone]
    
    Setting.level_0_instructions      = params[:setting][:level_0_instructions]
    Setting.level_1_instructions      = params[:setting][:level_1_instructions]
    Setting.level_2_instructions      = params[:setting][:level_2_instructions]
    Setting.level_3_instructions      = params[:setting][:level_3_instructions]
    Setting.level_4_instructions      = params[:setting][:level_4_instructions]    
    Setting.level_5_instructions      = params[:setting][:level_5_instructions]
     
    flash[:notice] = "Settings Updated"
    redirect_to :controller => "/management/admin"
  end
  
end
