" Class: module#less#list
" Author: lymslive
" Description: VimL module frame, list util
" Create: 2017-02-25
" Modify: 2017-03-09

" Module:
let s:class = {}

" Flat: 
" > a:lsArgv, a list
" > a:1, deepth
" < return, a flattend list
function! s:class.Flat(lsArgv, ...) dict abort "{{{
    let l:iDeepth = get(a:000, 0, 1)
    if l:iDeepth == 0
        return a:lsArgv
    endif

    let l:lsRet = []
    let l:iDeepth -= 1
    for l:arg in a:lsArgv
        if type(l:arg) == type([])
            let l:lsRet += self.Flat(l:arg, l:iDeepth)
        elseif  type(l:arg) == type({})
            for [l:key, l:val] in items(l:arg)
                let l:lsRet += [l:key, l:val]
                unlet l:key  l:val
            endfor
        else
            let l:lsRet += [larg]
        endif
    endfor

    return l:lsRet
endfunction "}}}

" IMPORT:
function! module#less#list#import() abort "{{{
    return s:class
endfunction "}}}

" TEST:
function! module#less#list#test(...) abort "{{{
    return 0
endfunction "}}}
