class CreateRegions < ActiveRecord::Migration[6.1]
  def change
    create_table :regions do |t|
      t.string :name
      t.timestamps
    end

    add_column :organizations, :id_regions, :jsonb, default: []

    add_reference :clinics, :region, foreign_key: true
    change_column_null :clinics, :region_id, true
  end
end
