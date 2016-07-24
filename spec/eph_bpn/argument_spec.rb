require "spec_helper"
require "date"

describe EphBpn::Argument do
  context "#self.new(\"20160723125959\")" do
    let(:a) { EphBpn::Argument.new("20160723125959") }

    context "object" do
      it { expect(a).to be_an_instance_of(EphBpn::Argument) }
    end

    context ".get_tdb" do
      subject { a.get_tdb }
      it do
        expect(subject).to eq Time.new(2016, 7, 23, 12, 59, 59, "+00:00")
      end
    end
  end

  context "#date-time digit is wrong" do
    let(:a) { EphBpn::Argument.new("201607239") }

    context "object" do
      it { expect(a).to be_an_instance_of(EphBpn::Argument) }
    end

    context ".get_tdb" do
      subject { a.get_tdb }
      it { expect(subject).to be_nil }
    end
  end

  context "#invalid date-time" do
    let(:a) { EphBpn::Argument.new("20160732") }

    context "object" do
      it { expect(a).to be_an_instance_of(EphBpn::Argument) }
    end

    context ".get_tdb" do
      subject { a.get_tdb }
      it { expect(subject).to be_nil }
    end
  end
end

