" Class: class#buffer#shield
" Author: lymslive
" Description: a special buffer shield, protcted from manually editing
"   suggest to create b:variable of this class
" Create: 2017-07-14
" Modify: 2017-07-25

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#buffer#shield'
let s:class._version_ = 1

" the logical owner object
let s:class.owner = {}
let s:class.bufnr = 0

function! class#buffer#shield#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#buffer#shield#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#buffer#shield#ctor(this, ...) abort "{{{
    let a:this.bufnr = bufnr('%')
endfunction "}}}

" OLD:
function! class#buffer#shield#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#buffer#shield#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Freeze: 
function! s:class.Freeze() dict abort "{{{
    : setlocal buftype=nofile
    : setlocal nobuflisted
    : setlocal bufhidden=delete 
    : setlocal nomodifiable
    : setlocal statusline=%t%=SHIELD
    : setlocal nonumber
    : setlocal nowrap
endfunction "}}}

" SetOwner: 
function! s:class.SetOwner(obj) dict abort "{{{
    let self.owner = a:obj
endfunction "}}}

" Update: update current buffer with lsText
function! s:class.Update(lsText) dict abort "{{{
    " before update
    let l:bSame = v:true
    let l:bufnr = bufnr('%')
    if l:bufnr != self.bufnr
        let l:bSame = v:false
        let l:winnr = bufwinnr(self.bufnr)
        if l:winnr == -1
            : WLOG 'the buffer ' . self.bufnr . ' is not in window any more'
            return
        endif
        let l:winnr_old = winnr()
        execute l:winnr . 'wincmd w'
    endif

    " update
    if empty(a:lsText)
        : 1,$ delete
        return
    endif

    : setlocal modifiable
    let l:posCursor = getcurpos()

    let l:iOldEnd = line('$')
    call setline(1, a:lsText)
    let l:iNewEnd = len(a:lsText)

    if l:iOldEnd > l:iNewEnd
        let l:cmd = printf("%d,$ delete", l:iNewEnd + 1)
        execute l:cmd
    endif

    call setpos('.', l:posCursor)
    : setlocal nomodifiable

    " after update
    if !bSame
        execute l:winnr_old . 'wincmd w'
    endif
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#buffer#shield is loading ...'
function! class#buffer#shield#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#buffer#shield#test(...) abort "{{{
    return 0
endfunction "}}}
