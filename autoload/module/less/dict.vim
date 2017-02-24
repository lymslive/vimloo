" Class: module#less#dict
" Author: lymslive
" Description: VimL module frame
" Create: 2017-02-24
" Modify: 2017-02-24

let s:class = {}

" FromList: 
function! s:class.FromList(lsArgv) dict abort "{{{
    let l:dict = {}

    let l:iEnd = len(a:lsArgv)
    let l:idx = 0
    while l:idx < l:iEnd
        let l:sKey = a:lsArgv[l:idx]
        if type(l:sKey) != type('')
            break
        endif
        let l:idx += 1
        if l:idx < l:iEnd
            let l:dict[l:sKey] = a:lsArgv[l:idx]
        else
            let l:dict[l:sKey] = ''
        endif
        let l:idx += 1
    endwhile

    return l:dict
endfunction "}}}

" ToList: 
function! s:class.ToList(dArg) dict abort "{{{
    let l:list = []
    for [l:key, l:val] in items(a:dArg)
        call extend(l:list, [l:key, l:val])
        unlet l:key 
    endfor

    return l:list
endfunction "}}}

" Absorb: 
function! s:class.Absorb(dOrigin, dForeign) dict abort "{{{
    for [l:key, l:val] in items(a:dForeign)
        if has_key(a:dOrigin, l:key)
            let a:dOrigin[l:key] = l:val
        endif
        unlet l:key 
    endfor
endfunction "}}}

" import: 
function! module#less#dict#import() abort "{{{
    return s:class
endfunction "}}}

" TEST:
function! module#less#dict#test(...) abort "{{{
    return 0
endfunction "}}}
