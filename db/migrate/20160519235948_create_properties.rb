class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :pin
      t.float :lat
      t.float :long
      t.string :address
      t.string :address_number 
      t.string :address_rose
      t.string :address_street
      t.string :address_suffix
      t.string :address_formatted
      t.string :city
      t.string :township
      t.string :zip
      t.string :property_class
      t.string :name
      t.string :tax_address
      t.string :tax_street_number
      t.string :tax_street_rose
      t.string :tax_street_name
      t.string :tax_street_suffix
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
