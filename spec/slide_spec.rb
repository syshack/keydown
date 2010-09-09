require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Keydown::Slide do

  shared_examples_for 'extracting slide data' do

    it "should set the classname to empty" do
      @slide.classnames.should == @classnames
    end

    it "should extract the content" do
      @slide.content.should match(/^# A Slide/)
    end

    it "should extract the notes" do
      @slide.notes.should match(/a simple note/)
    end

  end

  shared_examples_for "when generating HTML" do
    describe "when generating HTML" do

      before :each do
        @html = @slide.to_html
        @doc  = Nokogiri(@html)
      end

      it "should assign the classname(s) to the section" do
        @doc.css(@section_selector).should_not be_nil
      end

      it "should convert the content via Markdown" do
        @doc.css('section h1').text.should == 'A Slide'
      end
    end

  end

  describe 'without a CSS classname' do
    before :each do
      @slide_text       = <<-SLIDE

# A Slide
With some text

!NOTES
a simple note
      SLIDE

      @classnames       = ''
      template_dir      = File.join(File.dirname(__FILE__), '..', 'templates', 'rocks')
      @slide            = Keydown::Slide.new(template_dir, @slide_text)
      @section_selector = "section"
    end

    it_should_behave_like "extracting slide data"
    it_should_behave_like "when generating HTML"
  end

  describe "with a single CSS classname" do
    before :each do
      @slide_text       = <<-SLIDE

# A Slide
With some text

!NOTES
a simple note
      SLIDE

      @classnames       = 'foo'
      template_dir      = File.join(File.dirname(__FILE__), '..', 'templates', 'rocks')
      @slide            = Keydown::Slide.new(template_dir, @slide_text, @classnames)
      @section_selector = "section.#{@classnames}"
    end

    it_should_behave_like "extracting slide data"
    it_should_behave_like "when generating HTML"
  end

  describe "with multiple CSS classnames" do
    before :each do
      @slide_text       = <<-SLIDE

# A Slide
With some text

!NOTES
a simple note
      SLIDE

      @classnames       = 'foo bar'
      template_dir      = File.join(File.dirname(__FILE__), '..', 'templates', 'rocks')
      @slide            = Keydown::Slide.new(template_dir, @slide_text, @classnames)
      @section_selector = "section.#{@classnames}"
    end

    it_should_behave_like "extracting slide data"
    it_should_behave_like "when generating HTML"
  end

  describe "with code to higlight" do

    describe "using the Slidedown syntax" do
      before :each do
        @slide_text       = <<-SLIDE

# A Slide
With some text

@@@ ruby
  def a_method(options)
    puts "I can has options " + options
  end
@@@
!NOTES
a simple note

        SLIDE

        @classnames       = ''
        template_dir      = File.join(File.dirname(__FILE__), '..', 'templates', 'rocks')
        @slide            = Keydown::Slide.new(template_dir, @slide_text)
        @section_selector = "section"
      end

      it_should_behave_like "extracting slide data"
      it_should_behave_like "when generating HTML"

      describe "when Pygmentizing any code in the HTML" do
        before :each do
          @html = @slide.to_html
          @doc  = Nokogiri(@html)
        end

        it "should colorize the code fragments" do
          @doc.css('.highlight').length.should == 1
        end
      end
    end
  end
end