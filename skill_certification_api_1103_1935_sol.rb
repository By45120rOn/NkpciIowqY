# 代码生成时间: 2025-11-03 19:35:20
# SkillCertificationAPI endpoint
class SkillCertificationAPI < Sinatra::Base
  # Set the database connection
  configure do
    db = {adapter: "sqlite3", database: "skill_certification.sqlite"}
    ActiveRecord::Base.establish_connection(db)
  end

  # Endpoint to list all certifications
  get '/api/certifications' do
    # Fetch all certifications from the database
    @certifications = Certification.all
    # Return them in JSON format
    content_type :json
    @certifications.to_json
  end

  # Endpoint to add a new certification
  post '/api/certifications' do
    # Parse the JSON input from the request body
    content_type :json
    request.body.rewind
    certification_data = JSON.parse(request.body.read)

    # Create a new certification
    certification = Certification.new(certification_data)

    # Check for errors and return an appropriate response
    if certification.save
      status 201
      { certification: certification }.to_json
    else
      status 400
      { error: certification.errors.full_messages }.to_json
    end
  end

  # Error handling for unknown routes
  not_found do
    content_type :json
    { error: 'Not found' }.to_json
  end
end

# ActiveRecord models
module Models
  class Certification < ActiveRecord::Base
    # Add any required validations or associations here
    validates :name, presence: true
    validates :description, presence: true
  end
end

# Run the application
run! if app_file == $0