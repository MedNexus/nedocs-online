class NedocsController < ApplicationController
  skip_before_filter :authenticate_user, :only => ['graph_latest']
  before_filter :latest_nedocs_score
  skip_after_filter :compress_output, :only => ['graph_latest']
  
  def index
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
    
    if @item.save then
      @item.calc_score
      @notice = "NEDOCS Score: #{@item.nedocs_score}"
      saved = true
    else
      @error = @item.errors.full_messages.uniq.join('<br/>')
      saved = false
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
