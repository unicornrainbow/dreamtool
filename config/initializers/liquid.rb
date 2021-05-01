require 'liquid/database_file_system'

Liquid::Template.file_system = Liquid::DatabaseFileSystem.new
