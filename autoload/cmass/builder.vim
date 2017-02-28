" File: cmass#builder
" Author: lymslive
" Description: command use class#builder
" Create: 2017-02-14
" Modify: 2017-02-28

let s:rtp = module#less#rtp#import()

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

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassNew only execute under autoload director'
        return 0
    endif

    if a:0 > 1 && !empty(a:2)
        let l:jBuilder = class#builder#new(l:sAutoName, a:2)
    else
        let l:jBuilder = class#builder#new(l:sAutoName)
    endif

    if a:0 < 1
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    execute 'edit ' . l:pFileName . '.vim'
    call setline(1, l:lsContent)
endfunction "}}}

" ModuleNew:
function! cmass#builder#hModuleNew(name, ...) abort "{{{
    if a:0 == 0
        call cmass#builder#hClassNew(a:name, '', 'tempmodule')
    else
        call cmass#builder#hClassNew(a:name, a:1, 'tempmodule')
    endif
endfunction "}}}

" ClassAdd: add class frame to current opened buffer
function! cmass#builder#hClassAdd(...) abort "{{{
    let l:pFileName = expand('%:p:r')
    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassAdd only execute under autoload director'
        return 0
    endif

    let l:jBuilder = class#builder#new(l:sAutoName)
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
    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassPart only execute under autoload director'
        return 0
    endif

    let l:jBuilder = class#builder#new(l:sAutoName)
    let l:lsContent = jBuilder.SelectLine(a:sFilter)

    call append(line('.'), l:lsContent)
endfunction "}}}

