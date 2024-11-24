set -U prompt_debug 0

function deval
  if test "$debug" -eq 1
    eval "echo $argv[1] >> /tmp/debug"
  end

  eval "$argv[1]"
end

function check_args
  if test "$prompt_debug" -eq 1
    if test $argv[1] -ne $argv[2]
      echo "ERROR!!: Wrong number of argument. Got $argv[1] instead of $argv[2]." >> /tmp/debug
    end
  end
end

function prompt_set_global_buffer
  check_args (count $argv) 2

  set pid $argv[1]
  set buffer $argv[2]
  deval "set -U async_prompt_buffer_$pid \"$buffer\""
end

function prompt_append_global_buffer
  check_args (count $argv) 1

  set pid $argv[1]
  set new_buffer (string join '' (prompt_echo_global_buffer $pid) $argv[2])
  deval "set -U async_prompt_buffer_$pid \"$new_buffer\""
end

function prompt_echo_global_buffer
  check_args (count $argv) 1

  set pid $argv[1]
  deval "echo -n \$async_prompt_buffer_$pid"
end

function prompt_async_done
  check_args (count $argv) 1

  set pid $argv[1]
  deval "set -U async_prompt_done_$pid 1"
end

function prompt_async_not_done
  check_args (count $argv) 1

  set pid $argv[1]
  deval "set -U async_prompt_done_$pid 0"
end

function prompt_async_get_done
  check_args (count $argv) 1

  set pid $argv[1]
  deval "echo \$async_prompt_done_$pid"
end

function prompt_set_rebase_status
  check_args (count $argv) 2

  set pid $argv[1]
  deval "set -U async_prompt_rebase_status_$pid $argv[2]"
end

function prompt_get_rebase_status
  check_args (count $argv) 1

  set pid $argv[1]
  deval "echo \$async_prompt_rebase_status_$pid"
end
