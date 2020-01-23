class Edition
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

  include TryHelper

  ## Attributes
  field :title
  field :publication_name

  field :name
  field :page_title,       type: String
  field :path,             type: String
  field :html,             type: String     # The render html source markup
  field :layout_name,      type: String
  field :slug,             type: String
  field :publish_date,     type: DateTime
  field :grid_size,        type: String

  field :page_color,       type: String
  field :ink_color,        type: String
  field :links_color,      type: String
  field :line_color,       type: String
  field :selection_color,  type: String
  #field :fmt_price,        type: String  # Formatted price string

  field :has_sections,     type: Boolean # True or false, depending if section bar should be
                                         # shown and sections, if any, rendered.

  # Grid stuff, should be isolated
  field :page_width,       type: Integer
  field :columns,          type: Integer
  field :gutter_width,     type: Integer
  field :extra_grids,      type: Array

  field :volume_label, type: String  # Formatted price string
  field :page_pixel_height, type: Integer, default: 1200  # Default pixel height of pages in edition

  # A default option inherited by the sections when template name isn't set
  field :default_section_template_name, type: String, default: "default"

  ## Relationships
  embeds_many  :sections
  embeds_many  :pages
  embeds_many  :content_items
  embeds_many  :groups
  embeds_many  :colors

  embeds_one :masthead  # For future use. Editions and sections should be able to have configurable mastheads in the object model.

  has_one :masthead_artwork

  accepts_nested_attributes_for :sections
  accepts_nested_attributes_for :pages
  accepts_nested_attributes_for :content_items
  accepts_nested_attributes_for :groups
  accepts_nested_attributes_for :colors
  accepts_nested_attributes_for :masthead_artwork

  has_many :prints, :order => :created_at.desc


  #belongs_to :organization
  belongs_to :user
  belongs_to :publication, inverse_of: :editions


  scope :nouser, -> { where(user: nil) }

  # Methods

  # Resolves and returns all images referenced in the edition.
  def resolve_photos
    # Edition > Sections > Pages > Content Regions > Photo Content Items > Photos

    photos = []
    sections.each do |section|
      section.pages.each do |page|
        photos += page.content_items.where(_type: 'PhotoContentItem').map(&:photo)
      end
    end

    photos.compact
  end


  def resolve_videos
    # Edition > Sections > Pages > Content Regions > Photo Content Items > Photos

    videos = []
    sections.each do |section|
      section.pages.each do |page|
        videos += page.content_items.where(_type: 'VideoContentItem').map do |content_item|
          Video.find_by(name: content_item.video_name)
        end
      end
    end
    videos.compact
  end

  def resolve_fonts
    fonts = []
    default_weight = '500'

    # Collect Headline Fonts
    sections.each do |section|
      section.pages.each do |page|

        fonts += page.content_items.where(_type: 'HeadlineContentItem').map do |headline|
          puts 'love'
          family = headline.font_family
          family = family.split(',')[0]
          style  = headline.font_style
          weight = headline.font_weight || default_weight
          "#{family}/#{style}/#{weight}"
        end

      end
    end

    fonts.compact.uniq

  end

  def layout_module
    @layout_module ||= LayoutModule.new(layout_name)
  end

  def layout_module_root
    layout_module.root
  end

  def to_param
    slug || id.to_param
  end

  ## Liquid
  #liquid_methods :title


  before_save do
    # HACK: Typeset content_items with changes
    # content_items.where('_type' => 'TextAreaContentItem').each do |content_item|
    #   content_item.typeset!(layout_module) if content_item.changed?
    # end
  end
end

class EditionBackup < Edition
end
