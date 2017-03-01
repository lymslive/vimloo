" Class: module#less#rtp
" Author: lymslive
" Description: VimL module frame
" Create: 2017-02-28
" Modify: 2017-02-28

" MODULE:
let s:class = {}
let s:class.separator = fnamemodify('.', ':p')[-1:]

if has('win32') || has('win64') || has('win16') || has('win95')
    let s:class.os =  'win'
else
    let s:class.os = 'unix'
endif

" GetAutoName: convert a script filename to autoload namespace
" > a:pFileName, full path of a script file
" >   such as <leading-dir>/autoload/<subpath>/name[.vim]
" < return: subpath#name
function! s:class.GetAutoName(pFileName) dict abort "{{{
    if empty(a:pFileName)
        return ''
    endif

    " split path by / or #, last file extention is removed
    let l:lsPath = split(fnamemodify(a:pFileName, ':r'), self.separator . '\|#')

    let l:iEnd = len(l:lsPath) - 1 
    let l:idx = index(l:lsPath, 'autoload')

    " last part is 'autoload/' ? no subdirctory
    if l:idx == l:iEnd
        return ''
    endif

    " full path and no 'autoload/' in path
    if l:idx == -1 && self.IsAbsolute(a:pFileName)
        return ''
    endif

    let l:pSubpath = join(l:lsPath[l:idx+1:], '#')
    return l:pSubpath
endfunction "}}}

" IsAutoload: 
function! s:class.IsAutoload(pFileName) dict abort "{{{
    return a:pFileName =~# 'autoload' . self.separator
endfunction "}}}

" LikePath: 
function! s:class.LikePath(pFileName) dict abort "{{{
    return stridx(a:pFileName, self.separator) != -1
endfunction "}}}

" LikeFile: check a filename end with some extention
function! s:class.LikeFile(pFileName, sExtention) dict abort "{{{
    if a:sExtention =~ '^\.'
        let l:sExtention = substitute(a:sExtention, '^\.\+', '', '')
    else
        let l:sExtention = a:sExtention
    endif
    let l:sPattern = '\.' . l:sExtention . '$'
    return a:pFileName =~# l:sPattern
endfunction "}}}

" IsAbsolute: 
function! s:class.IsAbsolute(pFileName) dict abort "{{{
    if empty(a:pFileName)
        return v:false
    else
        return a:pFileName[0] ==# self.separator
    endif
endfunction "}}}

" Absolute: 
function! s:class.Absolute(pFileName) dict abort "{{{
    if self.IsAbsolute(a:pFileName)
        return a:pFileName
    endif

    if filereadable(a:pFileName)
        return fnamemodify(a:pFileName, ':p')
    else
        return fnamemodify(getcwd(), ':p') . self.separator . a:pFileName
    endif
endfunction "}}}

" IMPORT:
function! module#less#rtp#import() abort "{{{
    return s:class
endfunction "}}}

