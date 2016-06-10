class AddOwnerIdToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :owner_id, :integer

    @properties = Property.all
    @count = 1
    @properties.each do |id|
      #look up tax address in Owner and return id
      unless Owner.find_by(formatted_tax_address: @properties.find(@count).formatted_tax_address) == nil
      @id = Owner.find_by(formatted_tax_address: @properties.find(@count).formatted_tax_address).id

      id.update_attributes(:owner_id => @id)

      end
      @count += 1
    end

  end
end
