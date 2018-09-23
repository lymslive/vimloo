" File: util
" Author: lymslive
" Description: some util functions
" Create: 2017-03-06
" Modify: 2018-09-22

" GetAutoName: 
" my UltiSnips need this function
function! ly#util#GetAutoName(pFileName) abort "{{{
    let l:rtp = class#less#rtp#export()
    return l:rtp.GetAutoName(a:pFileName)
endfunction "}}}

" Func: s:execute 
" short for :execute printf(cmd, ...)
function! s:execute(...) abort "{{{
    if a:0 == 0
        return s:error('execute need at least a argument')
    elseif a:0 == 1
        let l:cmd = a:1
    else
        let l:cmd = call('printf', a:000)
    endif
    :WLOG l:cmd
    execute l:cmd
    return 0
endfunction "}}}

" Func: s:error 
" log a error msg and return a value
function! s:error(msg, ...) abort "{{{
    :ELOG a:msg
    return get(a:000, 0, 0)
endfunction "}}}
