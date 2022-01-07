Gem::Specification.new do |s|
  s.name = "nc_activeconfig"
  s.version = "1.0.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")

  s.authors = ["Jeremy Lawler", "Mark Friedgan", "Alexander Dymo"]
  s.date = "2018-11-20"
  s.description = "An extremely flexible configuration system.\ns the ability for certain values to be \"overridden\" when conditions are met.\nr example, you could have your production API keys only get read when the Rails.env == \"production\""
  s.summary = "An extremely flexible configuration system"
  s.email = "jeremylawler@gmail.com"

  s.executables = ["active_config"]
  s.require_paths = ["lib"]

  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = 'https://ninjaholdings.jfrog.io/artifactory/api/gems/default-rubygems-virtual'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  s.add_dependency("rdoc")
  s.add_dependency("bundler")
end
