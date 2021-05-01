## Composer / Capture Layer View

The capture layer view is a component of the composer. It's main purpose is to
capture mouse events and relay them to sub components.

It works by covering the entire screen, and not allowing any mouse events to
pass through, but rather, capturing them, and relaying them to it's internal
mechanism.

The capture layer view has no appearance. It is purely functional. It
essentially, disable the dom mouse event handling and propagation, and hands
control of such matters over the backbone application, and it's components.
