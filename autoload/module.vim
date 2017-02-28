" File: module.vim
" Author: lymslive
" Description: VimL module manager
" Create: 2017-02-27
" Modify: 2017-02-27

let s:class = {}
let s:class.basedir = 'module'
let s:class.imported = {}

function! s:class.class() dict abort "{{{
    return s:class
endfunction "}}}

" IMPORT:
function! module#import(name, ...) abort "{{{
    if has_key(s:class.imported, a:name)
        return s:class.imported[a:name]
    endif

    let l:class = {}

    " full module name?
    try
        let l:name = substitute(a:name, '[./]\+', '#', 'g')
        let l:class = eval(l:name . '#import()')
    catch
        let l:class = module#simport(a:name, a:000)
    endtry

    if !empty(l:class)
        let s:class.imported[a:name] = l:class
        return l:class
    endif

    " may ignore 'module' base dir
    if l:name !~# '^' . s:class.basedir
        let l:name = s:class.basedir . '#' . l:name
        let l:class = module#import(l:name, a:000)
    endif

    if !empty(l:class)
        let s:class.imported[a:name] = l:class
        return l:class
    endif

    return l:class
endfunction "}}}

" SIMPORT: 
function! module#simport(name, ...) abort "{{{
    let l:class = {}

    let l:pScriptFile = s:FindScript(a:name)
    if empty(l:pScriptFile)
        return l:class
    endif

    execute 'source ' . l:pScriptFile

    let l:rtp = module#less#rtp#import()
    if l:rtp.IsAutoload(l:pScriptFile)
        let l:sModule = l:rtp.GetAutoName(l:pScriptFile)
        if !empty(l:sModule)
            let l:Funcref = s:SelectImport(l:pScriptFile)
            if exists('*l:Funcref')
                let l:class = l:Funcref()
            endif
        endif
    endif

    if empty(l:class)
        let l:class = s:ParseImport(l:pScriptFile, a:000)
    endif

    return l:class
endfunction "}}}

" FindScript: 
function! s:FindScript(name) abort "{{{
    if empty(a:name)
        return ''
    elseif filereadable(a:name)
        return a:name
    endif

    " transform #. separater to unified /, add .vim suffix
    let l:name = substitute(a:name, '#', '/', 'g')
    if l:name !~? '\.vim$'
        let l:name = substitute(l:name, '\.', '/', 'g')
        let l:name .= '.vim'
    else
        let l:base = substitute(l:name, '\.vim$', '', 'i')
        let l:base = substitute(l:base, '\.', '/', 'g')
        let l:name = l:base . '.vim'
    endif

    if filereadable(l:name)
        return l:name
    endif

    " try script file under autoload subdirctory
    if l:name !~# '^autoload'
        let l:name = 'autoload/' . l:name
    endif

    let l:lsGlob = globpath(&runtimepath, l:name, 0, 1)
    if !empty(l:lsGlob)
        return l:lsGlob[0]
    endif

    return ''
endfunction "}}}

" SelectImport: 
" try the order: #import(), #instance(), #class()
function! s:SelectImport(sModule) abort "{{{
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
function! s:ParseImport(pScriptFile, lsOption) abort "{{{
    let l:list = module#less#list#import()
    let l:lsOption = l:list.Flat(a:lsOption, -1)

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
