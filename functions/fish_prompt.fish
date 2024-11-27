async_set_rebase_status %self -2
set INITIAL 0
set LOADING 1
set REPAINTING 2
set state "$INITIAL"

function _echo_virtual_env_with_arg
  # We have to direct stderr because ... python2 prints its version
  # on stderr
  set -l python_version ("$argv[1]" --version 2>&1 | sed -r "s/.*([0-9]\.[0-9]*)\..*/\1/")
  echo -n -s (set_color cyan) $python_version (set_color normal) " "
end

function _echo_virtual_env
  if set -q virtual_env
    if type -q python
      _echo_virtual_env_with_arg "python"
    else if type -q python3
      _echo_virtual_env_with_arg "python3"
    else if type -q python2
      _echo_virtual_env_with_arg "python2"
    end
  end
end

# PERF: 3 ms
function _check_symlink
  pwd | grep "$stellar_symlink_regex" 1> /dev/null 2>& 1
  # If current directory does not match the regex there is nothing to check
  if test "$status" -ne 0
    return 0
  end

  # If not a symbolic link nothing to check
  if ! test -L "$stellar_symlink_dir"
    return 0
  end

  set -l resolved_path (realpath "$stellar_symlink_dir")
  if test "$status" -ne 0
    return 0
  end

  echo "$resolved_path $(pwd)" >> /tmp/debug
  # -F means fixed string = don't interpret special characters (^/$ etc.)
  echo "$(pwd)"  | grep -F "$resolved_path"
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
  set -l rebasing_status (async_get_rebase_status %self)

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

function make_async_request
  if test "$state" -eq "$INITIAL"
    set state "$LOADING"
    set -l script_dir (dirname (realpath (status current-filename)))
    "$script_dir/update_git_info.fish" %self >> /tmp/debug 2>&1 &
  end
end

function start_profile
  echo "START" >> /tmp/debug
  pwd >> /tmp/debug
  date +%s%N | cut -b1-13 >> /tmp/debug
end

function end_profile
  date +%s%N | cut -b1-13 >> /tmp/debug
  pwd >> /tmp/debug
  echo "DONE" >> /tmp/debug
end

function fish_prompt
  # PERF: faster if we make the request before anything else
  make_async_request

  set -l last_status $status

  _echo_virtual_env

  _echo_pwd

  if test "$state" -eq "$REPAINTING"
    async_get_buffer %self
  end

  _echo_prompt $last_status

  if test "$state" -eq "$REPAINTING"
    set state "$INITIAL"
  end
end

function __async_prompt_repaint_prompt --on-signal SIGUSR1
  set state "$REPAINTING"
  commandline -f repaint >/dev/null 2>/dev/null
end
