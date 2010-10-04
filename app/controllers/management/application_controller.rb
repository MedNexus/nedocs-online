class Management::ApplicationController < ApplicationController
  layout 'application'
  before_filter :check_admin_rights
  
  def check_admin_rights
    unless session[:user_is_superuser]
      flash[:error] = "You must be an admin to access this area"
      redirect_to :controller => "/nedocs", :action => "index"
    end
  end
  
  def create_csv_file(nedocs)
    require 'csv'
    
    datestr = Time.now.strftime("%Y%m%d-%H%M%S")
    csvname = "#{RAILS_ROOT}/tmp/#{datestr}-#{Process.pid}.csv"
    
    csvData = File.open(csvname, 'w')
    CSV::Writer.generate(csvData, ',') do |csv|
      labels = [ 'created', 'created timestamp', 'nedocs score', 'longest_admit', 'last patient wait', 'total ed patients', 'number of hospital beds', 'number ed beds', 'total admits', 'total respirators', 'user name' ]
      csv << labels
      
      nedocs.each do |n|
        row = [ gm_to_local(n.created_at).strftime('%a %b %d, %Y') + ' at ' +
          gm_to_local(n.created_at).strftime('%I:%M%p').downcase, n.created_at.to_i, n.nedocs_score, n.longest_admit, n.last_patient_wait, n.total_patients_ed, n.number_hospital_beds, n.number_ed_beds, n.total_admits, n.total_respirators, n.user.username ]

        csv << row
      end
    end
    csvData.close
    
    csvname
  end
end
