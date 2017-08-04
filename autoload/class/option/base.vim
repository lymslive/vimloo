" Class: class#option#base
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-12
" Modify: 2017-08-04

" BASIC:
let s:class = class#old()
let s:class._name_ = 'class#option#base'
let s:class._version_ = 1

let s:class.Char = ''
let s:class.Name = ''
let s:class.Desc = ''

function! class#option#base#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#option#base#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#option#base#ctor(this, ...) abort "{{{
    if a:0 < 3
        echoerr '[class#option#base] expcet 3 arguments: (Char, Name, Desc)'
        return
    endif

    let a:this.Char = a:1
    let a:this.Name = a:2
    let a:this.Desc = a:3
endfunction "}}}

" OLD:
function! class#option#base#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" STRING: -c, --Name    Desc
" a:1, padding Name to this length, to make Desc align right 
function! s:class.string(...) dict abort "{{{
    let l:sRet = self.DescName()

    if a:0 > 0 && a:1 > 0
        let l:iPadding = a:1 - len(self.Name)
        if l:iPadding > 0
            let l:sRet .= repeat(' ', l:iPadding)
        endif
    endif

    let l:sRet .= self.Desc

    return l:sRet
endfunction "}}}

" DescName: 
function! s:class.DescName() dict abort "{{{
    if self.Name ==# '-'
        let l:sRet = '-'
    elseif self.Name ==# '--'
        let l:sRet = '--'
    else
        let l:sRet = '-' . self.Char . ', --' . self.Name
    endif
    return l:sRet
endfunction "}}}

function! s:class.number() dict abort "{{{
    return self._version_
endfunction "}}}

" LOAD:
function! class#option#base#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#option#base#test() abort "{{{
    return 1
endfunction "}}}
