" File: builder.vim
" Author: lymslive
" Description: create VimL class file by template
" Create: 2017-02-11
" Modify: 2017-02-11

" Class Definiation: {{{1
let s:class = class#old()
let s:class._name_ = 'class#builder'
let s:class._version_ = 1
let s:class.ClassName = ''

echom 'class#builder load ...'

function! class#builder#class() abort "{{{
    return s:class
endfunction "}}}

function! class#builder#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

function! class#builder#ctor(this, argv) abort "{{{
    if len(a:argv) > 0
        let a:this.ClassName = a:argv[0]
    endif
endfunction "}}}

" ExtractLine: extract content of template with filter option
" return a list of content lines
function! s:class.ExtractLine(sFilter) dict abort "{{{
    let l:lsTemp = readfile(s:FullTempFile())
    if empty(l:lsTemp)
        return []
    endif

    let l:lsOutPut = []
    let l:bOn = 1
    let l:bHeader = 1
    for l:sLine in l:lsTemp
        " empty line as paragraph ending
        if empty(l:sLine)
            if !empty(l:lsOutPut) && !empty(l:lsOutPut[-1])
                call add(l:lsOutPut, l:sLine)
            endif
            let l:bOn = 1
            let l:bHeader = 0
            continue
        endif

        " has -a option
        if stridx(a:sFilter, 'a') != -1
            call add(l:lsOutPut, l:sLine)
            let l:bOn = 1
            continue
        endif

        let l:lsMatch = matchlist(l:sLine, '^\("\s*[A-Z]\+:\)\s*-\([A-Za-z]\)')
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

            if l:bOn == 1 && l:bHeader == 0
                call add(l:lsOutPut, l:sComment)
            endif

        else
            " replace class name
            if !empty(self.ClassName) && match(l:sLine, s:tempclass) != -1
                let l:sLine = substitute(l:sLine, s:tempclass, self.ClassName, 'g')
            endif

            " comment header
            if l:bHeader
                if match(l:sLine, '\d\+-\d\+-\d\+') != -1
                    let l:sLine = substitute(l:sLine, '\d\+-\d\+-\d\+', s:today, 'g')
                endif
            endif

            if l:bOn == 1
                call add(l:lsOutPut, l:sLine)
            endif
        endif

    endfor

    return l:lsOutPut
endfunction "}}}

" SelectLine: select content of template with filter option, no default
" return a list of content lines
function! s:class.SelectLine(sFilter) dict abort "{{{
    let l:lsTemp = readfile(s:FullTempFile())
    if empty(l:lsTemp)
        return []
    endif

    if empty(a:sFilter)
        return []
    endif

    let l:lsOutPut = []
    let l:bOn = 0
    let l:bHeader = 1
    for l:sLine in l:lsTemp
        " empty line as paragraph ending
        if empty(l:sLine)
            if !empty(l:lsOutPut) && !empty(l:lsOutPut[-1])
                call add(l:lsOutPut, l:sLine)
            endif
            let l:bOn = 0
            let l:bHeader = 0
            continue
        endif

        let l:lsMatch = matchlist(l:sLine, '^\("\s*[A-Z]\+:\)\s*-\([A-Za-a]\)')
        if !empty(l:lsMatch)
            let l:sComment = l:lsMatch[1]

            " only when input filter contains lower option, whill output
            let l:cOption = l:lsMatch[2]
            if stridx(a:sFilter, tolower(l:cOption)) != -1
                let l:bOn = 1
            endif

            if l:bOn == 1 && l:bHeader == 0
                call add(l:lsOutPut, l:sComment)
            endif

        else
            " replace class name
            if !empty(self.ClassName) && match(l:sLine, s:tempclass) != -1
                let l:sLine = substitute(l:sLine, s:tempclass, self.ClassName, 'g')
            endif

            " comment header
            if l:bHeader
                if match(l:sLine, '\d\+-\d\+-\d\+') != -1
                    let l:sLine = substitute(l:sLine, '\d\+-\d\+-\d\+', s:today, 'g')
                endif
            endif

            if l:bOn == 1
                call add(l:lsOutPut, l:sLine)
            endif
        endif

    endfor

    return l:lsOutPut
endfunction "}}}

" Script Local Function: {{{1
let s:template = '../tempclass.vim'
let s:tempclass = 'tempclass'
if exists("*strftime")
    let s:today =  strftime('%Y-%m-%d')
else
    let s:today = ''
endif

" FullTempFile: 
let s:pScript = fnamemodify(expand('<sfile>'), ':p:h')
function! s:FullTempFile() abort "{{{
    return s:pScript . '/' . s:template
endfunction "}}}

" TEST: 
function! class#builder#test() abort "{{{
    echo s:FullTempFile()
    return 1
endfunction "}}}
