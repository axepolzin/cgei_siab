class Property < ActiveRecord::Base
  #belongs_to :taxpayer, :class_name => Taxpayer, :foreign_key => "taxpayer_id"
  validates :pin, :presence => true, :uniqueness => true


belongs_to :owner, :class_name => "Owner", :foreign_key => "owner_id"
end

#class Taxpayer < ActiveRecord::Base
#  has_many :properties, :class_name => Property, :foreign_key => "property_id"
#end
