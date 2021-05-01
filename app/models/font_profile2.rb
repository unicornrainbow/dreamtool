class FontProfile2

  def self.get(profile_name)
    path = File.join(Rails.root, "config", 'font_profiles', "#{profile_name}_profile.json")
    json = File.read(path)
    FontProfile2.new(JSON.parse(json))
  end

  def initialize(json)
    @json = json
  end

  def width_of(string)
    string.chars.map { |char| @json["normal"]["map"][char.ord.to_s] }.sum
  #rescue => e
    #debugger
    #true
  end

end
