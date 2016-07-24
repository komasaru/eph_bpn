require 'date'
require "eph_bpn/version"
require "eph_bpn/argument"
require "eph_bpn/compute"
require "eph_bpn/consts"
require "eph_bpn/ephemeris"

module EphBpn
  def self.new(arg)
    arg ||= Time.now.strftime("%Y%m%d%H%M%S")
    tdb = EphBpn::Argument.new(arg).get_tdb
    return unless tdb
    return EphBpn::Ephemeris.new(tdb)
  end
end
