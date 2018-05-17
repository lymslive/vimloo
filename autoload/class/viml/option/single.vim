" Class: class#viml#option#single
" Author: lymslive
" Description: option without argument
" Create: 2017-02-12
" Modify: 2017-08-05

" BASIC:
let s:class = class#viml#option#base#old()
let s:class._name_ = 'class#viml#option#single'
let s:class._version_ = 1

" dose this option is set? // v:false
let s:class.Set = v:false

function! class#viml#option#single#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#viml#option#single#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR: 3 arguments
function! class#viml#option#single#ctor(this, ...) abort "{{{
    if a:0 < 3
        echoerr '[class#viml#option#single] expcet 3 arguments: (Char, Name, Desc)'
        return
    endif
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:1, a:2, a:3)
endfunction "}}}

" OLD:
function! class#viml#option#single#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#viml#option#single#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
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

" UnSet: 
function! s:class.UnSet() dict abort "{{{
    let self.Set = v:false
endfunction "}}}

" STRING: -c, --Name    [0]Desc
" a:1, padding Name to this length, to make Desc align right 
" the [0] before Desc show this option need no more argument
function! s:class.string(...) dict abort "{{{
    let l:sRet = self.DescName()

    if self.Name ==# '-'
        let l:sRet .= '(single dash) ' . self.Desc
        return l:sRet
    elseif self.Name ==# '--'
        let l:sRet .= '(double dash) ' . self.Desc
        return l:sRet
    endif

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
function! class#viml#option#single#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#viml#option#single#test() abort "{{{
    return 1
endfunction "}}}
