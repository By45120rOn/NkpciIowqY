# 代码生成时间: 2025-10-30 23:24:54
# 引入Grape框架
require 'grape'
require 'grape-entity'
require 'json'

# 定义一个实体类，用于标签页数据的序列化
class TabPageEntity < Grape::Entity
  expose :id, documentation: { type: 'Integer', desc: '标签页的唯一标识符' }
  expose :title, documentation: { type: 'String', desc: '标签页的标题' }
  expose :content, documentation: { type: 'String', desc: '标签页的内容' }
end

# 创建API类
class TabSwitcherAPI < Grape::API
  # 定义标签页数据的存储结构
  TAB_PAGES = [
    { id: 1, title: 'Home', content: 'This is the home tab.' },
    { id: 2, title: 'Profile', content: 'This is the profile tab.' },
    { id: 3, title: 'Settings', content: 'This is the settings tab.' }
  ]

  # 获取所有标签页
  get do
    # 使用实体类来序列化数据
    TabPageEntity.represent(TAB_PAGES)
  end

  # 根据ID获取单个标签页
  params do
    requires :id, type: Integer, desc: '标签页的ID'
  end
  get ':id' do
    # 查找标签页并处理查找失败的情况
    tab_page = TAB_PAGES.find { |tab| tab[:id] == params[:id] }
    if tab_page
      TabPageEntity.represent(tab_page)
    else
      error!('Tab not found', 404)
    end
  end

  # 添加一个新的标签页
  params do
    requires :title, type: String, desc: '新标签页的标题'
    requires :content, type: String, desc: '新标签页的内容'
  end
  post do
    # 生成新标签页的ID并添加到列表中
    new_id = TAB_PAGES.map { |tab| tab[:id] }.max + 1
    new_tab = { id: new_id, title: params[:title], content: params[:content] }
    TAB_PAGES << new_tab
    TabPageEntity.represent(new_tab)
  end

  # 错误处理
  error_format :json, each_serializer: :to_json do |object, env|
    { error: object.message }
  end
end

# 启动API服务器
run!(TabSwitcherAPI, host: '0.0.0.0', port: 9292)