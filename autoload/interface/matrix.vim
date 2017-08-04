" Class: interface#matrix
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-02
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = interface#list#old()
let s:class._name_ = 'interface#matrix'
let s:class._version_ = 1

function! interface#matrix#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! interface#matrix#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! interface#matrix#ctor(this, ...) abort "{{{
    if a:0 == 0
        let a:this.matrix_ = []
    elseif type(a:1) == v:t_list
        let a:this.matrix_ = a:1
    else
        : ELOG '[interface#heap#ctor] expect a list variable'
    endif
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:this.matrix_)
endfunction "}}}

" MERGE:
function! interface#matrix#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" ISOBJECT:
function! interface#matrix#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" matrix: 
function! s:class.matrix() dict abort "{{{
    if has_key(self, 'matrix_')
        return self.matrix_
    else
        return self.list()
    endif
endfunction "}}}

" size: 
function! s:class.size() dict abort "{{{
    let l:matrix = self.matrix()
    let l:rows = len(l:matrix)
    if l:rows == 0
        return [0, 0]
    else
        let l:cols = len(l:matrix[0])
        return [l:rows, l:cols]
    endif
endfunction "}}}

" empty: 
function! s:class.empty() dict abort "{{{
    let l:size = self.size()
    if l:size[0] == 0 || l:size[1] == 0
        return v:true
    else
        return v:false
    endif
endfunction "}}}

" valid: test nonempty and each row has the same cols
function! s:class.valid() dict abort "{{{
    let l:matrix = self.matrix()
    let l:rows = len(l:matrix)
    if l:rows <= 0
        return v:false
    endif

    let l:cols = len(l:matrix[0])
    if l:cols <= 0
        return v:false
    endif

    for l:row in l:matrix
        if len(l:row) != l:cols
            return v:false
        endif
    endfor

    return v:true
endfunction "}}}

" string: 
function! s:class.string() dict abort "{{{
    let l:matrix = self.matrix()
    let l:lsOutput = []
    for l:row in l:matrix
        call add(l:lsOutput, string(l:row))
    endfor
    return join(l:lsOutput, "\n")
endfunction "}}}

" get: 
function! s:class.get(...) dict abort "{{{
    if a:0 == 1
        let l:size = self.size()
        let l:cols = l:size[1]
        let l:row = a:1 / l:cols
        let l:col = a:1 % l:cols
    elseif a:0 == 2
        let l:row = a:1
        let l:col = a:2
    else
        : ELOG '[interface#matrix.get] expect one or two index'
        return v:none
    endif

    let l:matrix = self.matrix()
    return l:matrix[l:row][l:col]
endfunction "}}}

" set: 
function! s:class.set(row, col, val) dict abort "{{{
    let l:matrix = self.matrix()
    let l:size = self.size()
    let l:cols = l:size[1]
    if a:col ==# '-'
        let l:index = a:row
        let l:row = l:index / l:cols
        let l:col = l:index % l:cols
    else
        let l:row = a:row
        let l:col = a:col
    endif
    let l:matrix[l:row][l:col] = a:val
endfunction "}}}

" flat: 
function! s:class.flat() dict abort "{{{
    let l:matrix = self.matrix()
    let l:vector = []
    for l:row in l:matrix
        call extend(l:vector, l:row)
    endfor
    return l:verctor
endfunction "}}}

" plus: 
function! s:class.plus(that) dict abort "{{{
    " code
endfunction "}}}

" minus: 
function! s:class.minus(that) dict abort "{{{
    " code
endfunction "}}}

" multiply: 
function! s:class.multiply(that) dict abort "{{{
    " code
endfunction "}}}

" mmultiply: as math matrix multiply
function! s:class.mmultiply(that) dict abort "{{{
    " code
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 interface#matrix is loading ...'
function! interface#matrix#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! interface#matrix#test(...) abort "{{{
    return 0
endfunction "}}}
