begin
  Gitlab::Pages.secret
rescue
  Gitlab::Pages.write_secret
end

# Try a second time. If it does not work this will raise.
Gitlab::Pages.secret
