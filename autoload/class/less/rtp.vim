" Class: module#less#rtp
" Author: lymslive
" Description: VimL module frame
" Create: 2017-02-28
" Modify: 2018-05-02

let s:class = {}
function! class#less#rtp#export() abort "{{{
    return s:class
endfunction "}}}

let s:class.separator = fnamemodify('.', ':p')[-1:]
let s:class.slash = s:class.separator

" indicator of a prjoect dir, which should has any of subdir in the list
let s:class.prjdir = ['.git', '.svn', '.vim']

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
function! s:SubSlash(path) abort "{{{
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
        return fnamemodify(getcwd(), ':p') . a:pFileName
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
    let l:lpGlob = glob(l:sPattern, '', 1)
    if empty(l:lpGlob)
        return []
    endif
    let l:iHead = len(a:dir) + 1
    return map(l:lpGlob, 'strpart(v:val, l:iHead)')
endfunction "}}}

" FixrtpDir: return a directory suitable for rtp, or empty string
" > a:pDirectory, the path candidate
" if contains 'autoload' in middle part, fix upto it parent
" otherwise check itself whether has 'autoload' subdirctory
function! s:class.FixrtpDir(pDirectory) dict abort "{{{
    if a:pDirectory =~# self.separator . 'autoload'
        let l:pDirectory = substitute(a:pDirectory, self.separator . 'autoload' . '.*$', '', '')
        return l:pDirectory
    elseif isdirectory(self.MakePath(a:pDirectory, 'autoload'))
        return a:pDirectory
    else
        return ''
    endif
endfunction "}}}

" FindAoptScript: find {path#to#script} in 
" ~/.vim/pack/*user/opt that not in &rtp
" a:1, indicate how action when find more than one
" 0=return the first one, 1=ask user select with one, 2=return all as list
function! s:class.FindAoptScript(name, ...) dict abort "{{{
    let l:name = substitute(a:name, '#', self.separator, 'g')
    let l:name .= '.vim'
    if l:name !~# '^autoload'
        let l:name = self.PutPath(l:name, 'autoload')
    endif

    let l:sPattern = self.MakePath('pack', '*', 'opt', '*', l:name)
    let l:lsGlob = globpath(&packpath, l:name, 0, 1)

    if empty(l:lsGlob)
        return ''
    elseif len(l:lsGlob) == 1
        return l:lsGlob[0]
    else
        if a:0 < 1 || empty(a:1)
            return l:lsGlob[0]
        elseif a:1 == 1
            let l:exlist = class#less#list#export()
            let l:display = l:exlist.PromptString(l:lsGlob)
            echo l:display
            let l:reply = input('Select: ', 0)
            return l:lsGlob[0+l:reply]
        elseif a:1 == 2
            return l:lsGlob
        endif
    endif

    return ''
endfunction "}}}

" SetProjectFlag: 
function! s:class.SetProjectFlag(...) dict abort "{{{
    if a:0 == 0 || empty(a:1)
        return self.prjdir
    elseif a:0 == 1
        if type(a:1) == type('')
            let self.prjdir = [a:1]
        elseif type(a:1) == type([])
            let self.prjdir = a:1
        else
            echoerr 'invalid argument type for project dir'
        endif
    else
        let self.prjdir = a:000
    endif
endfunction "}}}

" FindPrject: look upwords for project dir, with special flag dir in it
" a:1 = empty, from current directory
" a:1 = '.', from the directory of current file editing
" a:1 = other, use this argument as start directory
function! s:class.FindPrject(...) dict abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:startDir = getcwd()
    elseif a:1 == '.'
        let l:startDir = expand('%:p:h')
    else
        let l:startDir = a:1
    endif

    let l:currDir = l:startDir
    let l:lastDir = ''
    while len(l:currDir) > 0 && l:currDir != l:lastDir
        for l:flagDir in self.prjdir
            if isdirectory(self.AddPath(l:currDir, l:flagDir))
                return l:currDir
            endif
        endfor

        let l:lastDir = l:currDir
        let l:currDir = fnamemodify(l:currDir, ':h')
    endwhile

    return ''
endfunction "}}}

" TEST:
function! class#less#rtp#test(...) abort "{{{
    echo s:class.prjdir
    echo s:class.FindPrject()
    echo s:class.FindPrject('.')
endfunction "}}}
