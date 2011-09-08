require "time"
require "date"
require "rack/utils"
require "rack/mime"
require "goliath/api"


module GuideEmUp
  class Browser < Goliath::API
    def initialize(dir)
      @root  = dir
      @data  = File.expand_path("../../../data", __FILE__)
      @theme = Theme.new(File.join @data, "themes")
    end

    def response(env)
      path_info = Rack::Utils.unescape(env["PATH_INFO"])
      filename  = File.join(@root, path_info)
      datafile  = File.join(@data, path_info)
      if File.file?(filename)
        serve_file(filename)
      elsif filename.include? ".."
        unauthorized_access
      elsif File.directory?(filename)
        serve_index(filename)
      elsif path_info =~ /\/g-e-u\/theme\/(\w+)$/
        @theme.current = $1
        redirect_to env["HTTP_REFERER"] || "http://#{env["HTTP_HOST"]}/"
      elsif path_info =~ /\/g-e-u\/(css|images|icons|js)\//
        serve_data(datafile.sub 'g-e-u', '')
      else
        page_not_found(path_info)
      end
    end

  protected

    def serve_file(filename)
      mime = Rack::Mime.mime_type(File.extname filename)
      if mime =~ /^(audio|image|video)\//
        serve_data(filename, mime)
      else
        serve_guide(filename)
      end
    end

    def serve_guide(filename)
      body = Guide.new(filename, @theme.template).html
      [200, {
        "Content-Type"   => "text/html; charset=utf-8",
        "Content-Length" => Rack::Utils.bytesize(body).to_s
      }, [body] ]
    end

    def serve_index(path_info)
      body = Index.new(@root, path_info, @data, @theme.all).html
      [200, {
        "Content-Type"   => "text/html; charset=utf-8",
        "Content-Length" => Rack::Utils.bytesize(body).to_s,
      }, [body] ]
    end

    def serve_data(filename, mime=nil)
      if File.exists?(filename)
        body   = File.read(filename)
        mime ||= Rack::Mime.mime_type(File.extname filename)
        [200, {
          "Content-Type"   => mime,
          "Content-Length" => Rack::Utils.bytesize(body).to_s,
        }, [body] ]
      else
        page_not_found(filename)
      end
    end

    def redirect_to(location)
      body = "You are being redirected to #{location}"
      [302, {
        "Location"       => location,
        "Content-Type"   => "text/html; charset=utf-8",
        "Content-Length" => Rack::Utils.bytesize(body).to_s
      }, [body] ]
    end

    def page_not_found(path_info)
      [404, {
        "Content-Type"   => "text/plain",
        "Content-Length" => "0"
      }, ["File not found: #{path_info}\n"] ]
    end

    def unauthorized_access
      [403, {
        "Content-Type"   => "text/plain",
        "Content-Length" => "0"
      }, ["Forbidden\n"] ]
    end
  end
end
