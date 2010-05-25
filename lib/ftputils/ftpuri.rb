class FTPUtils
  class FTPURI
    attr_accessor :dirname, :filename, :path

    def self.parse(uri)
      if uri.match(/^ftp:\/\/.*?:.*?@.*?(\/.*)*$/)
        path = $1 || "/"
        parts = path.split(/\//)
        filename = parts[-1]
        dirname = parts[0..-2].join("\/")
        dirname = "/" if dirname.empty?

        ftp_uri = FTPURI.new(dirname, filename, path)
      else
        return nil
      end
    end

    def initialize(dirname, filename, path)
      self.dirname = dirname
      self.filename = filename
      self.path = path
    end
  end
end
