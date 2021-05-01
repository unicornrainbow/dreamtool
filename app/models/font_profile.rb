class FontProfile

  def self.get(profile_name)
    path = File.join(Rails.root, "config", 'font_profiles', "#{profile_name}_profile.json")
    json = File.read(path)
    JSON.parse(json)
  end

end
