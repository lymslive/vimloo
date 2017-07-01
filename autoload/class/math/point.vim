" Class: class#math#point
" Author: lymslive
" Description: a point(x, y) object
" Create: 2017-06-30
" Modify: 2017-06-30

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#math#point'
let s:class._version_ = 1

let s:class.x = 0
let s:class.y = 0

function! class#math#point#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#math#point#new(...) abort "{{{
    if a:0 < 2 || type(a:1) != type(0) || type(a:2) != type(0)
        :ELOG 'please new point(x,y)'
        return v:none
    endif

    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#math#point#ctor(this, x, y) abort "{{{
    " let l:Suctor = s:class._suctor_()
    " call l:Suctor(a:this)
    let a:this.x = a:x
    let a:this.y = a:y
endfunction "}}}

" ISOBJECT:
function! class#math#point#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" MoveLeft: 
function! s:class.MoveLeft(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    let self.x -= l:dist
    return self
endfunction "}}}
" MoveRight:
function! s:class.MoveRight(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    let self.x += l:dist
    return self
endfunction "}}}
" MoveDown: 
function! s:class.MoveDown(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    let self.y -= l:dist
    return self
endfunction "}}}
" MoveUp: 
function! s:class.MoveUp(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    let self.y += l:dist
    return self
endfunction "}}}
" Move: 
function! s:class.Move(x, y) dict abort "{{{
    let self.x = self.x + a:x
    let self.y = self.y + a:y
    return self
endfunction "}}}

" TouchLeft: 
function! s:class.TouchLeft(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    return class#math#point#new(self.x - l:dist, self.y)
endfunction "}}}
" TouchRight: 
function! s:class.TouchRight(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    return class#math#point#new(self.x + l:dist, self.y)
endfunction "}}}
" TouchDown: 
function! s:class.TouchDown(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    return class#math#point#new(self.x, self.y - l:dist)
endfunction "}}}
" TouchUp: 
function! s:class.TouchUp(...) dict abort "{{{
    let l:dist = get(a:000, 0, 1)
    return class#math#point#new(self.x, self.y + l:dist)
endfunction "}}}
" Touch: 
function! s:class.Touch(x, y) dict abort "{{{
    return class#math#point#new(self.x + a:x, self.y + a:y)
endfunction "}}}

" IsBound: test if this point is bound in some range
function! s:class.IsBound(...) dict abort "{{{
    if a:0 == 2
        let l:pt1 = a:1
        let l:pt2 = a:2
        return (self.x >= l:pt1.x && self.x <= l:pt2 || self.x <= l:pt1.x && self.x >= l:pt2.x)
                    \ (self.y >= l:pt1.y && self.y <= l:pt2.y || self.y <= l:pt1.y && self.y >= l:pt2.y)
    elseif a:0 == 4
        let l:x1 = a:1
        let l:x2 = a:2
        let l:y1 = a:3
        let l:y2 = a:4
        return (self.x >= l:x1 && self.x <= l:x2 || self.x <= l:x1 && self.x >= l:x2)
                    \ (self.y >= l:y1 && self.y <= l:y2 || self.y <= l:y1 && self.y >= l:y2)
    endif
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#math#point is loading ...'
function! class#math#point#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#math#point#test(...) abort "{{{
    return 0
endfunction "}}}
