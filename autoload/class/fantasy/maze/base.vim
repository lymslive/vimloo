" Class: class#fantasy#maze#base
" Author: lymslive
" Description: the basic data structure of maze
" Create: 2017-06-29
" Modify: 2017-07-06

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
    let l:iCellWidth = get(a:000, 0, l:iDefaultWidth)
    let l:iCellHeight = get(a:000, 1, l:iDefaultHeight)
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

" ListOfWall: ['h', row, col] or ['v', row, col]
" span list the hwall and vwall
function! s:class.ListOfWall() dict abort "{{{
    " code
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
