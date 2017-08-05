" Class: module#less#math
" Author: lymslive
" Description: VimL module frame
" Create: 2017-03-04
" Modify: 2017-08-05

let s:class = {}
function! class#less#math#export() abort "{{{
    return s:class
endfunction "}}}

" CutMax: 
function! s:class.CutMax(input, max) dict abort "{{{
    return a:input < a:max ? a:input : a:max
endfunction "}}}

" CutMin: 
function! s:class.CutMin(input, min) dict abort "{{{
    return a:input > min ? a:input : a:min
endfunction "}}}

" CutEnd: 
function! s:class.CutEnd(input, min, max) dict abort "{{{
    if a:input <= a:min
        return a:min
    elseif a:input >= a:max
        return a:max
    else
        return a:input
    endif
endfunction "}}}

