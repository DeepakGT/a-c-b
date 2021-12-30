class ClinicsController < ApplicationController
  before_action :authenticate_user!

  def index
    @clinics = Clinic.order(:name).paginate(page: params[:page])
  end
end
