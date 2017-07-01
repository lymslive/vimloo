" Class: class#math#random
" Author: lymslive
" Description: random number generator, by simple LCG
" Create: 2017-06-29
" Modify: 2017-06-30

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" LCG: x(n+1) = (a * x(n) + c) % m
let s:A = 16807
let s:C = 1
" The max int in vimL 2^31 - 1
let s:M = 2147483647
let s:X = localtime()

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#math#random'
let s:class._version_ = 1

let s:class.seed = s:X

function! class#math#random#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#math#random#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#math#random#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this)
    if a:0 > 0
        call a:this.First(a:1)
    else
        call a:this.First()
    endif
endfunction "}}}

" First: reset the rand seed
function! s:class.First(...) dict abort "{{{
    if a:0 < 1 || empty(a:1)
        let self.seed = localtime()
    else
        let self.seed = a:1
    endif
    return self.Next()
endfunction "}}}

" Next: 
function! s:class.Next() dict abort "{{{
    let self.seed = (self.seed * s:A + s:C) % s:M
    if self.seed < 0
        let self.seed = -self.seed
    endif
    return self.seed
endfunction "}}}

" Rand: 
function! s:class.Rand(iMax) dict abort "{{{
    let l:iRand = self.Next()
    return l:iRand % a:iMax
endfunction "}}}

" ISOBJECT:
function! class#math#random#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" TODO: optimize the default seed, other by simple localtime()

" LOAD:
let s:load = 1
:DLOG '-1 class#math#random is loading ...'
function! class#math#random#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#math#random#test(...) abort "{{{
    let l:rander = class#math#random#new()
    " call l:rander.First(localtime())
    for l:idx in range(20)
        echo l:rander.Rand(100)
    endfor
    return 0
endfunction "}}}
