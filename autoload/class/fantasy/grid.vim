" Class: class#fantasy#grid
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-12
" Modify: 2017-08-12

" LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#fantasy#grid'
let s:class._version_ = 1
let s:class._vim_ = 8

" the width * heigth of the cells
let s:class.wsize = 0
let s:class.hsize = 0

" the width * height of each cell
" can be list, each cell has diffrent width or height
let s:class.wcell = 4
let s:class.hcell = 1

" grid border character
let s:BORDER = {}
let s:BORDER.CROSS = '+'
let s:BORDER.HSIDE = '-'
let s:BORDER.VSIDE = '|'

function! class#fantasy#grid#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: new(wsize, hsize)
function! class#fantasy#grid#new(...) abort "{{{
    if a:0 < 2
        return {}
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#fantasy#grid#ctor(this, ...) abort "{{{
    let a:this.wsize = a:1
    let a:this.hsize = a:2
endfunction "}}}

" ISOBJECT:
function! class#fantasy#grid#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" SetWidth: 
" SetWidth() return wcell
" SetWidth(w), all cell is width of w
" SetWidth([w1, w2, ...]), set width for each column, length match wsize
" SetWidth(c, w), only change column c to width w, c is 0-based index
function! s:class.SetWidth(...) dict abort "{{{
    if a:0 == 0 || empty(a:1)
        return self.wcell
    endif

    if a:0 == 1
        if type(a:1) == v:t_number 
            let self.wcell = a:1
        elseif type(a:1) == v:t_list
            if len(a:1) != self.wsize
                : ELOG 'grid.SetWidth([w]) list length no match: ' . len(a:1) . ' vs ' . self.wsize
                return 0
            endif
            let self.wcell = a:1
        else
            : ELOG 'grid.SetWidth() need number or list of number'
            return 0
        endif
    elseif a:0 == 2
        let l:iColumn = a:1
        let l:iWidth = a:2
        if type(self.wcell) != v:t_list
            : ELOG 'grid.SetWidth() not list width now'
            return 0
        endif
        let self.wcell[l:iColumn] = a:2
    endif

    return self.wcell
endfunction "}}}

" SetHeight: 
" same as SetWidth
function! s:class.SetHeight(...) dict abort "{{{
    if a:0 == 0 || empty(a:1)
        return self.hcell
    endif

    if a:0 == 1
        if type(a:1) == v:t_number 
            let self.hcell = a:1
        elseif type(a:1) == v:t_list
            if len(a:1) != self.hsize
                : ELOG 'grid.SetHeight([w]) list length no match: ' . len(a:1) . ' vs ' . self.hsize
                return 0
            endif
            let self.hcell = a:1
        else
            : ELOG 'grid.SetHeight() need number or list of number'
            return 0
        endif
    elseif a:0 == 2
        if type(self.hcell) != v:t_list
            : ELOG 'grid.SetHeight() not list width now'
            return 0
        endif
        let self.hcell[a:1] = a:2
    endif

    return self.hcell
endfunction "}}}

" Output: 
" return a matrix of character with border and space
" a:1, if a:1>0, output this matrix to current buffer
function! s:class.Output(...) dict abort "{{{
    " raw row as "|   |   |"
    if type(self.wcell) == v:t_number
        let l:sCell = repeat(' ', self.wcell)
        let l:lsSpace = repeat([l:sCell], self.wsize)
    elseif type(self.wcell) == v:t_list
        let l:lsSpace = []
        for l:jdx in range(self.wsize)
            let l:sCell = repeat(' ', self.wcell[l:jdx])
            call add(l:lsSpace, l:sCell)
        endfor
    else
        : ELOG 'grid.Output(): unexpected type of self.wcell'
        return 0
    endif
    let l:sRowStr = s:BORDER.VSIDE . join(l:lsSpace, s:BORDER.VSIDE) . s:BORDER.VSIDE

    " build horizontal line as "+----+-----+"
    let l:sHline = l:sRowStr
    let l:sHline = substitute(l:sHline, s:BORDER.VSIDE, s:BORDER.CROSS, 'g')
    let l:sHline = substitute(l:sHline, ' ', s:BORDER.HSIDE, 'g')

    " build matrix
    let l:mtChar = [l:sHline]
    for l:idx in range(self.hsize)
        let l:iCellLines = 0
        if type(self.hcell) == v:t_number
            let l:iCellLines = self.hcell
        elseif type(self.hcell) == v:t_number
            let l:iCellLines = self.hcell[l:idx]
        else
            : ELOG 'grid.Output(): unexpected type of self.hcell'
            return 0
        endif
        for l:jdx in range(l:iCellLines)
            call add(l:mtChar, l:sRowStr)
        endfor
        call add(l:mtChar, l:sHline)
    endfor

    if a:0 > 0 && !empty(a:1)
        call setline(a:1, l:mtChar)
    endif

    return l:mtChar
endfunction "}}}

" Fillout: 
" a:content is a matrix that will fill in grid, size should be match
" a:1, if a:1>0, output result to current buffer
function! s:class.Fillout(content, ...) dict abort "{{{
    if type(a:content) != v:t_list
        : ELOG 'gird.FillOut() expect content as matrix'
        return 0
    endif

    let l:mtChar = self.Output()
    let l:iMaxLine = len(l:mtChar)
    let l:hSize = len(a:content)
    let l:iLineIndex = 0
    for l:hdx in range(l:hSize)
        let l:iLineIndex += 1
        if l:iLineIndex >= l:iMaxLine
            : ELOG 'grid.FillOut(): the content size seems exceed grid'
            break
        endif

        let l:rowSpace = l:mtChar[l:iLineIndex]
        let l:lsSpace = split(l:rowSpace, s:BORDER.VSIDE)
        let l:wSpace = len(l:lsSpace)

        " update content in each cell
        let l:rowContent = a:content[l:hdx]
        let l:wSize = len(l:rowContent)
        for l:wdx in range(l:wSize)
            if l:wdx >= l:wSpace
                : ELOG 'grid.FillOut(): the content size seems exceed grid'
                break
            endif
            let l:val = l:rowContent[l:wdx]
            let l:sFill = s:FillValue(l:val, len(l:lsSpace[l:wdx]))
            if !empty(l:sFill)
                let l:lsSpace[l:wdx] = l:sFill
            endif
        endfor

        " update the row line in l:mtChar
        let l:sRowStr = s:BORDER.VSIDE . join(l:lsSapce, s:BORDER.VSIDE) . s:BORDER.VSIDE
        let l:mtChar[l:iLineIndex] = l:sRowStr

        " move to next space line
        if type(self.hcell) == v:t_number
            let l:iLineIndex += self.hcell
        elseif type(self.hcell) == v:t_list
            let l:iLineIndex += self.hcell[l:hdx]
        else
            : ELOG 'grid.FillOut(): unexpected type of self.hcell'
            return 0
        endif
    endfor

    if a:0 > 0 && !empty(a:1)
        call setline(a:1, l:mtChar)
    endif

    return l:mtChar
endfunction "}}}

" FillValue: 
" content any value to string at most length
" length include an extra space in both end
" if too long, end with tow dot '..'
" list convert to "*[=]", dict convert to "*{=}", other complex to "**"
function! s:FillValue(value, length) abort "{{{
    if a:length < 3
        : ELOG '[grid]s:FillValue() length too small, min 3'
        return ''
    endif

    let l:iType = type(a:value)
    if l:iType == v:t_string
        let l:str = a:value
    elseif  l:iType == v:t_number
        let l:str = string(a:value)
    elseif  l:iType == v:t_list
        let l:str = '*[=]'
    elseif  l:iType == v:t_dict
        let l:str = '*{=}'
    elseif l:iType == v:t_bool || l:iType == v:t_float || l:iType == v:t_none
        let l:str = string(a:value)
    else
        let l:str = '**'
    endif

    if len(l:str) > a:length - 2
        let l:str = strpart(l:str, 0, a:length - 3)
        let l:str = ' ' . l:str . '..'
    else
        let l:str = ' ' . l:str . ' '
    endif

    return l:str
endfunction "}}}

" LOAD:
let s:load = 1
function! class#fantasy#grid#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#fantasy#grid#test(...) abort "{{{
    let l:obj = class#fantasy#grid#new(10, 10)
    call l:obj.SetHeight(2)
    " call l:obj.SetWidth(6)

    let l:lsWidth = []
    let l:random = class#math#random#new()
    for _ in range(10)
        let l:width = 4 + l:random.Rand(6)
        call add(l:lsWidth, l:width)
    endfor
    echo l:lsWidth
    call l:obj.SetWidth(l:lsWidth)

    echo join(l:obj.Output(), "\n")
endfunction "}}}
