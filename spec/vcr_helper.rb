require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.dirname(__FILE__) + '/fixtures/'
  c.hook_into :fakeweb
end

