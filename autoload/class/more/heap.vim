" Class: class#more#heap
" Author: lymslive
" Description: implement the min binary heap 
"   refer to: https://en.wikipedia.org/wiki/Heap_(data_structure)
" Create: 2017-07-27
" Modify: 2017-08-04

" zero-based list
" full binary tree, children of n is 2n+1 and 2n+2
" the top list[0] is min node

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#more#list#old()
let s:class._name_ = 'class#more#heap'
let s:class._version_ = 1

function! class#more#heap#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#more#heap#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#more#heap#ctor(this, ...) abort "{{{
    if a:0 == 0
        let a:this.heap_ = []
    elseif type(a:1) == v:t_list
        let a:this.heap_ = a:1
    else
        : ELOG '[class#more#heap#ctor] expect a list variable'
    endif
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:this.heap_)
endfunction "}}}

" heap: 
function! s:class.heap() dict abort "{{{
    if has_key(self, 'heap_')
        return self.heap_
    else
        return self.list()
    endif
endfunction "}}}

" LessEqual: 
function! s:class.LessEqual(first, second) dict abort "{{{
    return a:first <= a:second
endfunction "}}}

" peek: 
function! s:class.peek() dict abort "{{{
    let l:heap = self.heap()
    if empty(l:heap)
        return ''
    endif
    return l:heap[0]
endfunction "}}}

" pop: 
function! s:class.pop() dict abort "{{{
    let l:heap = self.heap()
    if empty(l:heap)
        return ''
    endif

    let l:peek = l:heap[0]
    let l:tail = remove(l:heap, -1)
    if !empty(l:heap)
        let l:heap[0] = l:tail
        call self.shift_down(0)
    endif

    return l:peek
endfunction "}}}

" push: 
function! s:class.push(item) dict abort "{{{
    let l:heap = self.heap()
    call add(l:heap, a:item)
    let l:index = len(l:heap) - 1
    call self.shift_up(l:index)
    return self
endfunction "}}}

" replace: pop and push in one operation
function! s:class.replace(item) dict abort "{{{
    let l:heap = self.heap()
    if empty(l:heap)
        call add(l:heap, a:item)
    else
        let l:heap[0] = a:item
        call self.shift_down(0)
    endif
    return self
endfunction "}}}

" shift_up: 
function! s:class.shift_up(index) dict abort "{{{
    let l:heap = self.heap()
    let l:index = a:index
    let l:parent = (l:index - 1) / 2
    while l:parent >= 0 && l:parent < l:index && self.LessEqual(l:heap[l:index], l:heap[l:parent])
        call s:swap(l:heap, l:index, l:parent)
        if l:parent <= 0
            break
        endif
        let l:index = l:parent
        let l:parent = (l:index - 1) / 2
    endwhile
    return self
endfunction "}}}

" shift_down: 
function! s:class.shift_down(index) dict abort "{{{
    let l:heap = self.heap()
    let l:index = a:index
    let l:size = len(l:heap)
    while 1
        let l:left = 2 * l:index + 1
        let l:right = 2 * l:index + 2
        if l:left >= l:size
            break
        endif

        let l:swap = l:index
        if l:left < l:size && self.LessEqual(l:heap[l:left], l:heap[l:swap])
            let l:swap = l:left
        endif

        if l:right < l:size && self.LessEqual(l:heap[l:right], l:heap[l:swap])
            let l:swap = l:right
        endif

        if l:swap != l:index
            call s:swap(l:heap, l:index, l:swap)
            let l:index = l:swap
        else
            break
        endif
    endwhile
    return self
endfunction "}}}

" swap: swap the value in tow position of a list
function! s:swap(list, i, j) abort "{{{
    let l:tmp = a:list[a:i]
    let a:list[a:i] = a:list[a:j]
    let a:list[a:j] = l:tmp
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#more#heap is loading ...'
function! class#more#heap#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#more#heap#test(...) abort "{{{
    let l:obj = class#new()
    call class#more#heap#merge(l:obj)
    let l:obj.heap_ = []
    let l:iMax = get(a:000, 0, 10) + 0

    let l:rand = []
    let l:randit = class#math#randit#new(l:iMax)
    for _ in range(l:iMax)
        let l:iNumber = l:randit.Next()
        call add(l:rand, l:iNumber)
        call l:obj.push(l:iNumber)
    endfor

    echo 'rand list = ' . string(l:rand)
    echo 'heap list = ' . string(l:obj.heap_)

    let l:sort = []
    for _ in range(l:iMax)
        let l:iNumber = l:obj.pop()
        call add(l:sort, l:iNumber)
    endfor

    echo 'sort list = ' . string(l:sort)
    echo 'heap list = ' . string(l:obj.heap_)

    return 0
endfunction "}}}
