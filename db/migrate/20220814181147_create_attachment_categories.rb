class CreateAttachmentCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :attachment_categories do |t|
      t.string :name
      t.boolean :delete_status, default: false

      t.timestamps
    end

    add_column :attachments, :role_permissions, :jsonb, default: []
    add_reference :attachments, :attachment_category, null: true, foreign_key: true
  end
end
