(ns dreamtool.text-editor)

(defn getElementById [element id]
  (.getElementById element id))

; (defn $ [selector]
;   ; if starts with #
;   (if )
;   (getElementById js/document selector))
[onmousedown onmouseup]

(alias send .)

(defn onmousedown [element callback]
  (send element
    :addEventHandler
    "onmousedown"
    callback)

(let
  [keyboard ($ "#keyboard")]

  (onmousedown keyboard
    (fn [event]
      ()))

  (onmouseup keyboard
    (fn [event]
      ())))

(defn find-direction
  [[x1 y1] [x2 y2]]
  (let [deltaX (- x2 x1)
    deltaY (- y2 y1)
    rad (.atan2 Math deltaY deltaX)]
    rad))
