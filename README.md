# Stasche

Utility to "stash" objects and enable sharing across separate ruby sessions.

## Configuration

In order to access Stasche, you will need to configure it in each sesssion you want to have access to the data. This can be done using either Redis or S3 as the backend store.

### Using S3
```rb
require 'stasche'

Stasche.configure do |configuration|
  configuration.store             = :s3
  configuration.namespace         = 'custom-stasche'
  configuration.region            = 'us-east-1'
  configuration.bucket            = 'my-s3-bucket'
  configuration.access_key_id     = 'my_aws_access_key_id'
  configuration.secret_access_key = 'my_aws_secret_access_key'
  configuration.encrypter         = MyEncrypter
  configuration.encryption_key    = 'my_super_secret_encryption_key'
end
```

### Using Redis
```rb
require 'stasche'

Stasche.configure do |configuration|
  configuration.store          = :redis
  configuration.namespace      = 'custom-stasche'
  configuration.url            = ENV['STASCHE_REDIS_URL']
  configuration.encrypter      = MyEncrypter
  configuration.encryption_key = 'my_super_secret_encryption_key'
end
```


### Encryption

The configuration requires an `encrypter`. Existing usage on the monolith uses `SimpleboxCryptr`, but you may also supply a different class as long as it supports the interface below
```rb
class MyEncrypter
  def self.encrypt(key, plaintext)
    ...
  end

  def self.decrypt(key, ciphertext)
    ...
  end
end
```


## Thor

Stasche is automatically configured when using [thor scripts](https://checkr.atlassian.net/wiki/spaces/RD/pages/493096635/Monolith+Thor+Scripts).

In order to set or get keys used by your thor script, you will need to configure stasche locally with the same values. The configuration for thor is defined at: https://gitlab.checkrhq.net/platform/checkr/-/blob/master/lib/scripts/base.thor#L4-13 


## Usage

### Setting/Retrieving values

When setting a key, please use a reasonably specific name for your data. This reduces the chance of conflicing with other keys. If you are unsure whether a key is already used, you can run `Stasche.get(:key_name)` and see if a value is returned.

```rb
# Session A
Stasche.set(user_emails: User.where(id: ids).pluck(:email))

# Session B
user_emails = Stasche.get(:user_emails)
```

### Setting options
The set method allows you to add an `options` hash as a second parameter, for example to set a given key even if already exists
```rb
# Session A
Stasche.set({foo: 'bar'}, force: true)

# Session B
foo_value = Stasche.get(:foo)
```

### Pushing/Peeking/Popping values

```rb
# Session A
Stasche << User.where(id: ids).pluck(:email)
# => "CKt6MiweFP8jc3ahmz5FZA"

# Session B
Stasche.peek # returns last value, without removing from cache
# => [...]
Stasche.pop # dequeues last value, deleting from cache
# => [...]
```

### Inspecting store

```rb
# Listing stored keys
Stasche.ls
# => [...]
```
