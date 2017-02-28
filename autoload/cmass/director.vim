" Class: cmass#director
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-14
" Modify: 2017-02-14

"LOAD: -l
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

let s:rtp = module#less#rtp#import()

" ClassLoad: 
" :ClassLoad [-r] [-d|D] [filename]
function! cmass#director#hClassLoad(...) abort "{{{
    let l:jOption = class#cmdline#new('ClassLoad')
    call l:jOption.AddSingle('r', 'reload', 'force reload script')
    call l:jOption.AddSingle('d', 'debug', 'set g:DEBUG to allow directlly reload')
    call l:jOption.AddSingle('D', 'nodebug', 'unset g:DEBUG variable')
    let l:iRet = l:jOption.ParseCheck(a:000)
    if l:iRet != 0
        return -1
    endif

    let l:lsPostArgv = l:jOption.GetPost()
    if empty(l:lsPostArgv)
        let l:pFileName = expand('%:p')
    else
        let l:pFileName = l:lsPostArgv[0]
    endif

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassLoad only execute under autoload director'
        return -1
    endif

    let l:FuncLoad = function(l:sAutoName . '#load')
    if l:jOption.Has('reload')
        call l:FuncLoad(1)
    endif

    if l:jOption.Has('debug')
        let g:DEBUG = 1
        echo 'let g:DEBUG = 1'
    endif

    if l:jOption.Has('nodebug') && exists('g:DEBUG')
        unlet g:DEBUG
        echo 'unlet g:DEBUG'
    endif

    if l:jOption.Has('reload') || l:jOption.Has('debug')
        execute 'source '. l:pFileName
    endif

    call l:FuncLoad()
    return 0
endfunction "}}}

" ClassTest: 
" :ClassTest [-f filename] -- [argument-list-pass-to-#test]
function! cmass#director#hClassTest(...) abort "{{{
    let l:jOption = class#cmdline#new('ClassTest')
    call l:jOption.AddPairs('f', 'file', 'the filename witch #test called', '.')
    let l:iRet = l:jOption.ParseCheck(a:000)
    if l:iRet != 0
        return -1
    endif

    let l:lsPostArgv = l:jOption.GetPost()

    if l:jOption.Has('file')
        let l:pFileName = l:jOption.Get('file')
    else
        let l:pFileName = expand('%:p:r')
    endif

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassTest only execute under autoload director'
        return 0
    endif

    call cmass#director#UnpackCall(l:sAutoName . '#test', l:lsPostArgv)
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
echo 'cmass#director loading ...'

" TEST: -t
function! cmass#director#test(...) abort "{{{
    echo 'in cmass#director#test'
    echo a:000
    for l:idx in range(a:0)
        echo a:000[l:idx]
    endfor
    return 1
endfunction "}}}
