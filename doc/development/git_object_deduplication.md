# Git object deduplication

When a GitLab user [forks a project](../workflow/forking_workflow.md),
GitLab creates a new Project with an associated Git repository that is a
copy of the original project at the time of the fork. If a large project
gets forked often, this can lead to a quick increase in Git repository
storage disk use. To counteract this problem we are adding Git object
deduplication for forks to GitLab. In this document we will describe how
GitLab implements Git object deduplication.

> TODO mention in which exact GitLab version this is possible

## Pool repositories

### Understanding Git alternates

At the Git level, we achieve deduplication by using [Git
alternates](https://git-scm.com/docs/gitrepository-layout#gitrepository-layout-objects).
Git alternates is a mechanism that lets a repository borrow objects from
another repository on the same machine.

If we want repository A to borrow from repository B we first write a
path that resolves to `B.git/objects` in the special file
`A.git/objects/info/alternates`. This establishes the alternates link.
Next, we must perform a Git repack in A. After the repack any objects
that are duplicated between A and B will get deleted from A. Repository
A is now no longer self-contained but it still has its own refs and
configuration. Objects in A that are not in B will remain in A. For this
to work it is of course critical that **no objects ever get deleted from
B** because A might need them.

### Alternates in GitLab: pool repositories

GitLab organizes this object borrowing by creating special **pool
repositories** which are hidden from the user. We then use Git
alternates to let a collection of project repositories borrow from a
single pool repository. We call such a collection of project
repositories a pool. Pools form star-shaped networks of repositories
that borrow from a single pool, which will resemble (but not be
identical to) the fork networks that get formed when users fork
projects.

At the Git level, pool repositories are created and managed using Gitaly
RPC calls. Just like with normal repositories, the authority on which
pool repositories exist, and which repositories borrow from them, lies
at the Rails application level in SQL.

In conclusion we need three things for effective object deduplication
across a collection of GitLab project repositories at the Git level:

1.  A pool repository must exist
2.  The participating project repositories must be linked to the pool
    repository via their respective `objects/info/alternates` files.
3.  The pool repository must contain Git object data common to the
    participating project repositories.

## SQL model

As of GitLab 11.8, project repositories in GitLab do not have their own
SQL table. They are indirectly identified by columns on the `projects`
table. In other words the only way to look up a project repository is to
first look up its project, and then call `project.repository`.

With pool repositories we made a fresh start. These live in their own
`pool_repositories` SQL table. The relations between these two tables
are as follows:

-   a `Project` belongs to at most one `PoolRepository`
    (`project.pool_repository`)
-   as an automatic consequence of the above, a `PoolRepository` has
    many `Project`s
-   a `PoolRepository` has exactly one "source `Project`"
    (`pool.source_project`)

### Assumptions

-   All repositories in a pool must use [hashed
    storage](../administration/repository_storage_types.md). This is so
    that we don't have to ever worry about updating paths in
    `object/info/alternates` files.
-   All repositories in a pool must be on the same Gitaly storage shard.
    The Git alternates mechanism relies on direct disk access across
    multiple repositories, and we can only assume direct disk access to
    be possible within a Gitaly storage shard.
-   All project repositories in a pool must have "Public" visibility in
    GitLab at the time they join. There are gotchas around visibility of
    Git objects across alternates links. This restriction is a defense
    against accidentally leaking private Git data.
-   The only two ways to remove a member project from a pool are (1) to
    delete the project or (2) to move the project to another Gitaly
    storage shard.

### Creating pools and pool memberships

-   When a pool gets created it must have a source project. The initial
    contents of the pool repository are a Git clone of the source
    project repository.
-   The occiasion for creating a pool is when an existing eligible
    (public, hashed storage, etc.) GitLab project gets forked and this
    project does not belong to a pool repository yet. The fork parent
    project becomes the source project of the new pool, and both the
    fork parent and the fork child project become members of the new
    pool.
-   Once project A has become the source project of a pool, all future
    eligible forks of A will become pool members.
-   If the fork source is itself a fork, the resulting repository will neither
    join the repository nor will a new pool repository be seeded.

    eg:

    Suppose fork A is part of a pool repository, any forks created off of fork A
    *will not* be a part of the pool repository that fork A is a part of.

    Suppose B is a fork of A, and A does not belong to an object
    pool. Now C gets created as a fork of B. C will not be part of a
    pool repositor.

### Consequences

-   If a normal Project participating in a pool gets moved to another
    Gitaly storage shard, its "belongs to PoolRepository" relation must
    be broken. Because of the way moving repositories between shard is
    implemented, we will automatically get a fresh self-contained copy
    of the project's repository on the new storage shard.
-   If the source project of a pool gets moved to another Gitaly storage
    shard or is deleted, we must break the "PoolRepository has one
    source Project" relation.

> TODO The scenario "source project leaves pool" has not been
> implemented yet, see https://gitlab.com/gitlab-org/gitaly/issues/1488

## Consistency between the SQL pool relation and Gitaly

As far as Gitaly is concerned, the SQL pool relations make two types of
claims about the state of affairs on the Gitaly server: pool repository
existence, and the existence of an alternates connection between a
repository and a pool.

### Pool existence

If GitLab thinks a pool repository exists (i.e. it exists according to
SQL), but it does not on the Gitaly server, then certain RPC calls that
take the object pool as an argument will fail.

> TODO Check or ensure that the system self-heals if SQL says the pool
> repo exists but Gitaly says it does not.

If GitLab thinks a pool does not exist, while it does exist on disk,
that has no direct consequences on its own. However if other
repositories on disk borrow objects from this unknown pool repository
then we risk data loss, see below.

### Pool relation existence

## Git object deduplication and GitLab Geo

