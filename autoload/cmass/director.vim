" Class: cmass#director
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-14
" Modify: 2017-08-04

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

" ClassView: 
" :ClassView [filename]
function! cmass#director#hClassView(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        let l:pFileName = a:1
    else
        let l:pFileName = expand('%:p:r')
    endif

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassView only execute under autoload director'
        return 0
    endif

    call call('class#echo', [l:sAutoName, '-am'])
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

    call call(l:sAutoName . '#test', l:lsPostArgv)
endfunction "}}}

" ClassDebug: 
" same as ClassTest, but redir message to locallist
" problem: error abort may confuse the redir
let s:output = ''
function! cmass#director#hClassDebug(...) abort "{{{
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

    let g:DEBUG = 1
    try
        redir => s:output
        silent call call(l:sAutoName . '#test', l:lsPostArgv)
    catch 
    finally
        redir END

        let l:lsContent = split(s:output, '\n')
        let l:lsQF = []
        let l:bufnr = bufnr('%')
        for l:sLine in l:lsContent
            if l:sLine =~# 'E\d\+'
                let l:item = {'bufnr': l:bufnr, 'lnum': 0, 'text': l:sLine}
            else
                let l:item = {'bufnr': l:bufnr,  'text': l:sLine}
            endif
            call add(l:lsQF, l:item)
        endfor

        let l:winnr = winnr()
        call setloclist(l:winnr, l:lsQF)

        if !empty(l:lsQF)
            :lopen
        endif
    endtry
endfunction "}}}

" MessageRefix: reload last message in quickfix or locallist
" a:count, the line count from message end, like `tail -n`
" a:type, 'qf', or 'll'
function! cmass#director#MessageRefix(count, type) abort "{{{
    : redir => s:output
    : silent messages
    : redir END

    let l:lsContent = split(s:output, '\n')
    if a:count > len(l:lsContent)
        let l:count = len(l:lsContent)
    else
        let l:count = a:count + 0
    endif
    let l:lsContent = l:lsContent[-l:count:-1]

    let l:lsQF = []
    let l:bufnr = bufnr('%')
    for l:sLine in l:lsContent
        if l:sLine =~# 'E\d\+'
            let l:item = {'bufnr': l:bufnr, 'lnum': 0, 'text': l:sLine}
        else
            let l:item = {'bufnr': l:bufnr,  'text': l:sLine}
        endif
        call add(l:lsQF, l:item)
    endfor

    if a:type ==? 'qf'
        call setqflist(l:lsQF)
        if !empty(l:lsQF)
            : botright copen
        endif
    elseif a:type ==? 'll'
        let l:winnr = winnr()
        call setloclist(l:winnr, l:lsQF)
        if !empty(l:lsQF)
            : lopen
        endif
    endif

endfunction "}}}

" PluginLocal: redirect to another script
" > a:pSource, the script full path where :PLUGINLOCAL in
" > a:sExtention, the default redirect file extention
" > a:1, a:pScript, default the same filename but wich a:sExtention
"   relative to the dir where a:pSource in
" < return true if redirect the target script successful
function! cmass#director#hPluginLocal(pSource, sExtention, ...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        let l:pScript = fnamemodify(a:pSource, ':p:h') . s:rtp.separator . a:1
    else
        let l:pScript = fnamemodify(a:pSource, ':p:r') . a:sExtention
    endif

    if filereadable(l:pScript)
        execute 'source ' . l:pScript
        " return v:true
        return 1
    else
        " return v:false
        return 0
    endif
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
DLOG 'cmass#director loading ...'

" TEST: -t
function! cmass#director#test(...) abort "{{{
    echo 'in cmass#director#test'
    echo a:000
    for l:idx in range(a:0)
        echo a:000[l:idx]
    endfor
    return 1
endfunction "}}}
