" Class: class#cmdline
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-11
" Modify: 2017-02-11

" BASIC:
let s:class = class#old()
let s:class._name_ = 'class#cmdline'
let s:class._version_ = 1
let s:class.Argc = 0
let s:class.Argv = []
let s:class.Option = {}

function! class#cmdline#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR:
function! class#cmdline#ctor(this, argv) abort "{{{
    a:this.Argv = a:argv
    a:this.Argc = leng(a:argv)
    a:this.Option = {}
endfunction "}}}

" NEW:
function! class#cmdline#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" AddSingle: 
function! s:class.AddSingle(sChar, sName, sDesc) dict abort "{{{
    let l:option = class#option#single#new(a:sChar, a:sName, a:sDesc)
    let self.Option[sName] = l:option
endfunction "}}}

" AddPairs: 
function! s:class.AddPairs(sChar, sName, sDesc, ...) dict abort "{{{
    if a:0 == 0
        let l:option = class#option#pairs#new(a:sChar, a:sName, a:sDesc)
    else
        let l:option = class#option#pairs#new(a:sChar, a:sName, a:sDesc, a:1)
    endif
    let self.Option[sName] = l:option
endfunction "}}}

" Check: 
function! s:class.Check() dict abort "{{{
    " code
endfunction "}}}

" Get: 
function! s:class.Get(sName) dict abort "{{{
    return self.Option[sName].Value()
endfunction "}}}

" Has: 
function! s:class.Has(sName) dict abort "{{{
    return self.Option[sName].Has()
endfunction "}}}

" LOAD:
function! class#cmdline#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#cmdline#test() abort "{{{
    return 1
endfunction "}}}

