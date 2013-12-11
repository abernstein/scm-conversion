#! /bin/bash
###################################################
# A simple script to migrate from SVN to GIT
#
# Following the recommended workflow, I decided to script it. The last item was to add variables to allow it more configurability.
#
# It's a complete work in progress, and issues will be fixed if noted.
#
# This pulls all the branches, tags and trunk from a current SVN repository and clones them. Creates an authors conversion file to use during the commit process. This pulls all the commit history and replaces the svn user with the matching one in the authors.txt file. Then it assembles them into remotes and pushes them to the origin at the end.
#
# @link http://git-scm.com/book/en/Git-and-Other-Systems-Migrating-to-Git

PREFIX=svn
AUTHOR_FILE=authors.txt
SVN_REPO_DIR=/www 
SVN_REPO_URL=https://svn.repo.url/repo
CLONE_DIR=~/
GIT_REPO_NAME=myrepository.git
GIT_REMOTE=git@my-git-server:myrepository.git

###################################################
# Create an authors file from the current svn repo

cd $SVN_REPO_DIR

svn log --xml | grep -P "^<author" | sort -u | \
  perl -pe 's/<author>(.*?)<\/author>/$1 = /' > $AUTHOR_FILE

####################################
# Create empty repo on local machine

cd $CLONE_DIR

git svn clone --stdLayout --prefix=$PREFIX/ \
  --authors-file=$AUTHOR_FILE $SVN_REPO_URL $GIT_REPO_NAME

#############################
# Confirm and reset the head

cd $REPO_NAME
git branch -a -v | cut -c1-60
git reset --hard $PREFIX/trunk
git branch -a -v | cut -c1-60

########################################
# Create tags for each remote tag/branch

git for-each-ref refs/remotes/$PREFIX/tags | \
  cut -d / -f 5- | grep -v @ \
  while read tagname; do \ 
    git tag "$tagname" "$PREFIX/tags/$tagname"; \
    git branch -r -d "$PREFIX/tags/$tagname"; \
  done

git for-each-ref refs/remotes/$PREFIX | \
  cut -d / -f 4- | grep -v @ | \
  while read branchname; do \
    git branch "$branchname" "refs/remotes/$PREFIX/$branchname"; \
    git branch -r -d "$branchname"; \
  done

################################
# Push to the master repository

git remote add origin $GIT_REMOTE
git push origin --all
git push origin --tags
