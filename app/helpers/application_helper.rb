module ApplicationHelper
  include NavbarHelper

  # TODO: add documentation.
  def parent_layout(layout)
    @view_flow.set(:layout,output_buffer)
    self.output_buffer = render(:file => "layouts/#{layout}")
  end

  # Returns true is the path matches the passed regular expression.
  def path_matches?(value)
    case value
    when String
      # Match leading / from the begin, otherwise do fuzzy match

      if value[0] == "/"
        value = /^#{value.to_s}/
      else
        value = /#{value.to_s}/
      end
    end
    request.fullpath.match(value)
  end

  # Return class "active" if path matches path passed.
  #
  # Helpful for generating bootstrap active classes for menu items.
  #
  # Example:
  #
  #     <li class="<%= active('/radio') %>"><a href="/radio">Radio</a></li>
  #
  def active(path, active_class="active")
    active_class if path_matches?(path)
  end

  def dropdown_menu(title, &block)
    tmp, @dropdown_active_paths = @dropdown_active_paths, []
    content = [
      content_tag('a', title.html_safe, href: "#", class: "dropdown-toggle", "data-toggle" => "dropdown"),
      content_tag('ul', capture(&block), class: "dropdown-menu")
    ].join
    active = @dropdown_active_paths.any? { |path| path_matches?(path) }
    @dropdown_active_paths, tmp = tmp, @dropdown_active_paths
    @dropdown_active_paths += tmp if @dropdown_active_paths
    content = content_tag('li', content.html_safe, class: "dropdown #{"active" if active}".html_safe ).html_safe
  end


  def navbar_li(title, url=nil, options={})
    options[:active_path] ||= url
    content = title

    if url
      content = content_tag('a', title, href: url)
      @dropdown_active_paths << options[:active_path] if @dropdown_active_paths
    end

    li_options = {}
    if options[:active_path]
      li_options[:class] = active(options[:active_path])
    end

    content_tag('li', content.html_safe, li_options).html_safe
  end

  def options_url(path, options)
    "#{path}?#{@options.merge(options).to_param}"
  end

  def format_date(date)
    date.localtime.try(:strftime, "%D")
  end

  def format_date_and_time(date)
    date.localtime.try(:strftime, "%D %l:%M%P")
  end

  def screenname
    # @screenname ||= session[:screenname]
    @screenname ||= current_user.try :screenname
  end

  def google_fonts(fonts)
    if fonts.is_a? String
      fonts = [fonts]
    end
    fonts = fonts.map { |fonts| fonts.gsub ' ', '+' }
    fonts = fonts.join '|'
    url = "https://fonts.googleapis.com/css"
    tag 'link', href: "#{url}?family=#{fonts}", rel: "stylesheet"
  end

  def img(*a)
    image_tag(*a)
  end

  def stylesheet(&block)
    raw "<style>\n" + capture(&block) + "\n</style>"
  end

end
