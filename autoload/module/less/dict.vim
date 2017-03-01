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

" Display: 
" Print(dict, [indent, sort])
function! s:class.Display(dict, ...) dict abort "{{{
    let l:sIndent = get(a:000, 0, '')
    let l:sSort = get(a:000, 1, '')
    let l:bSort = !empty(l:sSort)

    let l:lsKey = keys(a:dict)
    if l:bSort
        call sort(l:lsKey)
    endif

    let l:sText = ''
    for l:sKey in l:lsKey
        let l:sItem = printf('%s%s=%s', l:sIndent, l:sKey, string(a:dict[l:sKey]))
        let l:sText .= l:sItem
    endfor

    return l:sText
endfunction "}}}

" import: 
function! module#less#dict#import() abort "{{{
    return s:class
endfunction "}}}

" TEST:
function! module#less#dict#test(...) abort "{{{
    return 0
endfunction "}}}
