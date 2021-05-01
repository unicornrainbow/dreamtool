module Liquid
  # See: lib/liquid/tags/include.rb in the Liquid project.
  class DatabaseFileSystem
    # Called by Liquid to retrieve a template file
    def read_template_file(template_name)
      Partial.where(name: template_name).first.source
    end
  end
end
