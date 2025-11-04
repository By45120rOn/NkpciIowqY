# 代码生成时间: 2025-11-04 14:05:39
# 缓存键值对
CACHE = {}
CACHE_LOCK = Mutex.new

# DNS解析和缓存工具
class DNSResolverAPI < Grape::API
  format :json
  # 解析域名
  get '/resolve' do
    # 获取参数
    domain = params[:domain]
    
    # 参数校验
    unless domain
      status 400
      { error: 'Missing domain parameter' }
    end
    
    # 从缓存中查找
    result = CACHE_LOCK.synchronize { CACHE[domain] }
    unless result
      # 执行DNS解析
      begin
        result = Resolv.getaddress(domain)
        
        # 更新缓存
        CACHE_LOCK.synchronize { CACHE[domain] = result }
      rescue Resolv::ResolvError => e
        # 错误处理
        error!({ error: e.message }, 500)
      end
    end
    
    # 返回结果
    { domain: domain, ip: result }
  end
end

# 启动Grape服务
if __FILE__ == $0
  Rack::Server.start(app: DNSResolverAPI, Port: 4567)
end
