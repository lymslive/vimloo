" Class: module#less#math
" Author: lymslive
" Description: VimL module frame
" Create: 2017-03-04
" Modify: 2017-03-04

" MODULE:
let s:class = {}

" LimitMax: 
function! s:class.LimitMax(input, max) dict abort "{{{
    return a:input < a:max ? a:input : a:max
endfunction "}}}

" LimitMin: 
function! s:class.LimitMin(input, min) dict abort "{{{
    return a:input > min ? a:input : a:min
endfunction "}}}

" LimitBetween: 
function! s:class.LimitBetween(input, min, max) dict abort "{{{
    if a:input <= a:min
        return a:min
    elseif a:input >= a:max
        return a:max
    else
        return a:input
    endif
endfunction "}}}

" IMPORT:
function! module#less#math#import() abort "{{{
    return s:class
endfunction "}}}

