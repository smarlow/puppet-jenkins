# Add our own helper function to produce Sensitive types
# since puppet-rspec doesn't seem to support this currently
def sensitive(string)
  return RSpec::Puppet::RawString.new("Sensitive(#{string})")
end
