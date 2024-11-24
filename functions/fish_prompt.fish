prompt_async_not_done %self
prompt_set_rebase_status %self -2
set o 0

function _echo_virtual_env
  if set -q virtual_env
      set -l python_version (python -v | sed -r "s/.*([0-9]\.[0-9]*)\..*/\1/")
      echo -n -s (set_color cyan) $python_version (set_color normal) " "
  end
end

function _check_symlink
  pwd | grep "$prompt_symbolic_link_regex" 1> /dev/null 2>& 1
  # If current directory does not match the regex there is nothing to check
  if test "$status" -ne 0
    return 0
  end

  # If not a symbolic link nothing to check
  if ! test -L "$prompt_symbolic_link_to_check"
    return 0
  end

  set -l resolved_path (realpath "$prompt_symbolic_link_to_check")
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
  set -l rebasing_status (prompt_get_rebase_status %self)

  if test $argv[1] != 0
    set prompt_color (set_color red)
  else if test $rebasing_status -eq 0
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

  prompt_echo_global_buffer %self

  if test "$(prompt_async_get_done %self)" -eq 1
    prompt_async_not_done %self
  else
    prompt_set_global_buffer %self ""
    set -l script_dir (dirname (realpath (status current-filename)))
    "$script_dir/update_git_info.fish" %self &> /tmp/update_git_info_logs &
  end

  _echo_prompt $last_status
end

function __async_prompt_repaint_prompt --on-signal SIGUSR1
  commandline -f repaint >/dev/null 2>/dev/null
end
