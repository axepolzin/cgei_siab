require 'csv'

namespace :import do
  desc "Import users from CSV"
  task properties: :environment do


    CSV.foreach("#{Rails.root}/db/data/hyde_park_complete.csv", headers: true) do |row|
      unless Property.find_by(pin: row[0]).present?
        Property.create(
        pin: row[0],
        lat: row[1],
        long: row[2],
        address: row[3],
        address_formatted: row[8],
        city: row[9],
        township: row[10],
        zip: row[11],
        property_class: row[12],
        name: row[13],
        tax_city: row[19],
        tax_zip: row[21],
        formatted_tax_address: row[22],
        )
      end

    end
    puts "There are #{Property.count} lots in the database."


  end
  desc "Import owners from CSV"
  task owners: :environment do


    CSV.foreach("#{Rails.root}/db/data/hyde_park_complete.csv", headers: true) do |row|
      unless Owner.find_by(formatted_tax_address: row[22]).present?
        Owner.create(
        tax_city: row[19],
        tax_state: row[20],
        tax_zip: row[21],
        formatted_tax_address: row[22],
        tax_lat: row[23],
        tax_long: row[24]
        )
      end

    end
    puts "There are #{Owner.count} lots in the database."
  end


end
