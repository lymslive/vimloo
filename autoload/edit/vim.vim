" File: vim.vim
" Author: lymslive
" Description: implement for ftplugin/vim.vim
" Create: 2017-03-08
" Modify: 2018-05-02

" UpdateModity: 
" automatically update the Modify time in the commet header
function! edit#vim#UpdateModity() abort "{{{
    let l:sDate = strftime('%Y-%m-%d')
    let l:iEnd = line('$')
    if l:iEnd > 10
        let l:iEnd = 10
    endif

    let l:cmd = '1,%d g/"\s*Modify:/s/\d\+[-]\d\+[-]\d\+/%s/'
    let l:cmd = printf(l:cmd, l:iEnd, l:sDate)

    let l:save_cursor = getcurpos()
    execute l:cmd
    call setpos('.', l:save_cursor)
endfunction "}}}

" GotoSharpFunc: path#to#file#Func
function! edit#vim#GotoSharpFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    " the #function is in current file?
    let l:sPattern = '^\s*fu[nction]*!\?\s\+%s'
    let l:sPattern = printf(l:sPattern, l:name)
    if search(l:sPattern, 'cew') > 0
        return line('.')
    endif

    let l:lsPart = split(l:name, '#')
    let l:sFuncName = remove(l:lsPart, -1)
    let l:sAutoName = join(l:lsPart, '#')

    " find in &rtp
    let l:rtp = class#less#rtp#export()
    let l:pScriptFile = l:rtp.FindAutoScript(l:sAutoName)
    if !empty(l:pScriptFile) && filereadable(l:pScriptFile)
        # let l:cmd = 'edit +/%s %s'
        # let l:cmd = printf(l:cmd, l:name, l:pScriptFile)
        execute 'eidt' l:pScriptFile
        if search(l:sPattern, 'cew') <= 0
            :ELOG 'cannot find function: ' . l:name
        endif
        return line('.')
    endif

    " find in &packpath/opt
    let l:pScriptFile = l:rtp.FindAoptScript(l:sAutoName, 1)
    if !empty(l:pScriptFile) && filereadable(l:pScriptFile)
        execute 'eidt' l:pScriptFile
        if search(l:sPattern, 'cew') <= 0
            :ELOG 'cannot find function: ' . l:name
        endif
        return line('.')
    endif

    :ELOG 'cannot find function: ' . l:name
    return 0
endfunction "}}}

" GotoLocalFunc: s:Func
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

" GotoClassFunc: s:class.Func
function! edit#vim#GotoClassFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    if l:name =~# '^self\.'
        let l:name = substitute(l:name, '^self\.', 's:class.', '')
    elseif l:name =~# '^s:class\.'
        " pass
    else
        let l:name = 's:class.' . l:name
    endif

    return search(l:name, 'cew')
endfunction "}}}

" GotoDefineFunc: 
function! edit#vim#GotoDefineFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:cursor = module#less#cursor#import() 
        let l:name = l:cursor.GetWord('.', '#', ':')
        " let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    if l:name =~# '#'
        return edit#vim#GotoSharpFunc(l:name)
    elseif l:name =~# '^s:'
        return edit#vim#GotoLocalFunc(l:name)
    elseif l:name =~# '^self\.'
        return edit#vim#GotoClassFunc(l:name)
    else
        execute 'tag .' l:name
    endif
endfunction "}}}
