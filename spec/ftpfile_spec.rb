require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FTPUtils::FTPURI do
  describe "checking to see if a path is a directory" do
    it "should be true when the path is an FTP directory" do
      mock_uri = mock(FTPUtils::FTPURI, :path => "/path/to/directory")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/directory").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/directory").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to/directory")

      FTPUtils::FTPFile.directory?("ftp://admin:test@myhost/path/to/directory").should be_true
    end

    it "should be false when the path is an FTP file" do
      mock_uri = mock(FTPUtils::FTPURI, :path => "/path/to/file.txt")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to/file.txt").and_raise(Net::FTPPermError)

      FTPUtils::FTPFile.directory?("ftp://admin:test@myhost/path/to/file.txt").should be_false
    end

    it "should check the path using File.directory? if it doesn't look like an FTP URI" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)
      File.should_receive(:directory?).with("/path/to/file.txt")

      FTPUtils::FTPFile.directory?("/path/to/file.txt")
    end
  end

  describe "providing the directory name of a path" do
    it "should provide the directory name of an FTP URI" do
      mock_uri = mock(FTPUtils::FTPURI, :dirname => "/path/to")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)

      FTPUtils::FTPFile.dirname("ftp://admin:test@myhost/path/to/file.txt").should == "/path/to"
    end

    it "should provide the directory name of a non-FTP path" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)
      File.should_receive(:dirname).with("/path/to/file.txt").and_return("/path/to")

      FTPUtils::FTPFile.dirname("/path/to/file.txt").should == "/path/to"
    end
  end

  describe "checking to see if a file exists" do
    it "should be true when an FTP URI has size greater than 0" do
      mock_uri = mock(FTPUtils::FTPURI, :path => "/path/to/file.txt", :dirname => "/path/to", :filename => "file.txt")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to")
      mock_connection.should_receive(:size).with("file.txt").and_return(100)

      FTPUtils::FTPFile.exists?("ftp://admin:test@myhost/path/to/file.txt").should be_true
    end

    it "should be false when an FTP URI has size less than 0" do
      mock_uri = mock(FTPUtils::FTPURI, :path => "/path/to/file.txt", :dirname => "/path/to", :filename => "file.txt")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to")
      mock_connection.should_receive(:size).with("file.txt").and_return(-1)

      FTPUtils::FTPFile.exists?("ftp://admin:test@myhost/path/to/file.txt").should be_false
    end

    it "should pass the path to File.exists? if it's not an FTP URI" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)
      File.should_receive(:exists?)

      FTPUtils::FTPFile.exists?("/path/to/file.txt")
    end
  end

  describe "providing the basename" do
    it "should provide the basename of an FTP URI" do
      mock_uri = mock(FTPUtils::FTPURI, :filename => "file.txt")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)

      FTPUtils::FTPFile.basename("ftp://admin:test@myhost/path/to/file.txt").should == "file.txt"
    end

    it "should provide the basename of a non-FTP path" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)
      File.should_receive(:basename).with("/path/to/file.txt")

      FTPUtils::FTPFile.basename("/path/to/file.txt")
    end
  end

  describe "providing the relative path" do
    it "should provide the relative path for an FTP URI" do
      mock_uri = mock(FTPUtils::FTPURI, :path => "/path/to")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)

      FTPUtils::FTPFile.relative_path("ftp://admin:test@myhost/path/to/file.txt").should == "/path/to"
    end

    it "should provide the relative path for a non-FTP path" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)

      FTPUtils::FTPFile.relative_path("/path/to/file.txt").should be_nil
    end
  end

  describe "determining whether a path is a file" do
    it "should be true for an FTP URI of a file" do
      mock_uri = mock(FTPUtils::FTPURI, :dirname => "/path/to", :filename => "file.txt")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to")
      mock_connection.should_receive(:size).with("file.txt").and_return(100)

      FTPUtils::FTPFile.file?("ftp://admin:test@myhost/path/to/file.txt").should be_true
    end

    it "should be false for an FTP URI of a directory" do
      mock_uri = mock(FTPUtils::FTPURI, :dirname => "/path/to", :filename => "directory")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/directory").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/directory").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to")
      mock_connection.should_receive(:size).with("directory").and_raise(Net::FTPPermError)

      FTPUtils::FTPFile.file?("ftp://admin:test@myhost/path/to/directory").should be_false
    end

    it "should use File.directory? if the path doesn't look like an FTP URI" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)
      File.should_receive(:file?).with("/path/to/file.txt")

      FTPUtils::FTPFile.file?("/path/to/file.txt")
    end
  end

  describe "determining the modification time of a file" do
    it "should find the modificaiton of an FTP URI if it's a file" do
      mock_uri = mock(FTPUtils::FTPURI, :dirname => "/path/to", :filename => "file.txt")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to")
      mock_connection.should_receive(:mtime).with("file.txt").and_return("10:10")

      FTPUtils::FTPFile.mtime("ftp://admin:test@myhost/path/to/file.txt").should == "10:10"
    end

    it "should return nil if the FTP URI provided is a directory" do
      mock_uri = mock(FTPUtils::FTPURI, :dirname => "/path/to", :filename => "directory")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/directory").and_return(mock_uri)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@myhost/path/to/directory").and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/path/to")
      mock_connection.should_receive(:mtime).with("directory").and_raise(Net::FTPPermError)

      FTPUtils::FTPFile.mtime("ftp://admin:test@myhost/path/to/directory").should be_nil
    end

    it "should use File.mtime if the path is not an FTP URI" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)
      File.should_receive(:mtime).with("/path/to/file.txt")

      FTPUtils::FTPFile.mtime("/path/to/file.txt")
    end
  end

  describe "expanding the path" do
    it "should do nothing to the path if it's an FTP URI" do
      mock_uri = mock(FTPUtils::FTPURI, :dirname => "/path/to", :filename => "file.txt")
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@myhost/path/to/file.txt").and_return(mock_uri)

      FTPUtils::FTPFile.expand_path("ftp://admin:test@myhost/path/to/file.txt").should == "ftp://admin:test@myhost/path/to/file.txt"
    end

    it "should use File.expand_path if it's not an FTP URI" do
      FTPUtils::FTPURI.should_receive(:new).with("/path/to/file.txt").and_return(nil)
      File.should_receive(:expand_path).with("/path/to/file.txt")

      FTPUtils::FTPFile.expand_path("/path/to/file.txt")
    end
  end
end
