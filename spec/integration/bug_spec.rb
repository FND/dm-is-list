require 'spec_helper'

describe "DataMapper::Is::List bug" do

  supported_by :in_memory, :yaml, :sqlite, :postgres, :mysql, :oracle, :sqlserver do

    before do
      DataMapper.auto_migrate!
      DataMapper::Model.descendants.each { |model| model.destroy! }
      5.times do |i|
        Animal.create
      end
    end

    describe "move :below bug" do

      it "should not fail on initial move :below" do
        steps = []

        steps << {
          :order => Animal.all(:order => :position.asc).map(&:id).join(",")
        }

        steps << {
          :status => Animal.get!(5).move(:below => Animal.get!(3)),
          :order => Animal.all(:order => :position.asc).map(&:id).join(",")
        }

        steps << {
          :status => Animal.get!(5).move(:above => Animal.get!(3)),
          :order => Animal.all(:order => :position.asc).map(&:id).join(",")
        }

        steps << {
          :status => Animal.get!(5).move(:below => Animal.get!(3)),
          :order => Animal.all(:order => :position.asc).map(&:id).join(",")
        }

        steps[2][:status].should == true
        steps[3][:status].should == true

        steps[0][:order].should == "1,2,3,4,5"
        steps[2][:order].should == "1,2,5,3,4"
        steps[3][:order].should == "1,2,3,5,4"

        # failing
        steps[1][:status].should == true
        steps[1][:order].should == "1,2,3,5,4"

      end

    end

  end

end
