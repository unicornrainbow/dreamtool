class LayoutModule::CaptureConcat < SimpleDelegator
  attr_reader :captured_content

  def concat(value)
    @captured_content ||= "".html_safe
    @captured_content << value.html_safe
  end
end
