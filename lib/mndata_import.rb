require 'zip/zip'
require 'fileutils'
require 'nokogiri'

class MNImport
  attr_accessor :env, :zip_file
  attr_reader :logger, :outfile, :stats
  
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.info "MediaNet XML Feed Import Intiated ::"
    @env = Rails.env || "development"
    @logger.info "Environment => #{@env} ::"
    @lib_dir = File.expand_path(File.dirname(__FILE__))
    @zip_file = ARGV[1] || @lib_dir + "/RT-FULL-Feed-1_10_wMediaFiles_2011-05-25.zip"
    @logger.info "Unzipping file => #{@zip_file} ::"
    @outfile = Rails.root + "/tmp/medianet.xml"
    unzip_file
    #@databases = YAML.load_file(File.expand_path(Rails.root) + "/config/database.yml")
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    #ActiveRecord::Base.establish_connection(@databases[@env])
    #self.load_models
    @doc = self.load_xml
    @logger.info "XML File Loaded Successfully ::"
    @stats = self.show_stats
  end
  
  def do_import
    self.update_constants
    self.update_data
    @logger.info "XML File Was Imported Successfully ::"
  end
  
  def update_constants
    genre
    artist_types
    component_types
    metadata_types
    currency_codes
    label_owners
    labels
    price_scopes
    territories
    asset_types
  end
  
  def update_data
    components
    artists
    artist_components
    artist_metadata
    component_actions
    component_parents
    metadata
    related_components
    media_files
    wholesale_prices
    retail_prices
  end
  
  def load_models
    begin
      @logger.info "Models ::" + @lib_dir + '/../models/*.rb'
      Dir[@lib_dir + '/../models/*.rb'].each {|file| @logger.info "----> " + file }
      @logger.info "Models Loaded ::"
    rescue
      $stderr.puts "An error occurred: ",$!, "\n"
    end
  end
  
  def show_stats
    @stats = @doc.xpath("//Statistics")
  end
  
  def unzip_file
    begin
      Zip::ZipFile::open(@zip_file) do |zipfile|
        zipfile.each do |entry|
              #     
              @logger.debug "#{entry.name}"
              zipfile.extract(entry, @outfile) { true }
        end unless File.exist?(@outfile)
      end
      @logger.info "File was unzipped successfully to \"#{@outfile}\"::"
    rescue
      $stderr.puts "An error occurred: ",$!, "\n"
    end
  end
  
  def load_xml
    f = File.open(@outfile)
      doc = Nokogiri::XML(f)
    f.close
    doc
  end

  #XML PARSE-----------
  #Artists
  def artists
  # <Artist>
  #   <Id>17997</Id>
  #   <Amg-Id>P   542180</Amg-Id>
  #   <Name>Kelly Clarkson</Name>
  #   <Sort-Name>Clarkson, Kelly</Sort-Name>
  #   <Artist-Category>MUSIC</Artist-Category>
  #   <Created-Date>2003-06-06</Created-Date>
  #   <Last-Updated-Date>2005-01-14</Last-Updated-Date>
  # </Artist>
    nodes =  @doc.xpath("//Artists/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::Artist.new
          node.children.each do |c|
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Id'
                  m.id = c.child.text if c.child.text?
                when 'Amg-Id'
                  m.amg_id = c.child.text if c.child.text?
                when 'Name'
                  m.name = c.child.text if c.child.text?
                when 'Sort-Name'
                  m.sort_name = c.child.text if c.child.text?
                when 'Artist-Category'
                  m.artist_category = c.child.text if c.child.text?
                when 'Created-Date'
                  m.created_at = c.child.text if c.child.text?
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::Artist.where("id = ?", m.id).empty?
        end
        @logger.info "Artist's Updated"
      rescue => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No Artist's Present"
    end
  end
  
  #Artist Metadata
  def artist_metadata
  # <Artist-Metadata-Item>
  #   <Id>3</Id>
  #   <Artist-Id>1028037</Artist-Id>
  #   <Meta-Type-Id>57</Meta-Type-Id>
  #   <Value-Desc>687811</Value-Desc>
  #   <Created-Date>2010-04-13</Created-Date>
  #   <Last-Updated-Date>2011-02-15</Last-Updated-Date>
  #   </Artist-Metadata-Item>
  # <Artist-Metadata-Item>
    nodes =  @doc.xpath("//Artist-Metadata/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::ArtistMetadata.new
          node.children.each do |c|
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Id'
                  m.id = c.child.text if c.child.text?
                when 'Artist-Id'
                  m.artist_id = c.child.text if c.child.text?
                when 'Meta-Type-Id'
                  m.metadata_type_id = c.child.text if c.child.text?
                when 'Value-Desc'
                  m.value_desc = c.child.text if c.child.text?
                when 'Title'
                  m.title = c.child.text if c.child.text?
                when 'Created-Date'
                  m.created_at = c.child.text if c.child.text?
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::ArtistMetadata.where("id = ?", m.id).empty?
        end
        @logger.info "ArtistMetadata Updated"
      rescue   => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No ArtistMetadata Present"
    end
  end
  
  #ArtistComponent
  def artist_components
    # <Artist-Component>
    #     <Id>431772</Id>
    #     <Comp-Id>520765</Comp-Id>
    #     <Artist-Id>21950</Artist-Id>
    #     <Artist-Type-Id>2</Artist-Type-Id>
    #     <Ranking>1</Ranking>
    #     <Supplemental-Text>Executive Producer</Supplemental-Text>
    #     <Created-Date>2003-06-06</Created-Date>
    #     <Last-Updated-Date>2003-06-06</Last-Updated-Date>
    # </Artist-Component>
    nodes =  @doc.xpath("//Artist-Components/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::ArtistComponent.new
          node.children.each do |c|
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Id'
                  m.id = c.child.text if c.child.text?
                when 'Comp-Id'
                  m.component_id = c.child.text if c.child.text?
                when 'Artist-Id'
                  m.artist_id = c.child.text if c.child.text?
                when 'Artist-Type-Id'
                  m.artist_type_id = c.child.text if c.child.text?
                when 'Ranking'
                  m.ranking = c.child.text if c.child.text?
                when 'Supplemental-Text'
                  m.supplemental = c.child.text if c.child.text?
                when 'Created-Date'
                  m.created_at = c.child.text if c.child.text?
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::ArtistComponent.where("id = ?", m.id).empty?
        end
        @logger.info "ArtistComponent's Updated"
      rescue   => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No ArtistComponent's Present"
    end
  end
  
  #Artist-Types
  def artist_types
    # <Artist-Type>
    # <Id>16</Id>
    # <Type-Code>AUTHOR</Type-Code>
    # <Created-Date>2011-02-16</Created-Date>
    # </Artist-Type>
    nodes =  @doc.xpath("//Artist-Types/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::ArtistType.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Type-Code'
                m.type_code = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::ArtistType.where("id = ?", m.id).empty?
        end
        @logger.info "ArtistType's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No ArtistType's Present"
    end
  end
  
  #Asset-Types
  def asset_types
    # <Asset-Type>
    #         <Asset-Code>070</Asset-Code>
    #         <Asset-Code-Tag>a070</Asset-Code-Tag>
    #         <Description>MP3 Download 320 kbps cbr</Description>
    #         <Description-Code>MP3_DOWNLOAD_UENC_320kb_070</Description-Code>
    #         <Drm-Code>NA</Drm-Code>
    #         <File-Extension>mp3</File-Extension>
    #         <Buy-Price-Scope-Id>3</Buy-Price-Scope-Id>
    #     </Asset-Type>
    nodes =  @doc.xpath("//Asset-Types/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::AssetType.new
          node.children.each do |c|
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Asset-Code'
                  m.asset_code = c.child.text if c.child.text?
                when 'Asset-Code-Tag'
                  m.asset_code_tag = c.child.text if c.child.text?
                when 'Description'
                  m.description = c.child.text if c.child.text?
                when 'Description-Code'
                  m.description_code = c.child.text if c.child.text?
                when 'Drm-Code'
                  m.drm_code = c.child.text if c.child.text?
                when 'File-Extension'
                  m.file_extension = c.child.text if c.child.text?
                when 'Buy-Price-Scope-Id'
                  m.price_scope_id = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::AssetType.where("asset_code = ? ", m.asset_code).empty?
        end
        @logger.info "AssetType's Updated"
      rescue => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No AssetType's Present"
    end
    
  end
  
  #Components
  def components
    # <Component>
    #     <Id>39411383</Id>
    #     <Label-Id>803077</Label-Id>
    #     <Comp-Code>OVR323958</Comp-Code>
    #     <Comp-Type-Id>11</Comp-Type-Id>
    #     <Active-Status-Code>A</Active-Status-Code>
    #     <Title>Kaboom</Title>
    #     <Subtitle>Embracing The Suck In A Savage Little War</Subtitle>
    #     <Duration></Duration>
    #     <Parental-Advisory></Parental-Advisory>
    #     <Upc>NA</Upc>
    #     <Child-Items-Count>0</Child-Items-Count>
    #     <Release-Date>2010-03-02</Release-Date>
    #     <Cover-Art>FALSE</Cover-Art>
    #     <Short-Description></Short-Description>
    #     <Description></Description>
    #     <Exclusive-Ind>FALSE</Exclusive-Ind>
    #     <Created-Date>2010-04-14</Created-Date>
    #     <Last-Updated-Date>2010-06-14</Last-Updated-Date>
    # </Component>
    nodes = @doc.xpath("//Components/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::Component.new
          node.children.each do |c|
            if c.elem?
              #ap "-" * 10 + c.name + " :: " + c.child.to_s + "-" * 10
              unless c.child.nil?
                case c.name
                  when 'Id'
                    m.id = c.child.text if c.child.text?
                  when 'Label-Id'
                    m.label_id = c.child.text if c.child.text?
                  when 'Comp-Code'
                    m.comp_code = c.child.text if c.child.text?
                  when 'Comp-Type-Id'
                    m.component_type_id = c.child.text if c.child.text?
                  when 'Active-Status-Code'
                    m.active_status_code = c.child.text if c.child.text?
                  when 'Title'
                    unless c.child.nil?
                      m.title = c.child.text if c.child.text?
                    end
                  when 'Sort-Title'
                      m.sort_title = c.child.text if c.child.text?
                  when 'Subtitle'
                      m.subtitle = c.child.text if c.child.text?
                  when 'Duration'
                      m.duration = c.child.text if c.child.text?
                  when 'Parental-Advisory'
                      m.parental_advisory = c.child.text if c.child.text?
                  when 'Upc'
                      m.upc = c.child.text if c.child.text?
                  when 'Child-Items-Count'
                      m.child_items_count = c.child.text if c.child.text?
                  when 'Release-Date'
                      m.release_date = c.child.text if c.child.text?
                  when 'Cover-Art'
                      m.cover_art = c.child.text if c.child.text?
                  when 'Single'
                      m.single = c.child.text if c.child.text?
                  when 'Short-Description'
                      m.short_description = c.child.text if c.child.text?
                  when 'Description'
                      m.description = c.child.text if c.child.text?
                  when 'Season'
                      m.season = c.child.text if c.child.text?
                  when 'Exclusive-Ind'
                      m.exclusive_ind = c.child.text if c.child.text?
                  when 'Isrc'
                      m.isrc = c.child.text if c.child.text?
                  when 'Item-Number'
                      m.item_number = c.child.text if c.child.text?
                  when 'Disc-Number'
                      m.disc_number = c.child.text if c.child.text?
                  when 'Audio-Languages'
                      tmp=[]
                      c.children.each do |cc|
                        unless cc.child.nil?
                         tmp << cc.child
                        end
                      end
                      m.audio_languages = tmp * ","
                  when 'Subtitle-Languages'
                    tmp=[]
                    c.children.each do |cc|
                      unless cc.child.nil?
                       tmp << cc.child
                      end
                    end
                    m.subtitle_languages = tmp * ","
                  when 'Amg-Id'
                      m.amg_id = c.child.text if c.child.text?
                  when 'Muze-Id'
                      m.muze_id = c.child.text if c.child.text?
                  when 'Publish-Date'
                      m.publish_date = c.child.text if c.child.text?
                  when 'Created-Date'
                      m.created_at = c.child.text if c.child.text?
                  when 'Last-Updated-Date'
                      m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::Component.where("id = ?", m.id).empty?
        end
        @logger.info "Component's Updated"
      rescue => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No Component's Present"
    end
  end
  
  #ComponentActions
  def component_actions
  # <Component-Action>
  #     <Comp-Id>4025</Comp-Id>
  #     <Published-Date>2010-11-06</Published-Date>
  #     <Set-Purchasable-From><a075>2008-12-23</a075><a090>2008-12-23</a090><a100>2008-12-23</a100></Set-Purchasable-From>
  #     <Last-Updated-Date>2010-11-06</Last-Updated-Date>
  # </Component-Action>
    nodes =  @doc.xpath("//Component-Actions/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::ComponentAction.new
          node.children.each do |c|
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Comp-Id'
                  m.component_id = c.child.text if c.child.text?
                when 'Set-Purchasable-From'
                  tmp=[]
                  c.children.each do |cc|
                    unless cc.child.nil?
                     tmp << cc.child
                    end
                  end
                  m.set_purchase_from = tmp * ","
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::ComponentAction.where("component_id = ?", m.id).empty?
        end
        @logger.info "ComponentAction's Updated"
      rescue   => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No ComponentAction's Present"
    end
  end
  
  #Component-Types
  def component_types
    # <Component-Type>
    # <Id>12</Id>
    # <Type-Code>EB_TRACK</Type-Code>
    # <Parent-Ind>FALSE</Parent-Ind>
    # <Genre-Category>EBOOK</Genre-Category>
    # <Created-Date>2011-02-16</Created-Date>
    # </Component-Type>
    nodes = @doc.xpath("//Component-Types/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::ComponentType.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Type-Code'
                m.type_code = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              when 'Parent-Ind'
                m.parent_ind = c.child.text if c.child.text?
              when 'Genre-Category'
                m.genre_category = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::ComponentType.where("id = ?", m.id).empty?
        end
        @logger.info "ComponentType's Updated"
      rescue     => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No ComponentType's Present"
    end
  end
  
  #Component-Parents
  def component_parents
    #<Component-Parent>
    #   <Parent-Comp-Id>55</Parent-Comp-Id>
    #   <Child-Comp-Id>57</Child-Comp-Id>
    # </Component-Parent>
    nodes = @doc.xpath("//Component-Parents/*")
    if nodes.length > 0
      
        nodes.each do |node|
          m = Mnbackpack::ComponentParent.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Parent-Comp-Id'
                m.parent_component_id = c.child.text if c.child.text?
              when 'Child-Comp-Id'
                m.child_component_id = c.child.text if c.child.text?
              end
            end
          end
          begin
            m.save if Mnbackpack::ComponentParent.where("parent_component_id = ? AND child_component_id = ?", m.parent_component_id, m.child_component_id).empty?
          rescue => e
            $stderr.puts "An error occurred: ",$!, "\n"
          end
        end
        @logger.info "ComponentParent's Updated"
      
    else
      @logger.info "No ComponentParent's Present"
    end
  end
  
  #Genre
  def genre
    # <Id>1470</Id>
    # <Name>Nonfiction</Name>
    # <Genre-Category>EBOOK</Genre-Category>
    # <Genre-Type>MAIN</Genre-Type>
    # <Created-Date>2011-02-06</Created-Date>
    # <Last-Updated-Date>2011-02-06</Last-Updated-Date>
    # <Parent-Genre-Id></Parent-Genre-Id>
    nodes = @doc.xpath("//Genre-Reference/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::Genre.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Name'
                m.name = c.child.text if c.child.text?
              when 'Genre-Category'
                m.category = c.child.text if c.child.text?
              when 'Genre-Type'
                m.genre_type = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              when 'Last-Updated-Date'
                m.updated_at = c.child.text if c.child.text?
              when 'Parent-Genre-Id'
                m.parent_id = c.child.text if c.child.text?
              end
            end
          end 
          m.save if Mnbackpack::Genre.where("id = ?", m.id).empty?
        end
        @logger.info "Genre's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
       @logger.info "No Genre's Present"
    end
  end
   
  #Metadatas
  def metadata
    # <Metadata-Item>
    #     <Id>93240486</Id>
    #     <Comp-Id>12674569</Comp-Id>
    #     <Metadata-Type-Id>63</Metadata-Type-Id>
    #     <Metadata-Value>A10302B0000000GAEK</Metadata-Value>
    #     <Created-Date>2008-01-16</Created-Date>
    #     <Last-Updated-Date>2008-01-16</Last-Updated-Date>
    # </Metadata-Item>
    nodes = @doc.xpath("//Metadata/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::Metadata.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Comp-Id'
                m.component_id = c.child.text if c.child.text?
              when 'Metadata-Type-Id'
                m.metadata_type_id = c.child.text if c.child.text?
              when 'Metadata-Value'
                m.value = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              when 'Last-Updated-Date'
                m.updated_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::Metadata.where("id = ?", m.id).empty?
        end
        @logger.info "Metadata Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
       @logger.info "No Metadata Present"
    end
  end
  
  #Metadata-Types
  def metadata_types
    # <Metadata-Type>
    # <Id>72</Id>
    # <Type-Code>DISCS</Type-Code>
    # <Created-Date>2011-02-16</Created-Date>
    # </Metadata-Type>
    nodes = @doc.xpath("//Metadata-Types/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::MetadataType.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Type-Code'
                m.type_code = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::MetadataType.where("id = ?", m.id).empty?
        end
        @logger.info "MetadataType's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
       @logger.info "No MetadataType's Present"
    end
  end
  
  #Related-Components
  def related_components
    # <Related-Component>
    #     <Comp-Id>35989461</Comp-Id>
    #     <Related-Comp-Id>37985459</Related-Comp-Id>
    #     <Role>RELATED_AUDIO</Role>
    #     <Created-Date>2010-03-03</Created-Date>
    #     <Last-Updated-Date>2010-03-03</Last-Updated-Date>
    # </Related-Component>
    nodes = @doc.xpath("//Related-Components/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::RelatedComponent.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Comp-Id'
                m.component_id = c.child.text if c.child.text?
              when 'Related-Comp-Id'
                m.related_comp_id = c.child.text if c.child.text?
              when 'Role'
                m.role = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              when 'Last-Updated-Date'
                m.updated_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::RelatedComponent.where("component_id = ? AND related_comp_id = ?", m.component_id, m.related_comp_id).empty?
        end
        @logger.info "RelatedComponent's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No RelatedComponent's Present"
    end
  end
  
  #Media-Files
  def media_files
    # <File>
    #     <Comp-Id>44234785</Comp-Id>
    #     <Asset-Code>070</Asset-Code>
    #     <Name>44234785_070.mp3</Name>
    #     <File-Size>9738416</File-Size>
    #     <Bit-Rate>320</Bit-Rate>
    #     <Last-Updated-Date>2010-08-14</Last-Updated-Date>
    # </File>
    nodes =  @doc.xpath("//Media-Files/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::MediaFile.new
          node.children.each do |c|
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Comp-Id'
                  m.component_id = c.child.text if c.child.text?
                when 'Name'
                  m.name = c.child.text if c.child.text?
                when 'Asset-Code'
                  m.asset_code = c.child.text if c.child.text?
                when 'File-Size'
                  m.file_size = c.child.text if c.child.text?
                when 'Bit-Rate'
                  m.bit_rate = c.child.text if c.child.text?
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::MediaFile.where("component_id = ? AND name = ? AND file_size = ? AND bit_rate = ? ", m.component_id, m.name, m.file_size, m.bit_rate).empty?
        end
        @logger.info "MediaFile's Updated"
      rescue => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No MediaFile's Present"
    end
  end
  
  #Wholesale-Prices
  def wholesale_prices
    # <Wholesale-Price>
    #     <Comp-Id>57</Comp-Id>
    #     <Price-Scope-Id>1</Price-Scope-Id>
    #     <Territory-Id>228</Territory-Id>
    #     <Currency-Id>1</Currency-Id>
    #     <Price-Amount>.8</Price-Amount>
    #     <Effective-From-Date>1970-01-01</Effective-From-Date>
    #     <Effective-To-Date>9999-12-31</Effective-To-Date>
    #     <Created-Date>1970-01-01</Created-Date>
    #     <Last-Updated-Date>2010-05-03</Last-Updated-Date>
    # </Wholesale-Price>
    nodes =  @doc.xpath("//Wholesale-Prices/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::WholesalePrice.new
          node.children.each do |c|
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Comp-Id'
                  m.component_id = c.child.text if c.child.text?
                when 'Price-Scope-Id'
                  m.price_scope_id = c.child.text if c.child.text?
                when 'Territory-Id'
                  m.territory_id = c.child.text if c.child.text?
                when 'Currency-Id'
                  m.currency_id = c.child.text if c.child.text?
                when 'Price-Amount'
                  m.price_amount = c.child.text if c.child.text?
                when 'Effective-From-Date'
                  m.effective_from_date = c.child.text if c.child.text?
                when 'Effective-To-Date'
                  m.effective_to_date = c.child.text if c.child.text?
                when 'Created-Date'
                  m.created_at = c.child.text if c.child.text?
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::WholesalePrice.where("component_id = ?", m.component_id).empty?
        end
        @logger.info "WholesalePrice's Updated"
      rescue => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No WholesalePrice's Present"
    end
  end
  
  #Retail-Prices
  def retail_prices
    # <Wholesale-Price>
    #     <Comp-Id>57</Comp-Id>
    #     <Price-Scope-Id>1</Price-Scope-Id>
    #     <Territory-Id>228</Territory-Id>
    #     <Currency-Id>1</Currency-Id>
    #     <Price-Amount>.8</Price-Amount>
    #     <Effective-From-Date>1970-01-01</Effective-From-Date>
    #     <Effective-To-Date>9999-12-31</Effective-To-Date>
    #     <Created-Date>1970-01-01</Created-Date>
    #     <Last-Updated-Date>2010-05-03</Last-Updated-Date>
    # </Wholesale-Price>
    nodes =  @doc.xpath("//Retail-Prices/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::RetailPrice.new
          node.children.each do |c|
            
            if c.elem?
              unless c.child.nil?
                case c.name
                when 'Comp-Id'
                  m.component_id = c.child.text if c.child.text?
                when 'Price-Scope-Id'
                  m.price_scope_id = c.child.text if c.child.text?
                when 'Territory-Id'
                  m.territory_id = c.child.text if c.child.text?
                when 'Currency-Id'
                  m.currency_id = c.child.text if c.child.text?
                when 'Price-Amount'
                  m.price_amount = c.child if c.child.text?
                  #ap "-" * 10 + c.name + " :: "+ c.child.text + " :: #{m.price_amount}" + "-" * 10
                when 'Effective-From-Date'
                  m.effective_from_date = c.child.text if c.child.text?
                when 'Effective-To-Date'
                  m.effective_to_date = c.child.text if c.child.text?
                when 'Created-Date'
                  m.created_at = c.child.text if c.child.text?
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
                end
              end
            end
          end
          m.save if Mnbackpack::RetailPrice.where("component_id = ?", m.component_id).empty?
        end
        @logger.info "RetailPrice's Updated"
      rescue => e
        puts e.message
        puts e.backtrace
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No RetailPrice's Present"
    end
  end
  
  #Currency-Codes
  def currency_codes
    begin
      if Mnbackpack::Currency.where("id IN (1,2,3,4)").empty?
        Mnbackpack::Currency.create({:id => 1, :code => "USD", :name => "USA Dollar"})
        Mnbackpack::Currency.create({:id => 2, :code => "CAD", :name => "Canadian Dollar"})
        Mnbackpack::Currency.create({:id => 3, :code => "GBP", :name => "British Pound"})
        Mnbackpack::Currency.create({:id => 4, :code => "EUR", :name => "Euro"})
      else
        @logger.info "Currency Updated"
      end
     #
   rescue
     $stderr.puts "An error occurred: ",$!, "\n"
   end
  end
  
  def labels
  # <Label>
  #     <Id>928360</Id>
  #     <Label-Owner-Id>1305</Label-Owner-Id>
  #     <Label-Name>HarperCollins</Label-Name>
  #     <Active-Status-Code>A</Active-Status-Code>
  #     <Created-Date>2010-09-25</Created-Date>
  #     <Last-Updated-Date>2010-09-25</Last-Updated-Date>
  # </Label>
    nodes = @doc.xpath("//Labels/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::Label.new
          node.children.each do |c|
            if c.elem?
              case c.name
                when 'Id'
                  m.id = c.child.text if c.child.text?
                when 'Label-Owner-Id'
                  m.label_owner_id = c.child.text if c.child.text?
                when 'Label-Name'
                  m.name = c.child.text if c.child.text?
                when 'Active-Status-Code'
                  m.active = c.child.text if c.child.text?
                when 'Created-Date'
                  m.created_at = c.child.text if c.child.text?
                when 'Last-Updated-Date'
                  m.updated_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::Label.where("id = ?", m.id).empty?
        end
        @logger.info "Label's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
   else
      @logger.info "No Label's Present"
    end
  end
  
  #Label-Owners
  def label_owners
  # <Label-Owner>
  # <Id>286</Id>
  # <Corp-Code>KCD</Corp-Code>
  # <Label-Owner-Name>Koch Distribution</Label-Owner-Name>
  # <Active-Status-Code>A</Active-Status-Code>
  # <Created-Date>2006-01-09</Created-Date>
  # <Last-Updated-Date>2007-07-31</Last-Updated-Date>
  # </Label-Owner>
    nodes = @doc.xpath("//Label-Owners/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::LabelOwner.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Corp-Code'
                m.corp_code = c.child.text if c.child.text?
              when 'Label-Owner-Name'
                m.name = c.child.text if c.child.text?
              when 'Active-Status-Code'
                m.active = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              when 'Last-Updated-Date'
                m.updated_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::LabelOwner.where("id = ?", m.id).empty?
        end
        @logger.info "LabelOwner's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No LabelOwner's Present"
    end
  end
  
  #Price-Scopes
  def price_scopes
  # <Price-Scope>
  # <Id>5</Id>
  # <Scope-Code>EPUB</Scope-Code>
  # <Description>Price paid for purchase of EPUB content.</Description>
  # <Created-Date>2011-02-16</Created-Date>
  # </Price-Scope>
    nodes = @doc.xpath("//Price-Scopes/*")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::PriceScope.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Scope-Code'
                m.code = c.child.text if c.child.text?
              when 'Description'
                m.description = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::PriceScope.where("id = ?", m.id).empty?
        end
        @logger.info "PriceScope's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
      @logger.info "No PriceScope's Present"
    end
  end
  
  #Territory-Codes
  def territories
    # <Id>227</Id>
    # <Territory-Code>GB</Territory-Code>
    # <Territory-Name>United Kingdom</Territory-Name>
    # <Created-Date>2001-04-24</Created-Date>
    nodes = @doc.xpath("//Territory")
    if nodes.length > 0
      begin
        nodes.each do |node|
          m = Mnbackpack::Territory.new
          node.children.each do |c|
            if c.elem?
              case c.name
              when 'Id'
                m.id = c.child.text if c.child.text?
              when 'Territory-Code'
                m.code = c.child.text if c.child.text?
              when 'Territory-Name'
                m.name = c.child.text if c.child.text?
              when 'Created-Date'
                m.created_at = c.child.text if c.child.text?
              end
            end
          end
          m.save if Mnbackpack::Territory.where("id = ?", m.id).empty?
        end
        @logger.info "Territory's Updated"
      rescue
        $stderr.puts "An error occurred: ",$!, "\n"
      end
    else
       @logger.info "No TerritoryCode's Present"
    end
  end
  #End of class
end

#mn = MNImport.new
#mn.do_import
#puts mn.stats
# dir_name = Time.now.utc.strftime("%Y%m%d%H%M%S")


