# 代码生成时间: 2025-10-05 21:59:37
# data_encryption_service.rb
require 'grape'
require 'openssl'

# DataEncryptionService provides methods for encrypting and decrypting data
class DataEncryptionService < Grape::API
  # Error handling
  helpers do
    def handle_error(e)
      # Log the error
      # You can use a logger here, e.g., Rails.logger.error(e.message)
      raise e.message
    end
  end

  # API namespace for data encryption
  namespace :data do
    # POST /encrypt
    # Encrypts the provided data
    post 'encrypt' do
      data = params[:data]
      raise 'No data provided for encryption' if data.nil?

      # Encrypt the data using AES-256-GCM
      encrypted_data = encrypt_data(data)
      error!('Encryption failed', 500) unless encrypted_data

      { encrypted: encrypted_data }
    rescue => e
      handle_error(e)
    end

    # POST /decrypt
    # Decrypts the provided encrypted data
    post 'decrypt' do
      encrypted_data = params[:encrypted_data]
      raise 'No encrypted data provided for decryption' if encrypted_data.nil?

      # Decrypt the data using AES-256-GCM
      decrypted_data = decrypt_data(encrypted_data)
      error!('Decryption failed', 500) unless decrypted_data

      { decrypted: decrypted_data }
    rescue => e
      handle_error(e)
    end
  end

  private

  # Encrypts data using AES-256-GCM
  def encrypt_data(data)
    # Generate a random key and iv
    key = OpenSSL::Cipher.new('aes-256-gcm').random_key
    iv = OpenSSL::Cipher.new('aes-256-gcm').random_iv

    # Create a cipher for encryption
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv

    # Encrypt the data
    encrypted_data = cipher.update(data) + cipher.final
    # Get the authentication tag
    auth_tag = cipher.auth_tag

    # Return the encrypted data, key, iv, and auth tag
    {
      iv: iv,
      key: key,
      auth_tag: auth_tag,
      data: encrypted_data
    }
  end

  # Decrypts data using AES-256-GCM
  def decrypt_data(encrypted_data)
    # Extract the iv, key, auth tag, and encrypted data from the encrypted data
    iv = encrypted_data[:iv]
    key = encrypted_data[:key]
    auth_tag = encrypted_data[:auth_tag]
    data = encrypted_data[:data]

    # Create a cipher for decryption
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    cipher.auth_tag = auth_tag

    # Decrypt the data
    decrypted_data = cipher.update(data) + cipher.final
    decrypted_data
  end
end
