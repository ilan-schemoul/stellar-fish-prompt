function prompt_set_global_buffer
  set pid $argv[1]
  set buffer $argv[2]
  eval "set -U async_prompt_buffer_$pid $buffer"
end

function prompt_append_global_buffer
  set pid $argv[1]
  set buffer $argv[2]
  eval "set -UA async_prompt_buffer_$pid $buffer"
end

function prompt_echo_global_buffer
  set pid $argv[1]
  set buffer $argv[2]
  eval "echo \$async_prompt_buffer_$pid $buffer"
end

function prompt_async_done
  set pid $argv[1]
  eval "set -U async_prompt_done_$pid 1"
end

function prompt_async_not_done
  set pid $argv[1]
  eval "set -U async_prompt_done_$pid 0"
end

function prompt_async_get_done
  set pid $argv[1]
  eval "echo \$async_prompt_done_$pid"
end
