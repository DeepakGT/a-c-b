class AddFilenameToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :attachments, :file_name, :string
  end
end
