module GuideEmUp
  class Index < Struct.new(:root, :current_dir, :data_dir, :themes)
    FileEntry = Struct.new(:path, :name, :icon)

    def html
      file = File.join(data_dir, "/browser.erb")
      tmpl = File.read(file)
      Erubis::Eruby.new(tmpl).result(to_hash)
    end

  protected

    def to_hash
      { :themes => themes, :files => files, :dir => current_dir }
    end

    def files
      results = Dir["#{current_dir}/*"].sort.map do |f|
        path = f.sub(root, '').gsub('//', '/')
        name = File.basename(f)
        icon = File.directory?(f) ? "folder" : icon_for(name)
        FileEntry.new(path, name, icon)
      end
      if current_dir != root + '/'
        path = File.dirname(current_dir).sub(root, '/').gsub('//', '/')
        results.unshift FileEntry.new(path, "..", "parent")
      end
      results
    end

    def icon_for(filename)
      case filename
      when /\.(css|less|sass|scss)$/   then "css"
      when /\.(js|json)$/              then "js"
      when /\.(bmp|gif|ico|png)$/      then "image"
      when /\.html?$/                  then "html"
      when /\.rb$/                     then "rb"
      when /readme/i                   then "readme"
      when /authors/i                  then "authors"
      when /copying|license/i          then "copying"
      when /changelog/i                then "log"
      when /\.(md|mkd|markdown|txt)$/  then "text"
      when /\.(gz|bz2|zip|rar|7z|xz)$/ then "archive"
      else "unknown"
      end
    end
  end
end
