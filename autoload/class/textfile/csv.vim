" Class: class#textfile#csv
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-06
" Modify: 2017-08-06

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#textfile#old()
let s:class._name_ = 'class#textfile#csv'
let s:class._version_ = 1

let s:class.headNum = 0
let s:class.headLine = []
let s:class.cell = []

let s:class._master_ = ['class#more#matrix']

function! class#textfile#csv#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#textfile#csv#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#textfile#csv#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this)
endfunction "}}}

" ISOBJECT:
function! class#textfile#csv#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" matrix: 
function! s:class.matrix() dict abort "{{{
    return self.cell
endfunction "}}}

" GetCell: 
function! s:class.GetCell(row, col) dict abort "{{{
    " code
endfunction "}}}

" SetCell: 
function! s:class.SetCell(row, col, val) dict abort "{{{
    " code
endfunction "}}}

" USE:
function! class#textfile#csv#use(...) abort "{{{
    return class#use(s:class, a:000)
endfunction "}}}

" LOAD:
let s:load = 1
function! class#textfile#csv#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#textfile#csv#test(...) abort "{{{
    let l:obj = class#textfile#csv#new()
    call l:obj.disp()
    return 0
endfunction "}}}
