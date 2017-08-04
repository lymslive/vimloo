" Class: class#viml#source
" Author: lymslive
" Description: a viml script objcet
" Create: 2017-02-28
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#viml#source'
let s:class._version_ = 1

let s:class.path = ''
let s:class.sid = 0

function! class#viml#source#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#viml#source#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#viml#source#ctor(this, ...) abort "{{{
    if a:0 > 0 && filereadable(a:1)
        let a:this.path = resolve(a:1)
    else
        :ELOG 'class#viml#source need a full path'
    endif
    let a:this.sid = 0
endfunction "}}}

" ISOBJECT:
function! class#viml#source#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" SID: 
function! s:class.SID() dict abort "{{{
    if self.sid != 0
        return self.sid
    endif

    " :LOG 'self.path = ' . self.path
    let l:jMsg = class#messager#new('scriptnames')
    let l:lsOutPut = l:jMsg.CaptureList()
    let l:filename = fnamemodify(self.path, ':t')
    call filter(l:lsOutPut, 'v:val =~# l:filename')
    for l:sLine in l:lsOutPut
        let l:sLine = substitute(sLine, '^\s\+', '', '')
        let l:sLine = substitute(sLine, '\s\+$', '', '')
        let l:lsPart = split(l:sLine, '\s*:\s*')
        if len(l:lsPart) < 2
            continue
        endif

        let l:sid = 0 + l:lsPart[0]
        let l:script = l:lsPart[1]
        if expand(l:script) ==# expand(self.path)
            let self.sid = l:sid
            break
        endif
    endfor

    if self.sid <= 0
        :WLOG 'cannot find the sid of the script, may need source first'
    endif

    return self.sid
endfunction "}}}

" PrefixSID: 
function! s:class.PrefixSID() dict abort "{{{
    return '<SNR>' . self.SID() . '_'
endfunction "}}}

let s:pattern = {}
" match a function definition line, the matchstr is function name
let s:pattern.function_name = '^\s*function!\?\s\+\zs\h[:.#a-zA-Z0-9_]*\ze\s*(.*)'
" s:function
let s:pattern.function_local = '^s:\zs\h\w\+\ze$'
" dict.function \1=dict-name \2=func-name
let s:pattern.function_dict = '^\(.\+\)\.\(\h\w\+\)$'

" ExportFunction: 
function! s:class.ExportFunction() dict abort "{{{
    let l:dExport = {}
    if !filereadable(self.path)
        :ELOG 'script file isnot readable: ' . self.path
        return l:dExport
    endif

    execute 'source ' . self.path

    let l:lsContent = readfile(self.path)
    for l:sLine in l:lsContent
        let l:sFunction = matchstr(l:sLine, s:pattern.function_name)
        if empty(l:sFunction)
            continue
        endif

        let l:sLocal = matchstr(l:sFunction, s:pattern.function_local)
        if !empty(l:sLocal)
            let l:sKey = l:sLocal
            let l:sFullName = self.PrefixSID() . l:sLocal
            let l:dFunc = {'type': 's', 'name': l:sKey, 'func': function(l:sFullName)}
            let l:dExport[l:sFunction] = l:dFunc 
            continue
        endif

        if l:sFunction =~ '#'
            let l:lsPath = split(l:sFunction, '#')
            let l:sKey = remove(l:lsPath, -1)
            let l:sFullName = l:lsPath
            let l:dFunc = {'type': '#', 'name': l:sKey, 'func': function(l:sFullName)}
            let l:dExport[l:sFunction] = l:dFunc 
            continue
        endif

        let l:lsMatch = matchlist(l:sFunction, s:pattern.function_dict)
        if !empty(l:lsMatch)
            " dict function ref, export the dict itself
            " no good way to get it from outside the script
            continue
        endif

        :WLOG 'maybe occur global function: ' . l:sFunction
        let l:sKey = l:sFunction
        let l:sFullName = l:sFunction
        let l:dFunc = {'type': 'g', 'name': l:sKey, 'func': function(l:sFullName)}
        let l:dExport[l:sFunction] = l:dFunc 
    endfor

    return l:dExport
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#viml#source is loading ...'
function! class#viml#source#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#viml#source#test(...) abort "{{{
    let l:pScriptFile = expand('%:p')
    let l:obj = class#viml#source#new(l:pScriptFile)
    :LOG 'script: ' . l:pScriptFile
    let l:sid = l:obj.SID()
    :LOG 'SID=' . l:sid
    return 0
endfunction "}}}
