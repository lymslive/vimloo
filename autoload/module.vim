" File: module.vim
" Author: lymslive
" Description: VimL module manager
" Create: 2017-02-27
" Modify: 2017-08-05

let s:class = {}
let s:class.basedir = 'module'
let s:class.imported = {}

let s:rtp = module#less#rtp#import()
let s:class.imported['less.rtp'] = s:rtp

function! module#class() abort "{{{
    return s:class
endfunction "}}}

" module: query imported modules
function! s:class.module(...) dict abort "{{{
    if a:0 == 0
        return keys(s:class.imported)
    else
        return get(s:class.imported, a:1, {})
    endif
endfunction "}}}

" _import: try the order: #import(), #instance(), #class()
" > a:sModule, full module name sep by #
function! s:_import(sModule) abort "{{{
    try
        let l:class = eval(a:sModule . '#import()')
        :DLOG '-2 import module from: ' . a:sModule . '#import()'
    catch 
        if exists('*' . a:sModule . '#instance')
            let l:class = eval(a:sModule . '#instance()')
            :DLOG '-2 import module from: ' . a:sModule . '#instance()'
        elseif exists('*' . a:sModule . '#class')
            let l:class = eval(a:sModule . '#class()')
            :DLOG '-2 import module from: ' . a:sModule . '#class()'
        else
            let l:class = {}
        endif
    endtry
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
    let l:name = expand(a:name)
    let l:name = substitute(l:name, '#', s:rtp.separator, 'g')
    if l:name !~? '\.vim$'
        let l:name = substitute(l:name, '\.', s:rtp.separator, 'g')
        let l:name .= '.vim'
    else
        let l:base = substitute(l:name, '\.vim$', '', 'i')
        let l:base = substitute(l:base, '\.', s:rtp.separator, 'g')
        let l:name = l:base . '.vim'
    endif

    if filereadable(l:name)
        return l:name
    endif

    " try script file under autoload subdirctory
    if l:name !~# '^autoload'
        let l:name = 'autoload' . s:rtp.separator . l:name
    endif

    let l:lsGlob = globpath(&runtimepath, l:name, 0, 1)
    if !empty(l:lsGlob)
        return l:lsGlob[0]
    endif

    return ''
endfunction "}}}

" ParseImport: 
function! s:ParseImport(pScriptFile, lsOption) abort "{{{
    let l:list = module#less#list#import()
    let l:lsOption = l:list.Flat(a:lsOption, -1)

    let l:jOption = class#viml#cmdline#new('Module module-name ...')
    call l:jOption.AddSingle('S', 'nolocal', 'donot import script localed function')
    call l:jOption.AddSingle('g', 'global', 'also import global function')
    call l:jOption.AddSingle('n', 'pattern', 'only load these matched name')
    call l:jOption.AddSingle('u', 'private', 'also import function name begin with _')

    let l:iErr = l:jOption.ParseCheck(l:lsOption)
    if l:iErr != 0
        return {}
    endif

    let l:lsPostArgv = l:jOption.GetPost()

    let l:jSource = class#viml#source#new(a:pScriptFile)
    let l:dExport = l:jSource.ExportFunction()
    :DLOG '-2 ' . printf('find [%d] functions from script [%s]', len(l:dExport), a:pScriptFile)
    if empty(l:dExport)
        return {}
    endif

    let l:dImport = {}
    for [l:key, l:val] in items(l:dExport)
        let l:cType = l:val.type
        if l:cType ==# 's' && l:jOption.Has('nolocal')
            continue
        endif

        if l:cType ==# 'g' && !l:jOption.Has('global')
            continue
        endif

        let l:sName = l:val.name
        let l:bImport = v:true

        if l:sName =~# '^_' && !l:jOption.Has('private')
            let l:bImport = v:false
        endif

        if l:jOption.Has('pattern') && !empty(l:lsPostArgv)
            let l:bMatch = v:false
            for l:sInput in l:lsPostArgv
                if l:sName =~# l:sInput
                    let l:bMatch = v:true
                    break
                endif
            endfor
            let l:bImport = l:bMatch
        endif

        if !l:bImport
            continue
        endif

        if has_key(l:dImport, l:sName)
            :WLOG printf('%s: dumplicated function, maybe mixing scope', l:sName)
        endif
        let l:dImport[l:sName] = l:val.func

        unlet l:key  l:val
    endfor

    return l:dImport
endfunction "}}}

" IMPORT: import a module
" > a:name, [module#]foo#bar, [module.]foo.bar
function! module#import(name, ...) abort "{{{
    if has_key(s:class.imported, a:name)
        return s:class.imported[a:name]
    endif

    " when sep by /, treat as script file name
    if s:rtp.LikePath(a:name) || s:rtp.LikeFile(a:name, 'vim')
        return module#simport(a:name, a:000)
    endif

    let l:class = {}

    " transform to autoload name #
    let l:name = substitute(a:name, '[./]\+', '#', 'g')

    if l:name !~# '^' . s:class.basedir
        let l:sModule = s:class.basedir . '#' . l:name
        :DLOG '-2 try to import: ' . l:sModule
        let l:class = s:_import(l:sModule)
        if empty(l:class)
            let l:class = module#simport(l:sModule, a:000)
        endif
    endif

    if empty(l:class)
        let l:sModule = l:name
        :DLOG '-2 try to import: ' . l:sModule
        let l:class = s:_import(l:sModule)
        if empty(l:class)
            let l:class = module#simport(l:sModule, a:000)
        endif
    endif

    if !empty(l:class) && !has_key(s:class.imported, a:name)
        let s:class.imported[a:name] = l:class
        :DLOG '-2 saved imported module: ' . a:name
    endif

    return l:class
endfunction "}}}

" SIMPORT: import a script
function! module#simport(name, ...) abort "{{{
    if has_key(s:class.imported, a:name)
        return s:class.imported[a:name]
    endif

    let l:class = {}

    let l:pScriptFile = s:FindScript(a:name)
    if empty(l:pScriptFile)
        :DLOG '-2 fail to find script by: ' . a:name
        return l:class
    endif

    :DLOG '-2 has find script : ' . l:pScriptFile
    let l:pScriptFile = s:rtp.Absolute(l:pScriptFile)
    execute 'source ' . l:pScriptFile

    let l:sModule = s:rtp.GetAutoName(l:pScriptFile)
    if !empty(l:sModule)
        let l:class = s:_import(l:sModule)
    endif

    if empty(l:class)
        let l:class = s:ParseImport(l:pScriptFile, a:000)
    endif

    if !empty(l:class) && !has_key(s:class.imported, a:name)
        let s:class.imported[a:name] = l:class
        :DLOG '-2 saved imported module: ' . a:name
    endif

    return l:class
endfunction "}}}

" CIMPORT: import a class
function! module#cimport(name, ...) abort "{{{
    if has_key(s:class.imported, a:name)
        return s:class.imported[a:name]
    endif

    let l:class = {}
    let l:name = substitute(a:name, '[./]\+', '#', 'g')

    try
        let l:class = eval(l:name . '#import()')
        :DLOG '-2 import class from: ' . l:name . '#import()'
    catch
        try
            let l:class = eval('class#' . l:name . '#import()')
            :DLOG '-2 import class from: class#' . l:name . '#import()'
        catch
            "  no explict import() function
        endtry
    endtry

    " build module online based on #class() function
    " default import new and isobject function, without check
    if empty(l:class)
        let l:meta = class#class(l:name)
        if !empty(l:meta)
            let l:class.class = l:meta
            :DLOG '-2 import class from: #class()'
            try
                let l:sName = l:meta._name_
                let l:class.new = function(l:sName . '#new')
                let l:class.isobject = function(l:sName. '#isobject')
            catch 
                :WLOG l:name . ' class has no _name_ reserved property?'
            endtry
        endif
    endif

    if !empty(l:class)
        let s:class.imported[a:name] = l:class
        :DLOG '-2 saved imported class: ' . a:name
    endif

    return l:class
endfunction "}}}

" TEST:
function! module#test(...) abort "{{{
    let l:msg = module#import('unite.Vim.Message')
    call l:msg.warn('calling unite.Vim.Message.warn()')
    call l:msg.error('calling unite.Vim.Message.error()')

    let l:dict = module#import('less.dict')
    echo l:dict.Display(l:msg)
    return 0
endfunction "}}}

:DLOG '-1 module.vim is loading ...'
