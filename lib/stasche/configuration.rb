module Stasche
  Configuration = Struct.new(
    :access_key_id,
    :bucket,
    :encrypter,
    :encryption_key,
    :namespace,
    :region,
    :secret_access_key,
    :store,
    :url
  )
end
