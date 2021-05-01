# Some extensions to function


# Includes the enumerable properties from the base into the prototype of this.
# Good for Ruby module like extensions of classes. Copies getters and setters
# too, as long as they were mark enumerable when created.
#
# Usage:
#
#   class MyClass
#     @include MyModule
#
# MyClass would now contain properties, including enumerable getters and
# setters, from the prototype of MyModule.
#
# You can also simply pass an object, and properties will be copied directly
# from it, rather than the prototype object.

_.extend Function.prototype,
  include: (base) ->
    throw "Base was null or undefined." unless base?

    type = typeof base

    # If base is a constructor, retrieve the prototype.
    if _.isFunction(base)
      base = base.prototype

    #for prop in base
    for prop of base
      if hasOwnProperty.call(base, prop)
        desc = Object.getOwnPropertyDescriptor(base, prop)
        Object.defineProperty(@prototype, prop, desc)


  # Defines a getter. See: http://bl.ocks.org/joyrexus/65cb3780a24ecd50f6df
  getter: (prop, get) ->
    Object.defineProperty @prototype, prop, {get: get, configurable: yes, enumerable: true}

  # Defines a setter. See: http://bl.ocks.org/joyrexus/65cb3780a24ecd50f6df
  setter: (prop, set) ->
    Object.defineProperty @prototype, prop, {set: set, configurable: yes, enumerable: true}
