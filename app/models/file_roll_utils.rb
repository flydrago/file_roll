class FileRollUtils


  # 文件备份
  # filepath 文件路径
  # filename 文件名称
  # max_rotate 回滚上限
  # rotate_filesize 文件回滚大小上限
  def self.exec_roll(filepath, filename, max_rotate=50, rotate_filesize=0)

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
      p"备份文件失败！"
    end

    #侦测历史归档文件列表
    detection_files = []
    Dir::foreach(filepath) { |fn|
      if File::file?("#{filepath}/#{fn}") && fn=~/^#{filename}\d+\.tar\.gz$/
        p "侦测到历史归档文件：#{fn}！"
        detection_files << fn.gsub(/^#{filename}/, '').gsub(/\.tar\.gz$/, '')
      end
    }

    #判断是否超过最大归数，超过删除最久的文件
    if detection_files.size > max_rotate
      detection_files.sort_by { |i| i } #排序
      delete_files = detection_files[0, (detection_files.size-max_rotate)]
    end

    if delete_files.nil?
      p "没有要删除的文件"
    else
      delete_files.each do |del_fn|
        File::delete("#{filepath}/#{filename}#{del_fn}.tar.gz")
        p "删除过期的归档文件：#{filepath}/#{filename}#{del_fn}.tar.gz！"
      end
    end
  end


  #demo 工具方法
  def self.exec_demo(arg)
    p "指定操作执行，参数为：#{arg}"
  end


  #mongodb 数据库备份
  #host_name 地址
  #port 端口
  #bak_path 备份路径
  #username 用户名
  #password 密码
  #db 数据库名称
  #max_rotate 滚动的文件
  def self.mongodb_bak(host_name, port, bak_path, username, password, db="",max_rotate=15)

    #备份文件开头
    bakfile_prefix = "dbbak_"

    #创建文件夹
    create_dir_sh = "mkdir -p #{bak_path}/baktemp && mkdir -p #{bak_path}/bak "
    #本分shell
    dbbak_sh = "mongodump -h #{host_name}:#{port} -u #{username} -p #{password} -o #{bak_path}/baktemp"
    #备份数据库生成备份文件
    if db.present?
      dbbak_sh = "mongodump -h #{host_name}:#{port} -u #{username} -p #{password} -d #{db} -o #{bak_path}/baktemp"
    end

    #归档shell
    tar_sh = "tar -czvf #{bak_path}/bak/#{bakfile_prefix}#{Time.now.strftime("%Y%m%d%H%M%S")}.tar.gz #{bak_path}/baktemp"

    #清空临时备份目录
    clean_baktemp_sh = "rm -rf #{bak_path}/baktemp/*"

    if !system "#{create_dir_sh} && #{dbbak_sh} && #{tar_sh} && #{clean_baktemp_sh}"
      p "备份数据库文件失败！"
      return
    end

    #侦测历史归档文件列表
    detection_files = []
    Dir::foreach("#{bak_path}/bak/") { |fn|
      if File::file?("#{bak_path}/bak/#{fn}") && fn=~/^#{bakfile_prefix}\d+\.tar\.gz$/
        p "侦测到历史归档文件：#{fn}！"
        detection_files << fn.gsub(/^#{bakfile_prefix}/, '').gsub(/\.tar\.gz$/, '')
      end
    }

    #判断是否超过最大归数，超过删除最久的文件
    if detection_files.size > max_rotate
      detection_files.sort_by { |i| i } #排序
      delete_files = detection_files[0, (detection_files.size-max_rotate)]
    end

    if delete_files.nil?
      p "没有过期的归档文件"
    else
      delete_files.each do |del_fn|
        File::delete("#{bak_path}/bak/#{bakfile_prefix}#{del_fn}.tar.gz")
        p "删除过期的归档文件：#{bak_path}/bak/#{bakfile_prefix}#{del_fn}.tar.gz！"
      end
    end

  end

end