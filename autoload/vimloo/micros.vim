" File: micros.vim
" Author: lymslive
" Description: 
" Create: 2017-02-28
" Modify: 2017-08-01

" Log message to some file make use of :redir
command! -nargs=1 -complete=file LOGON call class#loger#SetLogFile(<f-args>)
command! -nargs=0 LOGOFF call class#loger#SetLogFile('')

" :LOG mainly used in script as used :echo, but only support one expr, eg:
" :LOG 'string' . l:variable
" :LOG '-2 -WarningMsg ' . l:variable
" if only option but no message, then set log level or/and highlight
" :SLOG -2 -WarningMsg no need quote
command! -nargs=+ LOG call class#loger#hLog(eval(<q-args>))
command! -nargs=+ ELOG call class#loger#hLog('-ErrorMsg ' . eval(<q-args>))
command! -nargs=+ WLOG call class#loger#hLog('-WarningMsg ' . eval(<q-args>))
command! -nargs=+ -complete=highlight SLOG call class#loger#hLog(<q-args>)

command! -nargs=+ DLOG
        \ if exists('g:DEBUG') <bar>
        \     call class#loger#hLog('-DEBUG ' . eval(<q-args>)) <bar>
        \ endif

" use to custom local plugin setting and mappings
command! -nargs=? PLUGINLOCAL
        \ if cmass#director#hPluginLocal(expand('<sfile>:p'), '.local', <q-args>) <bar>
        \     finish <bar>
        \ endif

command! -nargs=? PLUGINAFTER
        \ call cmass#director#hPluginLocal(expand('<sfile>:p'), '.after', <q-args>)

" load: 
function! vimloo#micros#load() abort "{{{
    return 1
endfunction "}}}
