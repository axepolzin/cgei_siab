class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :properties, :property_class, :property_type
  end
end
