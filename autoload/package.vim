" File: autoload/package.vim
" Author: lymslive
" Description: viml script packge schema, implemented in single file
" Create: 2018-09-11
" Modify: 2018-09-12

" LICENSE: "{{{1
" The MIT License (MIT)
" 
" Copyright (c) 2018 lymslive (403708621@qq.com)
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

" Package Example Style:  "{{{1
" A package(or module) is just a script under the 'autoload/' subdirctory
" of some &rtp. Each package has a private namespace, the special s: dict.
" This is schema to share private function with other package.
" The following global '#' functions are all optional, while usefull.

" #package() typically return s: to represent the current package.
" you can return other reasonable dict variables such as:
" s:_inner_pack_but_not_so_long_name_
" It is only mandatory to ":USE" command, as import to where?
function! package#package() abort
    return s:
endfunction

" #export() return a dict to represent export what to client.
function! package#export() abort
    return s:EXPORT
endfunction

" #load() mainly to triggle autoload package script.
" Also a good place for initial code, and is safer when reload.
function! package#load() abort "{{{
    if exists('s:__name__')
        return 1
    endif
    let s:__name__ = 'package'
    let s:EXPORTOR_FUNC = ['export', 'class', 'package']
    let s:EXPORTOR_NAME = 'EXPORT'
    let s:EXPORTOR_SID  = '<SID>'
    let s:SLASH = fnamemodify('.', ':p')[-1:]
    let s:scripts = []
    let s:imported = {}
    let s:mapSID = {}
    let s:EXPORT = {}
    let s:EXPORT.get_sid = function('s:get_sid')
    let s:EXPORT.file_sid = function('s:file_sid')
    let s:EXPORT.error = function('s:error')
    let s:EXPORT.scripts = function('s:script_list')
    return 1
endfunction "}}}

" Some way to use(import) other (lib) package from cliend script.
" Of course "package" should be "real#path#to#module".
" But ":USE" also support relative path based on current scipt.
" Note ":USE!" may pollution namespace, and symbol conflict.
function! package#usage() abort "{{{
    let s:P = package#import('package')
    echo s:P.get_sid('package')

    let s:sid = package#imports('package', 'get_sid')
    echo s:sid('package')

    USE package
    echo s:package.get_sid('package')

    USE! package get_sid
    echo s:get_sid('package')
endfunction "}}}

" Import Function API: "{{{1
" a:srcpack -- autoload package name like 'path#to#mod'
" a:000  -- specific symbol name to be imported
" return -- a dict with key is imported symbols
function! package#import(srcpack, ...) abort "{{{
    if stridx(a:srcpack, s:SLASH) >= 0
        return call('package#rimport', ['', a:srcpack] + a:000)
    endif
    let l:sid = s:get_sid(a:srcpack)
    if l:sid <= 0
        try
            call {a:srcpack}#load()
        catch /E117/
            " pass, just for autoload, #load() may not exist
        endtry
        let l:sid = s:get_sid(a:srcpack)
        if l:sid <=0
            return s:error('package not found: ' . a:srcpack, {})
        endif
    endif

    let l:srcpack = s:try_export(a:srcpack, l:sid, a:0)
    return call('s:_import', [l:srcpack, l:sid] + a:000)
endfunction "}}}

" imports: 
" must specific at least a symbol name to imported
" return a single or a list of symbol directlly
function! package#imports(srcpack, ...) abort "{{{
    if a:0 == 0
        return s:error('must privide imported symbol name, or use package#import() instead')
    endif

    let l:export = call('package#import', [a:srcpack] + a:000)
    if empty(l:export)
        return s:error('fail to import')
    endif

    if a:0 == 1
        return l:export[a:1]
    else
        return map(copy(a:000), 'l:export[v:val]')
    endif
endfunction "}}}

" importo: import symbols form src to dst namespace
" a:dstpack -- must be a dict
" a:srcpack -- can be a dict or string as autoload package name
" a:1 -- not overwrite exists key in dstpack, default will overwrite.
" return: less meanning, modify a:dstpack directlly.
function! package#importo(dstpack, srcpack, ...) abort "{{{
    if type(a:dstpack) != type({})
        return s:error('target namespace expect a dict')
    endif
    if type(a:srcpack) == type({})
        let l:srcpack = a:srcpack
    elseif type(a:srcpack) == type('')
        let l:srcpack = package#import(a:srcpack)
    else
        return s:error('export a dict or string as package name')
    endif
    let l:bKeep = get(a:000, 0, 0)
    return s:importto(a:dstpack, l:srcpack, l:bKeep)
endfunction "}}}

" rimport: import through relative path other than autoload
" a:basedir -- the base directory
" a:srcpath -- must has '/' or '.' as path separator, 
"   when '.' should without '.vim' extention
"   when '/' should with '.vim' extention, and assume absolute path
" return a dict as package#import()
function! package#rimport(basedir, srcpath, ...) abort "{{{
    if stridx(a:srcpath, '#') >= 0
        return s:error('aotoload #path should use import() instead')
    endif
    if stridx(a:srcpath, s:SLASH) >= 0
        if a:srcpath =~# '^\.'
            let l:srcpath = a:basedir . s:SLASH . a:srcpath
        else
            let l:srcpath = a:srcpath
        endif
    else
        let l:srcpath = substitute(a:srcpath, '^\.\+', '', 'g')
        let l:srcpath = tr(l:srcpath, '.', s:SLASH)
        let l:srcpath = a:basedir . s:SLASH . l:srcpath
        let l:srcpath .= '.vim'
    end

    let l:srcpath = resolve(expand(l:srcpath))
    let l:sid = s:file_sid(l:srcpath)
    if l:sid <= 0
        if !filereadable(l:srcpath)
            return s:error('cannot read source script', {})
        endif
        execute 'source ' . fnameescape(l:srcpath)
        let l:sid = s:file_sid(l:srcpath)
        if l:sid <= 0
            return s:error('fials to source script', {})
        endif
    endif

    let l:srcpack = s:try_export(l:srcpath, l:sid, a:0)
    return call('s:_import', [l:srcpack, l:sid] + a:000)
endfunction "}}}

" USE Command API: "{{{1
" An user defined command that can only be used in script but command line.
" That will be simpler than package#import() function.
" USE path#to#mod
" USE subdir.mod
" USE ./../relative/to/mod
" with '!' import to current s: namespace

" function Impletemention for USE command
" a:mix -- import to current s: namespace or not
" a:dstpack -- full path of current script <sfile>
" a:srcpack -- '#'ed autoload package name or '/' '.' relative path
function! package#use(mix, dstpack, srcpack, ...) abort "{{{
    if type(a:dstpack) != type('')
        return s:error('argument error, import to where, expect a path')
    endif
    if type(a:srcpack) != type('')
        return s:error('argument error, import from where, expect a path')
    endif

    let l:autopath = s:auto_name(a:dstpack)
    " must have #package() to return s:, or let it abort on error
    let l:dstpack = {l:autopath}#package()
    if type(l:dstpack) != type({})
        return s:error('#package() should return a dict')
    endif

    " import from relative path, when has '/' or '.'
    let l:srcpack = expand(a:srcpack)
    if stridx(l:srcpack, s:SLASH) >= 0 || stridx(l:srcpack, '.') >= 0
        let l:thisdir = fnamemodify(a:dstpack, ':p:h')
        let l:srcpack = call('package#rimport', [l:thisdir, l:srcpack] + a:000)
    else
        let l:srcpack = call('package#import', [l:srcpack] + a:000)
    end

    if !a:mix
        let l:name = s:tail_name(a:srcpack)
        if !has_key(l:dstpack, l:name)
            let l:dstpack[l:name] = {}
        endif
        let l:dstpack = l:dstpack[l:name]
    endif
    return s:importto(l:dstpack, l:srcpack)
endfunction "}}}
command! -nargs=+ -bang USE call package#use(<bang>0, expand('<sfile>:p'), <f-args>)

" Local Class API: {{{1
" A local package object can custom the base directory for relative import.
"   let s:P = obj.import('relative.path.to.module')
" The base directory can be absolute one(with '/'),
" or relative to autoload/(with '#'),
" and when empty, in just relative to autoload/.

let s:class = {'base_' : ''}
function! s:class_import(srcpack, ...) dict abort "{{{
    if stridx(a:srcpack, '#') >= 0
        return call('package#import', [a:srcpack] + a:000)
    elseif stridx(a:srcpack, s:SLASH) >= 0
        return call('package#rimport', ['', a:srcpack] + a:000)
    else
        if stridx(self.base_, s:SLASH) >= 0
            return call('package#rimport', [self.base_, a:srcpack] + a:000)
        else
            let l:srcpack = self.base_ . '#' . a:srcpack
            let l:srcpack = tr(l:srcpack, '.', '#')
            let l:srcpack = substitute(l:srcpack, '^#\+', '', 'g')
            let l:srcpack = substitute(l:srcpack, '##\+', '#', 'g')
            return call('package#import', [l:srcpack] + a:000)
        endif
    endif
endfunction "}}}
let s:class.import = function('s:class_import')

function! package#new(name, ...) abort "{{{
    let l:base = get(a:000, 0, a:name)
    let l:obj = copy(s:class)
    let l:obj.base_ = l:base
    let l:obj.name_ = a:name
    return l:obj
endfunction "}}}

" Private Impletement: "{{{1
" tail_name: the last part of (may full long) package name
function! s:tail_name(package) abort "{{{
    if type(a:package) != type('')
        return s:error('not string module name', '')
    endif
    let l:package = substitute(a:package, '\.vim$', '', 'g')
    let l:name = matchstr(l:package, '\w\+$')
    if empty(l:name)
        return s:error('invalid module name: ' a:package, '')
    endif
    return l:name
endfunction "}}}

" auto_name: convert to autoload name from full path
function! s:auto_name(path) abort "{{{
    let l:autoload = s:SLASH . 'autoload' . s:SLASH
    let l:idx = stridx(a:path, l:autoload)
    if l:idx == -1
        return s:error('may not a autoload script name', '')
    endif

    let l:autopath = strpart(a:path, l:idx + len(l:autoload))
    let l:autopath = tr(l:autopath, s:SLASH, '#')
    let l:autopath = substitute(l:autopath, '\.vim$', '', 'g')
    return l:autopath
endfunction "}}}

" try_export: try to call #export(), s:export() ... ect.
" a:srcpack -- string as autoload name.
" a:sid -- number as <SID> of the corresponding script.
" a:noscan -- not try to scan <SNR>_ function
" expect to return a dict.
function! s:try_export(srcpack, sid, noscan) abort "{{{
    let l:export = get(s:imported, a:srcpack, {})
    if !empty(l:export)
        return l:export
    endif

    for l:fun in s:EXPORTOR_FUNC
        if !empty(a:srcpack) && stridx(a:srcpack, s:SLASH) == -1
            let l:sharp = a:srcpack . '#' . l:fun
            if exists('*' . l:sharp)
                let l:Funref = function(l:sharp)
                let l:export = l:Funref()
            endif
        endif
        if empty(l:export) && !empty(a:sid)
            let l:Funref = s:name2func(a:sid, '_' . l:fun . '_')
            if !empty(l:Funref)
                let l:export = l:Funref()
            endif
        endif
        if !empty(l:export)
            break
        endif
    endfor

    if empty(l:export) && !a:noscan
        let l:export = s:funs2map(a:sid, s:scan_import(a:sid))
    endif

    " try to return the special key in exported dict
    if type(l:export) == type({}) && has_key(l:export, s:EXPORTOR_NAME)
        let l:export = l:export[s:EXPORTOR_NAME]
        if type(l:export) == type([])
            let l:export = s:funs2map(a:sid, l:export)
        endif
    endif

    " <SID> key to import all s: function, it's value is regexp to filter
    if type(l:export) == type({}) && has_key(l:export, s:EXPORTOR_SID)
        let l:sidfunc = s:funs2map(a:sid, s:scan_import(a:sid, l:export[s:EXPORTOR_SID]))
        let l:export = extend(deepcopy(l:export), l:sidfunc)
        unlet! l:export[s:EXPORTOR_SID]
    endif

    if !empty(l:export)
        let s:imported[a:srcpack] = l:export
    endif

    return l:export
endfunction "}}}

" importto: 
function! s:importto(dstpack, srcpack, ...) abort "{{{
    let l:bKeep = get(a:000, 0, 0)
    let l:num = 0
    for [l:key, l:Val] in items(a:srcpack)
        if has_key(a:dstpack, l:key)
            if l:bKeep
                continue
            else
                echomsg 'import will overwrite dest package key: ' . l:key
            endif
        endif
        let a:dstpack[l:key] = deepcopy(l:Val)
        let l:num += 1
        unlet l:key  l:Val
    endfor
    return l:num
endfunction "}}}

" _import: 
" a:pack -- a dict may exported by source package
" a:sid  -- the SID of the sourced script of package
" return a dict, it will be copy of a:pack if no extra argument.
" with optional argument, will also check private s: function.
function! s:_import(pack, sid, ...) abort "{{{
    if type(a:pack) != type({})
        return s:error('export function should return a dict: ' . a:pack)
    endif

    if a:0 == 0
        return deepcopy(a:pack)
    endif

    let l:export = {}
    for l:sName in a:000
        if has_key(a:pack, l:sName)
            let l:export[l:sName] = deepcopy(a:pack[l:sName])
        else
            let l:Funref = s:name2func(a:sid, l:sName)
            if !empty(l:Funref)
                let l:export[l:sName] = l:Funref
                let a:pack[l:sName] = l:Funref
            else
                call s:error('fail to import: ' . l:sName)
                let l:export[l:sName] = 0
            endif
        endif
    endfor

    return l:export
endfunction "}}}

" scan_import: scan :function output list, filter the <SNR>_{a:sid}
" a:sid -- the <SID> number
" a:1   -- pattern to match private function names
" return a dict with "EXPORT" key contains a list of function names
function! s:scan_import(sid, ...) abort "{{{
    if a:0 == 0 || empty(a:1) || a:1 == 1
        let l:pattern = '^[^_]\w\+'
    else
        let l:pattern = a:1
    endif

    let l:sOut = ''
    try
        redir => l:sOut
        silent execute 'function /^[^a-zA-Z]'
    finally
        redir END
    endtry
    if empty(l:sOut)
        return {}
    endif

    let l:funcs = split(l:sOut, "\n")
    let l:prefix = '<SNR>' . a:sid . '_'
    call filter(l:funcs, 'v:val =~# l:prefix')
    let l:select = l:prefix . '\zs\w\+\ze'
    call map(l:funcs, 'matchstr(v:val, l:select)')
    call filter(l:funcs, 'v:val =~# l:pattern')

    return l:funcs
endfunction "}}}

" name2func: 
function! s:name2func(sid, name) abort "{{{
    let l:private = printf('<SNR>%d_%s', a:sid, a:name)
    if exists('*' . l:private)
        return function(l:private)
    else
        return 0
    endif
endfunction "}}}

" funs2map: 
function! s:funs2map(sid, names) abort "{{{
    let l:export = {}
    for l:sName in a:names
        let l:Funref = s:name2func(a:sid, l:sName)
        if !empty(l:Funref)
            let l:export[l:sName] = l:Funref
        endif
    endfor
    return l:export
endfunction "}}}

" Manage SID: "{{{1

" scipt_list: 
function! s:script_list() abort "{{{
    call s:fresh_script()
    return copy(s:scripts)
endfunction "}}}

" fresh_script: track the loaded script, list by :scriptnames
function! s:fresh_script() abort "{{{
    let l:sOut = ''
    try
        redir => l:sOut
        silent execute 'scriptnames'
    finally
        redir END
    endtry
    if empty(l:sOut)
        return
    endif

    let l:scripts = split(l:sOut, "\n")
    let l:end = len(l:scripts)
    let l:idx = len(s:scripts)
    while l:idx < l:end
        let l:script = matchstr(l:scripts[l:idx], '^\s*\d\+:\s*\zs.*')
        let l:script = resolve(expand(l:script))
        call add(s:scripts, l:script)
        if l:script =~# 'autoload'
            let l:package = s:auto_name(l:script)
            if !empty(l:package) && !has_key(s:mapSID, l:package)
                let s:mapSID[l:package] = l:idx + 1
            endif
        endif
        let l:idx += 1
    endwhile

    return l:end - l:idx
endfunction "}}}

" get_sid: 
" get the SID of a package under autoload/ subdirctory
" return 0 when script not load
function! s:get_sid(package) abort "{{{
    if has_key(s:mapSID, a:package)
        return s:mapSID[a:package]
    else
        call s:fresh_script()
    endif
    return get(s:mapSID, a:package)
endfunction "}}}

" file_sid: find SID from full path of script file
function! s:file_sid(path) abort "{{{
    call s:fresh_script()
    let l:idx = 0
    let l:end = len(s:scripts)
    while l:idx < l:end
        if s:scripts[l:idx] ==# resolve(expand(a:path))
            return l:idx + 1
        endif
        let l:idx += 1
    endwhile
    return 0
endfunction "}}}

" Common Utils: {{{1
" print error massage and return a error code(default 0).
function! s:error(msg, ...) abort "{{{
    let l:stacks = split(expand('<sfile>'), '\.\.')
    if len(l:stacks) > 1
        let l:location = join(l:stacks[0:-2], '..')
    else
        let l:location = 'script'
    endif
    echohl ErrorMsg | echomsg 'vim> ' . l:location | echohl None
    echohl Error    | echomsg a:msg | echohl None
    return get(a:000, 0, 0)
endfunction "}}}

" a shortter global Import function, if you like
if get(g:, 'global_import_function', 0)
function! Import(...) abort
    return call('package#import', a:0000)
endfunction
endif

call package#load()
