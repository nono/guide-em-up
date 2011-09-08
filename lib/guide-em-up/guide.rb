require "albino"
require "digest/sha1"
require "erubis"
require "redcarpet"
require "yajl"


module GuideEmUp
  class Guide < Struct.new(:filename, :directory, :title, :content, :template)
    def initialize(filename, template)
      @codemap = {}
      self.filename  = filename
      self.directory = File.dirname(filename)
      self.title     = File.basename(filename)
      self.template  = template
      self.content   = get_content
    end

    def html
      tmpl = File.read(template)
      Erubis::Eruby.new(tmpl).result(to_hash)
    end

  protected

    def to_hash
      Hash[members.zip values]
    end

    def get_content
      raw = File.read(filename)
      tmp = extract_code(insert_include raw, directory)
      ext = [:autolink, :generate_toc, :no_intraemphasis, :smart, :strikethrough, :tables]
      red = Redcarpet.new(tmp, *ext)
      cnt = process_code red.to_html
      find_title cnt
    end

    def find_title(txt)
      txt.sub(/\A<h1[^>]*>([^>]*)<\/h1>/m) do
        self.title = $1
        ""
      end
    end

    def insert_include(md, dir)
      md.gsub(/!INCLUDE (\S+)/) do
        file = File.join(dir, $1)
        idir = File.dirname(file)
        insert_include File.read(file), idir
      end
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
