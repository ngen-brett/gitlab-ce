InvisibleCaptcha.setup do |config|
  config.honeypots = ['firstname', 'lastname']
  config.timestamp_enabled = true
  config.timestamp_threshold = 4
end