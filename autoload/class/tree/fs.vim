" Class: class#tree#fs
" Author: lymslive
" Description: file system
" Create: 2017-08-13
" Modify: 2017-08-13

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#tree#fs'
let s:class._version_ = 1

let s:class.root = class#new()

function! class#tree#fs#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#tree#fs#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#tree#fs#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call call(l:Suctor, extend([a:this], a:000))
endfunction "}}}

" ISOBJECT:
function! class#tree#fs#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" INSTANCE:
" let s:instance = {}
function! class#tree#fs#instance() abort "{{{
    if !exists('s:instance')
        let s:instance = class#new(s:class)
    endif
    return s:instance
endfunction "}}}

" get: return a file object from full path string
function! s:class.get(path) dict abort "{{{
    let l:rtp = class#less#rtp#export()
    if !l:rtp.IsAbsolute(a:path)
        return {}
    endif

    let l:lsPath = split(a:path, l:rtp.slash)
    let l:jFile = self.root
    for l:sName in l:lsPath
        let l:jFile = get(l:jFile.children, l:sName, {})
        if empty(l:jFile)
            break
        endif
    endfor

    return l:jFile
endfunction "}}}

function! s:class.add(path) dict abort "{{{
    let l:rtp = class#less#rtp#export()
    if !l:rtp.IsAbsolute(a:path)
        return self
    endif

    let l:lsPath = split(a:path, l:rtp.slash)
    let l:parent = self.root
    for l:idx in len(l:lsPath)
        let l:sName = l:lsPath[l:idx]
        if !has_key(l:parent.children, l:sName)
            let l:child = class#tree#file#new()
            let l:subPath = l:rtp.MakePath(l:lsPath[0 : l:idx])
            let l:subPath = l:rtp.slash . l:subPath
            call l:child.ReadNode(l:subPath)
            call l:parent.AddChild(l:child)
        endif
        let l:parent = l:parent.children[l:sName]
    endfor

    return l:parent
endfunction "}}}

" LOAD:
let s:load = 1
function! class#tree#fs#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#tree#fs#test(...) abort "{{{
    let l:obj = class#tree#fs#new()
    call class#echo(l:obj)
endfunction "}}}
