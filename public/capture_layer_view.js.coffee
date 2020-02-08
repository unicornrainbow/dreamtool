



<pre>
@$el.addClass "capture-layer-view"

 @mc = new Hammer(@el,
   inputClass: Hammer.TouchInput
 )
 @mc.on 'tap', @tap
 @mc.on 'doubletap', @doubletap
 @mc.on 'press', @press

 @topOffset = options.topOffset # Apply top offset (Allows room for menu)
 @composer = options.composer

 # Capture mouseups that happen off screen http://stackoverflow.com/a/5419564/32384
 $(window).mouseup @mouseup
 $(document).mouseout @documentMouseout

 # document.body.addEventListener 'touchmove', null, false;

 document.body.addEventListener 'touchmove',
   (e)->e.preventDefault(),
   {passive: false};

 @$el.css top: "#{@topOffset}px"
</pre>
