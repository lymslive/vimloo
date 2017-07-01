" Class: class#fantasy#maze#gener
" Author: lymslive
" Description: maze generation
"   algorithm see: https://en.wikipedia.org/wiki/Maze_generation_algorithm
" Create: 2017-06-29
" Modify: 2017-06-29

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#fantasy#maze#base#old()
let s:class._name_ = 'class#fantasy#maze#gener'
let s:class._version_ = 1

" mark visited room
let s:call.VISIT = 2

function! class#fantasy#maze#gener#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(height, width)
function! class#fantasy#maze#gener#new(...) abort "{{{
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
function! class#fantasy#maze#gener#ctor(this, height, width) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:height, a:width)
endfunction "}}}

" Reset: init a full blocked maze
function! s:class.#Reset() abort "{{{
    let self.room = []
    for l:row_idx in range(self.height)
        let l:row = repeat([self.VALID], self.width)
        call add(self.room, l:row)
    endfor

    let self.hwall = []
    for l:row_idx in range(self.height - 1)
        let l:row = repeat([self.BLOCKED], self.width -1)
        call add(self.hwall, l:row)
    endfor

    let self.vwall = deepcopy(self.hwall)

    return self
endfunction "}}}

" Backtracker: 
function! s:class.#Backtracker() abort "{{{
    " code
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#gener#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#fantasy#maze#gener is loading ...'
function! class#fantasy#maze#gener#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#fantasy#maze#gener#test(...) abort "{{{
    return 0
endfunction "}}}
