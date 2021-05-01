class LayoutModule
  attr_reader :name, :root, :templates, :partials

  SUPPORTED_TEMPLATE_FORMATS = [:erb, :haml, :slim]

  def initialize(name)
    @name = name
    @root = MEDIA_MODULES[@name]["path"]
    @templates = TemplateAccessor.new(self)
  end

  def config
    @config ||= YAML.load_file(File.join(@root, 'config.yml'))
  end

end
