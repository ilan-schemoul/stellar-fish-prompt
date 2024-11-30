set -U async_debug 0

function hash_pwd
  set hash (pwd | sha1sum | head -c 40)

  if test "$async_debug" -eq 1
    echo "path $(pwd) hash $hash" >> /tmp/debug
  end

  echo "$hash"
end

function deval
  if test "$async_debug" -eq 1
    echo "$(pwd) $argv[1]" >> /tmp/debug
    # UNSAFE: replace eval by smthg else
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
  end
end

function async_set_buffer
  check_args (count $argv) 1

  deval "set -U async_prompt_buffer_$(hash_pwd) \"$argv[1]\""
end

function async_print_buffer
  deval "echo -n \$async_prompt_buffer_$(hash_pwd)"
end

function async_set_rebase_status
  check_args (count $argv) 1 $argv[1]

  deval "set -U async_prompt_rebase_status_$(hash_pwd) \"$argv[1]\""
end

function async_get_rebase_status
  deval "echo \$async_prompt_rebase_status_$(hash_pwd)"
end

function async_clean_old_vars
  for var in (set --names)
    echo "$var" | grep -q "async_prompt"
    if test "$status" -eq 0
      set --erase "$var" &
    end
  end
end
