# 代码生成时间: 2025-10-11 03:44:21
# 引入Grape框架和相关模块
require 'grape'
require 'grape-swagger'
require 'grape-swagger-rails'
require 'rack/cors'

# 定义一个响应式布局API的模块
module ResponsiveLayout
  class API < Grape::API
    # 启用CORS（跨源资源共享）
    Rack::Cors::Middleware.insert_before Grape::Middleware::Error, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    # 定义版本和根URL
    format :json
    prefix :api
    version 'v1', using: :path
    content_type :json

    # 文档生成
    add_swagger_documentation layout: :full,
                                models: true,
                                info: { title: 'Responsive Layout API',
                                        description: 'API for responsive layout design',
                                        version: '1.0' }

    # 定义一个获取响应式布局配置的路由
    desc 'Get responsive layout configuration'
    params do
      optional :device_type, type: String, desc: 'Device type (desktop, tablet, mobile)'
    end
    get '/layout' do
      # 根据设备类型返回不同的布局配置
      device_type = params[:device_type] || 'desktop'
      layout_config = case device_type
                     when 'tablet'
                       {
                         'container_width' => '768px',
                         'grid_columns' => 8,
                         'grid_gap' => '16px'
                       }
                     when 'mobile'
                       {
                         'container_width' => '100%',
                         'grid_columns' => 4,
                         'grid_gap' => '8px'
                       }
                     else
                       {
                         'container_width' => '1200px',
                         'grid_columns' => 12,
                         'grid_gap' => '24px'
                       }
                     end

      # 错误处理
      error!('Device type is not supported', 400) unless layout_config

      layout_config
    end
  end
end