" Class: class#fantasy#maze#kruskal
" Author: lymslive
" Description: maze generation by Randomized Kruskal's algorithm
"   refer to: https://en.wikipedia.org/wiki/Maze_generation_algorithm
" Create: 2017-07-06
" Modify: 2017-07-06

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#fantasy#maze#kruskal'
let s:class._version_ = 1

function! class#fantasy#maze#kruskal#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#fantasy#maze#kruskal#new(...) abort "{{{
    if a:0 < 2
        :ELOG 'ctor need height & width'
        return 0
    endif

    if type(a:1) != type(0) || type(a:2) != type(0) || a:1 <= 0 || a:2 <= 0
        :ELOG 'invalid maze height and width'
        return 0
    endif

    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#fantasy#maze#kruskal#ctor(this, height, width) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:height, a:width)
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#kruskal#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#fantasy#maze#kruskal is loading ...'
function! class#fantasy#maze#kruskal#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#fantasy#maze#kruskal#test(...) abort "{{{
    return 0
endfunction "}}}
