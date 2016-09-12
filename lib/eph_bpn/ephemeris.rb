module EphBpn

  class Ephemeris
    attr_reader :tdb, :jd, :jc, :eps,
                :r_bias, :r_bias_prec, :r_bias_prec_nut,
                :r_prec, :r_prec_nut, :r_nut
    include Compute

    def initialize(tdb)
      @tdb = tdb                               # 太陽系力学時
      @jd  = gc2jd(@tdb)                       # TDB -> JD（ユリウス日）
      @jc  = jd2jc(@jd)                        # ユリウス世紀
      @eps = compute_obliquity(@jc)            # 平均黄道傾斜角
      @r_bias          = comp_r_bias           # 回転行列（バイアス）
      @r_bias_prec     = comp_r_bias_prec      # 回転行列（バイアス＆歳差）
      @r_bias_prec_nut = comp_r_bias_prec_nut  # 回転行列（バイアス＆歳差＆章動）
      @r_prec          = comp_r_prec           # 回転行列（歳差）
      @r_prec_nut      = comp_r_prec_nut       # 回転行列（歳差＆章動）
      @r_nut           = comp_r_nut            # 回転行列（章動）
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
    alias :apply_b :apply_bias

    #=========================================================================
    # Bias + Precession（歳差） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_bias_prec(pos)
      return rotate(@r_bias_prec, pos)
    end
    alias :apply_bp :apply_bias_prec

    #=========================================================================
    # Bias + Precession（歳差） + Nutation（章動） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_bias_prec_nut(pos)
      return rotate(@r_bias_prec_nut, pos)
    end
    alias :apply_bpn :apply_bias_prec_nut

    #=========================================================================
    # Precession（歳差） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_prec(pos)
      return rotate(@r_prec, pos)
    end
    alias :apply_p :apply_prec

    #=========================================================================
    # Precession（歳差） + Nutation（章動） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_p  (適用後直角座標)
    #=========================================================================
    def apply_prec_nut(pos)
      return rotate(@r_prec_nut, pos)
    end
    alias :apply_pn :apply_prec_nut

    #=========================================================================
    # Nutation（章動） 適用
    #
    # @param:  pos    (適用前直角座標)
    # @return: pos_n  (適用後直角座標)
    #=========================================================================
    def apply_nut(pos)
      return rotate(@r_nut, pos)
    end
    alias :apply_n :apply_nut
  end
end

