" Class: class#more#dict
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-02
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#more#dict'
let s:class._version_ = 1

function! class#more#dict#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#more#dict#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#more#dict#ctor(this, ...) abort "{{{
    if a:0 == 0
        let a:this.dict_ = {}
    elseif type(a:1) == v:t_list
        let a:this.dict_ = a:1
    else
        : ELOG '[class#more#dict#ctor] expect a dict variable'
    endif
endfunction "}}}

" MERGE:
function! class#more#dict#merge(that) abort "{{{
    call a:that._merge_(s:class)
endfunction "}}}

" ISOBJECT:
function! class#more#dict#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" dict: 
function! s:class.dict() dict abort "{{{
    if has_key(self, 'dict_')
        return self.dict_
    else
        : ELOG '[class#more#dict] ' . 'not implement dict()'
        return {}
    endif
endfunction "}}}

" size: 
function! s:class.size() dict abort "{{{
    return len(keys(self.dict()))
endfunction "}}}
" empty: 
function! s:class.empty() dict abort "{{{
    return empty(self.dict())
endfunction "}}}

" string: 
function! s:class.string() dict abort "{{{
    let l:lsOutput = []
    let l:sHeader = printf('{dict: %d keys}', self.size())
    call add(l:lsOutput, l:sHeader)
    for [l:key, l:val] in items(self.dict())
        let l:val_type = type(l:val)
        if l:val_type == v:t_string
            let l:val_str = l:val
        elseif l:val_type == v:t_list
            let l:val_str = '[...]'
        elseif l:val_type == v:t_dict
            let l:val_str = '{...}'
        else
            let l:val_str = string(l:val)
        endif
        let l:val_str = ''
        let l:sItem = printf('  %s => %s', l:key, l:val_str)
        call add(l:lsOutput, l:sItem)
        unlet l:key  l:val
    endfor
    return join(l:lsOutput, "\n")
endfunction "}}}
" disp: 
function! s:class.disp() dict abort "{{{
    echo self.string()
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#more#dict is loading ...'
function! class#more#dict#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#more#dict#test(...) abort "{{{
    return 0
endfunction "}}}
