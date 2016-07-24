require "spec_helper"

describe EphBpn::Ephemeris do
  # 2016-07-23 00:00:00 +00:00 (TDB)
  let(:e) { EphBpn::Ephemeris.new(Time.new(2016, 7, 23, 0, 0, 0, "+00:00")) }

  context "#new(2016-07-23 00:00:00 +00:00)" do
    context "object" do
      it { expect(e).to be_an_instance_of(EphBpn::Ephemeris) }
    end

    context ".apply_bias" do
      it { expect(e.apply_bias([-0.50787065, 0.80728228, 0.34996714])).to match([
        be_within(1.0e-16).of(-0.5078706789483137 ),
        be_within(1.0e-16).of( 0.8072822556207571 ),
        be_within(1.0e-17).of( 0.34996715422685276)
      ]) }
    end

    context ".apply_prec" do
      it { expect(e.apply_prec([-0.5078706789483137, 0.8072822556207571, 0.34996715422685276])).to match([
        be_within(1.0e-16).of(-0.5114184398597698),
        be_within(1.0e-16).of( 0.8053953379861463),
        be_within(1.0e-16).of( 0.3491472536549302)
      ]) }
    end

    context ".apply_nut" do
      it { expect(e.apply_nut([-0.5114184398597698, 0.8053953379861463, 0.3491472536549302])).to match([
        be_within(1.0e-16).of(-0.5114184385245731),
        be_within(1.0e-16).of( 0.8053953403876852),
        be_within(1.0e-16).of( 0.3491472500709293)
      ]) }
    end
  end
end

