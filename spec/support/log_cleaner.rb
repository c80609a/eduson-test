RSpec.configure do |config|
  config.before(:suite) do
    # чистим лог перед каждым запуском какого-нибудь теста
    # test_log_path = File.expand_path('../../log/test.log', __FILE__)
    # File.open(test_log_path, 'w') do |file|
    #   file.puts '[start suite]'
    # end
  end
end