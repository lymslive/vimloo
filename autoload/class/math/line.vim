" Class: class#math#line
" Author: lymslive
" Description: a line object with two point ends
" Create: 2017-06-30
" Modify: 2017-06-30

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#math#line'
let s:class._version_ = 1

let s:class.from = {}
let s:class.to = {}

function! class#math#line#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#math#line#new(...) abort "{{{
    if a:0 < 2
        :ELOG 'please new line(pt1, pt2)'
        return v:none
    endif

    if !class#math#point#isobject(a:1)
        :ELOG 'on #new line(pt1, pt2), argument pt1 is not a point'
        return v:none
    endif

    if !class#math#point#isobject(a:2)
        :ELOG 'on #new line(pt1, pt2), argument pt2 is not a point'
        return v:none
    endif

    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#math#line#ctor(this, from, to) abort "{{{
    " let l:Suctor = s:class._suctor_()
    " call l:Suctor(a:this)
    let a:this.from = a:from
    let a:this.to = a:to
endfunction "}}}

" ISOBJECT:
function! class#math#line#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Distance: 
function! s:class.Distance() dict abort "{{{
    if self.from.x == self.to.x
        return abs(self.from.y - self.to.y)
    elseif self.from.y == self.to.y
        return abs(self.from.x - self.to.x)
    else 
        return sqrt(pow(self.from.x - self.to.x, 2) + pow(self.from.y - self.to.y, 2))
    endif
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#math#line is loading ...'
function! class#math#line#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#math#line#test(...) abort "{{{
    return 0
endfunction "}}}
