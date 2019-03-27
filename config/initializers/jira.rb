# frozen_string_literal: true

# Treats JIRA DVCS user agent requests in order to be successfully handled
# by our API.
#
# Gitlab::Jira::Middleware is only defined on EE
#
# Use safe_constantize because the class may exist but still not be loaded
if "Gitlab::Jira::Middleware".safe_constantize
  Rails.application.config.middleware.use(Gitlab::Jira::Middleware)
end
