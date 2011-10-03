require 'rails/generators'
module Mnbackpack
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../', __FILE__)
       def copy_config_files
         say_status("MOVING", "Creating a mnbackpack.yml configuration in your app")
         copy_file 'mnbackpack.yml', 'config/mnbackpack.yml'
         say_status("INFO", "Please modify the /config/mnbackpack.yml with your medianet API credentials")
         say_status("INFO", "Please remember to mount your engine")
       end
       def create_initializer
         say_status("MOVING", "Creating a mnbackpack initializer in your app")
         copy_file 'mnbackpack_load.rb', 'config/initializers/mnbackpack_load.rb'
       end
    end
  end
end