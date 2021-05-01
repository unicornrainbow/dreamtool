module TryHelper

  # A slightly different take on try.
  #
  # Allow passing of dot delimited messages, which are broken apart
  # and recursivly invoked on the target if that target is not nil.
  def try(message)
    case message
    when String
      messages = message.split('.')

      messages.reduce(self) do |target, msg|
        target.send(msg) if target
      end
    else
      super
    end
  end

end
