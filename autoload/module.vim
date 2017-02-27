" File: module.vim
" Author: lymslive
" Description: VimL module manager
" Create: 2017-02-27
" Modify: 2017-02-27

let s:class = {}
let s:class.basedir = 'module'

" IMPORT:
function! module#import(name, ...) abort "{{{
    let l:name = substitute(a:name, '[./]\+', '#', 'g')
    let l:class = {}

    " full path name
    try
        let l:class = eval(l:name . '#import()')
    catch
        let l:name = substitute(l:name, '^#', '', 'g')
        let l:name = substitute(l:name, '#$', '', 'g')

        let l:path = substitute(l:name, '#', '/', 'g')
        if l:patn !~# '^autoload'
            let l:path = 'autoload' . l:path
        endif

        let l:lsGlob = globpath(&runtimepath, l:path, 0, 1)
        if !empty(l:lsGlob)
            let l:pScriptFile = l:lsGlob[0]
            execute 'source ' . l:pScriptFile
            let l:Funcref = s:class.SelectImport(l:name)
            if exists('*l:Funcref')
                let l:class = l:Funcref()
            else
                let l:class = s:class.ParseImport(l:pScriptFile, a:000)
            endif
        endif
    endtry

    if !empty(l:class)
        return l:class
    endif

    " may ignore 'module' base dir
    if l:name !~# '^' . s:class.basedir
        let l:name = s:class.basedir . '#' . l:name
        return module#import(l:name, a:000)
    endif

    return l:class
endfunction "}}}

" SelectImport: 
" try the order: #import(), #instance(), #class()
function! s:class.SelectImport(sModule) dict abort "{{{
    let l:Funcref = function(a:sModule . '#import')
    if exists('*l:Funcref')
        return l:Funcref
    endif

    let l:Funcref = function(a:sModule . '#instance')
    if exists('*l:Funcref')
        return l:Funcref
    endif

    let l:Funcref = function(a:sModule . '#class')
    if exists('*l:Funcref')
        return l:Funcref
    endif
    
    return function('module#NONE')
endfunction "}}}

" ParseImport: 
function! s:class.ParseImport(pScriptFile, lsOption) dict abort "{{{
    if type(a:lsOption) != type([])
        let l:lsOption = [a:lsOption]
    elseif len(a:lsOption) == 1 && type(a:lsOption[0]) == type([])
        " recursively call module#import will pass [a:000]
        let l:lsOption = a:lsOption[0]
    else
        let l:lsOption = a:lsOption
    endif

    let l:jOption = class#cmdline#new('Module module-name ...')
    call l:jOption.AddSingle('s', 'script-local', 'also load script localed function')
    call l:jOption.AddSingle('i', 'ignorecase', 'also load lowercase function')
    call l:jOption.AddSingle('n', 'func-name', 'only load these name')
    
    let l:iErr = l:jOption.ParseCheck(l:lsOption)
    if l:iErr != 0
        return {}
    endif
endfunction "}}}

" TEST:
function! module#test(...) abort "{{{
    return 0
endfunction "}}}
