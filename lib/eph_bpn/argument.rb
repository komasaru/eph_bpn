module EphBpn
  class Argument
    def initialize(arg)
      @arg = arg
    end

    #=========================================================================
    # 引数取得
    #
    # * コマンドライン引数を取得して日時の妥当性チェックを行う
    # * コマンドライン引数無指定なら、現在日時とする。
    #
    # @return: tdb (Time Object)
    #=========================================================================
    def get_tdb
      (puts Const::MSG_ERR_1; return) unless @arg =~ /^\d{8}$|^\d{14}$/
      year, month, day = @arg[ 0, 4].to_i, @arg[ 4, 2].to_i, @arg[ 6, 2].to_i
      hour, min,   sec = @arg[ 8, 2].to_i, @arg[10, 2].to_i, @arg[12, 2].to_i
      (puts Const::MSG_ERR_2; return) unless Date.valid_date?(year, month, day)
      (puts Const::MSG_ERR_2; return) if hour > 23 || min > 59 || sec > 59
      return Time.new(year, month, day, hour, min, sec, "+00:00")
    end
  end
end
