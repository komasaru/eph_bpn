require 'spec_helper'

describe EphBpn do
  it 'has a version number' do
    expect(EphBpn::VERSION).not_to be nil
  end

  # 2016-07-23 00:00:00 +00:00 (TDB)
  let(:e) { EphBpn::Ephemeris.new(Time.new(2016, 7, 23, 0, 0, 0, "+00:00")) }

  context "#new(2016-07-23 00:00:00 +00:00)" do
    context "object" do
      it { expect(e).to be_an_instance_of(EphBpn::Ephemeris) }
    end
  end
end
