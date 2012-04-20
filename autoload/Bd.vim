" ----------------------------------------------------------------
" Bd - Vim script to delete current buffer with keeping window layout.
"
" feature:
"   1. Bd can delete buffer without closing window.
"   2. Keeping window layout even if same buffer is opened in multiple windows.
"   3. You are able to close hidden buffer like 'help'.
"      You can use an option to confirm, before deleting hidden buffer if you need.
"   4. If it fails to close, Bd reverts buffer automatically.
"
" Usage:
"   :Bd
"
" Version: 0.0.1
" License: Vim license
" Maintainer: neco <neco.vim@gmail.com>
" URL: https://neco-@github.com/neco-/Bd.git
" Last change: April 20, 2012
"
" ----------------------------------------------------------------

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:option_confirm_bdelete_help")
  let g:option_confirm_bdelete_help = 0 " 1: to confirm before delete hidden buffer like 'help'
endif
if !exists("g:option_always_force_close")
  let g:option_always_force_close   = 0 " 1: always delete buffer even if buffer was modified(not recommend)
endif

" Bd function
function! Bd#My_bd(bang)
  " get current buffer number
  let l:current_buf_num = bufnr("%")

  " when buffer is modified.
  if empty(a:bang) && &mod == 1 && g:option_always_force_close == 0
    echohl Error
    echo "No write since last change for current buffer(add ! to force close)."
    echohl None
    return
  endif

  " get window number list
  let l:list_win_num = range(1, winnr("$"))

  " convert window number list to buffer number list
  let l:list_buf_num = map(l:list_win_num, "winbufnr(v:val)")

  " how many buffers is it included
  let l:count_included = count(l:list_buf_num, l:current_buf_num)

  " current buffer is opened in only one window
  if l:count_included != 0
    let l:win_list = range(1, winnr("$"))

    let l:cur_win_num = winnr()
    let l:win_id_list = []
    for l:win_id in l:win_list
      let l:buf_id = winbufnr(l:win_id)
      if l:buf_id == l:current_buf_num
        call add(l:win_id_list, l:win_id)
        silent exec l:win_id . "wincmd w"

        " get before buffer number
        let l:prev_buf_num = bufnr("#")

        " before buffer is listed
        let l:bd_before_listed = buflisted(l:prev_buf_num)
        if l:bd_before_listed == 0
          if &mod == 0 || g:option_always_force_close == 1 || a:bang == "!"
            enew
          endif
        else
          silent exec "b " . l:prev_buf_num
        endif
        silent exec l:cur_win_num . "wincmd w"
      endif
    endfor

    " delete buffer
    if buflisted(l:current_buf_num) != 0
      if g:option_always_force_close == 1
        silent exec "bd! " . l:current_buf_num
      else
        silent exec "bd" . a:bang . " " . l:current_buf_num
      endif
    endif

    " if buffer is still loaded
    if bufloaded(l:current_buf_num) == 1
      let l:input_result = ""
      if g:option_confirm_bdelete_help == 1
        call inputsave()
        let l:input_result = input("would you bdelete as like help? y/n: ")
        call inputrestore()
      else
        let l:input_result = "y"
      endif
      if l:input_result == "y"
        if g:option_always_force_close == 1
          silent exec "bwipeout! " . l:current_buf_num
        else
          silent exec "bwipeout" . a:bang . " " . l:current_buf_num
        endif
      endif
    endif

    " when failed to delete buffer
    if bufloaded(l:current_buf_num) != 0
      " revert buffer in each windows
      for l:win_id in l:win_id_list
        silent exec l:win_id . "wincmd w"
        silent exec "b " . l:current_buf_num
        silent exec l:cur_win_num . "wincmd w"
      endfor
    endif
  endif
endfunction

let &cpo = s:save_cpo
finish

