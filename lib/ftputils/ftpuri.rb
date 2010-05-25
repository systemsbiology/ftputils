class FTPUtils
  class FTPURI
    attr_accessor :dirname, :filename, :path

    def self.parse(uri)
      if uri.match(/^ftp:\/\/.*?:.*?@.*?(\/.*)*\/(.*)$/)
        ftp_uri = FTPURI.new
        ftp_uri.dirname = $1 || "/"
        ftp_uri.filename = $2
        ftp_uri.path = ftp_uri.dirname + "/" + ftp_uri.filename

        return ftp_uri
      else
        return nil
      end
    end

  end
end
