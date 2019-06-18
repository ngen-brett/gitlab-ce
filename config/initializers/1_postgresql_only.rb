raise "PostgreSQL is the only supported database from GitLab 12.1" unless
  Gitlab::Database.postgresql?
