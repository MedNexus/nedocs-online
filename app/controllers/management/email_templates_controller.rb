class Management::EmailTemplatesController < Management::ApplicationController
  
  def index
    @item = EmailTemplate.new
  end

  def edit
    @item = EmailTemplate.find_by_id(params[:id])
    render :update do |page|
      page.replace_html "template_id_#{@item.id}", :partial => 'form'
      page.visual_effect :toggle_blind, "template_id_#{@item.id}", { :duration => '.25' }
    end
  end
  
  def update
    @item = EmailTemplate.find_by_id(params[:id])
    @item.attributes = params[:item]
    
    if @item.save
      @notice = "Template <b>#{@item.name.upcase}</b> Successfully Updated"
    else
      @error = @item.errors.full_messages.uniq.join("<br/>")
    end
    
    render :update do |page|
      if @error
        page.replace_html "template_id_#{@item.id}", :partial => 'form'
      else
        page.replace_html "divNotification", @notice
        page.visual_effect :blind_up, "template_id_#{@item.id}", { :duration => '.25' }
        page.replace_html "listView", :partial => "template_list"
      end
    end
  end
  
  def new
    @item = EmailTemplate.new(params[:item])
    if @item.save
      @notice = "Template <b>#{@item.name.upcase}</b> Successfully Created"
      @item = EmailTemplate.new
    else
      @error = @item.errors.full_messages.uniq.join("<br/>")
    end
    
    render :update do |page|
      page.replace_html "divCreateUserForm", :partial => 'form'
      page.replace_html "listView", :partial => "template_list"
    end
    
  end
  
  def destroy
    @item = EmailTemplate.find_by_id(params[:id])
    @notice = "Template #{@item.name.upcase} Deleted"

    render :update do |page|
      page.replace_html "divNotification", @notice if @item.destroy
      page.replace_html "listView", :partial => "template_list"
    end
  end
  
end