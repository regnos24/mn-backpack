require 'rails'
require 'sunspot_rails'
module Mnbackpack
  class Engine < Rails::Engine
    isolate_namespace Mnbackpack
    engine_name "mnbackpack"
    config.before_initialize do
      # yaml_file = "#{Rails.root}/config/mnbackpack.yml"
      # if File.exist?(yaml_file)
      #   MN_CONFIG = YAML.load_file("#{Rails.root}/config/mnbackpack.yml")
      # else
      #   puts "!" * 50
      #   puts "You need to run 'rails g mnbackpack:install'"
      #   puts "!" * 50
      #   puts ""
      # end
    end
  end
end
