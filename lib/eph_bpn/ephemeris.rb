module EphBpn
  class Ephemeris
    attr_reader :tdb, :jd, :jc, :eps,
                :r_bias, :r_prec, :r_nut, :r_bias_prec
    include Compute

    def initialize(tdb)
      @tdb = tdb                     # 太陽系力学時
      @jd  = gc2jd(@tdb)             # TDB -> JD（ユリウス日）
      @jc  = jd2jc(@jd)              # ユリウス世紀
      @eps = compute_obliquity(@jc)  # 平均黄道傾斜角
      @r_bias      = comp_r_bias       # 回転行列（バイアス）
      @r_prec      = comp_r_prec       # 回転行列（歳差）
      @r_nut       = comp_r_nut        # 回転行列（章動）
      @r_bias_prec = comp_r_bias_prec  # 回転行列（バイアス＆歳差）
    end

    #=========================================================================
    # Bias 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_b  (適用後直角座標)
    #=========================================================================
    def apply_bias(pos)
      return rotate(@r_bias, pos)
    end

    #=========================================================================
    # Precession（歳差） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_prec(pos)
      return rotate(@r_prec, pos)
    end

    #=========================================================================
    # Nutation（章動） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_n  (適用後直角座標)
    #=========================================================================
    def apply_nut(pos)
      return rotate(@r_nut, pos)
    end

    #=========================================================================
    # Bias + Precession（歳差） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_bias_prec(pos)
      return rotate(@r_bias_prec, pos)  # IAU 2006 (Fukushima-Williams) 理論
    end
  end
end

