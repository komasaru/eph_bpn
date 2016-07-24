require "spec_helper"

describe EphBpn::Const do
  context "MSG_ERR_1" do
    it { expect(EphBpn::Const::MSG_ERR_1).to eq "[ERROR] Format: YYYYMMDD or YYYYMMDDHHMMSS" }
  end

  context "MSG_ERR_2" do
    it { expect(EphBpn::Const::MSG_ERR_2).to eq "[ERROR] Invalid date-time!" }
  end

  context "PI" do
    it { expect(EphBpn::Const::PI).to eq 3.141592653589793238462 }
  end

  context "PI2" do
    it { expect(EphBpn::Const::PI2).to be_within(1.0e-15).of(6.283185307179586) }
  end

  context "AS2R" do
    it { expect(EphBpn::Const::AS2R).to be_within(1.0e-20).of(4.84813681109536e-06) }
  end

  context "MAS2R" do
    it { expect(EphBpn::Const::MAS2R).to be_within(1.0e-23).of(4.84813681109536e-09) }
  end

  context "TURNAS" do
    it { expect(EphBpn::Const::TURNAS).to eq 1296000.0 }
  end

  context "U2R" do
    it { expect(EphBpn::Const::U2R).to be_within(1.0e-28).of(4.848136811095359e-13) }
  end

  context "R_UNIT" do
    it { expect(EphBpn::Const::R_UNIT).to match([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]) }
  end

  context "NUT_LS" do
    it { expect(EphBpn::Const::NUT_LS[0]).to match([
      0,  0,  0,  0,  1, -17206.4161, -17.4666,  3.3386, 9205.2331,  0.9086,  1.5377
    ]) }
    it { expect(EphBpn::Const::NUT_LS[-1]).to match([
      2,  0,  2,  4,  1,     -0.0003,   0.0000,  0.0000,    0.0002,  0.0000,  0.0000
    ]) }
  end

  context "NUT_PL" do
    it { expect(EphBpn::Const::NUT_PL[0]).to match([
      0,   0,   0,   0,   0,   0,   0,   8, -16,   4,   5,   0,   0,   0,
      0.1440,   0.0000,    0.0000,   0.0000
    ]) }
    it { expect(EphBpn::Const::NUT_PL[-1]).to match([
      0,   0,   2,   2,   2,   0,   0,   2,   0,  -2,   0,   0,   0,   0,
      0.0003,   0.0000,    0.0000,  -0.0001
    ]) }
  end
end

