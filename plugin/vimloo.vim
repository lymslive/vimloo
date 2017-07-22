" File: vimloo.vim
" Author: lymslive
" Description: global command defined for vimloo
" Create: 2017-02-11
" Modify: 2017-07-22

if exists('g:vimloo_plugin_disable')
    finish
endif

" Generate class frame code from template class file.
" :ClassNew will create a new file;
" :ClassAdd append code to current buffer;
" will check the current filename or directory required under autoload/
" :ClassTemp load frame code to current buffer without check filename
"
" They all accpet option to filt the template, and
" :ClassNew must provide a name before option.
" :ClassTemp -a option read in full template file, 
"  and the file itself list default option for each paragraph
command! -nargs=+ ClassNew call cmass#builder#hClassNew(<f-args>)
command! -nargs=* ClassAdd call cmass#builder#hClassAdd(<f-args>)
command! -nargs=* ClassTemp call cmass#builder#hClassTemp(<f-args>)

command! -nargs=+ ModuleNew call cmass#builder#hModuleNew(<f-args>)

" :ClassPart only add the sepecific paragraph subject it's option
" ignore the default option in the tempcall file
command! -nargs=1 ClassPart call cmass#builder#hClassPart(<f-args>)

" :ClassLoad [-r] [-d|D] [filename]
" load a script(default current file), with option
" -r force to reload
" -d set g:DEBUG, and then directlly source will work
" -D unset g:DEBUG
command! -nargs=* -complete=file ClassLoad call cmass#director#hClassLoad(<f-args>)

" :ClassTest [-f filename] argument-list-pass-to-#test
" call the #test function of some script, default currnet file
command! -nargs=* -complete=file ClassTest call cmass#director#hClassTest(<f-args>)
command! -nargs=* -complete=file ClassDebug call cmass#director#hClassDebug(<f-args>)

" display an overview of a class, use full class name with #
command! -nargs=1 ClassView execute 'call ' . <q-args> . '#class().echo()'

" display the last message in qf or local window
command! -nargs=0 -count=5 MessageQ call cmass#director#MessageRefix(<count>, 'qf')
command! -nargs=0 -count=5 MessageL call cmass#director#MessageRefix(<count>, 'll')
nnoremap g> :<C-u>5MessageQ<CR>
nnoremap g/ :<C-u>5MessageL<CR>
