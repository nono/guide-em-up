module GuideEmUp
  class Theme
    ThemeEntry = Struct.new(:name, :current)

    def initialize(dir)
      @dir = dir
      @templates = Dir["#{@dir}/*.erb"].sort
      @template = @templates.first
    end

    attr_reader :template

    def current=(tmpl)
      filename  = "#{@dir}/#{tmpl}.erb"
      @template = filename if File.exists?(filename)
    end

    def all
      @templates.map do |tmpl|
        name = File.basename(tmpl, '.erb')
        ThemeEntry.new(name, tmpl == template)
      end
    end
  end
end
