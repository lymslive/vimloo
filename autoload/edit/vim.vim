" File: vim.vim
" Author: lymslive
" Description: implement for ftplugin/vim.vim
" Create: 2017-03-08
" Modify: 2017-03-09

" UpdateModity: 
" automatically update the Modify time in the commet header
function! edit#vim#UpdateModity() abort "{{{
    let l:sDate = strftime('%Y-%m-%d')
    let l:cmd = '1,10 g/"\s*Modify:/s/\d\+[-]\d\+[-]\d\+/%s/'
    let l:cmd = printf(l:cmd, l:sDate)

    let l:save_cursor = getcurpos()
    execute l:cmd
    call setpos('.', l:save_cursor)
endfunction "}}}

" GotoSharpFunc: 
function! edit#vim#GotoSharpFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    let l:lsPart = split(l:name, '#')
    let l:sFuncName = remove(l:lsPart, -1)
    let l:sAutoName = join(l:lsPart, '#')

    let l:rtp = module#less#rtp#import()
    let l:pScriptFile = l:rtp.FindAutoScript(l:sAutoName)
    if !empty(l:pScriptFile) && filereadable(l:pScriptFile)
        let l:cmd = 'edit +/%s %s'
        let l:cmd = printf(l:cmd, l:name, l:pScriptFile)
        execute l:cmd
        return line('.')
    else
        :ELOG 'cannot find function: ' . l:name
        return 0
    endif
endfunction "}}}

" GotoLocalFunc: 
function! edit#vim#GotoLocalFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    if l:name !~# '^s:'
        let l:name = 's:' . l:name
    endif

    let l:sPattern = '^\s*function!\?\s\+%s'
    let l:sPattern = printf(l:sPattern, l:name)
    return search(l:sPattern, 'cew')
endfunction "}}}

" GotoClassFunc: 
function! edit#vim#GotoClassFunc(...) dict abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

endfunction "}}}

" GotoDefineFunc: 
function! edit#vim#GotoDefineFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    if l:name =~# '#'
        return edit#vim#GotoSharpFunc(l:name)
    elseif l:name =~# 's:'
        return edit#vim#GotoLocalFunc(l:name)
    else
        execute 'tag .' l:name
    endif
endfunction "}}}
