require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FTPUtils" do
  describe "copying a file" do
    describe "from FTP to FTP" do
      it "should work if a file URIs are specified for the source and destination" do
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/file1.txt").
          and_return(false)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host2/file2.txt").
          and_return("/")
        FTPUtils::FTPFile.should_receive(:basename).with("ftp://admin:test@host2/file2.txt").
          and_return("file2.txt")

        mock_src_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/file1.txt").
          and_return(mock_src_connection)
        mock_dest_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host2/file2.txt").
          and_return(mock_dest_connection)
        FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host1/file1.txt").
          and_return("/file1.txt")
        mock_src_connection.should_receive(:fxpto).with(mock_dest_connection, "//file2.txt", "/file1.txt")
      
        FTPUtils.cp "ftp://admin:test@host1/file1.txt", "ftp://admin:test@host2/file2.txt"
      end

      it "should work if a file URI with subdirnames are specified for the source and destination" do
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(false)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host2/subdir2/file2.txt").
          and_return("/subdir2")
        FTPUtils::FTPFile.should_receive(:basename).with("ftp://admin:test@host2/subdir2/file2.txt").
          and_return("file2.txt")

        mock_src_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(mock_src_connection)
        mock_dest_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host2/subdir2/file2.txt").
          and_return(mock_dest_connection)
        FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return("/subdir1/file1.txt")
        mock_src_connection.should_receive(:fxpto).with(mock_dest_connection, "/subdir2/file2.txt", "/subdir1/file1.txt")
      
        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "ftp://admin:test@host2/subdir2/file2.txt"
      end

      it "should work if a file URI is specified for the source and a directory for the destination" do
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(false)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host2/subdir2").
          and_return("/subdir2")
        FTPUtils::FTPFile.should_receive(:basename).with("ftp://admin:test@host2/subdir2").
          and_return(nil)
        FTPUtils::FTPFile.should_receive(:basename).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return("file1.txt")

        mock_src_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(mock_src_connection)
        mock_dest_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host2/subdir2").
          and_return(mock_dest_connection)
        FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return("/subdir1/file1.txt")
        mock_src_connection.should_receive(:fxpto).with(mock_dest_connection, "/subdir2/file1.txt", "/subdir1/file1.txt")
      
        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "ftp://admin:test@host2/subdir2"
      end

      it "should raise an error if the source URI is a directory" do
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1").
          and_return(true)
      
        lambda do
          FTPUtils.cp "ftp://admin:test@host1/subdir1", "ftp://admin:test@host2/subdir2"
        end.should raise_error("src should be a filename, not a directory")
      end
    end

    describe "from FTP to the local filesystem" do
      it "should work if the destination filename is given" do
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(false)

        FTPUtils::FTPFile.should_receive(:basename).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return("file1.txt")

        File.should_receive(:directory?).with("/home/me/file2.txt").and_return(false)

        mock_src_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(mock_src_connection)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return("/subdir1")
        mock_src_connection.should_receive(:chdir).with("/subdir1")
        mock_src_connection.should_receive(:getbinaryfile).with("file1.txt", "/home/me/file2.txt", 1024)

        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "/home/me/file2.txt"
      end

      it "should work if the destination directory is given" do
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(false)

        FTPUtils::FTPFile.should_receive(:basename).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return("file1.txt")

        File.should_receive(:directory?).with("/home/me").and_return(true)

        mock_src_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return(mock_src_connection)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host1/subdir1/file1.txt").
          and_return("/subdir1")
        mock_src_connection.should_receive(:chdir).with("/subdir1")
        mock_src_connection.should_receive(:getbinaryfile).with("file1.txt", "/home/me/file1.txt", 1024)

        FTPUtils.cp "ftp://admin:test@host1/subdir1/file1.txt", "/home/me"
      end

      it "should raise an error if the source URI is a directory" do
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1").
          and_return(true)

        lambda do
          FTPUtils.cp "ftp://admin:test@host1/subdir1", "/home/me"
        end.should raise_error("src should be a filename, not a directory")
      end
    end

    describe "from local filesystem to FTP" do
      it "should work if the source is a file and the destination is a file" do
        File.should_receive(:directory?).with("/home/me/file1.txt").and_return(false)
        FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host2/file2.txt").
          and_return("/file2.txt")
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host2/file2.txt").
          and_return(false)
        mock_dest_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host2/file2.txt").
          and_return(mock_dest_connection)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host2/file2.txt").and_return("/")
        mock_dest_connection.should_receive(:chdir).with("/")
        mock_dest_connection.should_receive(:putbinaryfile).with("/home/me/file1.txt", "/file2.txt", 1024)

        FTPUtils.cp "/home/me/file1.txt", "ftp://admin:test@host2/file2.txt"
      end

      it "should work if the source is a file and the destination is a directory" do
        File.should_receive(:directory?).with("/home/me/file1.txt").and_return(false)
        FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host2").
          and_return("")
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host2").
          and_return(true)
        File.should_receive(:basename).with("/home/me/file1.txt").and_return("file1.txt")
        mock_dest_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host2").
          and_return(mock_dest_connection)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host2").and_return("/")
        mock_dest_connection.should_receive(:chdir).with("/")
        mock_dest_connection.should_receive(:putbinaryfile).with("/home/me/file1.txt", "/file1.txt", 1024)

        FTPUtils.cp "/home/me/file1.txt", "ftp://admin:test@host2"
      end

      it "should provide an informative error message if the file can't be uploaded" do
        File.should_receive(:directory?).with("/home/me/file1.txt").and_return(false)
        FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host2/file2.txt").
          and_return("/file2.txt")
        FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host2/file2.txt").
          and_return(false)
        mock_dest_connection = mock(FTPUtils::FTPConnection)
        FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host2/file2.txt").
          and_return(mock_dest_connection)
        FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host2/file2.txt").and_return("/")
        mock_dest_connection.should_receive(:chdir).with("/")
        mock_dest_connection.should_receive(:putbinaryfile).with("/home/me/file1.txt", "/file2.txt", 1024).
          and_raise(Net::FTPPermError)

        lambda do
          FTPUtils.cp "/home/me/file1.txt", "ftp://admin:test@host2/file2.txt"
        end.should raise_error("Unable to copy /home/me/file1.txt to /file2.txt, possibly due to FTP server permissions")
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
  
  describe "removing a file" do
    it "should remove an FTP directory" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file.txt").
        and_return(false)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/file.txt").
        and_return(mock_connection)
      FTPUtils::FTPFile.should_receive(:dirname).with("ftp://admin:test@host1/subdir1/file.txt").and_return("/subdir1")
      mock_connection.should_receive(:chdir).with("/subdir1")
      mock_connection.should_receive(:delete).with("file.txt")

      FTPUtils.rm "ftp://admin:test@host1/subdir1/file.txt"
    end

    it "should raise an error if an FTP directory is provided" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1").
        and_return(true)

      lambda do
        FTPUtils.rm "ftp://admin:test@host1/subdir1"
      end.should raise_error("Can't use FTPUtils.rm on directories. Instead use FTPUtils.rm_r")
    end

    it "should fall back on FileUtils.rm if an FTP URI is not provided" do
      FileUtils.should_receive(:rm).with("file.txt")

      FTPUtils.rm "file.txt"
    end
  end

  describe "removing recursively" do
    it "should remove a directory with nested dirnames and files" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1").
        and_return(true)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1").
        and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/subdir1")
      mock_connection.should_receive(:nlst).and_return( ["subdir2", "file.txt"] )

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/subdir2").
        and_return(true)
      mock_subdir_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/subdir2").
        and_return(mock_subdir_connection)
      mock_subdir_connection.should_receive(:chdir).with("/subdir1/subdir2")
      mock_subdir_connection.should_receive(:nlst).and_return( [] )
      FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host1/subdir1/subdir2").twice.
        and_return("/subdir1/subdir2")
      mock_subdir_connection.should_receive(:rmdir).with("/subdir1/subdir2")

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file.txt").
        and_return(false)
      FTPUtils.should_receive(:rm).with("ftp://admin:test@host1/subdir1/file.txt")

      FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host1/subdir1").twice.
        and_return("/subdir1")
      mock_connection.should_receive(:rmdir).with("/subdir1")

      FTPUtils.rm_r "ftp://admin:test@host1/subdir1"
    end

    it "should remove a file" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file.txt").
        and_return(false)
      FTPUtils.should_receive(:rm).with("ftp://admin:test@host1/subdir1/file.txt")

      FTPUtils.rm_r "ftp://admin:test@host1/subdir1/file.txt"
    end

    it "should fall back on FileUtils.rm_r if a non-FTP URI is provided" do
      FileUtils.should_receive(:rm_r).with("dir")

      FTPUtils.rm_r "dir"
    end
  end

  describe "create a directory and all its parents" do
    it "should work on an FTP URI" do
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/subdir2").
        and_return(mock_connection)

      FTPUtils::FTPFile.should_receive(:relative_path).with("ftp://admin:test@host1/subdir1/subdir2").
        and_return("/subdir1/subdir2")

      mock_connection.should_receive(:mkdir).with("subdir1")
      mock_connection.should_receive(:chdir).with("subdir1")
      mock_connection.should_receive(:mkdir).with("subdir2")
      mock_connection.should_receive(:chdir).with("subdir2")

      FTPUtils.mkdir_p "ftp://admin:test@host1/subdir1/subdir2"
    end

    it "should fall back on FileUtils for a non-FTP URI" do
      FileUtils.should_receive(:mkdir_p).with("subdir1/subdir2")

      FTPUtils.mkdir_p("subdir1/subdir2")
    end
  end

  describe "copying recursively" do
    it "should copy an FTP directory to another FTP directory" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1").
        and_return(true)
      FTPUtils.should_receive(:mkdir_p).with("ftp://admin:test@host2/subdir2")
      mock_src_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1").
        and_return(mock_src_connection)
      mock_src_connection.should_receive(:nlst).and_return( ["subdira", "file.txt"] )

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/subdira").
        and_return(true)
      FTPUtils.should_receive(:mkdir_p).with("ftp://admin:test@host2/subdir2/subdira")
      mock_subdira_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/subdira").
        and_return(mock_subdira_connection)
      mock_subdira_connection.should_receive(:nlst).and_return([])

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file.txt").
        and_return(false)
      FTPUtils.should_receive(:cp).with("ftp://admin:test@host1/subdir1/file.txt",
                                        "ftp://admin:test@host2/subdir2/file.txt", {})

      FTPUtils.cp_r "ftp://admin:test@host1/subdir1", "ftp://admin:test@host2/subdir2"
    end

    it "should copy an FTP directory to a local directory" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1").
        and_return(true)
      FTPUtils.should_receive(:mkdir_p).with("/home/me/subdir2")
      mock_src_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1").
        and_return(mock_src_connection)
      mock_src_connection.should_receive(:nlst).and_return( ["subdira", "file.txt"] )

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/subdira").
        and_return(true)
      FTPUtils.should_receive(:mkdir_p).with("/home/me/subdir2/subdira")
      mock_subdira_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1/subdira").
        and_return(mock_subdira_connection)
      mock_subdira_connection.should_receive(:nlst).and_return([])

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1/file.txt").
        and_return(false)
      FTPUtils.should_receive(:cp).with("ftp://admin:test@host1/subdir1/file.txt",
                                        "/home/me/subdir2/file.txt", {})

      FTPUtils.cp_r "ftp://admin:test@host1/subdir1", "/home/me/subdir2"
    end

    it "should copy a local directory to an FTP directory" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host2/subdir2").
        and_return(true)
      FTPUtils.should_receive(:mkdir_p).with("ftp://admin:test@host2/subdir2")
      Dir.should_receive(:entries).with("/home/me/subdir1").and_return( ["subdira", "file.txt"] )

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host2/subdir2/subdira").
        and_return(true)
      FTPUtils.should_receive(:mkdir_p).with("ftp://admin:test@host2/subdir2/subdira")
      Dir.should_receive(:entries).with("/home/me/subdir1/subdira").and_return([])

      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host2/subdir2/file.txt").
        and_return(false)
      FTPUtils.should_receive(:cp).with("/home/me/subdir1/file.txt", "ftp://admin:test@host2/subdir2/file.txt", {})

      FTPUtils.cp_r "/home/me/subdir1", "ftp://admin:test@host2/subdir2"
    end

    it "should copy a local directory to another local directory" do
      FileUtils.should_receive(:cp_r).with("/home/me/subdir1", "/home/me/subdir2")

      FTPUtils.cp_r "/home/me/subdir1", "/home/me/subdir2"
    end
  end

  describe "listing the entries in a directory" do
    it "should return a list of entries in an FTP directory" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/subdir1").
        and_return(true)
      mock_connection = mock(FTPUtils::FTPConnection)
      FTPUtils::FTPConnection.should_receive(:connect).with("ftp://admin:test@host1/subdir1").
        and_return(mock_connection)
      mock_connection.should_receive(:chdir).with("/subdir1")
      mock_connection.should_receive(:nlst).and_return( ["subdir2", "file.txt"] )

      FTPUtils.ls("ftp://admin:test@host1/subdir1").should == ["subdir2", "file.txt"]
    end

    it "should return nil for an FTP URI that isn't a directory" do
      FTPUtils::FTPFile.should_receive(:directory?).with("ftp://admin:test@host1/file.txt").
        and_return(false)

      FTPUtils.ls("ftp://admin:test@host1/file.txt").should == nil
    end

    it "should use Dir.entries for a non-FTP URI" do
      Dir.should_receive(:entries).with("/home/me/subdir1")

      FTPUtils.ls("/home/me/subdir1")
    end
  end
end
