require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FTPUtils" do
  describe "Copying a file" do
    describe "from FTP to FTP" do
      it "should work if a file URIs are specified for the source and destination" do
        mock_src_connection = mock(Net::FTPFXP)
        mock_src_uri = mock(FTPUtils::FTPURI, :directory => false, :path => "/file1.txt",
          :filename => "file1.txt", :connection => mock_src_connection)
        mock_dest_connection = mock(Net::FTPFXP)
        mock_dest_uri = mock(FTPUtils::FTPURI, :directory => false, :folder => "/",
          :filename => "file2.txt", :connection => mock_dest_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/file1.txt").and_return(mock_src_uri)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host2/file2.txt").and_return(mock_dest_uri)
        mock_src_connection.should_receive(:fxpto).with(mock_dest_connection, "//file2.txt", "/file1.txt")
      
        FTPUtils.cp "ftp://admin:test@host1/file1.txt", "ftp://admin:test@host2/file2.txt"
      end

      it "should work if a file URI with subfolders are specified for the source and destination" do
        mock_src_connection = mock(Net::FTPFXP)
        mock_src_uri = mock(FTPUtils::FTPURI, :directory => false, :path => "/subdir1/file1.txt",
          :filename => "file1.txt", :connection => mock_src_connection)
        mock_dest_connection = mock(Net::FTPFXP)
        mock_dest_uri = mock(FTPUtils::FTPURI, :directory => false, :folder => "/subdir2",
          :filename => "file2.txt", :connection => mock_dest_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1/file1.txt").and_return(mock_src_uri)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host2/subdir2/file2.txt").and_return(mock_dest_uri)
        mock_src_connection.should_receive(:fxpto).with(mock_dest_connection, "/subdir2/file2.txt", "/subdir1/file1.txt")
      
        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "ftp://admin:test@host2/subdir2/file2.txt"
      end

      it "should work if a file URI is specified for the source and a directory for the destination" do
        mock_src_connection = mock(Net::FTPFXP)
        mock_src_uri = mock(FTPUtils::FTPURI, :directory => false, :path => "/subdir1/file1.txt",
          :filename => "file1.txt", :connection => mock_src_connection)
        mock_dest_connection = mock(Net::FTPFXP)
        mock_dest_uri = mock(FTPUtils::FTPURI, :directory => true, :folder => "/subdir2",
          :filename => nil, :connection => mock_dest_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1/file1.txt").and_return(mock_src_uri)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host2/subdir2").and_return(mock_dest_uri)
        mock_src_connection.should_receive(:fxpto).with(mock_dest_connection, "/subdir2/file1.txt", "/subdir1/file1.txt")
      
        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "ftp://admin:test@host2/subdir2"
      end

      it "should raise an error if the source URI is a directory" do
        mock_src_connection = mock(Net::FTPFXP)
        mock_src_uri = mock(FTPUtils::FTPURI, :directory => true, :path => "/subdir1/file1.txt",
          :filename => "file1.txt", :connection => mock_src_connection)
        mock_dest_connection = mock(Net::FTPFXP)
        mock_dest_uri = mock(FTPUtils::FTPURI, :directory => true, :folder => "/subdir2",
          :filename => nil, :connection => mock_dest_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1").and_return(mock_src_uri)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host2/subdir2").and_return(mock_dest_uri)
        mock_src_connection.should_not_receive(:fxpto)
      
        lambda do
          FTPUtils.cp "ftp://admin:test@host1/subdir1", "ftp://admin:test@host2/subdir2"
        end.should raise_error("src should be a filename, not a directory")
      end
    end

    describe "from FTP to the local filesystem" do
      it "should work if the destination filename is given" do
        mock_src_connection = mock(Net::FTPFXP)
        mock_src_uri = mock(FTPUtils::FTPURI, :directory => false, :folder => "/subdir1",
          :filename => "file1.txt", :connection => mock_src_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1/file1.txt").and_return(mock_src_uri)
        File.should_receive(:directory?).with("/home/me/file2.txt").and_return(false)
        mock_src_connection.should_receive(:chdir).with("/subdir1")
        mock_src_connection.should_receive(:getbinaryfile).with("file1.txt", "/home/me/file2.txt", 1024)

        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "/home/me/file2.txt"
      end

      it "should work if the destination directory is given" do
        mock_src_connection = mock(Net::FTPFXP)
        mock_src_uri = mock(FTPUtils::FTPURI, :directory => false, :folder => "/subdir1",
          :filename => "file1.txt", :connection => mock_src_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1/file1.txt").and_return(mock_src_uri)
        File.should_receive(:directory?).with("/home/me").and_return(true)
        mock_src_connection.should_receive(:chdir).with("/subdir1")
        mock_src_connection.should_receive(:getbinaryfile).with("file1.txt", "/home/me/file1.txt", 1024)

        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "/home/me"
      end

      it "should raise an error if the source URI is a directory" do
        mock_src_connection = mock(Net::FTPFXP)
        mock_src_uri = mock(FTPUtils::FTPURI, :directory => true, :path => "/subdir1/file1.txt",
          :filename => "file1.txt", :connection => mock_src_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1").and_return(mock_src_uri)

        lambda do
          FTPUtils.cp "ftp://admin:test@host1/subdir1", "/home/me"
        end.should raise_error("src should be a filename, not a directory")
      end
    end

    describe "from local filesystem to FTP" do
      it "should work if the source is a file and the destination is a file" do
        mock_dest_connection = mock(Net::FTPFXP)
        mock_dest_uri = mock(FTPUtils::FTPURI, :directory => false, :folder => "/", :path => "/file2.txt",
          :connection => mock_dest_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host2/file2.txt").and_return(mock_dest_uri)
        mock_dest_connection.should_receive(:chdir).with("/")
        mock_dest_connection.should_receive(:putbinaryfile).with("/home/me/file1.txt", "/file2.txt", 1024)

        FTPUtils.cp "/home/me/file1.txt", "ftp://admin:test@host2/file2.txt"
      end

      it "should work if the source is a file and the destination is a directory" do
        mock_dest_connection = mock(Net::FTPFXP)
        mock_dest_uri = mock(FTPUtils::FTPURI, :directory => true, :folder => "/", :path => "/",
          :connection => mock_dest_connection)
        FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host2").and_return(mock_dest_uri)
        mock_dest_uri.should_receive(:path=).with("//file1.txt")
        mock_dest_connection.should_receive(:chdir).with("/")
        mock_dest_connection.should_receive(:putbinaryfile).with("/home/me/file1.txt", "/", 1024)

        FTPUtils.cp "/home/me/file1.txt", "ftp://admin:test@host2"
      end

      it "should raise an error if the source file is a directory" do
        File.should_receive(:directory?).with("/home/me").and_return(true)

        lambda do
          FTPUtils.cp "/home/me", "ftp://admin:test@host1/subdir1"
        end.should raise_error("src should be a filename, not a directory")
      end
    end
    
    describe "from local filesystem to local filesystem" do
      it "should fall back on FileUtils.cp" do
        FileUtils.should_receive(:cp).with("file1.txt", "file2.txt", {})

        FTPUtils.cp "file1.txt", "file2.txt"
      end
    end
  end
  
  describe "Removing a file" do
    it "should remove an FTP directory" do
      mock_connection = mock(Net::FTPFXP)
      mock_uri = mock(FTPUtils::FTPURI, :directory => false, :folder => "/subdir1", :filename => "file.txt",
        :connection => mock_connection)
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1/file.txt").and_return(mock_uri)
      mock_connection.should_receive(:chdir).with("/subdir1")
      mock_connection.should_receive(:delete).with("file.txt")

      FTPUtils.rm "ftp://admin:test@host1/subdir1/file.txt"
    end

    it "should raise an error if an FTP directory is provided" do
      mock_connection = mock(Net::FTPFXP)
      mock_uri = mock(FTPUtils::FTPURI, :directory => true, :folder => "/subdir1", :filename => nil)
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1").and_return(mock_uri)

      lambda do
        FTPUtils.rm "ftp://admin:test@host1/subdir1"
      end.should raise_error("Can't use FTPUtils.rm on directories. Instead use FTPUtils.rm_r")
    end

    it "should fall back on FileUtils.rm if an FTP URI is not provided" do
      FileUtils.should_receive(:rm).with("file.txt")

      FTPUtils.rm "file.txt"
    end
  end

  describe "Removing recursively" do
    it "should remove a directory with nested folders and files" do
      mock_connection = mock(Net::FTPFXP)
      mock_uri = mock(FTPUtils::FTPURI, :directory => true, :path => "/subdir1",
        :connection => mock_connection)
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1").and_return(mock_uri)
      mock_connection.should_receive(:nlst).and_return( ["subdir2", "file.txt"] )

      mock_subdir_connection = mock(Net::FTPFXP)
      mock_subdir_uri = mock(FTPUtils::FTPURI, :directory => true, :path => "/subdir1/subdir2",
        :connection => mock_subdir_connection)
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1/subdir2").and_return(mock_subdir_uri)
      mock_subdir_connection.should_receive(:nlst).and_return( [] )
      mock_subdir_connection.should_receive(:rmdir).with("/subdir1/subdir2")

      mock_file_connection = mock(Net::FTPFXP)
      mock_file_uri = mock(FTPUtils::FTPURI, :directory => false, :path => "/subdir1/file.txt",
        :connection => mock_file_connection)
      FTPUtils::FTPURI.should_receive(:new).with("ftp://admin:test@host1/subdir1/file.txt").and_return(mock_file_uri)
      FTPUtils.should_receive(:rm).with("ftp://admin:test@host1/subdir1/file.txt")

      mock_connection.should_receive(:rmdir).with("/subdir1")

      FTPUtils.rm_r "ftp://admin:test@host1/subdir1"
    end
  end
end
