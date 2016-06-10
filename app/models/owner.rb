class Owner < ActiveRecord::Base
validates :formatted_tax_address, :presence => true, :uniqueness => true

has_many :properties, :class_name => "Property", :foreign_key => "owner_id"
end
