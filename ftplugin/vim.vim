" File: vim.vim
" Author: yourname
" Description: 
" Create: 2017-03-08
" Modify: 2017-03-09

setlocal iskeyword+=#
setlocal iskeyword+=:

augroup EDIT_VIM
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call edit#vim#UpdateModity()
augroup END

nnoremap <buffer> g<C-]> :call edit#vim#GotoDefineFunc()<CR>
