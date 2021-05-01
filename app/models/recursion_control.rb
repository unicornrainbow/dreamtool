# Curtosey of https://gist.github.com/avdi/1597716
module RecursionControl
  module ClassMethods
    def prevent_recursion(method_name)
      flag_name = "in:#{name}##{method_name}"
      original = instance_method(method_name)
      define_method(method_name) do |*args|
        if Thread.current[flag_name]
          return
        else
          begin
            Thread.current[flag_name] = true
            original.bind(self).call(*args)
          ensure
            Thread.current[flag_name] = nil
          end
        end
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
