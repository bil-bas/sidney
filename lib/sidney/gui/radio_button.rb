# encoding: utf-8

require_relative 'button'
require_relative '../event'

module Sidney
module Gui
  class RadioButton < Button
    class Group
      include Event

      attr_reader :name, :selected

      def value; @selected ? @selected.value : nil; end

      protected
      # @example
      #   RadioButton::Group.new do |group|
      #     HorizontalPacker.new(side_bar) do |packer|
      #       RadioButton.new(packer, 1, group: group, text: '1' checked: true)
      #       RadioButton.new(packer, 2, group: group, text: '2')
      #       group.subscribe :changed do |sender, value|
      #         puts value
      #       end
      #     end
      #    end
      def initialize(&block)
        @selected = nil
        @buttons = []

        yield self if block_given?
      end

      public
      def add(button)
        @buttons.push button
        button_checked button if button.checked?

        nil
      end

      public
      def button_checked(button)
        @selected.send :uncheck if @selected

        @selected = button

        publish :changed, @selected.value

        nil
      end

      public
      # @example
      #   RadioButton::Group.new do |group|
      #     HorizontalPacker.new(side_bar) do |packer|
      #       RadioButton.new(packer, 1, group: group, text: '1')
      #       RadioButton.new(packer, 2, group: group, text: '2')
      #       group.value = 2
      #     end
      #    end
      #
      #   # later
      #   group.value = 1
      def value=(value)
        button = @buttons.find { |b| b.value = value }

        raise "Group does not contain a RadioButton with this value (#{value})" unless button

        button_checked(button) unless button.checked?

        button
      end
    end

    CHECKED_BORDER_COLOR = Color.new(255, 0, 255)

    attr_reader :group, :value

    def checked?; @checked; end

    protected
    def initialize(parent, value, options = {}, &block)
      options = {
        checked: false
      }.merge! options

      @checked = options[:checked]

      @group = options[:group]
      @group.add self

      @value = value

      super(parent, options)
    end

    public
    def click
      super
      check
      nil
    end

    public
    def check
      @group.button_checked self unless checked?

      @checked = true
      publish :checked

      nil
    end

    protected
    # Only ever called from Group!
    def uncheck
      @checked = false
      publish :unchecked

      nil
    end

    public
    def draw
      super

      $window.draw_box x, y, width, height, z, CHECKED_BORDER_COLOR if checked?

      nil
    end
  end
end
end