# stasche

[![Circle CI](https://circleci.com/gh/checkr/stasche.svg?style=shield&circle-token=c30680de66d1919ea98ee301e888c1f06a9d0adc)](https://circleci.com/gh/checkr/stasche)
[![Code Climate](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/badges/90e62077a5dbf9420544/gpa.svg)](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/feed)
[![Test Coverage](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/badges/90e62077a5dbf9420544/coverage.svg)](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/badges)

Utility to "stash" objects and enable sharing across separate or remote
sessions.

## Configuration

### Using Redis as the backend store
```rb
require 'stasche'

class MyEncrypter
  def self.encrypt(key, plaintext)
    ...
  end

  def self.decrypt(key, ciphertext)
    ...
  end
end

Stasche.configure do |configuration|
  configuration.store          = :redis
  configuration.namespace      = 'custom-stasche'
  configuration.url            = ENV['STASCHE_REDIS_URL']
  configuration.encrypter      = MyEncrypter
  configuration.encryption_key = 'my_super_secret_encryption_key'
end
```

### Using S3 as the backend store
```rb
require 'stasche'

class MyEncrypter
  def self.encrypt(key, plaintext)
    ...
  end

  def self.decrypt(key, ciphertext)
    ...
  end
end

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

### Encryption
Stasche encrypts all data before storing it in your backend of choice.  As shown
in the example above, you must pass an object (in the examples a class is used)
which responds to `encrypt` and `decrypt` methods.  Both of these methods must
accept two arguments; the encryption key, and the plaintext/ciphertext to
encrypt/decrypt.

## Usage

### Setting/Retrieving values

```rb
# Session A
Stasche.set(user_emails: User.where(id: ids).pluck(:email))

# Session B
user_emails = Stasche.get(:user_emails)
```

### Pushing/Peeking/Popping values

```rb
# Session A
Stasche << User.where(id: ids).pluck(:email)
# => "CKt6MiweFP8jc3ahmz5FZA"

# Session B
Stasche.peek
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
