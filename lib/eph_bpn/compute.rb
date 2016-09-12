module EphBpn
  module Compute
    module_function

    #=========================================================================
    # 年月日(グレゴリオ暦)からユリウス日(JD)を計算する
    #
    # * フリーゲルの公式を使用する
    #   JD = int(365.25 * year)
    #      + int(year / 400)
    #      - int(year / 100)
    #      + int(30.59 (month - 2))
    #      + day
    #      + 1721088
    # * 上記の int(x) は厳密には、 x を超えない最大の整数
    # * 「ユリウス日」でなく「準ユリウス日」を求めるなら、
    #   `+ 1721088` を `- 678912` とする。
    #
    # @param:  t   (Time Object)
    # @return: jd  (ユリウス日)
    #=========================================================================
    def gc2jd(t)
      year, month, day = t.year, t.month, t.day
      hour, min, sec   = t.hour, t.min, t.sec

      begin
        # 1月,2月は前年の13月,14月とする
        if month < 3
          year  -= 1
          month += 12
        end
        # 日付(整数)部分計算
        jd  = (365.25 * year).floor \
            + (year / 400.0).floor \
            - (year / 100.0).floor \
            + (30.59 * (month - 2)).floor \
            + day \
            + 1721088.5
        # 時間(小数)部分計算
        t = (sec / 3600.0 + min / 60.0 + hour) / 24.0
        return jd + t
      rescue => e
        raise
      end
    end

    #=========================================================================
    # JD（ユリウス日） -> JC（ユリウス世紀）
    #
    # * t = (JD - 2451545) / 36525.0
    #
    # @param:  jd  (ユリウス日)
    # @return: jc  (ユリウス世紀)
    #=========================================================================
    def jd2jc(jd)
      return (jd - 2451545) / 36525.0
    rescue => e
      raise
    end

    #=========================================================================
    # 黄道傾斜角計算
    #
    # * 黄道傾斜角 ε （単位: rad）を計算する。
    #   以下の計算式により求める。
    #     ε = 84381.406 - 46.836769 * T - 0.0001831 T^2 + 0.00200340 T^3
    #       - 5.76 * 10^(-7) * T^4 - 4.34 * 10^(-8) * T^5
    #   ここで、 T は J2000.0 からの経過時間を 36525 日単位で表したユリウス
    #   世紀数で、 T = (JD - 2451545) / 36525 である。
    #
    # @param:  jc   (ユリウス世紀)
    # @return: eps  (平均黄道傾斜角)
    #=========================================================================
    def compute_obliquity(jc)
      return (84381.406        + \
             (  -46.836769     + \
             (   -0.0001831    + \
             (    0.00200340   + \
             (   -5.76 * 10e-7 + \
             (   -4.34 * 10e-8 ) \
             * jc) * jc) * jc) * jc) * jc) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # Bias 変換行列（一般的な理論）
    #
    # * 赤道座標(J2000.0)の極は ICRS の極に対して12時（x軸のマイナス側）の方
    #   向へ 17.3±0.2 mas、18時（y軸のマイナス側）の方向へ 5.1±0.2 mas ズレ
    #   ているので、変換する。
    #   さらに、平均分点への変換はICRSでの赤経を78±10 mas、天の極を中心に回
    #   転させる。
    #     18時の方向の変換はx軸を-5.1mas回転
    #                + 1     0      0   +
    #       R1(θ ) = | 0   cosθ   sinθ  |
    #                + 0  -sinθ   cosθ  +
    #     12時の方向の変換はy軸を-17.3mas回転
    #                + cosθ   0  -sinθ  +
    #       R2(θ ) = |   0    1     0   |
    #                + sinθ   0   cosθ  +
    #     天の極を中心に78.0mas回転
    #                +  cosθ   sinθ   0 +
    #       R3(θ ) = | -sinθ   cosθ   0 |
    #                +    0      0    1 +
    #
    # @param:  <none>
    # @return: r  (回転行列)
    #=========================================================================
    def comp_r_bias
      r = r_x( -5.1 * Const::MAS2R)
      r = r_y(-17.3 * Const::MAS2R, r)
      r = r_z( 78.0 * Const::MAS2R, r)
      return r
    rescue => e
      raise
    end

    #=========================================================================
    # Bias + Precession 変換行列
    #
    # * IAU 2006 (Fukushima-Williams 4-angle formulation) 理論
    #
    # @param:  <none>
    # @return: r  (変換行列)
    #=========================================================================
    def comp_r_bias_prec
      gamma = comp_gamma_bp
      phi   = comp_phi_bp
      psi   = comp_psi_bp
      r = r_z(gamma)
      r = r_x(phi,   r)
      r = r_z(-psi,  r)
      r = r_x(-@eps, r)
      return r
    rescue => e
      raise
    end

    #=========================================================================
    # Bias + Precession + Nutation 変換行列
    #
    # * IAU 2006 (Fukushima-Williams 4-angle formulation) 理論
    #
    # @param:  <none>
    # @return: r  (変換行列)
    #=========================================================================
    def comp_r_bias_prec_nut
      gamma = comp_gamma_bp
      phi   = comp_phi_bp
      psi   = comp_psi_bp
      fj2 = -2.7774e-6 * @jc
      dpsi_ls, deps_ls = compute_lunisolar
      dpsi_pl, deps_pl = compute_planetary
      dpsi, deps = dpsi_ls + dpsi_pl, deps_ls + deps_pl
      dpsi += dpsi * (0.4697e-6 + fj2)
      deps += deps * fj2
      r = r_z(gamma)
      r = r_x(phi,          r)
      r = r_z(-psi - dpsi,  r)
      r = r_x(-@eps - deps, r)
      return r
    rescue => e
      raise
    end

    #=========================================================================
    # precession（歳差）変換行列（J2000.0 用）
    #
    # * 歳差の変換行列
    #     P(ε , ψ , φ , γ ) = R1(-ε ) * R3(-ψ ) * R1(φ ) * R3(γ )
    #   但し、R1, R2, R3 は x, y, z 軸の回転。
    #              + 1     0      0   +            +  cosθ   sinθ   0 +
    #     R1(θ ) = | 0   cosθ   sinθ  | , R3(θ ) = | -sinθ   cosθ   0 |
    #              + 0  -sinθ   cosθ  +            +    0      0    1 +
    #                     + P_11 P_12 P_13 +
    #     P(ε, ψ, φ, γ) = | P_21 P_22 P_23 | とすると、
    #                     + P_31 P_32 P_33 +
    #     P_11 = cosψ cosγ + sinψ cosφ sinγ
    #     P_12 = cosψ sinγ - sinψ cosφ ̄cosγ
    #     P_13 = -sinψ sinφ
    #     P_21 = cosε sinψ cosγ - (cosε cosψ cosφ + sinε sinφ )sinγ
    #     P_22 = cosε sinψ cosγ + (cosε cosψ cosφ + sinε sinφ )cosγ
    #     P_23 = cosε cosψ sinφ - sinε cosφ
    #     P_31 = sinε sinψ cosγ - (sinε cosψ cosφ - cosε sinφ)sinγ
    #     P_32 = sinε sinψ cosγ + (sinε cosψ cosφ - cosε sinφ)cosγ
    #     P_33 = sinε cosψ sinφ + cosε cosφ
    #
    # @param:  <none>
    # @return: r  (変換行列)
    #=========================================================================
    def comp_r_prec
      gamma = comp_gamma_p
      phi   = comp_phi_p
      psi   = comp_psi_p
      r = r_z(gamma)
      r = r_x(phi,   r)
      r = r_z(-psi,  r)
      r = r_x(-@eps, r)
      return r
    rescue => e
      raise
    end

    #=========================================================================
    # Precession + Nutation 変換行列
    #
    # * IAU 2000A nutation with adjustments to match the IAU 2006 precession.
    #
    # @param:  <none>
    # @return: r  (変換行列)
    #=========================================================================
    def comp_r_prec_nut
      gamma = comp_gamma_p
      phi   = comp_phi_p
      psi   = comp_psi_p
      fj2 = -2.7774e-6 * @jc
      dpsi_ls, deps_ls = compute_lunisolar
      dpsi_pl, deps_pl = compute_planetary
      dpsi, deps = dpsi_ls + dpsi_pl, deps_ls + deps_pl
      dpsi += dpsi * (0.4697e-6 + fj2)
      deps += deps * fj2
      r = r_z(gamma)
      r = r_x(phi,          r)
      r = r_z(-psi - dpsi,  r)
      r = r_x(-@eps - deps, r)
      return r
    rescue => e
      raise
    end

    #=========================================================================
    # nutation（章動）変換行列
    #
    # * IAU 2000A nutation with adjustments to match the IAU 2006 precession.
    #
    # @param:  <none>
    # @return: r  (変換行列)
    #=========================================================================
    def comp_r_nut
      fj2 = -2.7774e-6 * @jc
      dpsi_ls, deps_ls = compute_lunisolar
      dpsi_pl, deps_pl = compute_planetary
      dpsi, deps = dpsi_ls + dpsi_pl, deps_ls + deps_pl
      dpsi += dpsi * (0.4697e-6 + fj2)
      deps += deps * fj2
      r = r_x(@eps)
      r = r_z(-dpsi, r)
      r = r_x(-@eps-deps, r)
      return r
    rescue => e
      raise
    end

    #=========================================================================
    # 歳差変換行列用 gamma 計算
    #
    # @param:  <none>
    # @return: gamma
    #=========================================================================
    def comp_gamma_p
      return ((10.556403    + \
              ( 0.4932044   + \
              (-0.00031238  + \
              (-0.000002788 + \
              ( 0.0000000260) \
              * @jc) * @jc) * @jc) * @jc) * @jc) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # 歳差変換行列用 phi 計算
    #
    # @param:  <none>
    # @return: phi
    #=========================================================================
    def comp_phi_p
      return (84381.406000    + \
             (  -46.811015    + \
             (    0.0511269   + \
             (    0.00053289  + \
             (   -0.000000440 + \
             (   -0.0000000176) \
             * @jc) * @jc) * @jc) * @jc) * @jc) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # 歳差変換行列用 psi 計算
    #
    # @param:  <none>
    # @return: psi
    #=========================================================================
    def comp_psi_p
      return (( 5038.481507    + \
              (    1.5584176   + \
              (   -0.00018522  + \
              (   -0.000026452 + \
              (   -0.0000000148) \
              * @jc) * @jc) * @jc) * @jc) * @jc) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # バイアス＆歳差変換行列用 gamma 計算
    #
    # @param:  <none>
    # @return: gamma
    #=========================================================================
    def comp_gamma_bp
      gamma = (-0.052928    + \
              (10.556378    + \
              ( 0.4932044   + \
              (-0.00031238  + \
              (-0.000002788 + \
              ( 0.0000000260) \
              * @jc) * @jc) * @jc) * @jc) * @jc) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # バイアス＆歳差変換行列用 phi 計算
    #
    # @param:  <none>
    # @return: phi
    #=========================================================================
    def comp_phi_bp
      phi   = (84381.412819    + \
              (  -46.811016    + \
              (    0.0511268   + \
              (    0.00053289  + \
              (   -0.000000440 + \
              (   -0.0000000176) \
              * @jc) * @jc) * @jc) * @jc) * @jc) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # バイアス＆歳差変換行列用 psi 計算
    #
    # @param:  <none>
    # @return: psi
    #=========================================================================
    def comp_psi_bp
      psi   = (  -0.041775    + \
              (5038.481484    + \
              (   1.5584175   + \
              (  -0.00018522  + \
              (  -0.000026452 + \
              (  -0.0000000148) \
              * @jc) * @jc) * @jc) * @jc) * @jc) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # 日月章動(luni-solar nutation)の計算
    #
    # @param:  <none>
    # @return: [dpsi_ls, deps_ls]
    #=========================================================================
    def compute_lunisolar
      dp, de = 0.0, 0.0

      begin
        l  = compute_l_iers2003(@jc)
        lp = compute_lp_mhb2000(@jc)
        f  = compute_f_iers2003(@jc)
        d  = compute_d_mhb2000(@jc)
        om = compute_om_iers2003(@jc)
        Const::NUT_LS.map do |x|
          x[0, 5] + x[5..-1].map { |y| y.to_s.sub(/\./, "").to_i }
        end.reverse.each do |x|
          arg = (x[0] * l + x[1] * lp + x[2] * f +
                 x[3] * d + x[4] * om) % Const::PI2
          sarg, carg = Math.sin(arg), Math.cos(arg)
          dp += (x[5] + x[6] * @jc) * sarg + x[ 7] * carg
          de += (x[8] + x[9] * @jc) * carg + x[10] * sarg
        end
        return [dp * Const::U2R, de * Const::U2R]
      rescue => e
        raise
      end
    end

    #=========================================================================
    # 惑星章動(planetary nutation)
    #
    # @param:  <none>
    # @return: [dpsi_pl, deps_pl]
    #=========================================================================
    def compute_planetary
      dp, de = 0.0, 0.0

      begin
        l   = compute_l_mhb2000(@jc)
        f   = compute_f_mhb2000(@jc)
        d   = compute_d_mhb2000_2(@jc)
        om  = compute_om_mhb2000(@jc)
        pa  = compute_pa_iers2003(@jc)
        lme = compute_lme_iers2003(@jc)
        lve = compute_lve_iers2003(@jc)
        lea = compute_lea_iers2003(@jc)
        lma = compute_lma_iers2003(@jc)
        lju = compute_lju_iers2003(@jc)
        lsa = compute_lsa_iers2003(@jc)
        lur = compute_lur_iers2003(@jc)
        lne = compute_lne_mhb2000(@jc)
        Const::NUT_PL.map do |x|
          x[0, 14] + x[14..-1].map { |y| y.to_s.sub(/\./, "").to_i }
        end.reverse.each do |x|
          arg = (x[ 0] * l   + x[ 2] * f   + x[ 3] * d   + x[ 4] * om  +
                 x[ 5] * lme + x[ 6] * lve + x[ 7] * lea + x[ 8] * lma +
                 x[ 9] * lju + x[10] * lsa + x[11] * lur + x[12] * lne +
                 x[13] * pa) % Const::PI2
          sarg, carg = Math.sin(arg), Math.cos(arg)
          dp += x[14] * sarg + x[15] * carg
          de += x[16] * sarg + x[17] * carg
        end
        return [dp * Const::U2R, de * Const::U2R]
      rescue => e
        raise
      end
    end

    #=========================================================================
    # Mean anomaly of the Moon (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_l_iers2003(jc)
      return ((    485868.249036  + \
              (1717915923.2178    + \
              (        31.8792    + \
              (         0.051635  + \
              (        -0.00024470) \
              * jc) * jc) * jc) * jc) % Const::TURNAS) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # Mean anomaly of the Sun (MHB2000)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lp_mhb2000(jc)
      return ((  1287104.79305   + \
              (129596581.0481    + \
              (       -0.5532    + \
              (        0.000136  + \
              (       -0.00001149) \
              * jc) * jc) * jc) * jc) % Const::TURNAS) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # Mean longitude of the Moon minus that of the ascending node (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_f_iers2003(jc)
      return ((     335779.526232 + \
              (1739527262.8478    + \
              (       -12.7512    + \
              (        -0.001037  + \
              (         0.00000417) \
              * jc) * jc) * jc) * jc) % Const::TURNAS) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # Mean elongation of the Moon from the Sun (MHB2000)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_d_mhb2000(jc)
      return ((   1072260.70369   + \
              (1602961601.2090    + \
              (        -6.3706    + \
              (         0.006593  + \
              (        -0.00003169) \
              * jc) * jc) * jc) * jc) % Const::TURNAS) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # Mean longitude of the ascending node of the Moon (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_om_iers2003(jc)
      return ((  450160.398036  + \
              (-6962890.5431    + \
              (       7.4722    + \
              (       0.007702  + \
              (      -0.00005939) \
              * jc) * jc) * jc) * jc) % Const::TURNAS) * Const::AS2R
    rescue => e
      raise
    end

    #=========================================================================
    # Mean anomaly of the Moon (MHB2000)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_l_mhb2000(jc)
      return (2.35555598 + 8328.6914269554 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Mean longitude of the Moon minus that of the ascending node (MHB2000)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_f_mhb2000(jc)
      return (1.627905234 + 8433.466158131 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Mean elongation of the Moon from the Sun (MHB2000)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_d_mhb2000_2(jc)
      return (5.198466741 + 7771.3771468121 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Mean longitude of the ascending node of the Moon (MHB2000)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_om_mhb2000(jc)
      return (2.18243920 - 33.757045 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # General accumulated precession in longitude (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_pa_iers2003(jc)
      return (0.024381750 + 0.00000538691 * jc) * jc
    rescue => e
      raise
    end

    #=========================================================================
    # Mercury longitudes (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lme_iers2003(jc)
      return (4.402608842 + 2608.7903141574 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Venus longitudes (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lve_iers2003(jc)
      return (3.176146697 + 1021.3285546211 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Earth longitudes (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lea_iers2003(jc)
      return (1.753470314 + 628.3075849991 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Mars longitudes (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lma_iers2003(jc)
      return (6.203480913 + 334.0612426700 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Jupiter longitudes (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lju_iers2003(jc)
      return (0.599546497 + 52.9690962641 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Saturn longitudes (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lsa_iers2003(jc)
      return (0.874016757 + 21.3299104960 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Uranus longitudes (IERS 2003)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lur_iers2003(jc)
      return (5.481293872 + 7.4781598567 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # Neptune longitude (MHB2000)
    #
    # @param:  jc         (ユリウス世紀)
    # @return: longitude  (rad)
    #=========================================================================
    def compute_lne_mhb2000(jc)
      return (5.321159000 + 3.8127774000 * jc) % Const::PI2
    rescue => e
      raise
    end

    #=========================================================================
    # 回転行列（x 軸中心）
    #
    # @param:  phi  (回転量(rad))
    # @param:  r    (回転行列)
    # @return: r_a  (回転後)
    #=========================================================================
    def r_x(phi, r = Const::R_UNIT)
      r_a = Array.new

      begin
        s, c = Math.sin(phi), Math.cos(phi)
        a10 =   c * r[1][0] + s * r[2][0]
        a11 =   c * r[1][1] + s * r[2][1]
        a12 =   c * r[1][2] + s * r[2][2]
        a20 = - s * r[1][0] + c * r[2][0]
        a21 = - s * r[1][1] + c * r[2][1]
        a22 = - s * r[1][2] + c * r[2][2]
        r_a << r[0]
        r_a << [a10, a11, a12]
        r_a << [a20, a21, a22]
        return r_a
      rescue => e
        raise
      end
    end

    #=========================================================================
    # 回転行列（y 軸中心）
    #
    # @param:  theta  (回転量(rad))
    # @param:  r      (回転行列)
    # @return: r_a    (回転後)
    #=========================================================================
    def r_y(theta, r = Const::R_UNIT)
      r_a = Array.new

      begin
        s, c = Math.sin(theta), Math.cos(theta)
        a00 = c * r[0][0] - s * r[2][0]
        a01 = c * r[0][1] - s * r[2][1]
        a02 = c * r[0][2] - s * r[2][2]
        a20 = s * r[0][0] + c * r[2][0]
        a21 = s * r[0][1] + c * r[2][1]
        a22 = s * r[0][2] + c * r[2][2]
        r_a << [a00, a01, a02]
        r_a << r[1]
        r_a << [a20, a21, a22]
        return r_a
      rescue => e
        raise
      end
    end

    #=========================================================================
    # 回転行列（z 軸中心）
    #
    # @param:  psi  (回転量(rad))
    # @param:  r    (回転行列)
    # @return: r_a  (回転後)
    #=========================================================================
    def r_z(psi, r = Const::R_UNIT)
      r_a = Array.new

      begin
        s, c = Math.sin(psi), Math.cos(psi)
        a00 =   c * r[0][0] + s * r[1][0];
        a01 =   c * r[0][1] + s * r[1][1];
        a02 =   c * r[0][2] + s * r[1][2];
        a10 = - s * r[0][0] + c * r[1][0];
        a11 = - s * r[0][1] + c * r[1][1];
        a12 = - s * r[0][2] + c * r[1][2];
        r_a << [a00, a01, a02]
        r_a << [a10, a11, a12]
        r_a << r[2]
        return r_a
      rescue => e
        raise
      end
    end

    #=========================================================================
    # 座標回転
    #
    # @param:  r      (回転行列)
    # @param:  pos    (回転前直角座標)
    # @return: pos_r  (回転後直角座標)
    #=========================================================================
    def rotate(r, pos)
      return (0..2).map do |i|
        (0..2).inject(0) { |sum, j| sum + r[i][j] * pos[j] }
      end
    rescue => e
      raise
    end
  end
end

