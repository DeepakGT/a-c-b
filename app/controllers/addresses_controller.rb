class AddressesController < ApplicationController
  before_action :authenticate_user!

  def country_list
    countries = Country.order(:name)
    prioritize_country = Country.find_by(name: "United States of America")
    countries = countries.to_a.prepend(prioritize_country)
    @countries = countries.uniq.compact
  end
end
