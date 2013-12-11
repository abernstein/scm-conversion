#!/bin/bash
#
# Simple scripts to convert ignore files between SVN and GIT
# 
# I found these to convert using oneliner bash scripts. They have an ok result, I may end up refactoring. It was quick and dirty though, so it's worth looking into them.
#
# Ignoring What Subversion Ignores
#
# If you clone a Subversion repository that has svn:ignore properties set anywhere, you’ll likely want to set corresponding .gitignore files so you don’t accidentally commit files that you shouldn’t. git svn has two commands to help with this issue. The first is git svn create-ignore, which automatically creates corresponding .gitignore files for you so your next commit can include them.
#
# The second command is git svn show-ignore, which prints to stdout the lines you need to put in a .gitignore file so you can redirect the output into your project exclude file:
#
# $ git svn show-ignore > .git/info/exclude
#
# That way, you don’t litter the project with .gitignore files. This is a good option if you’re the only Git user on a Subversion team, and your teammates don’t want .gitignore files in the project.

type=${1:svn}

if [ $type == 'svn' ]; then
  svn propget -R svn:ignore | grep -v "^$" | sed "s/\(\(.*\) - \)\(.*\)/\2\/\3/g" | sort >> .gitignore
else
  cat .gitignore | sed 's/^/\.\//g;s/\(.*\)\/\([0-9a-zA-Z\*\?\.]*\)$/svn propedit svn:ignore "\2" \1 /mg' | bash
fi
