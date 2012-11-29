require 'spec_helper'
require 'makeadd'

describe Airport_Reader do

	# let(:a) { Airport_Reader.new }
	
	before do
		@ar = Airport_Reader.new
		@ar.read_file
	end

	it { should respond_to(:input, :output, :lines, :a_ports)}

	it "should have an input that contains only (XXX) lines" do
		@ar.input.each { |l|
			l.index(/\(.{3}\)/).should be > 5
		}
	end

	it "should be able to delineate the addy" do
		@ar.a_ports = Hash.new
		h = @ar.break_addy("Albany, OR Bus service (CVO)")
		h.city.should eq("Albany")
		h.extra.should eq("Bus service")
		h.state.should eq("OR")
		h.code.should eq("CVO")
	end

	it "should write to the output file" do
		
	end

end

describe Airport do

	let(:air) { Airport.new(:code => "CVO",
	 :city => "Albany",
	 :state => "OR",
	 :extra => "Bus service")}

	it { should respond_to( :code, :city, :state, :extra )}


end
