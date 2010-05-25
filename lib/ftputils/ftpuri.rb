class FTPUtils
  class FTPURI
    attr_accessor :dirname, :filename, :path

    def initialize(uri)
      if uri.match(/^ftp:\/\/.*?:.*?@.*?(\/.*)*\/(.*)$/)
        self.dirname = $1 || "/"
        self.filename = $2
        self.path = dirname + "/" + filename
      else
        return nil
      end
    end

  end
end
