class AddIsManualRenderInScheudling < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :is_manual_render, :boolean, default: false
  end
end
