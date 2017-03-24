" Class: module#less#rtp
" Author: lymslive
" Description: VimL module frame
" Create: 2017-02-28
" Modify: 2017-03-24

" MODULE:
let s:class = {}
let s:class.separator = fnamemodify('.', ':p')[-1:]

if has('win32') || has('win64') || has('win16') || has('win95')
    let s:class.os =  'win'
else
    let s:class.os = 'unix'
endif

" AddPath: 
function! s:class.AddPath(base, sub) dict abort "{{{
    return a:base . self.separator . a:sub
endfunction "}}}

" PutPath: 
function! s:class.PutPath(sub, base) dict abort "{{{
    return a:base . self.separator . a:sub
endfunction "}}}

" MakePath: join each part in a list to a path string
function! s:class.MakePath(...) dict abort "{{{
    if a:0 > 1
        return join(a:000, self.separator)
    elseif a:0 == 1 && type(a:1) == type([])
        return join(a:1, self.separator)
    else
        return ''
    endif
endfunction "}}}

" MakeFull: 
function! s:class.MakeFull(path, file, extention) dict abort "{{{
    return a:path . self.separator . a:file . a:extention
endfunction "}}}

" AddSlash: add slash in the end
function! s:AddSlash(path) abort "{{{
    if empty(a:path)
        return ''
    endif
    if a:path[-1] ==# self.separator
        return a:path
    else
        return a:path . self.separator
    endif
endfunction "}}}

" SubSlash: remove ending slash
function! s:AddSlash(path) abort "{{{
    if empty(a:path)
        return ''
    endif
    if a:path[-1] ==# self.separator
        return a:path[0:-2]
    else
        return a:path
    endif
endfunction "}}}

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

" FindAutoScript: find {path#to#script} in &rtp
function! s:class.FindAutoScript(name) dict abort "{{{
    let l:name = substitute(a:name, '#', self.separator, 'g')
    let l:name .= '.vim'
    if l:name !~# '^autoload'
        let l:name = self.PutPath(l:name, 'autoload')
    endif

    let l:lsGlob = globpath(&runtimepath, l:name, 0, 1)
    if !empty(l:lsGlob)
        return l:lsGlob[0]
    endif
    return ''
endfunction "}}}

" GlobFile: return a list of file name
" > a:dir: the base directory
" > a:file: file wild pattern
" < file names, without heading directory, but may with extention.
function! s:class.GlobFile(dir, file) dict abort "{{{
    let l:sPattern = self.AddPath(a:dir, a:file)
    let l:lpGlob = glob(l:sPattern, '', '')
    if empty(l:lpGlob)
        return []
    endif
    let l:iHead = len(a:dir) + 1
    return map(l:lpGlob, 'strpart(v:val, l:iHead)')
endfunction "}}}

" IMPORT:
function! module#less#rtp#import() abort "{{{
    return s:class
endfunction "}}}

