" Class: class#heap#binary
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
let s:class = class#old()
let s:class._name_ = 'class#heap#binary'
let s:class._version_ = 1

let s:class.heap = []
" if the item in heap is a dict, 
" use  outkey in that dict to save index point into this heap,
" use cmpkey to compare two item
let s:class.outkey = ''
let s:class.cmpkey = ''

function! class#heap#binary#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new([outkey, LessEqual])
" a:1, outkey, may empty if no need to update item value
" a:2, cmpkey, FuncRef to overide the default LessEqual method
function! class#heap#binary#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#heap#binary#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this)
    let a:this.heap = []
    let a:this.outkey = get(a:000, 0, '')
    if a:0 >= 2 
        if type(a:2) == v:t_func
            let a:this.LessEqual = a:2
        elseif type(a:2) == v:t_string
            let a:this.cmpkey = a:2
        else
            : ELOG '[#heap#binary] expect a compare key or function'
        endif
    endif
endfunction "}}}

" LessEqual: 
function! s:class.LessEqual(first, second) dict abort "{{{
    if !empty(self.cmpkey)
        return a:first[self.cmpkey] <= a:second[self.cmpkey]
    else
        return a:first <= a:second
    endif
endfunction "}}}

" size: 
function! s:class.size() dict abort "{{{
    return len(self.heap)
endfunction "}}}

" empty: 
function! s:class.empty() dict abort "{{{
    return empty(self.heap)
endfunction "}}}

" peek: 
function! s:class.peek() dict abort "{{{
    if empty(self.heap)
        return ''
    endif
    return self.heap[0]
endfunction "}}}

" pop: 
function! s:class.pop() dict abort "{{{
    if empty(self.heap)
        return v:none
    endif

    let l:peek = self.heap[0]
    call self.delete_index(0)

    return l:peek
endfunction "}}}

" push: 
function! s:class.push(item) dict abort "{{{
    call add(self.heap, a:item)
    let l:index = len(self.heap) - 1
    call self.UpdateIndex(l:index)
    call self.shift_up(l:index)
    return self
endfunction "}}}

" replace: pop and push in one operation
function! s:class.replace(item) dict abort "{{{
    if empty(self.heap)
        call add(self.heap, a:item)
    else
        let self.heap[0] = a:item
        call self.UpdateIndex(0)
        call self.shift_down(0)
    endif
    return self
endfunction "}}}

" shift_up: 
function! s:class.shift_up(index) dict abort "{{{
    let l:index = a:index
    let l:parent = (l:index - 1) / 2
    while l:parent >= 0 && l:parent < l:index && self.LessEqual(self.heap[l:index], self.heap[l:parent])
        call self.swap(l:index, l:parent)
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
    let l:index = a:index
    let l:size = len(self.heap)
    while 1
        let l:left = 2 * l:index + 1
        let l:right = 2 * l:index + 2
        if l:left >= l:size
            break
        endif

        let l:swap = l:index
        if l:left < l:size && self.LessEqual(self.heap[l:left], self.heap[l:swap])
            let l:swap = l:left
        endif

        if l:right < l:size && self.LessEqual(self.heap[l:right], self.heap[l:swap])
            let l:swap = l:right
        endif

        if l:swap != l:index
            call self.swap(l:index, l:swap)
            let l:index = l:swap
        else
            break
        endif
    endwhile
    return self
endfunction "}}}

" swap: swap the value in tow position of a list
function! s:class.swap(i, j) dict abort "{{{
    if a:i !=# a:j
        let l:tmp = self.heap[a:i]
        let self.heap[a:i] = self.heap[a:j]
        let self.heap[a:j] = l:tmp
        call self.UpdateIndex(a:i)
        call self.UpdateIndex(a:j)
    endif
    return self
endfunction "}}}

" erase_end: 
function! s:class.erase_end() dict abort "{{{
    if empty(self.heap)
        return v:none
    endif
    let l:item = remove(self.heap, -1)
    if type(l:item) == type({}) && !empty(self.outkey)
        unlet! l:item[self.outkey]
    endif
    return l:item
endfunction "}}}

" UpdateIndex: 
function! s:class.UpdateIndex(index) dict abort "{{{
    let l:item = self.heap[a:index]
    if !empty(self.outkey) && type(l:item) == v:t_dict
        let l:item[self.outkey] = a:index
    endif
endfunction "}}}

" GetHeapIndex: 
" return the index of item in this heap, -1 if not in
function! s:class.GetHeapIndex(item) dict abort "{{{
    if type(a:item) == v:t_dict && !empty(self.outkey)
        return a:item[self.outkey]
    else
        for l:i in len(self.heap)
            if self.heap[l:i] is a:item || self.heap[l:i] ==# a:item
                return l:i
            endif
        endfor
    endif
    return -1
endfunction "}}}

" decrease: the key(value) of item has been decreased, need shift_up
function! s:class.decrease(item) dict abort "{{{
    let l:index = self.GetHeapIndex(a:item)
    if l:index >= 0 && l:index < len(self.heap)
        call self.shift_up(l:index)
    else
        : ELOG '[class#heap#binary] item not in heap'
    endif
endfunction "}}}

" increase: the key(value) of item has been increased, need shift_down
" if change the LessEqual function to make max-heap, you may use decrease
function! s:class.increase(item) dict abort "{{{
    let l:index = self.GetHeapIndex(a:item)
    if l:index >= 0 && l:index < len(self.heap())
        call self.shift_down(l:index)
    else
        : ELOG '[class#heap#binary] item not in heap'
    endif
endfunction "}}}

" delete: 
function! s:class.delete(item) dict abort "{{{
    let l:index = self.GetHeapIndex(a:item)
    if l:index >= 0 && l:index < len(self.heap())
        call self.delete_index(l:index)
    else
        : ELOG '[class#heap#binary] item not in heap'
    endif
endfunction "}}}

" delete_index: 
function! s:class.delete_index(index) dict abort "{{{
    let l:index = a:index
    let l:iend = len(self.heap)
    if l:index < 0 || l:index >= l:iend
        : ELOG '[class#heap#binary] beyond heap range: 0-' . l:iend
    elseif l:index == l:iend - 1
        call self.erase_end()
    else
        call self.swap(l:index, l:iend - 1)
        call self.erase_end()
        call self.shift_down(l:index)
    endif
    return self
endfunction "}}}

" build: build heap from an ready list
function! s:class.build(list) dict abort "{{{
    if !empty(self.heap)
        : ELOG '[class#heap#binary] the heap alreay built'
        return self
    else
        let self.heap = a:list
    endif

    let l:index = 0
    let l:iend = len(self.heap)
    let l:ihalf = (l:iend - 1) / 2
    while l:index >= 0
        call self.UpdateIndex(l:index)
        if l:index <= l:ihalf
            call slef.shift_down(l:index)
        endif
        let l:index -= 1
    endwhile

    return self
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#heap#binary is loading ...'
function! class#heap#binary#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#heap#binary#test(...) abort "{{{
    let l:obj = class#heap#binary#new()
    let l:iMax = get(a:000, 0, 10) + 0

    let l:rand = []
    let l:randit = class#math#randit#new(l:iMax)
    for _ in range(l:iMax)
        let l:iNumber = l:randit.Next()
        call add(l:rand, l:iNumber)
        call l:obj.push(l:iNumber)
    endfor

    echo 'rand list = ' . string(l:rand)
    echo 'heap list = ' . string(l:obj.heap)

    let l:sort = []
    for _ in range(l:iMax)
        let l:iNumber = l:obj.pop()
        call add(l:sort, l:iNumber)
    endfor

    echo 'sort list = ' . string(l:sort)
    echo 'heap list = ' . string(l:obj.heap)

    return 0
endfunction "}}}
