

(ns text-editor)

(def find-direction
  [[x1 y1] [x2 y2]]
  (let [deltaX (- x2 x1)
        deltaY (- y2 y1)
        rad (.atan2 Math deltaY deltaX)]
        rad))


text-editor.find-direction


(ns hello-world.core)

(enable-console-print!)

(println "Like ya!")


; (css {top y left x})
