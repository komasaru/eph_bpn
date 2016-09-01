# EphBpn

## Introduction

This is the gem library which calculates ephemeris(Bias, Precession Nutation).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eph_bpn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eph_bpn

## Usage

### Instantiation

    require 'eph_bpn'
    
    e = EphBpn.new("20160723")
    e = EphBpn.new("20160723123456")
    e = EphBpn.new

* You can set TDB formatted "YYYYMMDD" or "YYYYMMDDHHMMSS" as an argument.
* If you don't set an argument, this class considers the system time to have been set as an argument.

### Calculation

    pos_g  = [-0.50787065, 0.80728228, 0.34996714]  # GCRS Coordinate
    pos_b  = e.apply_bias(pos_g)       # Apply Bias
    pos_p  = e.apply_prec(pos_b)       # Apply Precession
    pos_n  = e.apply_nut(pos_p)        # Apply Nutation
    pos_bp = e.apply_bias_prec(pos_g)  # Apply Bias + Precession
    puts "TDB: #{e.tdb}"               #=> TDB: 2016-07-23 00:00:00 +0000
    puts " JD: #{e.jd}"                #=>  JD: 2457592.5
    puts " JC: #{e.jc}"                #=>  JC: 0.16557152635181382
    puts "EPS: #{e.eps}"               #=> EPS: 0.40905500411767176
    p pos_g                            #=> [-0.50787065, 0.80728228, 0.34996714]
    p pos_b                            #=> [-0.507870315369686, 0.8072824634004779, 0.34996720255697145]
    p pos_p                            #=> [-0.5114180771311418, 0.8053955471104202, 0.34914730256926324]
    p pos_n                            #=> [-0.5114180757959449, 0.8053955495119587, 0.34914729898526137]
    p pos_bp                           #=> [-0.5114184398598124, 0.805395337986056, 0.3491472536550768]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/komasaru/eph_bpn.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

