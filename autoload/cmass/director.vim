" Class: cmass#director
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-14
" Modify: 2017-02-14

"LOAD: -l
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" ClassLoad: 
function! cmass#director#hClassLoad(...) abort "{{{
    let l:jOption = class#cmdline#new(a:000)
    call l:jOption.AddSingle('r', 'reload', 'force reload script')
    let l:iRet = l:jOption.Check()
    if l:iRet != 0
        return -1
    endif

    let l:lsPostArgv = l:jOption.GetPost()
    if empty(l:lsPostArgv)
        let l:pFileName = expand('%:p')
    else
        let l:pFileName = l:lsPostArgv[0]
    endif

    let l:pAutoName = cmass#builder#CheckAutoName(l:pFileName)
    if empty(l:pAutoName)
        echom ':ClassLoad only execute under autoload director'
        return -1
    endif

    let l:FuncLoad = function(l:pAutoName . '#load')
    if l:jOption.Has('reload')
        call l:FuncLoad(1)
        execute 'source '. l:pFileName
    else
        call l:FuncLoad()
    endif

    return 0
endfunction "}}}

" ClassTest: 
function! cmass#director#hClassTest(...) abort "{{{
    let l:jOption = class#cmdline#new(a:000)
    call l:jOption.AddPairs('f', 'file', 'the filename witch #test called', '.')
    let l:iRet = l:jOption.Check()
    if l:iRet != 0
        return -1
    endif

    let l:lsPostArgv = l:jOption.GetPost()

    if l:jOption.Has('file')
        let l:pFileName = l:jOption.Get('file')
    else
        let l:pFileName = expand('%:p:r')
    endif

    let l:pAutoName =cmass#builder#CheckAutoName(l:pFileName)
    if empty(l:pAutoName)
        echom ':ClassTest only execute under autoload director'
        return 0
    endif

    call cmass#director#UnpackCall(l:pAutoName . '#test', l:lsPostArgv)
endfunction "}}}

" UpcakArgv: convert a list to string as used in function call
" [1, 2, '3'] ==> 1, 2, '3'
function! cmass#director#UpcakArgv(lsArgv) abort "{{{
    let l:sArgv = string(a:lsArgv)
    if type(a:lsArgv) == type([])
        return l:sArgv[1:-2]
    else
        return l:sArgv
    endif
endfunction "}}}

" UnpackCall: 
function! cmass#director#UnpackCall(sFunc, lsArgv) abort "{{{
    let l:sArgv = cmass#director#UpcakArgv(a:lsArgv)
    let l:sCmd = 'call ' . a:sFunc . '(' . l:sArgv. ')'
    execute l:sCmd
endfunction "}}}

" UnpackEval: 
function! cmass#director#UnpackEval(sFunc, lsArgv) abort "{{{
    let l:sArgv = cmass#director#UpcakArgv(a:lsArgv)
    let l:sCmd = 'eval ' . a:sFunc . '(' . l:sArgv. ')'
    execute l:sCmd
endfunction "}}}

" LOAD: -l
let s:load = 1
function! cmass#director#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}
echo 'cmass#director load ...'

" TEST: -t
function! cmass#director#test(...) abort "{{{
    echo 'in cmass#director#test'
    echo a:000
    for l:idx in range(a:0)
        echo a:000[l:idx]
    endfor
    return 1
endfunction "}}}
