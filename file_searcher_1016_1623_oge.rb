# 代码生成时间: 2025-10-16 16:23:57
# 文件搜索和索引工具的Grape API实现
class FileSearcherAPI < Grape::API
  desc '搜索文件系统中的文件'
  params do
    requires :path, type: String, desc: '要搜索的文件路径'
    optional :query, type: String, desc: '搜索关键字'
  end
  get '/search' do
    path = params[:path]
    query = params[:query].to_s.strip

    unless File.directory?(path)
      rack_response ['提供的路径不是一个有效的目录'], 400
      return
    end

    results = Find.find(path).select do |f|
      query.empty? || File.read(f).include?(query)
    end

    error!('未找到匹配的文件', 404) if results.empty?

    { files: results }
  end

  desc '获取文件的索引信息'
  params do
    requires :file, type: String, desc: '要获取索引信息的文件路径'
  end
  get '/index' do
    file = params[:file]

    unless File.exist?(file)
      rack_response ['文件不存在'], 404
      return
    end

    file_stat = File.stat(file)
    file_content = File.read(file)
    file_hash = Digest::SHA256.hexdigest(file_content)

    {
      path: file,
      size: file_stat.size,
      created_at: file_stat.ctime,
      updated_at: file_stat.mtime,
      hash: file_hash
    }
  end
end

# 启动文件搜索和索引工具的Grape API
if __FILE__ == $0
  Rack::Server.start(app: FileSearcherAPI, Port: 9292)
end