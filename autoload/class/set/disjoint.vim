" Class: class#set#disjoint
" Author: lymslive
" Description: Disjoint-set data structure
" Refer: https://en.wikipedia.org/wiki/Disjoint-set_data_structure
" Create: 2017-07-31
" Modify: 2017-08-01

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#set#disjoint'
let s:class._version_ = 1

" use an id to represent a node, id should be int or string
" that use as a key of dictionary
let s:class.hashid = {}

" the node structure
let s:struct = {}
let s:struct.id = 0
let s:struct.rank = 0
let s:struct.parent = {}

function! class#set#disjoint#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#set#disjoint#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#set#disjoint#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this)

    let a:this.hashid = {}
endfunction "}}}

" ISOBJECT:
function! class#set#disjoint#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" MakeSet: 
function! s:class.MakeSet(id) dict abort "{{{
    if !has_key(self.hashid, a:id)
        let l:item = copy(s:struct)
        let l:item.id = a:id
        let l:item.rank = 0
        let l:item.parent = l:item
        let self.hashid[a:id] = l:item
    else
        : ELOG '[#disjoint.MakeSet] already in set, id: ' . a:id
    endif
    return self
endfunction "}}}

" Find: 
function! s:class.Find(id) dict abort "{{{
    if !has_key(self.hashid, a:id)
        : ELOG '[#disjoint.Find] not in set, id: ' . a:id
        return 0
    endif
    let l:item = self.hashid[a:id]
    let l:root = self.FindItem_(l:item)
    return l:root.id
endfunction "}}}

" FindItem_: 
" find by item object, recursive algorithm
function! s:class.FindItem_(item) dict abort "{{{
    let l:item = a:item
    if l:item.parent isnot l:item
        let l:item.parent = self.FindItem_(l:item.parent)
    endif
    return l:item.parent
endfunction "}}}

" Union: 
function! s:class.Union(idX, idY) dict abort "{{{
    let l:ridX = self.Find(a:idX)
    let l:ridY = self.Find(a:idY)

    if l:ridX ==# l:ridY
        return self
    endif
    let l:rootX = self.hashid[l:ridX]
    let l:rootY = self.hashid[l:ridY]

    if l:rootX.rank < l:rootY.rank
        let l:rootX.parent = l:rootY
    elseif l:rootX.rank > l:rootY.rank
        let l:rootY.parent = l:rootX
    else
        let l:rootY.parent = l:rootX
        let l:rootX.rank += 1
    endif

    return self
endfunction "}}}

" Free: break cycle reference
function! s:class.Free() dict abort "{{{
    for [l:key, l:item] in items(self.hashid)
        unlet! l:item.parent
        unlet l:key  l:item
    endfor
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#set#disjoint is loading ...'
function! class#set#disjoint#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#set#disjoint#test(...) abort "{{{
    return 0
endfunction "}}}
