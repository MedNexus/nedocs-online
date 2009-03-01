class Management::AdminController < Management::ApplicationController
  skip_after_filter  :compress_output, :only => [ :download_csv ]  
  
  def index
  end
  
  def download_csv
    @nedocs = Nedoc.find(:all, :order => 'created_at ASC', :include => [:user])
    
    # trap exception when /tmp folder cannot be written to
    begin
      filename = create_csv_file(@nedocs)
    rescue Exception => e
      log_error(e)
      flash[:error] = "There was an error generating your CSV file. Please try again later."
      redirect_to :action => :index
      return false
    end
    
    send_file filename,
              :filename => File.basename(filename),
              :disposition => "attachment",
              :type => "text/csv"
  end
  
end