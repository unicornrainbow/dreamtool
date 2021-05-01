require  'layout_module'

class LayoutModule
  class View < SimpleDelegator

    def render(name, *args, &block)
      layout_module.templates[name].render(self, *args, &block)
    end

    def stylesheet_link_tag(name, options={})
      asset_recorder.try(:stylesheet, "#{name}.css")
      %Q{<link href="#{name}.css" rel="stylesheet" media="all" />}
    end

    def javascript_include_tag(name)
      asset_recorder.try(:javascript, "#{name}.js")
      %Q{<script src="#{name}.js" type="text/javascript"></script>}
    end

  end
end
