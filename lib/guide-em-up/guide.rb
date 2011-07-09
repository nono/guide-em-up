require "albino"
require "digest/sha1"
require "erubis"
require "redcarpet"
require "yajl"


module GuideEmUp
  class Guide < Struct.new(:filename, :title)
    def initialize(filename)
      self.filename = self.title = filename
      @codemap = {}
    end

    def html
      file = File.expand_path("../../../themes/github.erb", __FILE__)
      tmpl = File.read(file)
      Erubis::Eruby.new(tmpl).result(to_hash)
    end

  protected

    def to_hash
      hsh = Hash[members.zip values].merge(:content => content)
      hsh
    end

    def content
      raw = File.read(filename)
      tmp = extract_code(raw)
      red = Redcarpet.new(tmp, :autolink, :generate_toc, :smart, :strikethrough, :tables)
      process_code red.to_html
    end

    # Code taken from gollum (http://github.com/github/gollum)
    def extract_code(md)
      md.gsub(/^``` ?(.+?)\r?\n(.+?)\r?\n```\r?$/m) do
        id = Digest::SHA1.hexdigest($2)
        @codemap[id] = { :lang => $1, :code => $2 }
        id
      end
    end

    def process_code(data)
      @codemap.each do |id, spec|
        lang, code = spec[:lang], spec[:code]
        if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ /^(    |\t)/ }
          code.gsub!(/^(    |\t)/m, '')
        end
        output = Albino.new(code, lang).colorize(:P => "nowrap")
        data.gsub!(id, "<pre><code class=\"#{lang}\">#{output}</code></pre>")
      end
      data
    end
  end
end
