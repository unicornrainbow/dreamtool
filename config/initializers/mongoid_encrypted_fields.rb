
Mongoid::EncryptedFields.cipher =
  Gibberish::AES.new(ENV['PiNKBiCYCLE'])
