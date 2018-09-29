" File: list
" Author: lymslive
" Description: list util
" Create: 2018-09-29
" Modify: 2018-09-29

" Func: s:flat 
" Desc: return a flatten list from multiply items or lists.
function! s:list(...) abort "{{{
    let l:result = []
    for l:list in a:000
        if type(l:item) == v:t_list
            for l:item in l:list
                call extend(l:list, s:list(l:item))
            endfor
        else
            call add(l:result, l:list)
        endif
    endfor
    return l:result
endfunction "}}}

" Func: s:dict 
" Desc: make a dict from every two items of a list,
" the last odd key may map to 0.
function! s:dict(list) abort "{{{
    if type(a:list) != v:t_list
        echoerr 's:todict expect a list argument'
        return {}
    endif
    let l:dict = {}
    let l:iend = len(a:list)
    let l:idx = 0
    while l:idx < l:iend
        let l:key = a:list[l:idx]
        let l:idx += 1
        let l:val = l:idx < l:iend ? a:list[l:idx] : 0
        let l:dict[l:key] = l:val
        let l:idx +=1
    endwhile
    return l:dict
endfunction "}}}

" Func: s:zeros 
" Desc: reset all items of a list to zero number.
function! s:zeros(list) abort "{{{
    call map(a:list, '0')
endfunction "}}}

" Func: s:resize 
" Desc: pre-resize the list length, truncat or pad with 0.
function! s:resize(list, size) abort "{{{
    if a:size <= 0
        return []
    endif
    let l:iend = len(a:list)
    if a:size < l:iend
        call remove(a:list, a:size, -1)
    else
        for l:idx in range(a:size-1 : l:iend : -1)
            let a:list[l:idx] = 0
        endfor
    endif
    return a:list
endfunction "}}}

" Func: s:has 
function! s:has(list, val) abort "{{{
    return index(a:list, a:val) != -1
endfunction "}}}

" Func: s:class 
" Desc: A wrapper class of list. When the mothed modify self, return self to
" support mechod chain, such as `call jList.filter(?).map(?).sort(?).uniq(?)`
function! s:class() abort "{{{
    if exists('s:class')
        return s:class
    endif

    let s:class = {}
    let s:class.list_ = []

    " SECTION: four primary data type conversion.

    " Method: number 
    function! s:class.number() dict abort "{{{
        return len(self.list_)
    endfunction "}}}

    " Method: string 
    function! s:class.string() dict abort "{{{
        return string(self.list_)
    endfunction "}}}

    " Method: list 
    function! s:class.list() dict abort "{{{
        return self.list_
    endfunction "}}}

    " Method: dict 
    function! s:class.dict() dict abort "{{{
        return s:dict(self.list_)
    endfunction "}}}

    " SECTION: builtin wrapper to query information of a list.

    " Method: len 
    function! s:class.len() dict abort "{{{
        return len(self.list_)
    endfunction "}}}

    " Method: empty 
    function! s:class.empty() dict abort "{{{
        return empty(self.list_)
    endfunction "}}}

    " Method: max 
    function! s:class.max() dict abort "{{{
        return max(self.list_)
    endfunction "}}}

    " Method: min 
    function! s:class.min() dict abort "{{{
        return min(self.list_)
    endfunction "}}}

    " Method: get 
    function! s:class.get(idx, ...) dict abort "{{{
        return get(self.list_, a:idx, get(a:000,0,0))
    endfunction "}}}

    " Method: index 
    function! s:class.index(val, ...) dict abort "{{{
        reutrn a:0 ? call('index', [self.list_, a:val] + a:) : index(self.list_, a:val)
    endfunction "}}}

    " Method: count 
    function! s:class.count(val, ...) dict abort "{{{
        reutrn a:0 ? call('count', [self.list_, a:val] + a:000) : count(self.list_, a:val)
    endfunction "}}}

    " Method: join 
    function! s:class.join(...) dict abort "{{{
        return join(self.list_, get(a:000,0,' '))
    endfunction "}}}

    " Method: call 
    function! s:class.call(func, ...) dict abort "{{{
        return a:0 ? call(a:func, self.list_, a:1) : call(a:func, self.list_)
    endfunction "}}}

    " SECTION: builtin wrapper to modify list, return list object self.

    " Method: insert 
    function! s:class.insert(item, ...) dict abort "{{{
        call insert(self.list_, get(a:000,0,0), a:item)
        return self
    endfunction "}}}

    " Method: add 
    function! s:class.add(item) dict abort "{{{
        call add(self.list_, a:item)
        return self
    endfunction "}}}

    " Method: extend 
    function! s:class.extend(list, ...) dict abort "{{{
        call extend(self.list_, a:list, get(a:000,0,len(self.list_)))
        return self
    endfunction "}}}

    " Method: remove 
    function! s:class.remove(idx, ...) dict abort "{{{
        let l:ret = a:0 ? remove(self.list_, a:idx, a:1) : remove(self.list_, a:idx)
        return self
    endfunction "}}}

    " Method: copy 
    function! s:class.copy() dict abort "{{{
        return deepcopy(self)
    endfunction "}}}

    " Method: filter 
    function! s:class.filter(exp) dict abort "{{{
        call filter(self.list_, a:exp)
        return self
    endfunction "}}}

    " Method: map 
    function! s:class.map(exp) dict abort "{{{
        call map(self.list_, a:exp)
        return self
    endfunction "}}}

    " Method: sort 
    function! s:class.sort(...) dict abort "{{{
        let l:ret = a:0 ? call('sort', [self.list_] + a:) : sort(self.list_)
        return self
    endfunction "}}}

    " Method: reverse 
    function! s:class.reverse() dict abort "{{{
        call reverse(self.list_)
        return self
    endfunction "}}}

    " Method: uniq 
    function! s:class.uniq(...) dict abort "{{{
        let l:ret = a:0 ? call('uniq', [self.list_] + a:) : uniq(self.list_)
        return self
    endfunction "}}}

    " Method: repeat 
    function! s:class.repeat(count) dict abort "{{{
        let self.list_ = repeat(self.list_, 0+a:count)
        return self
    endfunction "}}}

    " SECTION: extra custom function.

    " Method: has 
    function! s:class.has(val) dict abort "{{{
        return s:has(self.list_, a:val)
    endfunction "}}}

    " Method: zeros 
    function! s:class.zeros() dict abort "{{{
        call s:zeros(self.list_)
        return self
    endfunction "}}}

    " Method: resize 
    function! s:class.resize(size) dict abort "{{{
        let self.list_ = s:resize(self.list_)
        return self
    endfunction "}}}

    return s:class
endfunction "}}}

" Func: s:new 
" Desc: return the wrapper object of a list
function! s:new(list, ...) abort "{{{
    let l:obj = copy(s:class())
    let l:obj.list_ = s:list([a:list] + a:000)
    return l:obj
endfunction "}}}
