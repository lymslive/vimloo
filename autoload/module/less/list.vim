" Class: module#less#list
" Author: lymslive
" Description: VimL module frame, list util
" Create: 2017-02-25
" Modify: 2017-02-25

" CLASS:
let s:class = class#old()

" Flat: 
function! s:class.Flat(lsArgv, ...) dict abort "{{{
    let l:lsRet = []
    for l:arg in lsArgv
        if type(l:arg) == type([])
            call extend(l:lsRet, l:arg)
        elseif  type(l:arg) == type({})
            for [l:key, l:val] in items(l:arg)
                call extend(l:lsRet, [l:key, l:val])
                unlet l:key  l:val
            endfor
        else
            call add(l:lsRet, l:arg)
        endif
    endfor

    let l:iDeepth = get(a:000, 0, 0)
    if l:iDeepth > 1
        let l:lsRet = self.Flat(l:lsRet, l:iDeepth - 1)
    endif

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
