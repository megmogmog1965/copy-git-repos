#!/bin/sh -e

#
# :author:
# - https://github.com/megmogmog1965
#
# :preconditions:
# - MacOS 10.13.6
# - git 2.15.2
# - You should create empty repositories as destinations.
#
# :see:
# - https://stackoverflow.com/questions/37985275/how-can-i-exclude-pull-requests-from-git-mirror-clone
#

# Source git server uri.
uri_src='https://{YOUR-SRC-BITBUCKET-SERVER-URI}'

# Destination git server uri.
uri_dst='https://{YOUR-DST-BITBUCKET-SERVER-URI}'

# A list of git repositories.
repos=('REPOSITORY-NAME-1' 'REPOSITORY-NAME-2' 'REPOSITORY-NAME-3')

# work dir.
current=`pwd`
workspace="$current/copy-git-repos"
mkdir -p "$workspace"

# copy 1 repo functions.
function copy_repo() {
  cd "$workspace"
  rm -rf "$1.git/"

  # clone git repository as mirror.
  git clone --mirror "${uri_src}/$1"

  # remove dirty Atlassian Stash/Bitbucket refs for pull-requests.
  cd "$1.git/"
  git show-ref | cut -d' ' -f2 | grep 'pull-request' | xargs -L1 git update-ref -d

  # push all histories into new repository.
  git push --mirror "${uri_dst}/$1"
}

# copy all git repos.
for repo_name in ${repos[@]}; do
    copy_repo "$repo_name"
done
