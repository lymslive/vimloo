" File: vimloo.vim
" Author: lymslive
" Description: global command defined for vimloo
" Create: 2017-02-11
" Modify: 2018-05-02

" for back compatible reason, pre-define some dummy command
if !exists(':DLOG')
    command! -nargs=* DLOG " pass
    command! -nargs=* ELOG " pass
    command! -nargs=* WLOG " pass
endif

" load: 
function! vimloo#plugin#load() abort "{{{
    return 1
endfunction "}}}

