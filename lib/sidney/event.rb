module Sidney

# Adds a method "event" to the class.
# Usage:
#   class Cheese
#     include Event
#     event :frog, :fish
#
#   end
#
# Instances would then have public on_frog and on_fish methods (to register handlers) as well as protected
# publish_frog and publish_fish methods to raise the event.
module Event
  def self.included(target) # :nodoc:
    # Add a list of events, by name (Symbol), to be handled by the object.
    def target.event(*args)
      args.each do |event|
        instance_eval do
          public
          define_method :"on_#{event}" do |method = nil, &block|
            raise "Expected proc or block for event handler" unless method or block
            handlers = instance_variable_get(:"@_#{event}_handlers")
            unless handlers
              handlers = []
              instance_variable_set("@_#{event}_handlers", handlers)
            end
            handlers.push(method ? method : block)

            nil
          end

          protected
          define_method :"publish_#{event}" do |*args|
            handlers = instance_variable_get(:"@_#{event}_handlers")
            handlers.each { |handler| handler.call(self, *args) } if handlers
            
            nil
          end
        end
      end
    end
  end
end
end