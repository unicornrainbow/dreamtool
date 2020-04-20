# Make a global copy of the dalli client available by convention.
# $dalli = Rails.cache.dalli

# Usage:
#
#     $dalli.set("key", value)  # Set data
#     $dalli.get("key")         # Get data
#     $dalli.delete("key")      # Remove data
#     $dalli.flush_all          # Flush everything
#
# Full api documentation http://www.ruby-doc.org/gems/docs/j/jashmenn-dalli-1.0.3/Dalli/Client.html
