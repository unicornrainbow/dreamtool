class GridCompositionRow
  attr_reader :content_regions, :more_room, :columns_width_remaining, :sequence

  def initialize(sequence, content_regions)
    @content_regions = content_regions
    @sequence = sequence
    @total_available_columns = 24
    @content_regions = @content_regions
    @columns_width_remaining ||= @total_available_columns - @content_regions.sum(&:column_width)

    # TODO: Drive from grid division selection for organization, publication,
    # edition, or page...
    @more_room = @columns_width_remaining > 0
  end

  alias :more_room? :more_room

end
