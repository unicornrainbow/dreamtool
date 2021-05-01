# GridComposition: Formats page into a grid for rendering.
class GridComposition
  def initialize(page)
    @page = page
  end

  def rows
    @rows ||= begin
      grouped_content_regions = @page.content_regions.group_by(&:row_sequence)
      grouped_content_regions.each.map do |i, content_regions|
        GridCompositionRow.new(i, content_regions.sort_by(&:sequence))
      end
    end
  end

  def more_room?
    true
  end

  def next_row_sequence
    rows.count + 1
  end
end
