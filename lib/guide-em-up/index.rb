module GuideEmUp
  class Index < Struct.new(:root, :current_dir, :data_dir)
    FileEntry = Struct.new(:path, :name, :icon)

    def html
      file = File.join(self.data_dir, "/browser.erb")
      tmpl = File.read(file)
      Erubis::Eruby.new(tmpl).result(to_hash)
    end

  protected

    def to_hash
      { :files => files, :dir => self.current_dir }
    end

    def files
      results = Dir["#{self.current_dir}/*"].sort.map do |f|
        path = f.sub(self.root, '').gsub('//', '/')
        name = File.basename(f)
        icon = File.directory?(f) ? "folder" : icon_for(name)
        FileEntry.new(path, name, icon)
      end
      if self.current_dir != self.root + '/'
        path = File.dirname(self.current_dir).sub(self.root, '/').gsub('//', '/')
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
