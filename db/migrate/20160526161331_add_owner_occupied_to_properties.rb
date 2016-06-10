class AddOwnerOccupiedToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :owner_occupied, :string

    @properties = Property.all
    @count = 1

    @properties.each do |occupancy|
      #look up tax address in Owner and return id
      #unless Owner.find_by(formatted_tax_address: @properties.find(@count).formatted_tax_address) == nil
      # @properties.find(@count).owner_id == nil || @properties.find(@count).owner_id == ""
      if @properties.find(@count).owner_id == nil || @properties.find(@count).owner_id == ""
        @count += 1
      elsif @properties.find(@count).address_formatted == Owner.find(@properties.find(@count).owner_id).formatted_tax_address then
        occupancy.update_attributes(:owner_occupied => "true")
        @count += 1
      else
        occupancy.update_attributes(:owner_occupied => "false")
        @count += 1

      end

    end


  end
end
