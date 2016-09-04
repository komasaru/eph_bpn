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
        be_within(1.0e-15).of(-0.507870315369686  ),
        be_within(1.0e-16).of( 0.8072824634004779 ),
        be_within(1.0e-17).of( 0.34996720255697145)
      ]) }
    end

    context ".apply_prec" do
      it { expect(e.apply_prec([-0.507870315369686, 0.8072824634004779, 0.34996720255697145])).to match([
        be_within(1.0e-16).of(-0.5114180771311418 ),
        be_within(1.0e-16).of( 0.8053955471104202 ),
        be_within(1.0e-17).of( 0.34914730256926324)
      ]) }
    end

    context ".apply_nut" do
      it { expect(e.apply_nut([-0.5114180771311418, 0.8053955471104202, 0.34914730256926324])).to match([
        be_within(1.0e-16).of(-0.5114035051003876 ),
        be_within(1.0e-16).of( 0.8054188741108514 ),
        be_within(1.0e-17).of( 0.34911483499021656)
      ]) }
    end

    context ".apply_bias_prec" do
      it { expect(e.apply_bias_prec([-0.50787065, 0.80728228, 0.34996714])).to match([
        be_within(1.0e-16).of(-0.5114184398598124),
        be_within(1.0e-15).of( 0.805395337986056 ),
        be_within(1.0e-16).of( 0.3491472536550768)
      ]) }
    end
  end
end

