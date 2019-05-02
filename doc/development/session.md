# Accessing session data

Session data in GitLab is stored in Redis and can be accessed in a variety of ways.

During a web request Rails provides access in controllers through [`ActionDispatch::Session`](https://guides.rubyonrails.org/action_controller_overview.html#session). Outside of controllers it is possible to access this through `Gitlab::Session`.

Sessions stored in Redis can also be accesed in a variety of ways. Data about the UserAgent associated with the session can be accessed through `ActiveSession`, or the session can be looked up directly in Redis.

## Gitlab::Session


```ruby
```

## Gitlab::NamespacedSessionStore


```ruby
```

## ActiveSession class


```ruby
```

See also doc/user/profile/active_sessions.md

## Through Redis

```ruby
```

See also doc/administration/operations/cleaning_up_redis_sessions.md