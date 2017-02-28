" File: micros.vim
" Author: lymslive
" Description: 
" Create: 2017-02-28
" Modify: 2017-02-28

command! -nargs=+ IMPORT
        \ let s:__list__ = split(<q-args>) <bar>
        \ let s:__arg__ = s:__list__[0] <bar>
        \ let s:__variable__ = split(s:__arg__, '[./#]')[-1] <bar>
        \ let s:__dict__ = module#hImport(<q-args>) <bar>
        \ execute 'let s:' . s:__variable__ . ' = s:__dict__' 

