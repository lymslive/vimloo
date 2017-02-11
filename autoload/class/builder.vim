" File: builder.vim
" Author: lymslive
" Description: create VimL class file by template
" Create: 2017-02-11
" Modify: 2017-02-11

let s:class = class#old()
let s:class._name_ = 'class#builder'
let s:class._version_ = 1
let s:class.template = '../tempclass.vim'

echom 'class#build load ...'

function! class#builder#class() abort "{{{
    return s:class
endfunction "}}}

" FullTempFile: 
function! s:class.FullTempFile() dict abort "{{{
    let l:pScript = fnamemodify(expand('<sfile>'), ':p:h')
    return l:pScript . '/' . self.template
endfunction "}}}

" CheckClassName: check if a file name can be used as class file
" a:pFileName should be as <leading-dir>/autoload/<subpath>/name
" return subpath#name
" return empty string if pFileName not under some autoload directory
function! s:class.CheckClassName(pFileName) dict abort "{{{
    let l:lsPath = split(a:pFileName, '/')

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

" ExtractLine: extract content of template with filter option
" return a list of content lines
function! s:class.ExtractLine(sFilter) dict abort "{{{
    let l:lsTemp = readfile(self.FullTempFile())
    if empty(l:lsTemp)
        return []
    endif

    let l:lsOutPut = []
    let l:bOn = 1
    for l:sLine in l:lsTemp
        " empty line as paragraph ending
        if empty(l:sLine)
            if !empty(l:lsOutPut) && !empty(l:lsOutPut[-1])
                call add(l:lsOutPut, l:sLine)
            endif
            let l:bOn = 1
            continue
        endif

        " has -a option
        if stridx(a:sFilter, 'a') != -1
            call add(l:lsOutPut, l:sLine)
            let l:bOn = 1
            continue
        endif

        let l:lsMatch = matchlist(l:sLine, '^\("\s*[A-Z]\+:\)\s*-\([A-Za-a]\)')
        if !empty(l:lsMatch)
            let l:sComment = l:lsMatch[1]

            " default option in template
            let l:cOption = l:lsMatch[2]
            if l:cOption ==# tolower(l:cOption)
                let l:bOn = 1
            else
                let l:bOn = 0
            endif

            " overide by option
            if !empty(a:sFilter)
                if stridx(a:sFilter, tolower(l:cOption)) != -1
                    let l:bOn = 1
                endif
                if stridx(a:sFilter, toupper(l:cOption)) != -1
                    let l:bOn = 0
                endif
            endif

            if l:bOn == 1
                call add(l:lsOutPut, l:sComment)
            endif
        else
            if l:bOn == 1
                call add(l:lsOutPut, l:sLine)
            endif
        endif

    endfor

    return l:lsOutPut
endfunction "}}}

" INSTANCE:
let s:instance = {}
function! class#builder#instance() abort "{{{
    if empty(s:instance)
        let s:instance = class#new('class#builder')
    endif
    return s:instance
endfunction "}}}

" ClassNew: open a new file name.vim and fill class frame
function! class#builder#hClassNew(name, ...) abort "{{{
    if empty(a:name)
        echom ':ClassNew command need a name as argument'
        return 0
    endif

    if a:name[0] ==# '/'
        let l:pFileName = a:name
    else
        let l:pFileName = getcwd() . '/' . a:name
    endif

    let l:jBuilder = class#builder#instance()
    let l:pFullName = l:jBuilder.CheckClassName(l:pFileName)
    if empty(l:pFullName)
        echom ':ClassNew only execute under autoload director'
        return 0
    endif

    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    execute 'edit ' . a:name . '.vim'
    call setline(1, l:lsContent)
endfunction "}}}

" ClassAdd: add class frame to current opened buffer
function! class#builder#hClassAdd(...) abort "{{{
    let l:pFileName = expand('%:p:r')
    let l:jBuilder = class#builder#instance()
    let l:pFullName = l:jBuilder.CheckClassName(l:pFileName)
    if empty(l:pFullName)
        echom ':ClassNew only execute under autoload director'
        return 0
    endif

    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine()
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    call append(line('$'), l:lsContent)
endfunction "}}}

" ClassTemp: same as ClassAdd but don't care the filename
function! class#builder#hClassTemp(...) abort "{{{
    let l:jBuilder = class#builder#instance()

    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine()
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    call append(line('$'), l:lsContent)
endfunction "}}}
