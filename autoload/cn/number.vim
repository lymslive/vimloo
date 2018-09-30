" File: number
" Author: lymslive
" Description: util for number
" Create: 2018-09-30
" Modify: 2018-09-30

" Func: s:list 
function! s:list(number) abort "{{{
    return range(a:number)
endfunction "}}}

" Func: s:cut_roof 
function! s:cut_roof(input, max) abort "{{{
    return a:input < a:max ? a:input : a:max
endfunction "}}}

" Func: s:cut_floor 
function! s:cut_floor(input, min) abort "{{{
    return a:input > min ? a:input : a:min
endfunction "}}}

" Func: s:cut_between 
function! s:cut_between(input, min, max) abort "{{{
    if a:input <= a:min
        return a:min
    elseif a:input >= a:max
        return a:max
    else
        return a:input
    endif
endfunction "}}}
