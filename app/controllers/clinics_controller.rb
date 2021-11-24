class ClinicsController < ApplicationController

  def index
    @clinics = Clinic.all.order(:name).paginate(page: params[:page])
  end

end
