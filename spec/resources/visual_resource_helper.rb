require_relative 'resource_helper'

require 'gosu_ext'
require 'chingu'

share_examples_for 'VisualResource' do
  it_should_behave_like "Resource"

  before :all do
    $window = Gosu::Window.new(640, 480, false)
  end

  before :each do
    @png_created = File.join(GENERATED_DIR, "#{described_class.type}_images", "#{@name} - #{@uid}.png")
    @default_png_created = File.join(GENERATED_DIR, "#{described_class.type}_images", "default.png")
  end

  subject { described_class.load(@uid) }
  
  describe "#image" do
    it "should create a png image" do
      File.delete(@png_created) if File.exists?(@png_created)
      FileUtils.mkdir_p(File.dirname(@png_created))
      subject.image.save(@png_created)
      File.exist?(@png_created).should be_true
      File.size(@png_created).should > 0
    end
  end

  describe "#default" do
    subject { described_class.default }

    describe "#image" do
      it "should create a png image" do
        File.delete(@default_png_created) if File.exists?(@default_png_created)
        FileUtils.mkdir_p(File.dirname(@default_png_created))
        subject.image.save(@default_png_created)
        File.exist?(@default_png_created).should be_true
        File.size(@default_png_created).should > 0
      end
    end
  end
  

=begin
  describe "to_image() ALL" do
    it "should create a png image" do
      Dir[File.join(CACHE_IN, described_class.type, "*")].each do |filename|
        object = described_class.load(File.basename(filename))
        image = object.to_image.save(File.join(GENERATED_DIR, "#{described_class.type}_images", "#{object.name} - #{File.basename(filename)}.png"))
      end
    end
  end
=end

end