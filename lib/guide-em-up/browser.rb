require "time"
require "rack/utils"
require "rack/mime"
require "goliath/api"


module GuideEmUp
  class Browser < Goliath::API
    def initialize(dir)
      @root = dir
    end

    def response(env)
      path_info = File.join(@root, Rack::Utils.unescape(env["PATH_INFO"]))
      if File.file?(path_info)
        serve_guide(path_info)
      elsif path_info.include? ".."
        unauthorized_access
      elsif File.directory?(path_info)
        serve_index(path_info)
      else
        page_not_found(path_info)
      end
    end

  protected

    def serve_guide(filename)
      body = Guide.new(filename).html
      [200, {
        "Content-Type"   => "text/html; charset=utf-8",
        "Content-Length" => Rack::Utils.bytesize(body).to_s
      }, [body] ]
    end

    def serve_index(path_info)
      body = "TODO"
      [200, {
        "Content-Length" => Rack::Utils.bytesize(body).to_s,
        "Content-Type"   => "text/html; charset=utf-8",
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