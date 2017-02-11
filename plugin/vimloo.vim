" File: vimloo.vim
" Author: lymslive
" Description: global command defined for vimloo
" Create: 2017-02-11
" Modify: 2017-02-11

" Generate class frame code from template class file.
" :ClassNew will create a new file;
" :ClassAdd append code to current buffer;
" will check the current filename or directory required under autoload/
" :ClassTemp load frame code to current buffer without check filename
"
" They all accpet option to filter the template, and
" :ClassNew must provide a name before option.
" :ClassTemp -a option read in full template file, 
"  and the file itself list default option for each paragraph
command! -nargs=+ ClassNew call class#builder#hClassNew(<f-args>)
command! -nargs=* ClassAdd call class#builder#hClassAdd(<f-args>)
command! -nargs=* ClassTemp call class#builder#hClassTemp(<f-args>)
