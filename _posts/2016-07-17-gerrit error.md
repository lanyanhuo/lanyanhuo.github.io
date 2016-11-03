---
layout: post
title: gerrit error
category: Git
tags: [gerrit]
---


## Gerrit

#### 1. git commit —amend之后，git push

```
 ! [remote rejected] HEAD -> refs/for/master (change http://gerrit/10993 closed)
 ! [remote rejected] HEAD -> refs/for/master (missing Change-Id in commit message footer)
  error: failed to push some refs to 'ssh://xxxxxxxxxxxx'
```
这是最笨的办法也最实用 git reset 最开始的commitId, 然后再去commit，push 或者 `git cherry-pick commitId` 将之前的提交记录同步 

#### 2. git status

```
On branch master
`Your branch and 'gerrit/master' have diverged,`
and have 1 and 1 different commit each, respectively.
  (use "git pull" to merge the remote branch into yours)
nothing to commit, working directory clean
```

```
git status
rebase in progress; onto 62ea959
You are currently rebasing branch 'master' on '62ea959'.
  (all conflicts fixed: run "git rebase --continue")

Not currently on any branch.
—— git status
HEAD detached at 97b7f6c
nothing to commit, working directory clean

```

终极解决：`git reset --hard gerrit/master`, 然后git commit， git push 

#### 3. error: src refspec HERD does not match any.

引起该错误的原因是，目录中没有文件，空目录是不能提交上去的

! [remote rejected] HEAD -> refs/for/master (internal error)

查看[here](http://stackoverflow.com/questions/24114676/git-error-failed-to-push-some-refs-to)


#### 4. error: insufficient permission for adding an object to repository database ./objects




#### 5. 

```
git status
On branch master
Your branch is ahead of 'gerrit/master' by 2 commits.
  (use "git push" to publish your local commits)
nothing to commit, working directory clean
   
```
使用git pull --rebase解决
   
```
使用git pull --rebase
remote: Counting objects: 37, done
remote: Finding sources: 100% (19/19)
remote: Total 19 (delta 11), reused 18 (delta 11)
Unpacking objects: 100% (19/19), done.
From ssh://xxx
6132a74..2655ed6  master     -> gerrit/master
   
```
解决成功是用的这里的内容

1. Do a local rebase (git pull --rebase)
2. Someone clicks "Rebase change" on Gerrit (which results in the same base tree, but different date and/or commiter name)
3. Try to push to Gerrit
4. [网页原文](https://bugs.chromium.org/p/gerrit/issues/detail?id=2936)
Result:
The commit is rejected (following commits, if there are any, are therefore rejected as well, although this happens silently).


#### 6  Could not read from remote repository
```
git fetch
fatal: No remote repository specified.  Please, specify either a URL or a
remote name from which new revisions should be fetched.

git fetch gerrit/dev
fatal: 'gerrit/dev' does not appear to be a git repository
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```
以上错误是因为没有个远程分支绑定，可直接修改vi .git/config 把 dev分支对应的远程改为 gerrit/dev


####  一系列解决问题的网址
1. [http://www.jianshu.com/p/ae4857d2f868](http://www.jianshu.com/p/ae4857d2f868)
2. [http://www.cnblogs.com/Security-Darren/p/4383838.html](http://www.cnblogs.com/Security-Darren/p/4383838.html)
3. [http://m.blog.csdn.net/article/details?id=46583217](http://m.blog.csdn.net/article/details?id=46583217)
4. [http://blog.csdn.net/csfreebird/article/details/7583363](http://blog.csdn.net/csfreebird/article/details/7583363)



## Git

#### github 使用 —amend 时报错，然后需要重新pull

```
git add .
➜  project git:(master) ✗ git commit --amend
[master 1a5bace] format
 Date: Wed Nov 2 17:31:24 2016 +0800
 4 files changed, 11 insertions(+), 8 deletions(-)
➜  project git:(master) git push
To https://github.com/xxx/project.git
 ! [rejected]        master -> master (non-fast-forward)
error: failed to push some refs to 'https://github.com/xxx/project.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

#### 需要pull的时候

```
git status
On branch master
Your branch and 'origin/master' have diverged,
and have 1 and 1 different commit each, respectively.
  (use "git pull" to merge the remote branch into yours)
nothing to commit, working directory clean
➜  project git:(master) ✗ git reset --soft origin/master
➜  project git:(master) ✗ git status
On branch master
Your branch is up-to-date with 'origin/master'.
```