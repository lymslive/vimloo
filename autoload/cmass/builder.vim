" File: cmass#builder
" Author: lymslive
" Description: command use class#builder
" Create: 2017-02-14
" Modify: 2017-02-14

" Command Hander Interface: {{{1
" ClassNew: open a new file name.vim and fill class frame
function! cmass#builder#hClassNew(name, ...) abort "{{{
    if empty(a:name)
        echom ':ClassNew command need a name as argument'
        return 0
    endif

    if a:name[0] ==# '/'
        let l:pFileName = a:name
    else
        let l:pFileName = getcwd() . '/' . a:name
    endif

    let l:pFullName = cmass#builder#CheckAutoName(l:pFileName)
    if empty(l:pFullName)
        echom ':ClassNew only execute under autoload director'
        return 0
    endif

    let l:jBuilder = class#builder#new(l:pFullName)
    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    execute 'edit ' . a:name . '.vim'
    call setline(1, l:lsContent)
endfunction "}}}

" ClassAdd: add class frame to current opened buffer
function! cmass#builder#hClassAdd(...) abort "{{{
    let l:pFileName = expand('%:p:r')
    let l:pFullName =cmass#builder#CheckAutoName(l:pFileName)
    if empty(l:pFullName)
        echom ':ClassAdd only execute under autoload director'
        return 0
    endif

    let l:jBuilder = class#builder#new(l:pFullName)
    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    call append(line('$'), l:lsContent)
endfunction "}}}

" ClassTemp: same as ClassAdd but don't care the filename
function! cmass#builder#hClassTemp(...) abort "{{{
    let l:jBuilder = class#builder#new('')

    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    call append(line('$'), l:lsContent)
endfunction "}}}

" ClassPart: 
function! cmass#builder#hClassPart(sFilter) abort "{{{
    let l:pFileName = expand('%:p:r')
    let l:pFullName =cmass#builder#CheckAutoName(l:pFileName)
    if empty(l:pFullName)
        echom ':ClassPart only execute under autoload director'
        return 0
    endif

    let l:jBuilder = class#builder#new(l:pFullName)
    let l:lsContent = jBuilder.SelectLine(a:sFilter)

    call append(line('.'), l:lsContent)
endfunction "}}}

" Script Local Function: {{{1
" CheckClassName: check if a file name is autoload vim file
" a:pFileName should be as <leading-dir>/autoload/<subpath>/name
" return subpath#name
" return empty string if pFileName not under some autoload directory
function! cmass#builder#CheckAutoName(pFileName) abort "{{{
    let l:lsPath = split(fnamemodify(a:pFileName, ':r'), '/')

    let l:iEnd = len(l:lsPath) - 1 
    let l:idx = l:iEnd
    while l:idx >= 0
        if l:lsPath[l:idx] ==# 'autoload'
            break
        endif
        let l:idx = l:idx - 1
    endwhile

    if l:idx < 0 || l:idx == l:iEnd
        return ''
    endif

    let l:pSubpath = join(l:lsPath[l:idx+1:], '#')
    return l:pSubpath
endfunction "}}}

