---
type: reference
---

# Rate Request Limit on Raw Endpoints

NOTE: **Note:** Introduced on GitLab 12.2

This option allows to limit the eequests to raw endpoints, i.e: `https://gitlab.com/gitlab-org/gitlab-ce/raw/master/app/controllers/application_controller.rb`, to `300` requests per minute for each raw path. The setting can be modified in **Admin Area > Network > Performance Optimization**

![img/rate_request_limit_on_raw_endpoints.png]
 
This limit is active by default, to disable set the option to `0`.
