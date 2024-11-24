# If current directory matches this regex then we will check symbolic link
set symbolic_link_regex "mmsx\-"
# We will resolve this symbolic link to check it against current directory
set symbolic_link_to_check "$HOME/dev/mmsx"

function _echo_git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _check_git_is_dirty
  command git status -s --ignore-submodules=dirty 2> /dev/null
end

function _check_rebase
  test -d "$(git rev-parse --git-path rebase-merge)" || test -d "$(git rev-parse --git-path rebase-apply) 2>/dev/null"
end

function _check_inside_git
  git rev-parse --is-inside-git-dir 1> /dev/null 2>& 1
end

function _echo_git_info
  set git_branch (_echo_git_branch_name)

  # -n is not empty string
  if test -n "$git_branch"
    if test -n (echo $git_branch | grep "/")
      set git_branch (echo $git_branch | sed -r "s/.*?\/(.*)/\1/")
    end

    if [ (_check_git_is_dirty) ]
      set git_info (set_color yellow) $git_branch "±" (set_color normal)
    else
      set git_info (set_color green) $git_branch (set_color normal)
    end

    set stash_nb (git stash list | wc -l)
    if test $stash_nb != 0
      set -a git_info "(" (set_color normal) $stash_nb  ")"
    end

    echo -n -s ' ' $git_info (set_color normal)
  end
end

function _echo_virtual_env
  if set -q virtual_env
      set -l python_version (python -v | sed -r "s/.*([0-9]\.[0-9]*)\..*/\1/")
      echo -n -s (set_color cyan) $python_version (set_color normal) " "
  end
end

function _check_symlink
  pwd | grep "$symbolic_link_regex" 1> /dev/null 2>& 1
  # If current directory does not match the regex there is nothing to check
  if test "$status" -ne 0
    return 0
  end

  # If not a symbolic link nothing to check
  if ! test -L "$symbolic_link_to_check"
    echo "not a $symbolic_link_to_check" > /dev/stderr
    return 0
  end

  set -l resolved_path (realpath "$symbolic_link_to_check")
  if test "$status" -ne 0
    return 0
  end

  test "$resolved_path" = "$(pwd)"
end

function _echo_pwd
  set -l symblink_status (_check_symlink)

  if test "$status" -eq 0
    echo -n (set_color blue)
  else
    echo -n (set_color red)
  end

  set -l cwd (basename (pwd | sed "s:^$HOME:~:"))
  echo -n -s $cwd (set_color normal)
end

function _echo_prompt
  set -l inside_git_status -1
  set -l rebasing_status -1

  _check_inside_git
  set -l inside_git_status $status

  if test "$inside_git_status" = 0
    _check_rebase
    set rebasing_status $status
  end

  if test $argv[1] != 0
    set prompt_color (set_color red)
  else if test $inside_git_status -eq 0 && test $rebasing_status -eq 0
    set prompt_color (set_color "#da70d6")
  else
    set -l prompt_color (set_color normal)
  end

  # terminate with a nice prompt char
  echo -e -n -s $prompt_color ' ⟩ ' (set_color normal)
end

function fish_prompt
  set -l last_status $status

  _echo_virtual_env

  _echo_pwd

  # Print info such as git branch, git stash etc.
  _echo_git_info

  _echo_prompt $last_status
end
