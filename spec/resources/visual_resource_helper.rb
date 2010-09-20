require_relative 'resource_helper'

share_examples_for 'VisualResource' do
  it_should_behave_like "Resource"

  before :each do
    @png_created = File.join(GENERATED_DIR, "#{described_class.type}_images", "#{@name} - #{@uid}.png")
    @default_png_created = File.join(GENERATED_DIR, "#{described_class.type}_images", "default.png")
  end
  
  describe "to_image()" do
    it "should create a png image" do
      File.delete(@png_created) if File.exists?(@png_created)
      @resource.to_image.write(@png_created)
      File.exist?(@png_created).should be_true
      File.size(@png_created).should > 0
    end
  end

  describe "default()" do
    before :each do
      @default_resource = described_class.default
    end

    describe "to_image()" do
      it "should create a png image" do
        File.delete(@default_png_created) if File.exists?(@default_png_created)
        @default_resource.to_image.write(@default_png_created)
        File.exist?(@default_png_created).should be_true
        File.size(@default_png_created).should > 0
      end
    end
  end
  

#  describe "to_image() ALL" do
#    it "should create a png image" do
#      Dir[File.join(CACHE_IN, described_class.type, "*")].each do |filename|
#        object = described_class.load(File.basename(filename))
#        image = object.to_image
#        image.write(File.join(GENERATED_DIR, "#{described_class.type}_images", "#{object.name} - #{File.basename(filename)}.png"))
#      end
#    end
#  end
end