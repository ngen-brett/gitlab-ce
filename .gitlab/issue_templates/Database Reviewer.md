#### Database Reviewer Onboarding

Thank you for becoming a database reviewer! :-) Please review and work on the list below to complete your setup. For any question, reach out to #database or your assigned buddy.

| Database Reviewer                               | @your-alias-here |
| ----------------------------------------------- | ---------------- |
| Database Buddy (another Reviewer or Maintainer) | @...             |

- [ ] Review general [code review guide](https://docs.gitlab.com/ee/development/code_review.html)
- [ ] Review [database review documentation](https://gitlab.com/gitlab-com/www-gitlab-com/merge_requests/19980) (TODO: Adjust link once published)
- [ ] Familiarize with [migration helpers](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/gitlab/database/migration_helpers.rb) and review usage in existing migrations

- [ ] Read [database migration style guide](https://docs.gitlab.com/ee/development/migration_style_guide.html) and [database guides](https://docs.gitlab.com/ee/development/#database-guides)

- [ ] Review [database best practices](https://docs.gitlab.com/ee/development/#best-practices)
- [ ] Review how we use [database instances restored from a backup](https://ops.gitlab.net/gitlab-com/gl-infra/gitlab-restore/postgres-gprd) for testing and make sure you're set up (GCP account, permissions for `gitlab-restore` project - reach out to @abrandl)
- [ ] Get yourself added to [@gl-database](https://gitlab.com/groups/gl-database/-/group_members) group and respond to @-mentions to the group (reach out to any maintainer on the group to get added). You will get TODOs on gitlab.com for group mentions.
- [ ] Indicate in `data/team.yml` your role as a database reviewer ([example MR](https://gitlab.com/gitlab-com/www-gitlab-com/merge_requests/19600/diffs)).
- [ ] Make sure you have proper access to at least a read-only replica in staging and production
- [ ] Remember only database maintainers approve MRs formally - as a reviewer, pass to a maintainer for approval.
- [ ] Send one MR to improve the review documentation in this document
- [ ] Review 

cc @abrandl

/label ~meta ~database
