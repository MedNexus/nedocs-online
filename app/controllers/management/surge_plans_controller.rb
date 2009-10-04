class Management::SurgePlansController < Management::ApplicationController
  def index
    @item = SurgePlan.new
  end
  
  def edit
    @item = SurgePlan.find_by_id(params[:id])
    render :update do |page|
      page.replace_html "surge_id_#{@item.id}", :partial => 'form'
      page.visual_effect :toggle_blind, "surge_id_#{@item.id}", { :duration => '.25' }
    end
  end
  
  def update
    @item = SurgePlan.find_by_id(params[:id])
    @item.attributes = params[:item]
    
    if @item.save
      @notice = "Surge Plan <b>#{@item.name.upcase}</b> Successfully Updated"
    else
      @error = @item.errors.full_messages.uniq.join("<br/>")
    end
    
    render :update do |page|
      if @error
        page.replace_html "surge_id_#{@item.id}", :partial => 'form'
      else
        page.replace_html "divNotification", @notice
        page.visual_effect :blind_up, "surge_id_#{@item.id}", { :duration => '.25' }
        page.replace_html "listView", :partial => "surge_list"
      end
    end
  end
  
  def new
    @item = SurgePlan.new(params[:item])
    if @item.save
      @notice = "Plan <b>#{@item.name.upcase}</b> Successfully Created"
      @item = SurgePlan.new
    else
      @error = @item.errors.full_messages.uniq.join("<br/>")
    end
    
    render :update do |page|
      page.replace_html "divCreateUserForm", :partial => 'form'
      page.replace_html "listView", :partial => "surge_list"
    end
    
  end
  
  def destroy
    @item = SurgePlan.find_by_id(params[:id])
  
    destroy = false
    @notice = "Plan #{@item.name.upcase} Deleted"
    destroy = @item.destroy

    render :update do |page|
      page.replace_html "divNotification", @notice if @item.destroy
      page.replace_html "listView", :partial => "surge_list"
    end
  end
  
end