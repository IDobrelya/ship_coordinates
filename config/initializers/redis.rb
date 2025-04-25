unless ENV['RACK_ENV'] == 'test' || ENV['RAILS_ENV'] == 'test'
  $redis = Redis.new(host: Rails.application.credentials.redis[:host], port: Rails.application.credentials.redis[:port])
end
