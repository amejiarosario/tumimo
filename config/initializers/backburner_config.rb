Backburner.configure do |config|
  config.beanstalk_url = "beanstalk://127.0.0.1"
  config.tube_namespace = "tumimo.jobs"
  config.on_error = lambda { |e| puts e }
  config.logger = Logger.new(STDOUT)
end