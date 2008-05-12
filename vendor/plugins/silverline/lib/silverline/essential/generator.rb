# NOTE: requires filesystemwatcher to be installed
# http://www.jhorman.org/FileSystemWatcher/index.html
require "filesystemwatcher"
require 'silverline/essential/xap'

# Generates the XAP on modification of watched files
module Silverline::Essential::Generator
  include Silverline
  Xap = Silverline::Essential::XAPChiron
  
  # List of files/directories to watch for modification.
  # Triggers generation of the Silverlight package (XAP)
  def self.register
    puts "** Initializing Silverlight"
    watcher = FileSystemWatcher.new
    watcher.addDirectory CLIENT_ROOT
    watcher.addDirectory PLUGIN_CLIENT
    
    # TODO: watch all client controllers, as well as all views
    watcher.addFile "#{RAILS_ROOT}/app/controllers/client_controller.rb"
    watcher.addDirectory RAILS_VIEWS
    
    watcher.sleepTime = 1
    watcher.start { |status, file| generate }
    generate # make sure to generate XAPs the first time
  end
  
  def self.generate
    puts "** Generating client.xap"
    %W(#{XAP_FILE}).each do |file|
      File.delete(file) if File.exists?(file)
    end
    
    # First copy the plugin's client folder to tmp folder
    FileUtils.cp_r "#{Silverline::PLUGIN_CLIENT}/.", TMP_CLIENT
    
    # TODO: copy all controllers, views, and models to tmp folder
    FileUtils.mkdir_p "#{TMP_CLIENT}/controllers"
    FileUtils.mkdir_p "#{TMP_CLIENT}/views"
    FileUtils.cp 'app/controllers/client_controller.rb', "#{TMP_CLIENT}/controllers"
    FileUtils.cp_r "#{RAILS_VIEWS}/.", "#{TMP_CLIENT}/views"
    
    # Lastly, client root wins
    FileUtils.cp_r "#{CLIENT_ROOT}/.", TMP_CLIENT
    Xap.new(XAP_FILE, TMP_CLIENT).generate
    
    FileUtils.rm_r TMP_CLIENT
  end
end