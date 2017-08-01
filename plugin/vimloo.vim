" File: vimloo.vim
" Author: lymslive
" Description: global command defined for vimloo
" Create: 2017-02-11
" Modify: 2017-08-01

if exists('g:vimloo_plugin_enable')
    call vimloo#plugin#load()
    call vimloo#micros#load()
endif

