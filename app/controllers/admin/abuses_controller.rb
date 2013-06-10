class Admin::AbusesController < ApplicationController
  unloadable
  
  def index
    @banned = Authorizable::Abuse.banned.order('created_at desc')
  end
  
  def unban
    @abuse = Authorizable::Abuse.find params[:id]
    @abuse.unban!
    flash[:notice] = "#{abuse.ip_address} unbanned."
    redirect_to [:admin, :abuses]
  end
end