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

    e = EphBpn.new("20160723")
    e = EphBpn.new("20160723123456")
    e = EphBpn.new

* You can set TDB formatted "YYYYMMDD" or "YYYYMMDDHHMMSS" as an argument.
* If you don't set an argument, this class considers the system time to have been set as an argument.

### Calculation

    r_i = [-0.50787065, 0.80728228, 0.34996714]  # ICRS Coordinate
    r_b = e.apply_bias(r_i)  # Apply Bias
    r_p = e.apply_prec(r_b)  # Apply Precession
    r_n = e.apply_nut(r_p)   # Apply Nutation
    puts "TDB: #{e.tdb}"     #=> TDB: 2016-07-23 00:00:00 +0000
    puts " JD: #{e.jd}"      #=>  JD: 2457592.5
    puts " JC: #{e.jc}"      #=>  JC: 0.16557152635181382
    puts "EPS: #{e.eps}"     #=> EPS: 0.40905500411767176
    p r_i                    #=> [-0.50787065, 0.80728228, 0.34996714]
    p r_b                    #=> [-0.5078706789483137, 0.8072822556207571, 0.34996715422685276]
    p r_p                    #=> [-0.5114184398597698, 0.8053953379861463, 0.3491472536549302]
    p r_n                    #=> [-0.5114184385245731, 0.8053953403876852, 0.3491472500709293]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/komasaru/eph_bpn.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

