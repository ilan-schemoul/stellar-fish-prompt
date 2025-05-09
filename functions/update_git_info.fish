#!/bin/fish

function _check_rebase
  test -d "$(git rev-parse --git-path rebase-merge)" || test -d "$(git rev-parse --git-path rebase-apply) 2>/dev/null"
end

function _check_inside_git
  git rev-parse --is-inside-git-dir 1> /dev/null 2>& 1
end

function _echo_git_branch_name
  echo (git symbolic-ref --short HEAD)
end

function _check_git_is_dirty
  test -z "$(git status --porcelain)"
end

function update_git_info
  set pid $argv[1]
  set folder (pwd)

  # XXX: global variables takes time to update so we need to wait 1ms
  trap "kill -s SIGUSR1 $pid" EXIT

  _check_inside_git
  if test "$status" != 0
    async_set_buffer ""
    exit
  end

  _check_rebase
  async_set_rebase_status $status

  set git_branch (_echo_git_branch_name)

  # -n is not empty string
  if test -n "$git_branch"
    # if test -n (echo $git_branch | grep "/")
    #   set git_branch (echo $git_branch | sed -r "s/.*?\/(.*)/\1/")
    # end

    set stash_nb (git stash list | wc -l)
    set stash_info ""
    if test $stash_nb != 0
      set stash_info " $stash_nb"
    end

    _check_git_is_dirty
    if test $status -ne 0
      async_set_buffer (echo "$(set_color yellow) $git_branch±$(set_color normal)$stash_info")
    else
      async_set_buffer (echo "$(set_color green) $git_branch$(set_color normal)$stash_info")
    end
  else
    async_set_buffer ""
  end
end

# 30 ms to execute on my computer
update_git_info $argv[1]
