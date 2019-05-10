Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['APP_ID'], ENV['APP_SECRET']
end

OmniAuth.config.on_failure = Proc.new do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
