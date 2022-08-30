class AttachmentCategoriesController < ApplicationController
  before_action :authenticate_user!
  def index
    @attachment_categories = AttachmentCategory.all.sort_by(&:name)
  end

  def create
    @attachment_category = AttachmentCategory.new(attachment_category_params)

    if @attachment_category.valid?
      @attachment_category.save!
    else
      unprosessable_entity_response(@attachment_category)
    end
  end

  private

  def attachment_category_params
    params.permit(:name)
  end
end
