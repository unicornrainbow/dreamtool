class LinearMeasure
  attr_reader :value
  attr_reader :units

  def initialize(value, units=nil)
    if value.is_a? String
      @value, @units = parse(value)
    else
      @value, @units = value, units
    end
  end

  def self.parse(string)
    string =~ /(\d*)(\w*)/
    value, units = $~[1].to_i, $~[2]
  end

  def to_s
    "#{value}#{units}"
  end

  private

  def parse(value)
    LinearMeasure.parse(value)
  end
end
