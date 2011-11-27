$:.push File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.push File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'woof'))

require 'rspec'
require 'pry'
require 'woof'

RSpec.configure do |config|
  config.color_enabled = true
end
