" Class: class#option#pairs
" Author: lymslive
" Description: option with argument
" Create: 2017-02-13
" Modify: 2017-02-13

" BASIC:
let s:class = class#option#base#old()
let s:class._name_ = 'class#option#pairs'
let s:class._version_ = 1

" the argument for this option
let s:Argument = ''
" default value, if not provided, it's argument is must required
let s:class.Default = ''

function! class#option#pairs#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR: 4 arguments
function! class#option#pairs#ctor(this, argv) abort "{{{
    let l:Suctor = a:this._suctor_()
    call l:Suctor(a:this, [0:2])
    let l:class.Default = argv[3]
endfunction "}}}

" NEW:
function! class#option#pairs#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" OLD:
function! class#option#pairs#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" Must: 
function! s:class.Must() dict abort "{{{
    return empty(self.Default)
endfunction "}}}

" Value: 
" the value of argument for this option
function! s:class.Value() dict abort "{{{
    if !empty(self.Argument)
        return self.Argument
    else
        return self.Default
    endif
endfunction "}}}

" Has: does provid this option?
function! s:class.Has() dict abort "{{{
    return !empty(slef.Argument)
endfunction "}}}

" LOAD:
function! class#option#pairs#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#option#pairs#test() abort "{{{
    return 1
endfunction "}}}
