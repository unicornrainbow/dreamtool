
class @Newstime.VideoPropertiesView extends Backbone.View

  tagName: 'ul'

  events:
    'click .video-name-field': 'clickVideoName'
    'change .video-name-field': 'changeVideoName'
    'change .show-caption-field': 'changeShowCaption'
    'change .caption-field': 'changeCaption'


  initialize: ->

    @$el.addClass('video-properties')

    @$el.html """
      <li class="property">
        <label>Video Name</label>
        <span class="field"><input class="video-name-field" style="width: 100px"></input></span>
      </li>

      <li class="property">
        <label>Caption</label>
        <span class="field">
          <textarea class="caption-field" style="width: 100px"></textarea>
        </span>
      </li>

      <li class="property">
        <label>Show Cap</label>
        <span class="field">
          <input class='show-caption-field' type="checkbox"></input>
        </span>
      </li>

      <li class="property" style="display: none;">
        <label>Video URL</label>
        <span class="field"><input class="video-url-field" style="width: 100px"></input></span>
      </li>

      <li class="property" style="display: none;">
        <label>Cover URL</label>
        <span class="field"><input class="cover-image-url-field" style="width: 100px;"></input></span>
      </li>
    """

    @$videoNameField = @$('.video-name-field')
    @$videoURLField = @$('.video-url-field')
    @$coverImageURLField = @$('.cover-image-url-field')
    @$captionField = @$('.caption-field')
    @$showCaptionField = @$('.show-caption-field')

  render: ->
    @$videoNameField.val(@model.get('video_name') || '')
    @$showCaptionField.prop('checked', @model.get('show_caption'))
    @$captionField.val(@model.get('caption') || '')
    this

  changeVideoName: ->
    @model.set 'video_name', @$videoNameField.val()

  clickVideoName: ->
    console.log "Show video selector"

  changeShowCaption: ->
    @model.set 'show_caption', @$showCaptionField.prop('checked')

  changeCaption: ->
    @model.set 'caption', @$captionField.val()
