require 'rails'

namespace :mnbackpack do
  desc "Load data from medianet XML"
  task :load_data => :environment do
    task_dir = File.expand_path(File.dirname(__FILE__))
    require task_dir + '/../mndata_import'
    mn = MNImport.new
    mn.do_import
  end
  namespace :sunspot do
    desc "Reindex all solr models that are located in mnbackpack models directory."
    task :reindex => :environment do
      puts "*"*50
      reindex_options = {:batch_commit => false}
      all_files = []
      models_path = ""
       Rails.application.railties.engines.each do |engine|
          engine_models = engine.config.root.join('app', 'models')
          if Dir.exists?(engine_models)
            all_files = Dir.glob(engine_models.join('**', '*.rb'))
            models_path = engine_models
          end
      end
      all_models = all_files.map { |path| path.sub(models_path.to_s, '')[0..-4].camelize.sub(/^::/, '').constantize rescue nil }.compact
      sunspot_models = all_models.select { |m| m < ActiveRecord::Base and m.searchable? }
      sunspot_models.each do |model|
        model.solr_reindex reindex_options
      end
      puts sunspot_models.inspect
      puts "*"*50
    end
  end
end




  