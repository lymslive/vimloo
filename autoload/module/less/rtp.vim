" Class: module#less#rtp
" Author: lymslive
" Description: VimL module frame
" Create: 2017-02-28
" Modify: 2017-02-28

" MODULE:
let s:class = {}

" GetAutoName: convert a script filename to autoload namespace
" > a:pFileName, full path of a script file
" >   such as <leading-dir>/autoload/<subpath>/name[.vim]
" < return: subpath#name
function! s:class.GetAutoName(pFileName) dict abort "{{{
    if empty(a:pFileName)
        return ''
    endif

    " split path by / or #, last file extention is removed
    let l:lsPath = split(fnamemodify(a:pFileName, ':r'), '/\|#')

    let l:iEnd = len(l:lsPath) - 1 
    let l:idx = index(l:lsPath, 'autoload')

    " last part is 'autoload/' ? no subdirctory
    if l:idx == l:iEnd
        return ''
    endif

    " full path and no 'autoload/' in path
    if l:idx == -1 && a:pFileName[0] == '/'
        return ''
    endif

    let l:pSubpath = join(l:lsPath[l:idx+1:], '#')
    return l:pSubpath
endfunction "}}}

" IsAutoload: 
function! s:class.IsAutoload(pFileName) dict abort "{{{
    return a:pFileName =~# 'autoload/'
endfunction "}}}

" IMPORT:
function! module#less#rtp#import() abort "{{{
    return s:class
endfunction "}}}

