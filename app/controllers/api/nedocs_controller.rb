class Api::NedocsController < ApplicationController
  
  session :off
  skip_before_filter :authenticate_user, :only => ['current_score']
  
  def current_score
    @nedoc = Nedoc.latest
    @plans = SurgePlan.find_plans_by_score(@nedoc.nedocs_score)
    render :nothing => true, :status => 404 and return unless @nedoc
    render :layout => false
  end
  
end