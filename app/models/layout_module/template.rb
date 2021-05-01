require  'layout_module'

class LayoutModule
  class Template
    def initialize(layout_module, name)
      @layout_module = layout_module
      @name = name
    end

    def render(view, *args, &block)
      _layouts, view.layouts = view.layouts, []

      content = view.capture(&block) if block_given?
      content = tilt.render(view, *args) { content }.html_safe

      while layout = view.layouts.pop
        template_name = layout.shift
        content = view.layout_module.templates[template_name].render(view, *layout) { content }
      end

      view.layouts = _layouts
      content
    end

  private

    # Returns tilt template
    def tilt
      @tilt ||= begin
        file_name = "#{templates_root}/#{@name}.html"
        ext = resolve_ext(file_name)
        file_name << ".#{ext}"
        tilt = Tilt.new(file_name)
     end
    end

    # Resolve which type of template (erb, haml, slim...)
    def resolve_ext(file_name)
      SUPPORTED_TEMPLATE_FORMATS.find { |ext| File.exists?("#{file_name}.#{ext}") }
    end

    def templates_root
      @root ||= "#{@layout_module.root}/templates"
    end

  end
end
