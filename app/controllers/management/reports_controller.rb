class Management::ReportsController < Management::ApplicationController
  
  
  def index
    # if there are no scores avail, redirect to management screen
    unless Nedoc.find(:first)
      flash[:error] = 'There is no NEDOCS data with which to generate reports'
      redirect_to :controller => "/management/admin", :action => "index"
    end
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
  
  def historic_graph
    render :action => 'index'
  end
  
  def scores_time_day
  end

end
