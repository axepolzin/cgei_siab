class MapController < ApplicationController

  def index
    @properties = Property.all
    render("index.html.erb")
  end

  def about
    render("about.html.erb")
  end

  def display
    @properties = Property.all
    render("display.html.erb")
  end

  def notaxaddress
    @properties1 = Property.all
    @properties1 = @properties1.where.not(address_formatted: "")

    @vacancies = @properties1.where(formatted_tax_address: "")
    @vacancy_count = @vacancies.count
    @vacancy_ratio = (@vacancy_count.to_f / @properties1.count.to_f * 100).round(2)
    #Property.store(:rentvown, @rentvown)
    render("notaxaddress.html.erb")
  end

  def rentvown
    @properties = Property.all
    @owned = @properties.where(owner_occupied: "true")
    @rented = @properties.where(owner_occupied: "false")
    @notax = @properties.where(owner_occupied: nil )

    @rentratio = ((@owned.count.to_f / (@owned.count + @rented.count)) * 100).round(2)


    render("rentvown.html.erb")
  end

  def localorno
    @properties = Property.all
    @notaxaddress = @properties.where(formatted_tax_address: "")
    @rented = @properties.where(owner_occupied: "false")

    @local_zip = @rented.where(tax_zip: "60637")
    @local_chi = @rented.where(tax_city: "CHICAGO")
    @notlocal_zip = @rented.where.not(tax_zip: "60637")
    @notlocal_chi = @rented.where.not(tax_city: "CHICAGO")
    @percent_notlocal_zip = (@notlocal_zip.count.to_f / @rented.count.to_f * 100).round(2)
    @percent_notlocal_chi = (@notlocal_chi.count.to_f / @rented.count.to_f * 100).round(2)

    #this works: Property.find(1).owner.tax_zip but cant figure out how to get it to work with a where
    #Property.store(:rentvown, @rentvown)
    render("localorno.html.erb")
  end




  def count
    @properties = Property.all
    @properties.each do |count|

      @formatted_tax_address1 = Property.pluck(:formatted_tax_address)


      @dup = @formatted_tax_address1.select{|element| @formatted_tax_address1.count(element) > 1 }

      @counts = Hash.new 0

      @dup.each do |word|
        @counts[word] += 1
      end
      #can this be donw w group instead?
      #how to bring this back and display all related info?
      #@results = Property.where()tax_address = @counts
    end
    render("count.html.erb")
  end

  def count2
    @owners = Owner.all
    @properties = Property.all
#Property.group(:owner_id).count

    #how to bring this back and display all related info?
    #@results = Property.where()tax_address = @counts

    render("count2.html.erb")
  end



end
