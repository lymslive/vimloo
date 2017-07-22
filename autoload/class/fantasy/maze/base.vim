" Class: class#fantasy#maze#base
" Author: lymslive
" Description: the basic data structure of maze
" Create: 2017-06-29
" Modify: 2017-07-18

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

" tow matrix walls between rooms: horizontal, vertical
" hwall is [height-1 * width] matrix
" vwall is [height * width-1]
let s:class.hwall = []
let s:class.vwall = []
let s:class.PASSAGE = 0
let s:class.BLOCKED = 1
" usally no need to handle the corner
let s:class.CORNER = -1

" constant for algorithm
" mark visited room
let s:class.VISIT = 2

let s:class.CHAR_CROSS = '+'
let s:class.CHAR_HSIDE = '-'
let s:class.CHAR_VSIDE = '|'

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
    " let l:Suctor = s:class._suctor_()
    " call l:Suctor(a:this)
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
function! s:class.SetWall(hwall, vwall) abort "{{{
    if type(a:hwall) == type([])
        let self.hwall = a:hwall
    endif
    if type(a:vwall) == type([])
        let self.vwall = a:vwall
    endif

    return self
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#base#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" DrawMap: 
" return a list of string to draw
function! s:class.DrawMap(...) dict abort "{{{
    let l:iDefaultWidth = 3
    let l:iDefaultHeight = 2
    let l:iCellHeight = get(a:000, 0, l:iDefaultHeight)
    let l:iCellWidth = get(a:000, 1, l:iDefaultWidth)
    let l:cCross = '+'
    let l:hSide = '-'
    let l:vSide = '|'

    " space matrix
    let l:mtChar = []
    let l:iCharWidth = self.width * l:iCellWidth + self.width + 1
    let l:iCharHeight = self.height * l:iCellHeight + self.height + 1
    for l:line_idx in range(l:iCharHeight)
        let l:row_char = repeat([' '], l:iCharWidth)
        call add(l:mtChar, l:row_char)
    endfor

    " grid box -- outter frame
    let l:mtChar[0] = repeat([l:hSide], l:iCharWidth)
    let l:mtChar[-1] = repeat([l:hSide], l:iCharWidth)
    for l:row_char in l:mtChar
        if l:row_char[0] == l:hSide
            let l:row_char[0] = l:cCross
        else
            let l:row_char[0] = l:vSide
        endif
        if l:row_char[-1] == l:hSide
            let l:row_char[-1] = l:cCross
        else
            let l:row_char[-1] = l:vSide
        endif
    endfor

    for l:j in range(len(self.hwall))
        let l:hwall = self.hwall[l:j]
        let l:hChar_idx = (l:j + 1) * (l:iCellHeight + 1)
        let l:hChar = l:mtChar[l:hChar_idx]
        for l:i in range(len(l:hwall))
            if l:hwall[l:i] == s:class.BLOCKED
                let l:iLeft = l:i * (l:iCellWidth + 1) + 1
                let l:iRigth = (l:i + 1) * (l:iCellWidth + 1)
                for l:k in range(l:iLeft, l:iRigth)
                    if l:hChar[l:k] == l:vSide
                        let l:hChar[l:k] = l:cCross
                    else
                        let l:hChar[l:k] = l:hSide
                    endif
                endfor
                if l:hChar[l:iLeft-1] == l:vSide
                    let l:hChar[l:iLeft-1] = l:cCross
                else
                    let l:hChar[l:iLeft-1] = l:hSide
                endif
            endif
        endfor
    endfor

    for l:j in range(len(self.vwall))
        let l:vwall = self.vwall[l:j]
        for l:i in range(len(l:vwall))
            let l:hIndex = (l:i + 1) * (l:iCellWidth + 1)
            if l:vwall[l:i] == s:class.BLOCKED
                let l:iTop = l:j * (l:iCellHeight + 1) + 1
                let l:iBot = (l:j + 1) * (l:iCellHeight + 1)
                for l:k in range(l:iTop, l:iBot)
                    if l:mtChar[l:k][l:hIndex] == l:hSide
                        let l:mtChar[l:k][l:hIndex] = l:cCross
                    else
                        let l:mtChar[l:k][l:hIndex] = l:vSide
                    endif
                endfor
                if l:mtChar[l:iTop-1][l:hIndex] == l:hSide
                    let l:mtChar[l:iTop-1][l:hIndex] = l:cCross
                endif
            endif
        endfor
    endfor

    let l:lsString = []
    for l:hChar in l:mtChar
        let l:str = join(l:hChar, '')
        call add(l:lsString, l:str)
    endfor
    return l:lsString
endfunction "}}}

" ListOfWall: wall tuple is ['h', row, col] or ['v', row, col]
" span list the hwall and then vwall, row by row
function! s:class.ListOfWall() dict abort "{{{
    let l:list = []

    for l:row in hwall
        let l:row = map(copy(l:row), 'extend(["h"], v:val)')
        call extend(l:list, l:row)
    endfor

    for l:row in vwall
        let l:row = map(copy(l:row), 'extend(["v"], v:val)')
        call extend(l:list, l:row)
    endfor

    return l:list
endfunction "}}}

" WallOfIndex: reindex in range[0, sizeof(hwall) + sizeof(vwall) - 1]
" return a wall tuple
function! s:class.WallOfIndex(index) dict abort "{{{
    let l:iSizeHWall = (self.height-1) * self.width
    let l:iSizeVWall = self.height * (self.width-1)
    if a:index < 0 || a:index >= l:iSizeHWall + l:iSizeVWall
        :ELOG 'beyond index range: ' . a:index
        return []
    endif

    if a:index < l:iSizeHWall
       let l:row = a:index / self.width
       let l:col = a:index % self.width
       return ['h', l:row, l:col]
   else
       let l:index = a:index - l:iSizeHWall
       let l:row = l:index / (self.width - 1)
       let l:col = l:index % (self.width - 1)
       return ['v', l:row, l:col]
    endif
endfunction "}}}

" RoomOfIndex: room tuple is [row, col]
function! s:class.RoomOfIndex(index) dict abort "{{{
    let l:iSizeRoom = self.width * self.height
    if a:index < 0 || a:index >= l:iSizeRoom
        :ELOG 'beyond index range: ' . a:index
        return []
    endif

    let l:row = a:index / self.width
    let l:col = a:index % self.width
    return [l:row, l:col]
endfunction "}}}

" RoomOfWallIndex: get the walls devided by a wall
" return a list of two room item [[row1, col1], [row2, col2]]
function! s:class.RoomOfWallIndex(index) dict abort "{{{
    let l:wall = self.WallOfIndex(a:index)
    if empty(l:wall)
        return []
    endif

    let l:row = l:wall[1]
    let l:col = l:wall[2]

    if l:wall[0] == 'h'
        return [[l:row, l:col], [l:row + 1, l:col]]
    elseif l:wall[0] == 'v'
        return [[l:row, l:col], [l:row, l:col + 1]]
    else
        :ELOG 'error type of wall'
        return []
    endif
endfunction "}}}

" WallOfRoom: get at most four walls around a room
" return a list of wall tuple
function! s:class.WallOfRoom(room) dict abort "{{{
    let l:row = a:room[0]
    let l:col = a:room[1]

    let l:lsWall = []
    if l:row > 0
        let l:wall = ['h', l:row-1, l:col]
        call add(l:lsWall, l:wall)
    endif
    if l:col > 0
        let l:wall = ['v', l:row, l:col-1]
        call add(l:lsWall, l:wall)
    endif
    if l:row < self.height - 1
        let l:wall = ['h', l:row, l:col]
        call add(l:lsWall, l:wall)
    endif
    if l:col < self.width - 1
        let l:wall = ['v', l:row, l:col]
        call add(l:lsWall, l:wall)
    endif
    return l:lsWall
endfunction "}}}

" GridWall: init a full blocked maze
function! s:class.GridWall() dict abort "{{{
    let self.room = class#math#matrix#raw(self.height, self.width, self.VALID)
    let self.hwall = class#math#matrix#raw(self.height-1, self.width, self.BLOCKED)
    let self.vwall = class#math#matrix#raw(self.height, self.width-1, self.BLOCKED)

    return self
endfunction "}}}

" PassageWall: set a wall as PASSAGE
" a:wall is wall tuple
function! s:class.PassageWall(wall) dict abort "{{{
    if a:wall[0] == 'h'
        let self.hwall[a:wall[1]][a:wall[2]] = self.PASSAGE
    elseif a:wall[0] == 'v'
        let self.vwall[a:wall[1]][a:wall[2]] = self.PASSAGE
    else
        :ELOG 'error wall type'
        return v:none
    endif
    return self
endfunction "}}}

" MarkRoom: 
" a:room is a room tuple [row, col]
" a:marker is any value, usually number is ok
function! s:class.MarkRoom(room, marker) dict abort "{{{
    let self.room[a:room[0]][a:room[1]] = a:marker
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
