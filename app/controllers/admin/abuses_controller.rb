class Admin::AbusesController < ApplicationController
  unloadable
  
  def index
    @banned = Authorizable::Abuse.banned.order('created_at desc')
  end
end