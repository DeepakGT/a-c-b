class ClinicsController < ApplicationController

  def index
    @clinics = Clinic.all.order(:name).paginate(page: 1)
  end

end
