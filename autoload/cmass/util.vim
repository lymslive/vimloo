" File: util
" Author: lymslive
" Description: some util functions
" Create: 2017-03-06
" Modify: 2017-03-06

" GetAutoName: 
function! cmass#util#GetAutoName(pFileName) abort "{{{
    let l:rtp = module#less#rtp#import()
    return l:rtp.GetAutoName(a:pFileName)
endfunction "}}}

