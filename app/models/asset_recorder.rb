# Utility class for collecting which assets were called during render
class AssetRecorder
  attr_reader :stylesheet_assets, :javascript_assets

  def initialize
    @stylesheet_assets = []
    @javascript_assets = []
  end

  def stylesheet(path)
    @stylesheet_assets << path
  end

  def javascript(path)
    @javascript_assets << path
  end

end
