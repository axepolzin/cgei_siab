class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :tax_city
      t.string :tax_state
      t.string :tax_zip
      t.string :formatted_tax_address
      t.float :tax_lat
      t.float :tax_long

      t.timestamps null: false
    end
  end
end
