# 代码生成时间: 2025-10-29 10:57:19
# 使用Grape框架创建标签页切换器API

require 'grape'
require 'grape-entity'

# 定义标签页实体
class TabEntity < Grape::Entity
  expose :id, :as => :tab_id
  expose :name, :as => :tab_name
  expose :content, :as => :tab_content
end

# 定义标签页切换器API
class TabSwitcherAPI < Grape::API
  format :json

  # 获取标签页列表
  get '/tabs' do
    # 模拟标签页数据
    @tabs = [
      { id: 1, name: 'Home', content: 'Welcome to the Home tab!' },
      { id: 2, name: 'About', content: 'Learn more about us on the About tab.' },
      { id: 3, name: 'Contact', content: 'Get in touch with us on the Contact tab.' }
    ]
    # 使用实体映射响应
    @tabs.map { |tab| TabEntity.represent(tab) }
  end

  # 切换到指定标签页
  get '/tabs/:tab_id' do
    # 从模拟数据中查找指定标签页
    @tab = @tabs.find { |t| t[:id] == params[:tab_id].to_i }
    not_found!('Tab not found') unless @tab
    # 使用实体映射响应
    TabEntity.represent(@tab)
  end

  # 错误处理
  error_response :forbidden do
    error!('You are not authorized to access this resource.', 403)
  end
end
