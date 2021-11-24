# Staff is just an aliased for Users i.e. staff are nothing but users
# so User model itself using as staff
class StaffController < ApplicationController
  include PaginationDictConcern
  before_action :set_clinic

  def index
    staff = @clinic.staff.order(:first_name).paginate(page: 1, per_page: 30)
    render json: staff, meta: pagination_dict(staff), root: :data, adapter: :json, each_serializer: StaffSerializer
  end

  def show
    staff = @clinic.staff.find(params[:id])
    render json: staff, serializer: CompleteStaffSerializer
  end

  private

  def set_clinic
    @clinic = Clinic.find(params[:clinic_id])
  end

  # end of private
end
