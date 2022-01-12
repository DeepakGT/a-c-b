class AddressesController < ApplicationController
  before_action :authenticate_user!

  def country_list
    @countries = Country.order(:name)
  end
end
