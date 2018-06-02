" File: rtp_test
" Author: lymslive
" Description: unit test for rtp.vim
" Create: 2018-06-01
" Modify: 2018-06-01

let s:rtp = class#less#rtp#export()

" Main: 
function! class#less#rtp_test#Main() abort "{{{
    " code
endfunction "}}}

" FindAoptScript: 
function! class#less#rtp_test#FindAoptScript() abort "{{{
    let l:name = 'note'
    let l:script = s:rtp.FindAoptScript(l:name)
    echomsg l:script
endfunction "}}}
