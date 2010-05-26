class FTPUtils
  class FTPFile

    def self.basename(path, suffix=nil)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        if suffix
          return ftp_uri.filename.gsub!(/#{suffix}\Z/,'')
        else
          return ftp_uri.filename
        end
      else
        if suffix
          return File.basename(path, suffix)
        else
          return File.basename(path)
        end
      end
    end

    def self.directory?(path)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        begin
          connection = FTPUtils::FTPConnection.connect(path)
          connection.chdir(ftp_uri.path)
          
          return true
        rescue Net::FTPPermError
          return false
        end
      else
        return File.directory? path
      end
    end

    def self.dirname(path)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        return ftp_uri.dirname
      else
        return File.dirname(path)
      end
    end

    def self.exists?(path)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        connection = FTPUtils::FTPConnection.connect(path)
        connection.chdir ftp_uri.dirname

        begin
          if connection.size(ftp_uri.filename) > 0
            return true
          else
            return false
          end
        rescue
          return false
        end
      else
        return File.exists?(path)
      end
    end

    def self.expand_path(path)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        return path
      else
        return File.expand_path(path)
      end
    end

    def self.file?(path)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        connection = FTPUtils::FTPConnection.connect(path)
        connection.chdir(ftp_uri.dirname)

        begin
          connection.size(ftp_uri.filename)
          return true
        rescue Net::FTPPermError
          return false
        end
      else
        return File.file? path
      end
    end

    def self.mtime(path)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        connection = FTPUtils::FTPConnection.connect(path)
        connection.chdir(ftp_uri.dirname)

        return connection.mtime(ftp_uri.filename)
      else
        return File.mtime path
      end
    end

    def self.relative_path(path)
      if ftp_uri = FTPUtils::FTPURI.parse(path)
        return ftp_uri.path
      else
        return nil
      end
    end

    private

    def self.ftp_url?(str)
      str.match(/^ftp:\/\//i) ? true : false
    end
  end
end
