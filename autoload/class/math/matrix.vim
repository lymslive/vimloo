" Class: class#math#matrix
" Author: lymslive
" Description: matrix object, using screen coordinate
" Create: 2017-06-30
" Modify: 2017-07-05

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#math#matrix'
let s:class._version_ = 1

" matrix data is in size of (rows * cols) 
let s:class.rows = 0
let s:class.cols = 0
let s:class.data = []

function! class#math#matrix#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: matrix#new(rows, cols)
function! class#math#matrix#new(...) abort "{{{
    if a:0 < 2 || type(a:1) != type(0) || type(a:2) != type(0)
        :ELOG 'useage: matrix#new(rows, cols)'
        return v:none
    endif
    
    if a:1 < 0 || a:2 < 0
        :ELOG 'the matrix size(rows or cols) cannot less than zero'
        return v:none
    endif

    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#math#matrix#ctor(this, rows, cols) abort "{{{
    " let l:Suctor = s:class._suctor_()
    " call l:Suctor(a:this)
    let a:this.rows = a:rows
    let a:this.cols = a:cols
    let a:this.data = []
endfunction "}}}

" ISOBJECT:
function! class#math#matrix#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Fill: fill the matrix all with the same value
function! s:class.Fill(value) dict abort "{{{
    let self.data = []
    if self.rows == 0 || self.cols == 0
        return self
    endif

    for l:idx in range(self.rows)
        let l:row = repeat([a:value], self.cols)
        call add(self.data, l:row)
    endfor

    return self
endfunction "}}}

" Zeros: 
function! s:class.Zeros() dict abort "{{{
    return self.Fill(0)
endfunction "}}}
" Ones: 
function! s:class.Ones() dict abort "{{{
    return self.Fill(1)
endfunction "}}}

" ways to get the matrix data, notice the matrix data maybe large
" ReferList: share the data
function! s:class.ReferList() dict abort "{{{
    return self.data
endfunction "}}}
" MoveList: steal the data, the object invalid after then
function! s:class.MoveList() dict abort "{{{
    let l:data = self.data
    self.data = []
    self.rows = 0
    self.cols = 0
    return l:data
endfunction "}}}
" CopyList: 
function! s:class.CopyList() dict abort "{{{
    return deepcopy(self.data)
endfunction "}}}
" SpanList: convert 2D matrix to a liner list
function! s:class.SpanList(...) dict abort "{{{
    if a:0 > 0 && !empty(a:1)
        return self.CSPanList()
    endif

    let l:list = []
    for l:idx in range(self.rows)
        call append(l:list, self.data[l:idx])
    endfor

    return l:list
endfunction "}}}
" CSPanList: also linear list, but colum first
function! s:class.CSPanList() dict abort "{{{
    let l:list = []
    for l:cIdx in range(self.cols)
        for l:rIdx in range(self.rows)
            call add(l:list, self.data[l:rIdx][l:cIdx])
        endfor
    endfor
    return l:list
endfunction "}}}

" list: default to ReferList()
function! s:class.list() dict abort "{{{
    return self.ReferList()
endfunction "}}}

" get: 
function! s:class.get(row, col) dict abort "{{{
    return self.data[a:row][a:col]
endfunction "}}}
" set: 
function! s:class.set(row, col, val) dict abort "{{{
    self.data[a:row][a:col] = a:val
endfunction "}}}

" raw: build and return a raw matrix data, or nested list
" global function, not create matrix object
" row * col matrix, with each cell init value with a:1 (default 0)
function! class#math#matrix#raw(row, col, ...) abort "{{{
    let l:val = get(a:000, 0, 0)
    let l:mt = class#math#matrix#new(a:row, a:col)
    call l:mt.Fill(l:val)
    return l:mt.data
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#math#matrix is loading ...'
function! class#math#matrix#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#math#matrix#test(...) abort "{{{
    return 0
endfunction "}}}
