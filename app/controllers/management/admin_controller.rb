class Management::AdminController < Management::ApplicationController
  skip_after_filter  :compress_output, :only => [ :download_csv ]  
  
  def index
  end
  
  def download_csv
    @nedocs = Nedoc.find(:all, :order => 'created_at ASC')
    filename = create_csv_file(@nedocs)
    send_file filename,
              :filename => File.basename(filename),
              :disposition => "attachment",
              :type => "text/csv"
  end
  
end