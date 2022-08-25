class AttachmentCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attachment_category, only: %i[show update destroy]


  def index
    @attachment_categories = AttachmentCategory.all_active_categories
  end

  def show
    @attachment_category
  end

  def create
    @attachment_category = AttachmentCategory.new(attachment_category_params)

    if @attachment_category.valid?
      @attachment_category.save!
    else
      unprosessable_entity_response(@attachment_category)
    end
  end

  def update
    if @attachment_category.update(attachment_category_params)
      @attachment_category
    else
      unprosessable_entity_response(@attachment_category)
    end
  end

  def destroy
    @attachment_category.update(delete_status: true) if current_user.role_name == "super_admin"
  end

  private

  def set_attachment_category
    @attachment_category = AttachmentCategory.find(params[:id])
  end

  def attachment_category_params
    params.permit(:name)
  end
end
