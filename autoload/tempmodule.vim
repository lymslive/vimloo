" HEADER: -h
" Class: tempmodule
" Author: lymslive
" Description: VimL module frame
" Create: 2017-02-27
" Modify: 2017-02-27

" MODULE:
let s:class = {}

" IMPORT: -z
function! tempmodule#import() abort "{{{
    return s:class
endfunction "}}}

" TEST: -T
function! tempmodule#test(...) abort "{{{
    return 0
endfunction "}}}
