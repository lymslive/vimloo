" Class: class#math#randit
" Author: lymslive
" Description: iterate randomly in range[1, maxint]
"   each time call Next(), generate a rand number with no repeat and
"   after maxint times, output 0 marked as the end
" Create: 2017-07-06
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#math#randit'
let s:class._version_ = 1

let s:class.maxint = 10

function! class#math#randit#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#math#randit#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#math#randit#ctor(this, ...) abort "{{{
    if a:0 < 1 || type(a:1) != type(0)
        :ELOG 'expcet randit(maxint)'
        return v:none
    endif
    call a:this.Reset(a:1)
endfunction "}}}

" ISOBJECT:
function! class#math#randit#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" Reset: 
function! s:class.Reset(maxint) dict abort "{{{
    if type(a:maxint) != type(0)
        :ELOG 'randit expcet a int number'
    else
        let self.maxint = a:maxint
    endif

    let self._range = range(1, self.maxint)
    let self._random = class#math#random#new()
    return self
endfunction "}}}

" Next: 
function! s:class.Next() dict abort "{{{
    if self.Empty()
        return 0
    endif

    let l:idx = self._random.Rand(len(self._range))
    return remove(self._range, l:idx)
endfunction "}}}

" Empty: 
function! s:class.Empty() dict abort "{{{
    return empty(self._range)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#math#randit is loading ...'
function! class#math#randit#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#math#randit#test(...) abort "{{{
    let l:it = class#math#randit#new(10)
    for _ in range(10)
        echo l:it.Next()
    endfor

    echo '---'
    let l:it = class#math#randit#new(16)
    let l:rand = l:it.Next()
    while !empty(l:rand)
        echo l:rand
        let l:rand = l:it.Next()
    endwhile

    return 0
endfunction "}}}
