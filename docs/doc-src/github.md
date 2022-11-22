# Github

We encourage people to get involved and contribute to this project.

As with any activity, we have our ways-of-working that help keep entropy under control.

Working with Git and Github can be quite a steep learning curve. Here is an
attempt to collect general best-practices and recipes.

## Git Development Workflow

Here is a brief description of the development workflow:

1. (Optional) Reach out and open an issue (or grab an open issue) for the
   feature you want to implement. The issue can be a great way of raising the
   attention and is also useful to track the implementation of certain features
   (which can go over multiple pull requests).
2. (Only once) Fork the repository into your own namespace using GitHub (you only need to do
   this once!). [Configure the upstream
   remote](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/configuring-a-remote-for-a-fork)
3. Synchronize the remote fork and bring it up to date:
   ```
   git fetch --all
   git checkout master
   git pull upstream master
   ```
4. Clone your forked repository (`xxx` is the username you have forked the
   repository to in step 2.):
    ```
    git clone git@github.com:xxxx/core-v-mcu.git
    ```
5. Create a new branch for the feature/bug you want to implement/fix. Give the
   branch a meaningful name. You can also prefix it with `feature` or `fix` to
   make the intention more clear. For example if you want to add another CPU
   core you can name your branch `feature/add-new-cpu`. The name of the branch
   isn't super important so you can also pick more concise names.
    ```
    git checkout -b feature/add-new-cpu
    ```
6. Git will have created this branch and switch to it. Start development.
7. Once you are happy with the contribution (or somewhere in between if you
   think it is worth making a commit), you can add the files to your staging
   area. For example:
   ```
   git add file/i/ve/touched.txt
   ```
8. Commit the changes and add a meaningful commit message:
   ```
   git commit
   ```
9. Push the changes to your Github fork.
   ```
   git push origin feature/add-new-cpu
   ```
10. Open a pull request using the [Github
    interface](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).
11. Iterate on the pull request interface until all code quality checks are
    passed and the maintainer is happy with the contribution. You can simply
    change files and repeat step 7 - 9. Your pull request will automatically be
    updated and the maintainer notified.
12. The maintainer will merge your changes into the `master` branch. You can now
    finish and delete your branch (if you want). For the next feature go back to
    3.


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
