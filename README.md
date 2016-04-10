# stache

[![Circle CI](https://circleci.com/gh/checkr/stache.svg?style=shield&circle-token=5fc36ea99e2d3ad9f0b52d1bd7afeb9b464d3384)](https://circleci.com/gh/checkr/stache)
[![Code Climate](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/badges/90e62077a5dbf9420544/gpa.svg)](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/feed)
[![Test Coverage](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/badges/90e62077a5dbf9420544/coverage.svg)](https://codeclimate.com/repos/5709c3dc4b265e0077000f93/badges)

Utility to "stash" objects and enable sharing across separate or remote
sessions.

## Configuration

```rb
require 'stache'

Stache.configuration do |configuration|
  configuration.store     = :redis
  configuration.namespace = 'custom-stache'
  configuration.url       = ENV['STACHE_REDIS_URL']
end
```

## Usage

### Setting/Retrieving values

```rb
# Session A
Stache.set(user_emails: User.where(id: ids).pluck(:email))

# Session B
user_emails = Stache.get(:user_emails)
```

### Pushing/Peeking/Popping values

```rb
# Session A
Stache << User.where(id: ids).pluck(:email)
# => "CKt6MiweFP8jc3ahmz5FZA"

# Session B
Stache.peek
# => [...]
Stache.pop # dequeues last value, deleting from cache
# => [...]
```

### Inspecting store

```rb
# Listing stored keys
Stache.ls
# => [...]
```
