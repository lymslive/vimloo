" File: buffer
" Author: lymslive
" Description: handle special buffer
" Create: 2018-09-23
" Modify: 2018-09-23

let s:execute = package#imports('ly#util', 'execute')

let s:AUX_OPTION = {'buftype': 'nofile', 'bufhidden':'hide'}
lockvar s:AUX_OPTION

" Func: s:auxbuffer 
" create an auxiliary buffer, with name and local option dict
" return the bufnr.
" if the auxiliary buffer with that name already exist, just return.
" a:1 -- option dict
" a:2 -- callback func without argument, to init the buffer
function! s:auxbuffer(name, ...) abort "{{{
    if bufnr(a:name) > 0
        return bufnr(a:name)
    endif
    if a:0 > 0 && type(a:1) == type({}) && !empty(a:1)
        let l:option = extend(copy(s:AUX_OPTION), a:1)
    else
        let l:option = s:AUX_OPTION
    endif

    call s:execute('hide edit %s', a:name)
    let l:bufnr = bufnr('%')
    call s:_setlocal(l:option)
    if a:0 >= 2 && type(a:2) == v:t_func
        call call(a:2, [])
    endif
    buffer #

    return l:bufnr
endfunction "}}}

" Func: s:_setlocal 
function! s:_setlocal(option) abort "{{{
    for [l:opt, l:val] in items(a:option)
        call s:execute('setlocal %s=%s', l:opt, l:val)
        unlet l:opt  l:val
    endfor
endfunction "}}}
