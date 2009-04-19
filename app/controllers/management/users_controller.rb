class Management::UsersController < Management::ApplicationController

  def index
    # display user list
    @users_active = User.list
    @users_inactive =  User.list_inactive
    @item = User.new
  end
  
  def edit
    @item = User.find_by_id(params[:id])
    render :update do |page|
      page.replace_html "user_id_#{@item.id}", :partial => 'form'
      page.visual_effect :toggle_blind, "user_id_#{@item.id}", { :duration => '.25' }
    end
  end
  
  def update
    @item = User.find_by_id(params[:id])
    @item.attributes = params[:item]
    
    if @item.save
      @notice = "User <b>#{@item.username.upcase}</b> Successfully Updated"
    else
      @error = @item.errors.full_messages.uniq.join("<br/>")
    end
    
    render :update do |page|
      if @error
        page.replace_html "user_id_#{@item.id}", :partial => 'form'
      else
        page.replace_html "divNotification", @notice
        page.visual_effect :blind_up, "user_id_#{@item.id}", { :duration => '.25' }
        page.replace_html "listView", :partial => "user_list"
      end
    end
  end
  
  def new
    @item = User.new(params[:item])
    if @item.save
      @notice = "User <b>#{@item.username.upcase}</b> Successfully Created"
      @item = User.new
    else
      @error = @item.errors.full_messages.uniq.join("<br/>")
    end
    
    render :update do |page|
      page.replace_html "divCreateUserForm", :partial => 'form'
      page.replace_html "listView", :partial => "user_list"
    end
    
  end
  
  def destroy
    @item = User.find_by_id(params[:id])
  
    destroy = false
    if User.count(:all, :conditions => ["active = 1 and is_superuser = 1"]) <= 1
      @notice = "Cannot delete the last admin user"
    elsif
      @notice = "User #{@item.username.upcase} Deleted"
      destroy = @item.destroy
    end

    render :update do |page|
      page.replace_html "divNotification", @notice if @item.destroy
      page.replace_html "listView", :partial => "user_list"
    end
  end
  

end