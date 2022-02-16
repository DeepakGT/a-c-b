class CreateAttachments < ActiveRecord::Migration[6.1]
  def change
    create_table :attachments do |t|
      t.string :category
      t.references :attachable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
