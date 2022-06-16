# lib/api_key.rb

module ApiKey
  def self.generator
    SecureRandom.base64.tr('+/=', 'Qrt')
  end
end
