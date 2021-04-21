# Github

We encourage people to get involved and contribute to this project.

As with any activity, we have our ways-of-working that help keep entropy under control.

Working with Git and Github can be quite a steep learning curve. Here is an
attempt to collect general best-practices and recipes.

## ECA and Signing Commits

We programmatically enforce signing all your commits and check your email
against the [Eclipse Contributor
Agreement](https://www.eclipse.org/legal/ECA.php) database. Be sure to sign-up
with the right email address and add it to either the global or local repository
setting. For example to add it to the local settings execute the following in
the local repository:

```bash
$ git config user.email "username@example.com"
```

You can sign your commits by using `git commit -s` or if you want to
automatically sign your commits you can use the `prepare-commit-msg` hook:

```bash
$ cat <<"EOF" > .git/hooks/prepare-commit-msg
#!/bin/sh

# Add a Signed-off-by line to the commit message if not already present.
git interpret-trailers --if-exists doNothing --trailer \
  "Signed-off-by: $(git config user.name) <$(git config user.email)>" \
  --in-place "$1"
EOF
$ chmod +x .git/hooks/prepare-commit-msg
```
