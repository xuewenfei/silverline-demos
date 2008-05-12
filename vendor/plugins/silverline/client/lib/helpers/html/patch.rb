include System::Windows::Browser

class HtmlDocument
  def method_missing(m, *args)
    super
  rescue => e
    id = get_element_by_id(m)
    return id unless id.nil?
    raise e  
  end

  alias_method :orig_get_element_by_id, :get_element_by_id
  def get_element_by_id(id)
    orig_get_element_by_id(id.to_s.to_clr_string)
  end
end

class HtmlElement
  def [](index)
    val = get_attribute(index)
    return get_property(index) if val.nil?
    return val
  end

  def []=(index, value)
    val = get_attribute(index)
    val.nil? ? set_property(index, value) : set_attribute(index, value)
  end

  def method_missing(m, *args, &block)
    super
  rescue => e
    if(block.nil?)
      id = self[m] 
      return id unless id.nil?
      raise e
    else
      unless attach_event(m.to_s.to_clr_string, System::EventHandler.new(&block))
        raise e
      end
    end
  end

  def style
    HtmlStyle.new(self)
  end

  alias_method :orig_get_attribute, :get_attribute
  def get_attribute(index)
    orig_get_attribute(index.to_s.to_clr_string)
  end

  alias_method :orig_set_attribute, :set_attribute
  def set_attribute(index, value)
    orig_set_attribute(index.to_s.to_clr_string, value)
  end

  alias_method :orig_get_property, :get_property
  def get_property(index)
    orig_get_property(index.to_s.to_clr_string)
  end

  alias_method :orig_set_property, :set_property
  def set_property(index, value)
    orig_set_property(index.to_s.to_clr_string, value)
  end

  alias_method :orig_get_style_attribute, :get_style_attribute
  def get_style_attribute(index)
    orig_get_style_attribute(index.to_s.to_clr_string)
  end

  alias_method :orig_set_style_attribute, :set_style_attribute
  def set_style_attribute(index, value)
    orig_set_style_attribute(index.to_s.to_clr_string, value)
  end
end

class HtmlStyle
  def initialize(element)
    @element = element
  end

  def [](index)
    @element.get_style_attribute(index)
  end 

  def []=(index, value)
    @element.set_style_attribute(index, value)
  end

  def method_missing(m)
    super
  rescue => e
    style = self[m]
    return style unless style.nil?
    raise e
  end
end