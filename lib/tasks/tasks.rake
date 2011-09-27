require 'rails'
namespace :mnbackpack do
  desc "Load data from medianet XML"
  task :load_data => :environment do
    task_dir = File.expand_path(File.dirname(__FILE__))
    require task_dir + '/../mndata_import'
    mn = MNImport.new
    mn.do_import
  end
end