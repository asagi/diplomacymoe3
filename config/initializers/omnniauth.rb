# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['APP_ID'], ENV['APP_SECRET']
end

OmniAuth.config.on_failure = proc do |env|
  # OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  new_path = env['omniauth.params']['redirect']
  Rack::Response.new(['302 Moved'], 302, 'Location' => new_path).finish
end
