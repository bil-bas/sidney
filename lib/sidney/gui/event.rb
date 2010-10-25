# encoding: utf-8

module Sidney

# Adds simple event handling methods to an object (subscribe/publish pattern).
#
# @example
#   class JumpingBean
#     include Event
#   end
#
#   bean = JumpingBean.new
#   bean.subscribe :jump do |object, direction, distance|
#     puts "#{object} jumped #{distance} metres #{direction}"
#   end
#
#   bean.publish :jump, :up, 4
#
module Event
  # @overload subscribe(event, method)
  #   Add an event handler for an event, using a method.
  #   @return nil
  #
  # @overload subscribe(event, &block)
  #   Add an event handler for an event, using a block.
  #   @return nil
  public
  def subscribe(event, method = nil, &block)
    raise ArgumentError, "Expected method or block for event handler" unless !block.nil? ^ !method.nil?
    @_event_handlers = Hash.new() { |hash, key| hash[key] = [] } unless @_event_handlers
    @_event_handlers[event].push(method ? method : block)

    nil
  end

  # Publish an event to all previously added handlers.
  # @param [Symbol] event Name of the event to publish.
  # @param [Array] args Arguments to pass to the event handlers.
  # @return nil
  public
  def publish(event, *args)
    @_event_handlers[event].each { |handler| handler.call(self, *args) } if @_event_handlers

    nil
  end
end
end