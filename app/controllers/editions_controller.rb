class EditionsController < ApplicationController
  wrap_parameters include: [*Edition.attribute_names, :sections_attributes, :pages_attributes, :content_items_attributes, :groups_attributes, :colors_attributes, :masthead_artwork_attributes]

  before_action :find_edition, only: [:compose, :preview, :compile, :download, :edit, :update, :show, :wip, :tearout]
  before_action :detect_mobile, only: :compose

  skip_before_action :track_hit, only: [:wip]
  skip_before_action :verify_authenticity_token, only: :import

  respond_to :html, :json

  def index
    if current_user
      @editions = current_user.editions.desc(:updated_at)
    else
      @editions =
        Edition.nouser
          .desc(:updated_at)
    end
  end

  def new
    @publications = current_user.publications
    @publication = params[:publication_id] ? Publication.find(params[:publication_id]) : Publication.first
    @publication = Publication.new
    @edition = @publication.build_edition
  end

  def composer
    flash[:notice] # Clear flash, since it's not currently displayed anywhere

    @section = @edition.sections.build(path: "main.html")
    @section.pages.build(number: 1)

    # Set composing flag as indication to layout_module.
    @composing = true

    # Reconstruct path with extension
    @path = "main.html"

    # Find section by path of edition.
    @section       = @edition.sections.find_by(path: @path)

    @pages         = @section.pages || []
    @layout_name   = @edition.layout_name
    @template_name = @section.template_name.presence || @edition.default_section_template_name
    @title         = @section.page_title.presence || @edition.page_title
    @layout_module = LayoutModule.new(@layout_name) # TODO: Rename to MediaModule
    @content_item = ContentItem.new

    # Sets config values which are avialable client-side at `Newstime.config`.
    set_client_config

    render 'compose', layout: 'layout_module'
  end

  def create
         pub_name = params.dig :publication, :name
    edition_title = params.dig :edition, :title

    if pub_name
      @publication = current_user.publications.where(name: pub_name).first
      unless @publication
        @publication = Publication.create(
          user: current_user,
          name: pub_name
        )
      end

      @edition = @publication.editions.new(
        user: current_user,
        name: edition_title,
        layout_name: 'default',
        has_sections: false
      )

      # Add first page.
      # @page = @edition.pages.build(number: 1)
      # @page.section = @section
      # @edition.build_page(number: 1)

      sections_attributes = JSON.parse(@publication.default_section_attributes)
      sections_attributes.each do |section_attributes|
        pages_attributes = section_attributes.delete("pages_attributes")
        section = @edition.sections.build(section_attributes)
        if pages_attributes
          pages_attributes.each do |page_attributes|
            page = @edition.pages.build(page_attributes)
            page.section = section
          end
        end
      end

      if @edition.save
        #redirect_to @edition, notice: "Edition created successfully."
        redirect_to compose_edition_path(@edition)
      else
        render "new"
      end

    end
    # if
    # @publication = Publication.find_by(name: params[:publication][:name])
    # render text: params[:publication_name]
  end

  def edit
  end

  def compose
    flash[:notice] # Clear flash, since it's not currently displayed anywhere

    # Redirect to main if no path specified.
    # redirect_to (send("#{params[:action]}_edition_path".to_sym, @edition.slug || @edition) + '/main.html') and return unless params['path']
    unless params['path']
      redirect_to request.url + '/main.html' and return
    end

    # if @edition.user
    #   unless current_user == @edition.user
    #     not_authorized and return
    #   end
    # end
    #
    # def 🍬
    #   puts "Yummy"
    # end
    #
    # ⚠️ 🍷 ☕️ 🍩
    #
    # 🍵

    # Set composing flag as indication to layout_module.
    @composing = params[:action] == 'compose'

    # Reconstruct path with extension
    @path = "#{params['path'] || 'main'}.html"

    # Find section by path of edition.
    @section       = @edition.sections.find_by(path: @path)

    @pages         = @section.pages || []
    @layout_name   = @edition.layout_name
    @template_name = @section.template_name.presence || @edition.default_section_template_name
    @title         = @section.page_title.presence || @edition.page_title
    @layout_module = LayoutModule.new(@layout_name) # TODO: Rename to MediaModule
    @content_item  = ContentItem.new

    # Sets config values which are avialable client-side at `Newstime.config`.
    set_client_config

    set_workspace

    render 'compose', layout: 'layout_module'
  end


  alias :preview :compose

  def tearout
    # render text: params['path']
    # @path = "#{params['path']}.html"
    @story_title = params['path']

    @layout_name   = @edition.layout_name
    @layout_module = LayoutModule.new(@layout_name)

    # Find story by story title...
    @content_item = @edition.content_items.where(story_title: @story_title).first

    @group = @content_item.group

    @width = @content_item.width

    # @section       = @edition.sections.find_by(path: @path)
    # @pages         = @section.pages || []

    render 'tearout', layout: 'layout_module'
  end

  def update
    #Rails.logger.info "Updateing Edition Attributes"

    @edition.update_attributes(edition_params)
    @edition.update_attribute :has_sections, edition_params[:has_sections] == '1'

    @edition.update_attribute :slug, edition_params[:name].parameterize

    # Update WIP Screenshot
    WIPWorker.perform_async(@edition.id.to_s)

    #Rails.logger.info "Edition Attributes Updated"
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { respond_with @edition.to_json }
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to action: :compose }
      format.json { respond_with @edition }
    end
  end

  def destroy
    @edition = Edition.find(params[:id]).destroy
    redirect_to editions_path, notice: "Edition deleted successfully."
  end

  def download
    render layout: false
  end

  def compile
    @path = "#{params['path']}.html"
    @section = @edition.sections.where(path: @path).first
    section_compiler = SectionCompiler.new(@section)
    section_compiler.compile!
    render text: section_compiler.html
  end

  def wip
    screenname = @edition.user.screenname
    id = @edition.id.to_s[0..7]
    send_file "#{Rails.root}/share/#{screenname}/#{id}/wip.png"
  end

  def import
    if request.method == "POST"

      edp = JSON.parse(params[:edition])
      ats = edp.slice(*Edition.attribute_names)

      edition = Edition.find(edp['_id'])

      if edition
        edition.update(ats)
        # edition.sections.delete_all
        # edition.pages.delete_all
        edition.colors.delete_all
        # edition.sections_attributes = edp["sections_attributes"]
        # edition.pages_attributes = edp["pages_attributes"]
        # edition.pages
        # edition.update(edp)
      else
        edition = Edition.new(ats)
      end

      # Sections
      edp["sections_attributes"].each do |moo|
        section = edition.sections.find(moo["_id"])
        if section
          section.update(moo)
        else
          section = edition.sections.new(moo)
        end
      end

      # Pages
      edp["pages_attributes"].each do |pat|
        page = edition.pages.find(pat["_id"])
        pat.delete('page_ref')
        if page
          page.update(pat)
        else
          page = edition.pages.new(pat)
        end
      end

      # Groups
      edp["groups_attributes"].each do |gats|
        group =
        edition.groups.
        find(gats["_id"])

        if group
          group.update(gats)
        else
          group = edition.groups.
                 new(gats)
        end
      end

      # Content Items
      edp["content_items_attributes"].each do |cats|
        content_item =
        edition.content_items.
        find(cats["_id"])

        if content_item
          content_item.update(cats)
        else
          content_item=
          edition.content_items.
          new(cats)
        end
      end

      # Colors
      edp["colors_attributes"].each do |kat|
        kolor =
        edition.colors.
        find(kat["_id"])

        if kolor
          kolor.update(kat)
        else
          kolor = edition.colors.
                 new(kat)
        end
      end

      # edition.groups_attributes =
      # edp["groups_attributes"]
      # edition.colors.build(edp["colors_attributes"])
      # edition.colors_attributes =
      # edp["colors_attributes"]
      edition.save

      redirect_to edition
      return


      edition = Edition.new(ats)
      edition.reload
      edition.save
      redirect_to edition
      # render text: edp.slice(*Edition.attribute_names)
      return
      # render text: edp
      # edition = Edition.find(edp["_id"])
      # render text: edition.name
      # render text: edp["_id"]
      edition = Edition.new(edp)
      edition.save
      return
      edition = Edition.create(edp)
      redirect_to edition


      m = JSON.parse(params[:edition])

      m[]

    end


  end

private

  def detect_mobile
    # Try to detect mobile from User-Agent
    @mobile = request.headers['User-Agent'] =~ /Mobile|Android/

    # Allow mobile to be requested with url param
    @mobile ||= params['mobile'] == 'true'
  end

  def set_client_config
    @client_config = {
      editionID:  @edition.id,
      sectionID:  @section.id,
      headlineFontWeights: @layout_module.config["headline_font_weights"],
      storyTextLineHeight: @layout_module.config["story_text_line_height"],
      mobile: @mobile
    }
  end

  def set_workspace
    if current_user
      if current_user.workspace
        @workspace = current_user.workspace
      else
        @workspace = current_user.create_workspace
      end
    else
      @workspace = {}
    end
  end

  def edition_params
    content_item_attributes =
      (ContentItem.attribute_names +
      PhotoContentItem.attribute_names +
      TextAreaContentItem.attribute_names +
      VideoContentItem.attribute_names +
      HeadlineContentItem.attribute_names +
      DividerContentItem.attribute_names +
      HTMLContentItem.attribute_names
      ).uniq

    params.require(:edition).
      permit(:title, :name, :publication_name, :slug,
             :sections_attributes => [Section.attribute_names],
             :pages_attributes => [Page.attribute_names],
             :groups_attributes => [Group.attribute_names],
             :content_items_attributes => [content_item_attributes],
             :colors_attributes => [Color.attribute_names],
             :masthead_artwork_attributes => [:height, :lock]
            )
  end

end
