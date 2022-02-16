class RemoveInvoiceNoteFromClientEnrollment < ActiveRecord::Migration[6.1]
  def change
    remove_column :client_enrollments, :top_invoice_note, :text
    remove_column :client_enrollments, :bottom_invoice_note, :text
  end
end
