
Dir[Rails.root.join('spec/support/helpers/*.rb')].each { |f| require f }

# noinspection RubyResolve
RSpec.configure do |config|
  config.include RequestSpecHelper#, type: :request
  config.include ControllerSpecHelper
  config.include UtilsHelper
end