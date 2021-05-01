# Media Module Intializer

# Example:
#
#   # get path for a media module
#   MEDIA_MODULES['sfrecord']

file_path = File.expand_path('../media_modules.yml', __dir__)

if File.exists?(file_path)
  # Read in media module configuration to a global constant.
  MEDIA_MODULES = YAML::load_file(file_path)
else
  MEDIA_MODULES = {}
end

# Set default media module
MEDIA_MODULES['default'] = { 'path' => 'etc/default_layout' }

# Expand Paths relative to project root
MEDIA_MODULES.map do |k, v|
  v["path"] = File.expand_path(v["path"], Rails.root)
end
