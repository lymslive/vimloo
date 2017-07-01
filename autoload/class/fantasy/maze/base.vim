" Class: class#fantasy#maze#base
" Author: lymslive
" Description: the basic data structure of maze
" Create: 2017-06-29
" Modify: 2017-06-29

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#fantasy#maze#base'
let s:class._version_ = 1

" the size of maze, cells of room
let s:class.height = 0
let s:class.width = 0

" room is [height * width] matrix
" for normal maze each room is valid space
" default empty room is acceptable
let s:class.room = []
let s:class.VALID = 0
let s:class.SOLID = 1

" wall is [height-1 * width-1] matrix, walls between rooms
" tow matrix walls: horizontal, vertical
let s:class.hwall = []
let s:class.vwall = []
let s:class.PASSAGE = 0
let s:class.BLOCKED = 1
" usally no need to handle the corner
let s:class.CORNER = -1

function! class#fantasy#maze#base#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#fantasy#maze#base#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#fantasy#maze#base#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this)
    let a:this.room = []
    let a:this.hwall = []
    let a:this.vwall =[]

    if a:0 >= 2
        if type(a:1) != type(0) || type(a:2) != type(0) || a:1 <= 0 || a:2 <= 0
            :ELOG 'invalid maze height and width'
            return
        endif
        let a:this.height = a:1
        let a:this.width = a:2
    endif
endfunction "}}}

" OLD:
function! class#fantasy#maze#base#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" SetRoom: 
" not check regular matrix room, trust provided by user
function! s:class.SetRoom(room) abort "{{{
    if empty(a:room)
        let self.room = []
    else
        if type(a:room) == type([])
            let self.room = a:room
        endif
    endif
    return self
endfunction "}}}

" SetWall:
function! s:class.SetRoom(hwall, ...) abort "{{{
    if type(a:hwall) == type([])
        let self.hwall = a:hwall
    endif
    if a:0 >= 1 && type(a:1) == type([])
        let self.vwall = a:1
    else
        let self.vwall = hwall
    endif

    return self
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#base#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#fantasy#maze#base is loading ...'
function! class#fantasy#maze#base#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#fantasy#maze#base#test(...) abort "{{{
    return 0
endfunction "}}}
" Class: class#fantasy#maze#base
" Author: lymslive
" Description: VimL class frame
" Create: 2017-06-29
" Modify: 2017-06-29

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#fantasy#maze#base'
let s:class._version_ = 1

function! class#fantasy#maze#base#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#fantasy#maze#base#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#fantasy#maze#base#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this)
endfunction "}}}

" OLD:
function! class#fantasy#maze#base#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#base#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#fantasy#maze#base is loading ...'
function! class#fantasy#maze#base#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#fantasy#maze#base#test(...) abort "{{{
    return 0
endfunction "}}}
