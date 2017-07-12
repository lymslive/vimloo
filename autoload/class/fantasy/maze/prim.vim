" Class: class#fantasy#maze#prim
" Author: lymslive
" Description: maze generation by Randomized Prim's algorithm
"   refer to: https://en.wikipedia.org/wiki/Maze_generation_algorithm
" Create: 2017-07-11
" Modify: 2017-07-11

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#fantasy#maze#base#old()
let s:class._name_ = 'class#fantasy#maze#prim'
let s:class._version_ = 1

function! class#fantasy#maze#prim#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#fantasy#maze#prim#new(...) abort "{{{
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
function! class#fantasy#maze#prim#ctor(this, height, width) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:height, a:width)
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#prim#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Reset: 
function! s:class.Reset() abort "{{{
    call self.GridWall()

    return self
endfunction "}}}

" Generate: 
function! s:class.Generate() dict abort "{{{
    call self.Reset()

    " randomly select a init room, and its walls
    let l:random = class#math#random#new()
    let l:row = l:random.Rand(self.height)
    let l:col = l:random.Rand(self.width)
    let l:room = [l:row, l:col]

    " :DLOG 'init room = ' . string(l:room)

    " call self.MarkRoom(l:room, self.VISIT)
    let self.room[l:row][l:col] = self.VISIT
    let l:lsWall = self.WallOfRoom(l:room)

    for l:wall in l:lsWall
        " :DLOG 'init l:wall = ' . string(l:wall)
        if l:wall[0] == 'h'
            let self.hwall[l:wall[1]][l:wall[2]] = self.VISIT
        elseif l:wall[0] == 'v'
            let self.vwall[l:wall[1]][l:wall[2]] = self.VISIT
        else
            :ELOG 'error type of wall'
            return v:none
        endif
    endfor

    " :DLOG 'begin to expand maze room'
    while !empty(l:lsWall)
        let l:index = l:random.Rand(len(l:lsWall))
        " let l:wall = l:lsWall[l:index]
        let l:wall = remove(l:lsWall, l:index)
        let l:row = l:wall[1]
        let l:col = l:wall[2]

        " :DLOG 'random l:wall = ' . string(l:wall)
        let l:lsMoreWall = []
        " randomly visit neighbour
        if l:wall[0] == 'h'
            if self.room[l:row][l:col] != self.VISIT
                let self.room[l:row][l:col] = self.VISIT
                let self.hwall[l:row][l:col] = self.PASSAGE
                " :DLOG '> visit neighbour room: ' . string([l:row, l:col])
                let l:lsMoreWall = self.WallOfRoom([l:row, l:col])
            elseif self.room[l:row+1][l:col] != self.VISIT
                let self.room[l:row+1][l:col] = self.VISIT
                let self.hwall[l:row][l:col] = self.PASSAGE
                " :DLOG '> visit neighbour room: ' . string([l:row+1, l:col])
                let l:lsMoreWall = self.WallOfRoom([l:row+1, l:col])
            endif
        elseif l:wall[0] == 'v'
            if self.room[l:row][l:col] != self.VISIT
                let self.room[l:row][l:col] = self.VISIT
                let self.vwall[l:row][l:col] = self.PASSAGE
                " :DLOG '> visit neighbour room: ' . string([l:row, l:col])
                let l:lsMoreWall = self.WallOfRoom([l:row, l:col])
            elseif self.room[l:row][l:col+1] != self.VISIT
                let self.room[l:row][l:col+1] = self.VISIT
                let self.vwall[l:row][l:col] = self.PASSAGE
                " :DLOG '> visit neighbour room: ' . string([l:row, l:col+1])
                let l:lsMoreWall = self.WallOfRoom([l:row, l:col+1])
            endif
        else
            :ELOG 'error type of wall'
            return v:none
        endif

        for l:more in l:lsMoreWall
            " :DLOG '> neighbour l:more = ' . string(l:more)
            if l:more == l:wall
                continue
            endif
            if l:more[0] == 'h'
                if self.hwall[l:more[1]][l:more[2]] == self.PASSAGE
                            \ || self.hwall[l:more[1]][l:more[2]] == self.VISIT
                    continue
                else
                    call add(l:lsWall, l:more)
                    let self.hwall[l:more[1]][l:more[2]] = self.VISIT
                endif
            elseif l:more[0] == 'v'
                if self.vwall[l:more[1]][l:more[2]] == self.PASSAGE
                            \ || self.vwall[l:more[1]][l:more[2]] == self.VISIT
                    continue
                else
                    call add(l:lsWall, l:more)
                    let self.vwall[l:more[1]][l:more[2]] = self.VISIT
                endif
            endif
        endfor
    endwhile

    call self.AfterGenerate()
    return self
endfunction "}}}

" AfterGenerate: 
function! s:class.AfterGenerate() dict abort "{{{
    " remove room set marker
    for l:row in range(self.height)
        for l:col in range(self.width)
            let self.room[l:row][l:col] = self.VALID
        endfor
    endfor

    for l:row in range(self.height-1)
        for l:col in range(self.width)
            if self.hwall[l:row][l:col] != self.PASSAGE
                let self.hwall[l:row][l:col] = self.BLOCKED
            endif
        endfor
    endfor
    for l:row in range(self.height)
        for l:col in range(self.width-1)
            if self.vwall[l:row][l:col] != self.PASSAGE
                let self.vwall[l:row][l:col] = self.BLOCKED
            endif
        endfor
    endfor

    return self
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#fantasy#maze#prim is loading ...'
function! class#fantasy#maze#prim#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#fantasy#maze#prim#test(...) abort "{{{
    let l:maze = class#fantasy#maze#prim#new(10, 10)
    call l:maze.Generate()
    let l:lsString = l:maze.DrawMap()
    for l:str in l:lsString
        echo l:str
    endfor
    return 0
endfunction "}}}
