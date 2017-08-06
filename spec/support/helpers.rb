
Dir[Rails.root.join('spec/support/helpers/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # noinspection RubyResolve
  config.include RequestSpecHelper#, type: :request
  # noinspection RubyResolve
  config.include ControllerSpecHelper
end