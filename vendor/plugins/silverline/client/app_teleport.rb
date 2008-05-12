require 'silverlight'
require 'controllers/application'

# This is the Silverlight router for Rails Controllers. It first hooks
# any links marked as Silverlight links to the correct actions. When a client
# action is triggered, it figures out which Controller and Action to render
# 
# To hook Silverlight links, it takes one special initParam ":client_links", 
# which is a list of unique identifiers and url_for-action-syntax for all 
# the client links on the page. It then grabs those links and hooks them
# with the appropriate action.
class Teleport < SilverlightApplication
  def initialize
    super
    unless params[:client_links].to_s == "null"
      @client_links = dejsonify(params[:client_links])
      find_client_links.each { |a| hook_client_link(a) }
    end
  end
  
  private
  
    def find_client_links
      $app.puts params[:client_links]
      $app.puts @client_links.inspect
      titles = @client_links.collect { |l| puts l.keys.inspect; l.fetch("title") }
      $app.puts titles.inspect
      document.get_elements_by_tag_name("a").select {
        |a| titles.include?(a.title) && a.rel == "silverlight".to_clr_string
      }
    end
  
    def hook_client_link(a)
      $app.puts "hooking stuff"
      link = @client_links.select{ |l| l['title'] == a[:title] }.first
        $app.puts "hooking stuff"
      unless link.nil?
        $app.puts "hooking stuff"
        a.onclick { |s, e| do_action(link['options']) }
        a.remove_attribute("title")
      end
    end
  
    def do_action(options)
      #TODO: don't hardcode controller!
      require 'controllers/client_controller'
      controller = ClientController
      c = controller.new
      c.host = self
      c.send(options['url']['action'])
    end
end

Teleport.new