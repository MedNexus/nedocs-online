class NedocsController < ApplicationController
  skip_before_filter :authenticate_user, :only => ['graph_latest']
  before_filter :latest_nedocs_score
  skip_after_filter :compress_output, :only => ['graph_latest']
  
  def index
    @item = Nedoc.new()
    # set defaults
    @item.number_hospital_beds = Setting.number_of_hospital_beds
    @item.number_ed_beds = Setting.number_of_ed_beds
    
  end
  
  def latest_nedocs_score
    @nedoc = Nedoc.latest
    unless @nedoc.nedocs_score
      @nedoc.calc_score
    end
  end
  
  def new
    @item = Nedoc.new(params[:item])
    @item.user = @user
    @error = @item.errors.full_messages.uniq.join('<br/>') unless @item.valid?
    
    # need to add confirmation
    begin
      @item.calc_score
    rescue
      @error +=  "<br/>There was an error calculating the score, please try again<br/>"
    end
    
    # unless we already have an error, continue
    unless @error
      
      if @item.notify_list.size > 0 and !params[:confirm]
        # we have to warn the user we're gonna email
        @notice = "The following people " +
                  "will be notified of this score update:<br/><ul><li>" + @item.notify_list.collect{ |x| x.name }.join("</li><li>")
        @notice += "</li></ul>"
        
        # display with confirmation option
        render :update do |page|
          page.replace_html 'updateForm', :partial => 'confirm_form'
          page.visual_effect :highlight, 'formCard', {:duration => '.5' }
        end
      
        return
      end
    
      if @item.save then
        @item.calc_score
        @notice = "NEDOCS Score: #{@item.nedocs_score}"
        
        # blank out nedocs score object
        @item = Nedoc.new
        saved = true
      else
        @error = @item.errors.full_messages.uniq.join('<br/>')
        saved = false
      end
    end
    
    latest_nedocs_score
    
    render :update do |page|
      page.replace_html 'updateForm', :partial => 'form'
      page.replace_html 'graph', :partial => 'graph'
      page.visual_effect :highlight, 'graphCard', {:duration => '1' } if saved
    end
  end
  
  def graph_latest
    @nedoc = Nedoc.latest
    send_file @nedoc.image,
        :filename => "nedocs_graph.jpg",
        :disposition => 'inline',
        :type => "image/jpg"
  end
  
end
