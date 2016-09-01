module EphBpn
  class Ephemeris
    attr_reader :tdb, :jd, :jc, :eps
    include Compute

    def initialize(tdb)
      @tdb = tdb                     # 太陽系力学時
      @jd  = gc2jd(@tdb)             # TDB -> JD（ユリウス日）
      @jc  = jd2jc(@jd)              # ユリウス世紀
      @eps = compute_obliquity(@jc)  # 平均黄道傾斜角
    end

    #=========================================================================
    # Bias 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_b  (適用後直角座標)
    #=========================================================================
    def apply_bias(pos)
      return rotate(r_bias, pos)
    end

    #=========================================================================
    # Precession（歳差） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_prec(pos)
      return rotate(r_prec, pos)
    end

    #=========================================================================
    # Bias + Precession（歳差） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_bias_prec(pos)
      return rotate(r_fw_iau_06, pos)  # IAU 2006 (Fukushima-Williams) 理論
    end

    #=========================================================================
    # Nutation（章動） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_n  (適用後直角座標)
    #=========================================================================
    def apply_nut(pos)
      return rotate(r_nut, pos)
    end
  end
end

