# Date Extensions
class Date

  # strftime using %
  def %(fmt)
    strftime(fmt)
  end

  alias :strf :strftime

end

# The date is Today!
class Today < Date
  def self.to_mdy
    today.strf('%m/%d/%Y')
  end

  def self.date
    to_mdy
  end
end
