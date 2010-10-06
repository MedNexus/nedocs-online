module REncrypt #:nodoc:
  require 'openssl'
  require 'digest/sha1'
  require 'base64'
  
  class Key
    # Algorithm = 'aes-128-cbc'
    Algorithm = 'DES'
    SaltLength = 16 # :nodoc:
    SaltChars = (('a'..'f').to_a).concat(('0'..'9').to_a) # :nodoc:
    
    def initialize(password, salt = nil)
      # create the salt if we need to
      if !salt || salt.empty?
        salt = ''
        SaltLength.times do
          salt << SaltChars[rand(SaltChars.length)]
        end
      end
      
      # now, let the hashing begin
      digest = Digest::SHA1.new
      digest << salt << password
      @key = salt << digest.hexdigest
    end
    
    def self.encrypt_with_password(password, salt, data)
      key = Key.new(password, salt)
      key.encrypt(data)
    end
    
    def self.decrypt_with_password(password, salt, data)
      key = Key.new(password, salt)
      key.decrypt(data)
    end
    
    def self.encrypt64_with_password(password, salt, data)
      key = Key.new(password, salt)
      key.encrypt64(data)
    end
    
    def self.decrypt64_with_password(password, salt, data)
      key = Key.new(password, salt)
      key.decrypt64(data)
    end
    
    def encode
      Base64.encode64(@key).chop
    end
    
    def decode(str)
      Base64.decode64(str)
    end
    
    def to_s
      encode
    end
    
    def encrypt(data)
      if data.nil? || data == ''
        nil
      else
        @cipher = OpenSSL::Cipher::Cipher.new(Algorithm)
        @cipher.key = @key
        @cipher.encrypt
        output = @cipher.update(data)
        output << @cipher.final
        output
      end
    end
    
    def encrypt64(data)
      data = encrypt(data)
      if data.nil? || data == ''
        nil
      else
        Base64.encode64(data)
      end
    end
    
    def decrypt(data)
      if data.nil? || data == ''
        nil
      else
        @cipher = OpenSSL::Cipher::Cipher.new(Algorithm)
        @cipher.key = @key
        @cipher.decrypt
        output = @cipher.update(data)
        output << @cipher.final
        output
      end
    end
    
    def decrypt64(data)
      if data.nil? || data == ''
        nil
      else
        decrypt(Base64.decode64(data))
      end
    end
    
    def marshal_dump
      encode
    end
    
    def marshal_load(str) 
      decode(str)
    end
  end
end
