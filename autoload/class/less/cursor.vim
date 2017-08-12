" Class: module#less#cursor
" Author: lymslive
" Description: funtions deal with current cursor
" Create: 2017-03-09
" Modify: 2017-08-05

let s:class = {}
function! class#less#cursor#export() abort "{{{
    return s:class
endfunction "}}}


" GetWord: Get the word under cursor, as <cword>
" > a:000, add each to &isk temporary, get the word then restore &isk
" > only a:1 == one space, get word as <cWORD>
function! s:class.GetWord(...) dict abort "{{{
    if a:0 == 0
        return expand('<cword>')
    elseif a:0 == 1 && a:1 ==# ' '
        return expand('<cWORD>')
    endif

    let l:opSave = &l:iskeyword

    for l:c in a:000
        execute 'setlocal iskeyword+=' . l:c
    endfor

    let l:word = expand('<cword>')
    let &l:iskeyword = l:opSave
    return l:word
endfunction "}}}

" SplitLine: split line into three parts by cursor
" accpect upto 2 arguments, then shift left and right first
function! s:class.SplitLine(...) dict abort "{{{
    if a:0 == 0
        return self.SplitCursor_()
    elseif a:0 == 1
        if empty(a:1)
            return self.SplitCursor_()
        endif
        let l:cLeft = a:1
        let l:cRight = a:1
    elseif a:0 >= 2
        let l:cLeft = a:1
        let l:cRight = a:2
    endif
    return self.SplitBetween_(l:cLeft, l:cRight)
endfunction "}}}

" SplitCursor_: [string before, char at cursor, string after]
" return list of 3 item
function! s:class.SplitCursor_() dict abort "{{{
    let l:line = getline('.')
    if empty(l:line)
        return ['', '', '']
    endif

    let l:idx = col('.') - 1
    let l:end = len(l:line) - 1
    if l:idx <= 0
        return ['', l:line[0], strpart(l:line, 1)]
    elseif l:idx >= l:end
        return [strpart(l:line, 0, l:end), l:line[l:end], '']
    else
        return [strpart(l:line, 0, l:idx), 
                \ l:line[l:idx], 
                \ strpart(l:line, l:idx+1)]
    endif
endfunction "}}}

" SplitBetween_: 
" shift cursor to match left and right
" split line to 3 parts
" when either is empty, hold on cursor
function! s:class.SplitBetween_(left, right) dict abort "{{{
    let l:line = getline('.')
    if empty(l:line)
        return ['', '', '']
    endif

    if empty(a:left) && empty(a:right)
        return self.SplitCursor_()
    endif

    let l:idx = col('.') - 1
    let l:end = len(l:line) - 1
    
    let l:iLeft = l:idx
    if !empty(a:left) && l:line[l:idx] != a:left
        let l:iLeft = strridx(l:line, a:left, l:idx)
    endif

    let l:iRight = l:idx
    if !empty(a:right) && l:line[l:idx] != a:right
        let l:iRight = stridx(l:line, a:right, l:idx)
    endif

    return [strpart(l:line, 0, l:iLeft),
            \ strpart(l:line, l:iLeft, l:iRight - l:iLeft + 1),
            \ strpart(l:line, l:iRight+1)]
endfunction "}}}

