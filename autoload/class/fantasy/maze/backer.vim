" Class: class#fantasy#maze#backer
" Author: lymslive
" Description: maze generation with recursive backtracker algorithm
"   refer to: https://en.wikipedia.org/wiki/Maze_generation_algorithm
" Create: 2017-06-29
" Modify: 2017-07-05

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#fantasy#maze#base#old()
let s:class._name_ = 'class#fantasy#maze#backer'
let s:class._version_ = 1

" mark visited room
let s:class.VISIT = 2
call interface#stack#merge(s:class)

function! class#fantasy#maze#backer#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(height, width)
function! class#fantasy#maze#backer#new(...) abort "{{{
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
function! class#fantasy#maze#backer#ctor(this, height, width) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:height, a:width)
endfunction "}}}

" Reset: init a full blocked maze
function! s:class.Reset() abort "{{{
    let self.room = class#math#matrix#raw(self.height, self.width, self.VALID)
    let self.hwall = class#math#matrix#raw(self.height-1, self.width, self.BLOCKED)
    let self.vwall = class#math#matrix#raw(self.height, self.width-1, self.BLOCKED)

    let self._stack = []
    let self._random = class#math#random#new()

    return self
endfunction "}}}

" stack: 
function! s:class.stack() dict abort "{{{
    return self._stack
endfunction "}}}

" Backtracker: 
function! s:class.Backtracker() abort "{{{
    let l:x = self._random.Rand(self.width)
    let l:y = self._random.Rand(self.height)
    let l:cell = class#math#point#new(l:x, l:y)
    call self.MarkVisit(l:cell)
    call self.push(l:cell)

    while len(self.stack()) > 0
        let l:neighbour = self.VisitNeighbour(l:cell)
        if empty(l:neighbour)
            let l:cell = self.pop()
        else
            call self.MarkVisit(l:neighbour)
            call self.RemoveWall(l:cell, l:neighbour)
            call self.push(l:neighbour)
            let l:cell = l:neighbour
        endif
    endwhile

    return self
endfunction "}}}

" MarkVisit: 
function! s:class.MarkVisit(cell) dict abort "{{{
    let self.room[a:cell.y][a:cell.x] = s:class.VISIT
    return self
endfunction "}}}

" IsVisit: 
function! s:class.IsVisit(cell) dict abort "{{{
    return self.room[a:cell.y][a:cell.x] == s:class.VISIT
endfunction "}}}

" VisitNeighbour: 
function! s:class.VisitNeighbour(cell) dict abort "{{{
    let l:lsNeighbour = []
    let l:ptLow = class#math#point#new(0, 0)
    let l:ptHigh = class#math#point#new(self.width - 1, self.height - 1)

    let l:cell = a:cell.TouchLeft()
    if l:cell.IsBound(l:ptLow, l:ptHigh) && !self.IsVisit(l:cell)
        call add(l:lsNeighbour, l:cell)
    endif

    let l:cell = a:cell.TouchRight()
    if l:cell.IsBound(l:ptLow, l:ptHigh) && !self.IsVisit(l:cell)
        call add(l:lsNeighbour, l:cell)
    endif

    let l:cell = a:cell.TouchDown()
    if l:cell.IsBound(l:ptLow, l:ptHigh) && !self.IsVisit(l:cell)
        call add(l:lsNeighbour, l:cell)
    endif

    let l:cell = a:cell.TouchUp()
    if l:cell.IsBound(l:ptLow, l:ptHigh) && !self.IsVisit(l:cell)
        call add(l:lsNeighbour, l:cell)
    endif

    let l:iCount = len(l:lsNeighbour)
    if l:iCount <= 0
        return {}
    else
        let l:idx = self._random.Rand(l:iCount)
        return get(l:lsNeighbour, l:idx, {})
    endif
endfunction "}}}

" RemoveWall: 
function! s:class.RemoveWall(cell, neighbour) dict abort "{{{
    if a:cell.x == a:neighbour.x
        if abs(a:cell.y - a:neighbour.y) != 1
            :ELOG 'can only remove wall between neighbours'
            return
        endif
        let l:idx = min([a:cell.y, a:neighbour.y])
        let self.hwall[l:idx][a:cell.x] = s:class.PASSAGE
    elseif a:cell.y == a:neighbour.y
        if abs(a:cell.x - a:neighbour.x) != 1
            :ELOG 'can only remove wall between neighbours'
            return
        endif
        let l:idx = min([a:cell.x, a:neighbour.x])
        let self.vwall[a:cell.y][l:idx] = s:class.PASSAGE
    else
        :ELOG 'can only remove wall between neighbours'
    endif
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#backer#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#fantasy#maze#backer is loading ...'
function! class#fantasy#maze#backer#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#fantasy#maze#backer#test(...) abort "{{{
    let l:maze = class#fantasy#maze#backer#new(10, 10)
    call l:maze.Reset()
    call l:maze.Backtracker()
    let l:lsString = l:maze.DrawMap()
    for l:str in l:lsString
        echo l:str
    endfor
    return 0
endfunction "}}}