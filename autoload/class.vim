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
function! class#ctor(this, argc, argv) abort "{{{
endfunction "}}}

" dector: 
function! class#dector() abort "{{{
endfunction "}}}

" new: create a instance object of named class
" if name is empty or 0, use this base class
function! class#new(name, ...) abort "{{{
    if empty(a:name)
        let l:obj = copy(s:class)
    else
        let l:class = eval(a:name . '#class()')
        let l:obj = copy(l:class)
    endif
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" old: create a new class from super class
" if super(a:1) is empty or 0, the super is this base class
" another optional(a:2) is the sub-class name
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
    let l:obj = class#new(0)
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

" class._new_: 
" construct a object from any argument
" call each ctor from top downwise
function! s:class._new_(argv) dict abort "{{{
    let l:argc = len(a:argv)
    let l:argv = [self._name_]
    call extend(l:argv, a:argv)

    " call ctor of super class, from the most base level
    let l:liSuper = self._supers_()
    while !empty(l:liSuper)
        let l:super = remove(l:liSuper, -1)
        let l:Ctor = function(l:super . '#ctor')
        if exists('*l:Ctor')
            call l:Ctor(self, l:argc, l:argv)
        endif
    endwhile

    let l:Ctor = function(self._name_ . '#ctor')
    if exists('*l:Ctor')
        call l:Ctor(self, l:argc, l:argv)
    endif
endfunction "}}}

" class._old_: 
" set the right name of super and self relation
function! s:class._old_() dict abort "{{{
    let self._super_ = self._name_
    let self._name_ = ''
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
