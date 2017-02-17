" Class: class#option#single
" Author: lymslive
" Description: option without argument
" Create: 2017-02-12
" Modify: 2017-02-12

" BASIC:
let s:class = class#option#base#old()
let s:class._name_ = 'class#option#single'
let s:class._version_ = 1

" dose this option is set?
let s:class.Set = v:false

function! class#option#single#class() abort "{{{
    return s:class
endfunction "}}}

" CTOR:
function! class#option#single#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" NEW:
function! class#option#single#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" OLD:
function! class#option#single#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#option#single#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Has: 
function! s:class.Has() dict abort "{{{
    return self.Set
endfunction "}}}

" Value: this type option is just boolean, set or unset
function! s:class.Value() dict abort "{{{
    if self.Has()
        return 1
    else
        return 0
    endif
endfunction "}}}

" SetValue: 
function! s:class.SetValue() dict abort "{{{
    let self.Set = v:true
endfunction "}}}

" STRING: -c, --Name    [0]Desc
" a:1, padding Name to this length, to make Desc align right 
" the [0] before Desc show this option need no more argument
function! s:class.string(...) dict abort "{{{
    let l:sRet = '-' . self.Char . ', --' . self.Name

    if a:0 > 0 && a:1 > 0
        let l:iPadding = a:1 - len(self.Name)
        if l:iPadding > 0
            let l:sRet .= repeat(' ', l:iPadding)
        endif
    endif

    let l:sRet .= '  [0]' . self.Desc

    return l:sRet
endfunction "}}}

" LOAD:
function! class#option#single#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#option#single#test() abort "{{{
    return 1
endfunction "}}}
