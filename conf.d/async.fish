set -U async_debug 0

function deval
  if test "$async_debug" -eq 1
    echo "$(pwd) $argv[1]" >> /tmp/debug
    eval "echo $(pwd) $argv[1] >> /tmp/debug"
    echo "" >> /tmp/debug
  end

  eval "$argv[1]"
end

function check_args
  if test "$async_debug" -eq 1
    if test $argv[1] -ne $argv[2]
      echo "ERROR: Wrong number of argument. Got $argv[1] instead of $argv[2]." >> /tmp/debug
      echo "async: wrong number of argument" > /dev/stderr
    end

    if test -z $argv[3]
      echo "ERROR: pid not set" >> /tmp/debug
      echo "async: pid not set" > /dev/stderr
    end
  end
end

function async_set_buffer
  check_args (count $argv) 2 $argv[1]

  set pid $argv[1]
  set buffer $argv[2]
  deval "set -U async_prompt_buffer_$pid \"$buffer\""
end

function async_get_buffer
  check_args (count $argv) 1 $argv[1]

  set pid $argv[1]
  # Wait 1 ms because otherwise I randomly get old value ...
  sleep 0.001
  deval "echo -n \$async_prompt_buffer_$pid"
end

function async_set_rebase_status
  check_args (count $argv) 2 $argv[1]

  set pid $argv[1]
  deval "set -U async_prompt_rebase_status_$pid $argv[2]"
end

function async_get_rebase_status
  check_args (count $argv) 1 $argv[1]

  set pid $argv[1]
  deval "echo \$async_prompt_rebase_status_$pid"
end

# XXX: it's clumsy and manual and error prone
function async_clean_old_vars
  for var in (set --names)
    echo "$var" | grep -q "async_prompt"
    if test "$status" -eq 0
      echo "$var" | grep -q "%self"
      if test "$status" -ne 0
        set --erase "$var" &
     end
    end
  end
end
