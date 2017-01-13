module FileRollUtils

  def self.exec_roll(filepath, filename, max_rotate=50,rotate_filesize=0)

    log_path = "#{filepath}/#{filename}"

    #备份文件
    if !File::file?(log_path)
      p "备份文件（#{filepath}/#{filename}）不存在！"
      return
    end

    if File::size(log_path) < rotate_filesize
      p "备份文件（#{filepath}/#{filename}）大小为：#{File::size(log_path)/(1024*1024)}m 不需要归档！"
      return
    end

    #归档并清空源文件
    if !system "tar -czvf #{filepath}/#{filename}#{Time.now.strftime("%Y%m%d%H%M%S")}.tar.gz #{log_path} ; echo '' > #{log_path} "
      p "备份文件失败！"
    end

    #侦测历史归档文件列表
    detection_files = []
    Dir::foreach(filepath) { |fn|
      if File::file?("#{filepath}/#{fn}") && fn=~/^#{filename}\d+\.tar\.gz$/
        p "侦测到历史归档文件：#{fn}！"
        detection_files << fn.gsub(/^#{filename}/,'').gsub(/\.tar\.gz$/,'')
      end
    }

    #判断是否超过最大归数，超过删除最久的文件
    if detection_files.size > max_rotate
      detection_files.sort_by{|i| i}  #排序
      delete_files = detection_files[0,(detection_files.size-max_rotate)]
    end

    if delete_files.nil?
      p "没有要删除的文件"
    else
      delete_files.each do |del_fn|
        File::delete("#{filepath}/#{filename}#{del_fn}.tar.gz")
      end
    end
  end
end