# 代码生成时间: 2025-10-28 20:51:50
# Initializes the API and sets up the version
class FileSplitMergeAPI < Grape::API
  version 'v1', using: :header, vendor: 'filesplitmerge'
  format :json

  # Split a file into chunks
  params do
    requires :file_path, type: String, desc: 'The path to the file to be split.'
    requires :chunk_size, type: Integer, desc: 'The size of each chunk in bytes.'
  end
  get :split do
    file_path = params[:file_path]
    chunk_size = params[:chunk_size]

    # Check if file exists and is readable
    unless File.exist?(file_path) && File.readable?(file_path)
      error!('File not found or not readable', 404)
    end

    # Split the file into chunks
    chunks = []
    file = File.open(file_path, 'rb')
    while buffer = file.read(chunk_size)
      chunks << buffer.force_encoding('BINARY')
    end
    file.close

    present chunks, with: ChunkEntity
  end

  # Merge chunks back into a file
  params do
    requires :output_path, type: String, desc: 'The path to save the merged file.'
    requires :chunks, type: Array, desc: 'The array of chunks to merge.'
  end
  post :merge do
    output_path = params[:output_path]
    chunks = params[:chunks]

    # Check if output path is writable
    unless File.writable?(File.dirname(output_path))
      error!('Output path not writable', 403)
    end

    # Merge the chunks into a file
    File.open(output_path, 'wb') do |file|
      chunks.each do |chunk|
        file.write(chunk)
      end
    end

    present { message: 'File successfully merged' }, with: SuccessEntity
  end
end

# Represents a chunk of a file
class ChunkEntity < Grape::Entity
  expose :data, documentation: { type: 'String', desc: 'The binary data of the chunk.' }
end

# Represents a success message
class SuccessEntity < Grape::Entity
  expose :message, documentation: { type: 'String', desc: 'The success message.' }
end

# Error handling for file not found
error_format :json
error_class :not_found do
  def message
    'Resource not found'
  end
end

# Error handling for file not writable
error_class :forbidden do
  def message
    'Action not allowed'
  end
end

# Run the Grape API
run!(FileSplitMergeAPI)