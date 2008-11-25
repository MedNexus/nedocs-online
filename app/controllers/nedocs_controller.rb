class NedocsController < ApplicationController
  before_filter :latest_nedocs_score
  before_filter :login_required, :only => ['new']
  
  def index
    @user = authenticate_user
  end
  
  def latest_nedocs_score
    @nedoc = Nedoc.find(:first, :order => "created_at DESC")
  end
  
  def new
    @item = Nedoc.new(params[:item])
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
  
end
