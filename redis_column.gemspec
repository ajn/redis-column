# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_column/version"

Gem::Specification.new do |s|
  s.name        = "redis_column"
  s.version     = RedisColumn::VERSION
  s.authors     = ["Alex Neill"]
  s.email       = ["alex.neill@gmail.com"]
  s.homepage    = "https://github.com/ajn/redis_column"
  s.summary     = %q{Seamlessly extend your AR model with Redis}
  s.description = %q{RedisColumn allows for the seamless integration of Redis within your ActiveRecord model as a table extension; TODO justification :)}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord"
  s.add_dependency "redis"
  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "autotest"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "fakeredis"
end
