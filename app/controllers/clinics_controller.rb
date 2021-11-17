class ClinicsController < ApplicationController

  def index
    @clinics = Clinic.all.order(:name)
    render json: @clinics
  end

end
