require "albino"
require "digest/sha1"
require "erubis"
require "redcarpet"
require "yajl"


module GuideEmUp
  class Guide < Struct.new(:filename, :title, :template)
    def initialize(filename, template)
      self.filename = filename
      self.title    = File.basename(filename)
      self.template = template
      @codemap = {}
    end

    def html
      tmpl = File.read(template)
      Erubis::Eruby.new(tmpl).result(to_hash)
    end

  protected

    def to_hash
      Hash[members.zip values].merge(:content => content)
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
