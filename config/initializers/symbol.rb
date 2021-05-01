
# Alias to_partial_path to to_s
# on Symbol class so that symbols
# can be used as the key to the
# render method.
class Symbol
  alias to_partial_path to_s
end

# alias_method_chain :render, :symbol
# def render_with_symbol(*args)
#   if args[0].is_a Symbol
#     args[0] = args[0].to_s
#   end
#   render_without_symbol(partial, *args)
# end
