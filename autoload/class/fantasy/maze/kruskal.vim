" Class: class#fantasy#maze#kruskal
" Author: lymslive
" Description: maze generation by Randomized Kruskal's algorithm
"   refer to: https://en.wikipedia.org/wiki/Maze_generation_algorithm
" Create: 2017-07-06
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#fantasy#maze#base#old()
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

    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#fantasy#maze#kruskal#ctor(this, height, width) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:height, a:width)
endfunction "}}}

" ISOBJECT:
function! class#fantasy#maze#kruskal#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" Reset: 
function! s:class.Reset() abort "{{{
    call self.GridWall()

    " init each room set by itself
    let self._set = {}
    let l:iRoomSet = -1
    for l:row in range(self.height)
        for l:col in range(self.width)
            let self.room[l:row][l:col] = l:iRoomSet
            let self._set[l:iRoomSet] = [[l:row, l:col]]
            let l:iRoomSet -= 1
        endfor
    endfor

    return self
endfunction "}}}

" MergeRoom: merge two rooms if not the same set
" a:room, a:other is 2-element list [row, col]
" return v:true if have exceute merge operation
function! s:class.MergeRoom(room, other) dict abort "{{{
    let l:iRoomSet = self.room[a:room[0]][a:room[1]]
    let l:iOtherSet = self.room[a:other[0]][a:other[1]]
    if l:iRoomSet == l:iOtherSet
        return v:false
    endif

    let l:lsRoom = self._set[l:iOtherSet]
    for l:room in l:lsRoom
        let self.room[l:room[0]][l:room[1]] = l:iRoomSet
    endfor

    call extend(self._set[l:iRoomSet], l:lsRoom)
    unlet self._set[l:iOtherSet]

    return v:true
endfunction "}}}

" Generate: 
function! s:class.Generate() dict abort "{{{
    call self.Reset()

    " randomly join room set
    let l:iWallCount = (self.height-1) * self.width
    let l:iWallCount += self.height * (self.width-1)
    let l:rand = class#math#randit#new(l:iWallCount)
    for _ in range(l:iWallCount)
        let l:index = l:rand.Next() - 1
        let l:wall = self.WallOfIndex(l:index)
        let l:lsRoom = self.RoomOfWallIndex(l:index)
        if len(l:lsRoom) != 2
            :ELOG 'wall error, expect to divide two rooms'
            return v:none
        endif

        if self.MergeRoom(l:lsRoom[0], l:lsRoom[1])
            call self.PassageWall(l:wall)
        endif
    endfor

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

    let l:lsKey = keys(self._set)
    if len(l:lsKey) == 1
        :DLOG '-2 the last room set is: ' . l:lsKey[0]
    else
        :ELOG 'generator error, not all room merge to one set'
    endif

    unlet self._set
    return self
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
    let l:iHeight = get(a:000, 0, 10) + 0
    let l:iWidth = get(a:000, 1, 10) + 0
    let l:maze = class#fantasy#maze#kruskal#new(l:iHeight, l:iWidth)
    call l:maze.Generate()
    let l:lsString = l:maze.DrawMap()
    for l:str in l:lsString
        echo l:str
    endfor

    let l:graph = l:maze.ConvertGraph()
    call l:graph.disp()
    return 0
endfunction "}}}
