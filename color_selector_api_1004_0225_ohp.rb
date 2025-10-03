# 代码生成时间: 2025-10-04 02:25:19
# 定义颜色选择器组件的API
class ColorSelectorAPI < Grape::API
  format :json
  default_format :json

  # 定义颜色选择器资源
  class ColorRepresenter < Roar::Decorator
    include Roar::JSON::HAL
    include Roar::Representer::Feature::Hypermedia
    include Representable::JSON::Hash

    property :id,     render_nil: true
    property :name,  render_nil: true
    property :hex,   render_nil: true
  end

  # 定义颜色选择器资源路由
  namespace :color_selector do
    # 获取所有颜色
    get do
      # 模拟颜色数据
      colors = [
        { id: 1, name: 'Red', hex: '#FF0000' },
        { id: 2, name: 'Green', hex: '#00FF00' },
        { id: 3, name: 'Blue', hex: '#0000FF' }
      ]

      # 使用ColorRepresenter格式化颜色数据
      present colors, with: ColorRepresenter
    end

    # 根据ID获取颜色
    params do
      requires :id, type: Integer, desc: 'Color identifier'
    end
    get ':id' do
      # 模拟颜色数据
      colors = [
        { id: 1, name: 'Red', hex: '#FF0000' },
        { id: 2, name: 'Green', hex: '#00FF00' },
        { id: 3, name: 'Blue', hex: '#0000FF' }
      ]

      # 查找颜色并格式化输出
      color = colors.find { |c| c[:id] == params[:id].to_i }
      if color
        present color, with: ColorRepresenter
      else
        error!('Color not found', 404)
      end
    end
  end
end

# 启动程序
run! if app.running?