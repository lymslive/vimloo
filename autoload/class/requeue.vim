" Class: class#requeue
" Author: lymslive
" Description: a fixed queue, only add, only remove when full
" Create: 2017-03-13
" Modify: 2017-03-15

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#requeue'
let s:class._version_ = 1

" fixed size array
let s:class.capacity = 0
let s:class.array = []
" the vaild array content is [head, tail)
let s:class.head = 0
let s:class.tail = 0
" head and tail will wrap around when to end
" full if head == tail again

function! class#requeue#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: requeue(capacity, [init-array])
function! class#requeue#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#requeue#ctor(this, argv) abort "{{{
    let l:argc = len(a:argv)
    if l:argc < 1 || type(a:argv[0]) != type(0)
        :ELOG 'class#queue need a capacity'
        return -1
    endif

    let a:this.capacity = a:argv[0]
    let a:this.array = repeat([''], a:this.capacity)
    let a:this.head = -1
    let a:this.tail = -1

    if l:argc > 1
        call a:this.Fill(a:argv[1])
    endif

    return 0
endfunction "}}}

" ISOBJECT:
function! class#requeue#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Size: 
function! s:class.Size() dict abort "{{{
    if self.head < 0
        return 0
    endif

    if self.tail > self.head
        return self.tail - self.head
    else
        return self.tail - self.head + self.capacity
    endif
endfunction "}}}

" MaxSize: 
function! s:class.MaxSize() dict abort "{{{
    return self.capacity
endfunction "}}}

" IsFull: 
function! s:class.IsFull() dict abort "{{{
    return self.head >= 0 && self.head == self.tail
endfunction "}}}

" IsEmpty: 
function! s:class.IsEmpty() dict abort "{{{
    return self.head < 0 && self.tail < 0
endfunction "}}}

" Clear: 
function! s:class.Clear() dict abort "{{{
    call map(self.array, '""')
    let self.head = -1
    let self.tail = -1
    return self
endfunction "}}}

" Add: add a item to tail, or rearrange to tail if already existed
function! s:class.Add(item) dict abort "{{{
    " first item
    if self.IsEmpty()
        let self.array[0] = a:item
        let self.head = 0
        let self.tail = 1
        return self
    endif

    " already in the tail
    if a:item == self.array[self.tail-1]
        return self
    endif

    let l:size = self.Size()
    let l:scan = 0
    let l:bFound = v:false

    " re-add old item?
    let l:idx = self.head
    while l:scan < l:size
        if l:idx >= self.capacity
            let l:idx = 0
        endif

        let l:item = self.array[l:idx]
        if l:item == a:item && !l:bFound
            let l:bFound = v:true
        elseif l:bFound
            let self.array[l:idx-1] = self.array[l:idx]
        endif

        let l:idx += 1
        let l:scan += 1
    endwhile

    if l:bFound
        let self.array[l:idx-1] = a:item
        return self
    endif

    " add new item
    let self.array[self.tail] = a:item
    let self.tail += 1
    if self.tail >= self.capacity
        let self.tail = 0
    endif

    " full array
    if l:size == self.capacity
       let self.head = self.tail
    endif

    return self
endfunction "}}}

" Normalize: return a normalized list
function! s:class.Normalize() dict abort "{{{
    if self.IsEmpty()
        return []
    endif

    if self.tail > self.head
        return self.array[self.head : self.tail - 1]
    endif

    let l:list = self.array[self.head : ]
    if self.tail > 0
        call extend(l:list, self.array[0 : self.tail - 1])
    endif

    return l:list
endfunction "}}}
" list: 
function! s:class.list() dict abort "{{{
    return self.Normalize()
endfunction "}}}

" Resize: 
function! s:class.Resize(capacity) dict abort "{{{
    if self.capacity == a:capacity
        return self
    endif

    let l:list = self.Normalize()
    let l:size = self.Size()

    if self.capacity < a:capacity
        call extend(l:list, repeat([''], a:capacity - self.capacity))
        let self.array = l:list
    else
        let self.array = l:list[0 : a:capacity - 1]
    endif

    let self.head = 0
    let self.tail = l:size

    return self
endfunction "}}}

" Fill: fill the queue, option a:1 is bIgnoreEmpty
function! s:class.Fill(array, ...) dict abort "{{{
    if self.IsFull() || empty(a:array)
        return self
    endif

    if type(a:array) != type([])
        :ELOG 'requeue.fill expect a list'
        return self
    endif

    let l:bIgnoreEmpty = get(a:000, 0, v:false)

    let l:left = self.MaxSize() - self.Size()

    if self.head < 0
        let self.head = 0
    endif
    if self.tail < 0
        let self.tail = 0
    endif

    let l:count = 0
    for l:item in a:array
        if l:count >= l:left
            break
        endif

        if empty(l:item) && l:bIgnoreEmpty
            continue
        endif

        let self.array[self.tail] = l:item
        let self.tail += 1
        let l:count += 1
    endfor

    return self
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#queue is loading ...'
function! class#requeue#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#requeue#test(...) abort "{{{
    let l:jObj = class#requeue#new(5)
    for l:item in range(1, 10)
        call l:jObj.Add(l:item)
        echo 'add item: ' . l:item
        echo 'obj.array:'
        echo l:jObj.array
        echo 'obj.list():'
        echo l:jObj.list()
        echo '-----'
    endfor

    for l:item in range(10, 6, -1)
        call l:jObj.Add(l:item)
        echo 'add item: ' . l:item
        echo 'obj.array:'
        echo l:jObj.array
        echo 'obj.list():'
        echo l:jObj.list()
        echo '-----'
    endfor

    return 0
endfunction "}}}
