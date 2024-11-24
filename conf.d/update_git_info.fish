source ./async.fish

function update_git_info
  set pid $argv[1]
  # set git_branch (_echo_git_branch_name)
  #
  # # -n is not empty string
  # if test -n "$git_branch"
  #   if test -n (echo $git_branch | grep "/")
  #     set git_branch (echo $git_branch | sed -r "s/.*?\/(.*)/\1/")
  #   end
  #
  #   if [ (_check_git_is_dirty) ]
  #     prompt_set_global_buffer $pid (echo (set_color yellow) $git_branch "┬▒" (set_color normal))
  #   else
  #     prompt_set_global_buffer $pid (echo (set_color green) $git_branch (set_color normal))
  #   end
  #
  #   set stash_nb (git stash list | wc -l)
  #   if test $stash_nb != 0
  #     prompt_append_global_buffer $pid (echo "(" (set_color normal) $stash_nb  ")")
  #   end
  # end

  prompt_set_global_buffer $pid "Hello"
  prompt_async_done
  commandline -f repaint
end
