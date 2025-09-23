# 代码生成时间: 2025-09-24 01:07:35
# 进程管理器模块
module ProcessManager
  # 启动一个子进程
  def self.start_process(command)
    puts "Starting process with command: #{command}"
    success = system(command)
    unless success
      raise "Failed to start process with command: #{command}"
    end
  end

  # 停止一个子进程
  def self.stop_process(pid)
    puts "Stopping process with PID: #{pid}"
    Process.kill('TERM', pid)
    unless $CHILD_STATUS.success?
      raise "Failed to stop process with PID: #{pid}"
    end
  end

  # 列出所有子进程
  def self.list_processes
    puts "Listing all processes"
    Open3.popen3('ps aux') do |stdin, stdout, stderr, wait_thr|
      lines = stdout.readlines
      lines.each do |line|
        puts line
      end
    end
  end
end

# Grape API 定义
class ProcessManagerAPI < Grape::API
  format :json

  # 启动进程的路由
  get '/start' do
    command = params[:command]
    raise 'Command is required' if command.nil?
    ProcessManager.start_process(command)
    { message: 'Process started successfully' }
  end

  # 停止进程的路由
  get '/stop' do
    pid = params[:pid]
    raise 'PID is required' if pid.nil?
    ProcessManager.stop_process(pid.to_i)
    { message: 'Process stopped successfully' }
  end

  # 列出所有进程的路由
  get '/list' do
    ProcessManager.list_processes
    { message: 'Processes listed successfully' }
  end
end

# 运行 Grape API
run! if __FILE__ == $0