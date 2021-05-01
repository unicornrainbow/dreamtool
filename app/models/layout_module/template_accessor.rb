require  'layout_module'

class LayoutModule
  class TemplateAccessor

    def initialize(layout_module)
      @layout_module = layout_module
    end

    def [](name)
      Template.new(@layout_module, name)
    end

  end
end
