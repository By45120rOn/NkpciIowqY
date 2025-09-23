# 代码生成时间: 2025-09-23 23:39:39
# 创建定时任务调度器API
class SchedulerAPI < Grape::API
  # 定义定时任务的存储结构
  @@scheduler = Rufus::Scheduler.new

  # 获取所有定时任务
  get '/tasks' do
    # 错误处理
    if @@scheduler.nil?
      error!('Scheduler is not initialized', 500)
    end
    # 返回所有的定时任务
    @@scheduler.jobs.map { |job| { job_id: job.job_id, schedule: job.original } }.to_json
  end

  # 添加一个新的定时任务
  post '/tasks' do
    # 从请求体中获取任务信息
    task_params = JSON.parse(request.body.read)
    # 验证参数
    unless task_params['schedule'] && task_params['task']
      error!('Schedule and task are required', 400)
    end
    # 创建定时任务
    begin
      job = @@scheduler.every(task_params['schedule']) do
        task_params['task'].call
      end
      # 返回创建的任务信息
      { job_id: job.job_id, schedule: job.original }.to_json
    rescue Rufus::Scheduler::InvalidScheduleError => e
      # 错误处理
      error!('Invalid schedule format', 400)
    end
  end

  # 删除一个定时任务
  delete '/tasks/:job_id' do
    job_id = params['job_id']
    # 验证任务是否存在
    unless @@scheduler.jobs.include?(job_id: job_id)
      error!('Task not found', 404)
    end
    # 删除任务
    @@scheduler.unschedule(job_id)
    # 返回成功信息
    { message: 'Task removed successfully' }.to_json
  end
end

# 启动定时任务调度器API
run!(SchedulerAPI, port: 4567)