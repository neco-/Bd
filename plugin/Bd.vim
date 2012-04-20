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

" check version 
if v:version < 700 || &cp
  finish
endif

" Load this module only once
if exists('loaded_bd')
  finish
endif
let loaded_bd = 1

if !exists(":Bd")
  command! -bang -nargs=? Bd :call Bd#My_bd('<bang>')
endif

