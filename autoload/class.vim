" File: class.vim 
" Author: lymslive
" Description: base class for vimL
" Create: 2017-02-07
" Modify: 2017-02-10

let s:class = {}
let s:class._name_ = 'class'
let s:class._version_ = 1
let s:class._super_ = 'class'

" class: 
function! class#class() abort "{{{
    return s:class
endfunction "}}}

" ctor: 
function! class#ctor(this, argv) abort "{{{
endfunction "}}}

" dector: 
function! class#dector() abort "{{{
endfunction "}}}

" new: create a instance object of named class
" if name is empty or 0, use this base class
function! class#new(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        let l:class = eval(a:1 . '#class()')
        let l:obj = copy(l:class)
    else
        let l:obj = copy(s:class)
    endif

    if a:0 > 1
        let l:argv = a:000[1:]
    else
        let l:argv = []
    endif

    call l:obj._new_(l:argv)
    return l:obj
endfunction "}}}

" old: create a new class from super class
" if super(a:1) is empty or 0, the super is this base class
function! class#old(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:class = copy(s:class)
    else
        let l:super = eval(a:1 . '#class()')
        let l:class = copy(l:super)
    endif
    call l:class._old_()
    return l:class
endfunction "}}}

" delete: 
function! class#delete(this) abort "{{{
    call a:this._del_()
endfunction "}}}

" isobject: 
function! class#isobject(...) abort "{{{
    if a:0 == 0
        return v:false
    elseif a:0 == 1
        return class#SameClass(s:class, a:1)
    else
        let l:class = eval(a:1 . '#class()')
        return class#SameClass(l:class, a:2)
    endif
endfunction "}}}

" SameClass: 
function! class#SameClass(first, second) abort "{{{
    if type(a:first) == 4 && type(a:second)
       if has_key(a:first, '_name_') && has_key(a:second, '_name_')
           if a:first._name_ ==# a:second._name_
               return v:true
           endif
       endif 
    endif
    return v:false
endfunction "}}}

" convert object to string
function! s:class.string() dict abort "{{{
    return self._name_
endfunction "}}}

" convert object to number
function! s:class.number() dict abort "{{{
    return self._version_
endfunction "}}}

" triggle to load this vimL file
function! class#load() abort "{{{
    return 1
endfunction "}}}

" unit test for this vimL file
function! class#test() abort "{{{
    let l:obj = class#new()
    call l:obj.hello()
    call l:obj.hello('vim')
    return 1
endfunction "}}}

" return a list of super classes in derived path
function! s:class._supers_() dict abort "{{{
    if !has_key(self, '_super_')
        return []
    endif
    if self._super_ == self._name_
        return []
    endif

    let l:liSuper = []
    call add(l:liSuper, self._super_)
    let l:super_name = self._super_
    let l:super_class = eval(l:super_name . '#class()')
    while has_key(l:super_class, '_super_') && l:super_class._super_ != l:super_name
        call add(l:liSuper, l:super_class._super_)
        let l:super_name = l:super_class._super_
        let l:super_class = eval(l:super_name . '#class()')
    endwhile

    return l:liSuper
endfunction "}}}

" _ctor_: 
function! s:class._ctor_() dict abort "{{{
    let l:Ctor = function(self._name_ . '#ctor')
    if !exists('*l:Ctor')
        let l:Ctor = function('class#ctor')
    endif
    return l:Ctor
endfunction "}}}

" _suctor_: 
function! s:class._suctor_() dict abort "{{{
    let l:Ctor = function(self._super_ . '#ctor')
    if !exists('*l:Ctor')
        let l:Ctor = function('class#ctor')
    endif
    return l:Ctor
endfunction "}}}

" _dector_: 
function! s:class._dector_() dict abort "{{{
    let l:Dector = function(self._name_ . '#dector')
    if !exists('*l:Dector')
        let l:Dector = function('class#dector')
    endif
    return l:Dector
endfunction "}}}

" _sudector_: 
function! s:class._sudector_() dict abort "{{{
    let l:Dector = function(self._super_ . '#dector')
    if !exists('*l:Dector')
        let l:Dector = function('class#dector')
    endif
    return l:Dector
endfunction "}}}

" _new_: 
function! s:class._new_(argv) dict abort "{{{
    let l:Ctor = self._ctor_()
    if exists('*l:Ctor')
        call l:Ctor(self, a:argv)
    endif
endfunction "}}}

" class._old_: 
" set the right name of super and self relation
function! s:class._old_() dict abort "{{{
    let self._super_ = self._name_
    let self._name_ = ''
endfunction "}}}

" _copy_: 
function! s:class._copy_(that) dict abort "{{{
    for l:sKey in keys(self)
        let l:iType = type(self[l:sKey])
        " Funcref = 2
        if l:iType == 2
            continue
        endif

        " List = 3, Dict = 4
        if l:iType == 3 || l:iType == 4
            if has_key(a:that, l:sKey)
                let self[l:sKey] = copy(a:that[l:sKey])
            endif
        else
            let self[l:sKey] = a:that[l:sKey]
        endif
    endfor
endfunction "}}}

" class._del_: 
" call echa dector from bottom upwise
function! s:class._del_() dict abort "{{{
    let l:Dector = function(self._name_ . '#dector')
    if exists('*l:Dector')
        call l:Dector()
    endif

    let l:liSuper = self._supers_()
    for l:super in l:liSuper
        let l:Dector = function(l:super . '#dector')
        if exists('*l:Dector')
            call l:Dector()
        endif
    endfor
endfunction "}}}

" the shared instance: 
let s:instance = {}
function! class#instance() abort "{{{
    if empty(s:instance)
        let s:instance = class#new(0)
    endif
    return s:instance
endfunction "}}}

" class.hello: 
function! s:class.hello(...) dict abort "{{{
    if a:0 == 0
        let l:word = 'world'
    else
        let l:word = a:1
    endif
    echo self.string() . '[' . self.number() . ']: hello ' . l:word . '!'
endfunction "}}}
