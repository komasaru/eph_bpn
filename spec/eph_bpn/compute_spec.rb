require "spec_helper"

describe EphBpn::Compute do
  let(:c) { EphBpn::Compute }

  context ".gc2jd" do
    subject { c.gc2jd(Time.new(2016, 7, 23, 0, 0, 0, "+00:00")) }
    it { expect(subject).to eq 2457592.5 }
  end

  context ".jd2jc" do
    subject { c.jd2jc(2457592.5) }
    it { expect(subject).to be_within(1.0e-17).of(0.16557152635181382) }
  end

  context ".compute_obliquity" do
    subject { c.compute_obliquity(0.16557152635181382) }
    it { expect(subject).to be_within(1.0e-17).of(0.40905500411767176) }
  end

  context ".comp_r_bias" do
    subject { c.comp_r_bias}
    it { expect(subject).to match([
      [
        be_within(1.0e-15).of(0.999999999999925    ),
        be_within(1.0e-22).of(3.781546733392249e-07),
        be_within(1.0e-23).of(8.387275748188115e-08)
      ], [
        be_within(1.0e-23).of(-3.7815467126542776e-07),
        be_within(1.0e-16).of( 0.9999999999999282    ),
        be_within(1.0e-24).of(-2.4725529453463136e-08)
      ], [
        be_within(1.0e-23).of(-8.387276683194964e-08 ),
        be_within(1.0e-24).of( 2.4725497736586244e-08),
        be_within(1.0e-16).of( 0.9999999999999961    )
      ]
    ]) }
  end

  context ".comp_r_bias_prec" do
    subject do
      c.instance_variable_set(:@jc,  0.16557152635181382)
      c.instance_variable_set(:@eps, 0.40905500411767176)
      c.comp_r_bias_prec
    end
    it { expect(subject).to match([
      [
        be_within(1.0e-16).of( 0.9999918518786002   ),
        be_within(1.0e-19).of(-0.0037024886248251923),
        be_within(1.0e-19).of(-0.0016086498658162921)
      ],
      [
        be_within(1.0e-18).of( 0.003702488711461927 ),
        be_within(1.0e-16).of( 0.9999931457609051   ),
        be_within(1.0e-21).of(-2.924159313910657e-06)
      ],
      [
        be_within(1.0e-19).of( 0.0016086496664120891 ),
        be_within(1.0e-22).of(-3.0318724813516162e-06),
        be_within(1.0e-15).of( 0.999998706117692     )
      ]
    ]) }
  end

  context ".comp_r_bias_prec_nut" do
    subject do
      c.instance_variable_set(:@jc,  0.16557152635181382)
      c.instance_variable_set(:@eps, 0.40905500411767176)
      c.comp_r_bias_prec_nut
    end
    it { expect(subject).to match([
      [
        be_within(1.0e-16).of( 0.9999919187533183   ),
        be_within(1.0e-18).of(-0.003687258120905521 ),
        be_within(1.0e-19).of(-0.0016020473172943998)
      ], [
        be_within(1.0e-18).of( 0.003687329501491259 ),
        be_within(1.0e-16).of( 0.9999932009119931   ),
        be_within(1.0e-20).of( 4.160448832457586e-05)
      ], [
        be_within(1.0e-19).of( 0.0016018830183462576 ),
        be_within(1.0e-21).of(-4.7511428444280135e-05),
        be_within(1.0e-16).of( 0.9999987158559053    )
      ]
    ]) }
  end

  context ".comp_r_prec" do
    subject do
      c.instance_variable_set(:@jc,  0.16557152635181382)
      c.instance_variable_set(:@eps, 0.40905500411767176)
      c.comp_r_prec
    end
    it { expect(subject).to match([
      [
        be_within(1.0e-16).of( 0.9999918520110741   ),
        be_within(1.0e-19).of(-0.0037024178948059177),
        be_within(1.0e-17).of(-0.00160873030498547  )
      ], [
        be_within(1.0e-18).of( 0.003702417927931962 ),
        be_within(1.0e-16).of( 0.9999931460228814   ),
        be_within(1.0e-21).of(-2.957516671786564e-06)
      ], [
        be_within(1.0e-19).of( 0.0016087302287474193 ),
        be_within(1.0e-22).of(-2.9986993484998337e-06),
        be_within(1.0e-16).of( 0.9999987059881922    )
      ]
    ]) }
  end

  context ".comp_r_prec_nut" do
    subject do
      c.instance_variable_set(:@jc,  0.16557152635181382)
      c.instance_variable_set(:@eps, 0.40905500411767176)
      c.comp_r_prec_nut
    end
    it { expect(subject).to match([
      [
        be_within(1.0e-16).of( 0.9999919188852461   ),
        be_within(1.0e-18).of(-0.003687187390663237 ),
        be_within(1.0e-19).of(-0.0016021277569724754)
      ], [
        be_within(1.0e-19).of( 0.0036872587215447186 ),
        be_within(1.0e-16).of( 0.9999932011743686    ),
        be_within(1.0e-21).of( 4.1571132186168924e-05)
      ], [
        be_within(1.0e-19).of( 0.0016019635838308039),
        be_within(1.0e-20).of(-4.747825578998999e-05),
        be_within(1.0e-16).of( 0.9999987157284209   )
      ]
    ]) }
  end

  context ".comp_gamma_p" do
    subject do
      c.instance_variable_set(:@jc, 0.16557152635181382)
      c.comp_gamma_p
    end
    it { expect(subject).to be_within(1.0e-21).of(8.539309447074353e-06) }
  end

  context ".comp_phi_p" do
    subject do
      c.instance_variable_set(:@jc, 0.16557152635181382)
      c.comp_phi_p
    end
    it { expect(subject).to be_within(1.0e-15).of(0.409055031577845) }
  end

  context ".comp_psi_p" do
    subject do
      c.instance_variable_set(:@jc, 0.16557152635181382)
      c.comp_psi_p
    end
    it { expect(subject).to be_within(1.0e-18).of(0.004044663800284435) }
  end

  context ".comp_gamma_bp" do
    subject do
      c.instance_variable_set(:@jc, 0.16557152635181382)
      c.comp_gamma_bp
    end
    it { expect(subject).to be_within(1.0e-21).of(8.282687194101404e-06) }
  end

  context ".comp_phi_bp" do
    subject do
      c.instance_variable_set(:@jc, 0.16557152635181382)
      c.comp_phi_bp
    end
    it { expect(subject).to be_within(1.0e-17).of(0.40905506463647395) }
  end

  context ".comp_psi_bp" do
    subject do
      c.instance_variable_set(:@jc, 0.16557152635181382)
      c.comp_psi_bp
    end
    it { expect(subject).to be_within(1.0e-18).of(0.004044461250893452) }
  end

  context "#Nutation computation" do
    let(:jc) { 0.16557152635181382 }

    context ".comp_r_nut" do
      subject do
        c.instance_variable_set(:@jc, jc)
        c.comp_r_nut
      end
      it { expect(subject).to match([
        [
          be_within(1.0e-05).of(1.0),
          be_within(1.0e-21).of(1.5230627822141132e-05),
          be_within(1.0e-21).of(6.602601380018686e-06)
        ], [
          be_within(1.0e-21).of(-1.5230921650908751e-05),
          be_within(1.0e-05).of(1.0),
          be_within(1.0e-21).of(4.4504203998374514e-05)
        ], [
          be_within(1.0e-22).of(-6.6019235457465905e-06),
          be_within(1.0e-20).of(-4.450430455593679e-05),
          be_within(1.0e-05).of(1.0)
        ]
      ]) }
    end

    context ".compute_lunisolar" do
      subject do
        c.instance_variable_set(:@jc, jc)
        c.compute_lunisolar
      end
      it { expect(subject).to match([
        be_within(1.0e-21).of(-1.6598098362618997e-05),
        be_within(1.0e-20).of(-4.450550418054413e-05 )
      ]) }
    end

    context ".compute_planetary" do
      subject do
        c.instance_variable_set(:@jc, jc)
        c.compute_planetary
      end
      it { expect(subject).to match([
        be_within(1.0e-24).of(-2.093306192089416e-09),
        be_within(1.0e-25).of( 1.2294199731308438e-09)
      ]) }
    end

    context ".compute_l_iers2003" do
      subject { c.compute_l_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-16).of(5.3321295788256675) }
    end

    context ".compute_lp_mhb2000" do
      subject { c.compute_lp_mhb2000(jc) }
      it { expect(subject).to be_within(1.0e-16).of(3.4548235589061664) }
    end

    context ".compute_f_iers2003" do
      subject { c.compute_f_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-15).of(3.102629229938814) }
    end

    context ".compute_d_mhb2000" do
      subject { c.compute_d_mhb2000(jc) }
      it { expect(subject).to be_within(1.0e-15).of(3.864253621839477) }
    end

    context ".compute_om_iers2003" do
      subject { c.compute_om_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-16).of(2.8764198733973796) }
    end

    context ".compute_l_mhb2000" do
      subject { c.compute_l_mhb2000(jc) }
      it { expect(subject).to be_within(1.0e-15).of(5.332125781942402) }
    end

    context ".compute_f_mhb2000" do
      subject { c.compute_f_mhb2000(jc) }
      it { expect(subject).to be_within(1.0e-16).of(3.1026312782487793) }
    end

    context ".compute_d_mhb2000_2" do
      subject { c.compute_d_mhb2000_2(jc) }
      it { expect(subject).to be_within(1.0e-16).of(3.8642548224681335) }
    end

    context ".compute_om_mhb2000" do
      subject { c.compute_om_mhb2000(jc) }
      it { expect(subject).to be_within(1.0e-16).of(2.8764190414027215) }
    end

    context ".compute_pa_iers2003" do
      subject { c.compute_pa_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-19).of(0.0040370712390038165) }
    end

    context ".compute_lme_iers2003" do
      subject { c.compute_lme_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-16).of(2.8042168934771965) }
    end

    context ".compute_lve_iers2003" do
      subject { c.compute_lve_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-15).of(2.633071098458565) }
    end

    context ".compute_lea_iers2003" do
      subject { c.compute_lea_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-15).of(5.252351265849597) }
    end

    context ".compute_lma_iers2003" do
      subject { c.compute_lma_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-15).of(4.965842992239303) }
    end

    context ".compute_lju_iers2003" do
      subject { c.compute_lju_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-16).of(3.0865353077436115) }
    end

    context ".compute_lsa_iers2003" do
      subject { c.compute_lsa_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-15).of(4.405642594770295) }
    end

    context ".compute_lur_iers2003" do
      subject { c.compute_lur_iers2003(jc) }
      it { expect(subject).to be_within(1.0e-15).of(0.436278906597094) }
    end

    context ".compute_lne_mhb2000" do
      subject { c.compute_lne_mhb2000(jc) }
      it { expect(subject).to be_within(1.0e-13).of(5.9524463737577) }
    end
  end

  context ".r_x" do
    let(:phi) { 0.4090926336600278 }
    let(:r)   { [
      [0.999999999999967, -2.5660218513765243e-07, 0.0],
      [2.5660218513765243e-07, 0.999999999999967, 0.0],
      [0, 0, 1]
    ] }
    subject { c.r_x(phi, r) }
    it { expect(subject).to match([
      [
        be_within(1.0e-15).of( 0.999999999999967     ),
        be_within(1.0e-23).of(-2.5660218513765243e-07),
        0.0
      ], [
        be_within(1.0e-22).of(2.354279193609251e-07),
        be_within(1.0e-16).of(0.9174821299149254   ),
        be_within(1.0e-17).of(0.39777699944405615  )
      ], [
        be_within(1.0e-23).of(-1.0207044725484357e-07),
        be_within(1.0e-17).of(-0.39777699944404304   ),
        be_within(1.0e-16).of( 0.9174821299149556    )
      ]
    ]) }
  end

  context ".r_y" do
    let(:theta) { -8.387276683194973e-05 }
    let(:r)     { [
      [1, 0, 0],
      [0.0, 0.9999999996943248, -2.472549773406701e-05],
      [0.0, 2.472549773406701e-05, 0.9999999996943248]
    ] }
    subject { c.r_y(theta, r) }
    it { expect(subject).to match([
      [
        be_within(1.0e-16).of(0.9999999964826795    ),
        be_within(1.0e-24).of(2.0737959038219024e-09),
        be_within(1.0e-20).of(8.387276670797612e-05 )
      ], [
        0.0,
        be_within(1.0e-16).of( 0.9999999996943248   ),
        be_within(1.0e-20).of(-2.472549773406701e-05)
      ], [
        be_within(1.0e-20).of(-8.387276673361394e-05 ),
        be_within(1.0e-21).of( 2.4725497647099508e-05),
        be_within(1.0e-16).of( 0.9999999961770043    )
      ]
    ]) }
  end

  context ".r_z" do
    let(:psi) { -2.5660218513765524e-07 }
    let(:r)   { [[1, 0, 0], [0, 1, 0], [0, 0, 1]] }
    subject { c.r_z(psi, r) }
    it { expect(subject).to match([
      [
        be_within(1.0e-15).of(0.999999999999967),
        be_within(1.0e-23).of(-2.5660218513765243e-07),
        0.0
      ], [
        be_within(1.0e-23).of(2.5660218513765243e-07),
        be_within(1.0e-15).of(0.999999999999967),
        0.0
      ], [
        0,
        0,
        1
      ]
    ]) }
  end

  context ".rotate" do
    let(:r) { [
      [ 0.9999999999999941,    -7.078368960971556e-08, 8.056213977613186e-08 ],
      [ 7.078368694637676e-08,  0.9999999999999969,    3.3059437354321375e-08],
      [-8.056214211620057e-08, -3.305943169218395e-08, 0.9999999999999962    ]
    ] }
    let(:pos) { [-0.50787065, 0.80728228, 0.34996714] }
    subject { c.rotate(r, pos) }
    it { expect(subject).to match([
      be_within(1.0e-6).of(-0.507871),
      be_within(1.0e-6).of( 0.807282),
      be_within(1.0e-6).of( 0.349967)
    ]) }
  end

end

