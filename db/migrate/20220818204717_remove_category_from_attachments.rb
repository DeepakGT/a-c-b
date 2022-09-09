class RemoveCategoryFromAttachments < ActiveRecord::Migration[6.1]
  def change
    remove_column :attachments, :category
  end
end
