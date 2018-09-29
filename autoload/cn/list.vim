" File: list
" Author: lymslive
" Description: list util
" Create: 2018-09-29
" Modify: 2018-09-29

" Func: s:class 
" Desc: A wrapper class of list. When the mothed modify self, return self to
" support mechod chain, such as `call jList.filter(?).map(?).sort(?).uniq(?)`
function! s:class() abort "{{{
    if exists('s:class')
        return s:class
    endif

    let s:class = {}
    let s:class.list_ = []

    " Method: list 
    function! s:class.list() dict abort "{{{
        return self.list_
    endfunction "}}}

    " Method: string 
    function! s:class.string() dict abort "{{{
        return string(self.list_)
    endfunction "}}}

    " Method: get 
    function! s:class.get(idx, ...) dict abort "{{{
        return get(self.list_, a:idx, get(a:,0,0))
    endfunction "}}}

    " Method: len 
    function! s:class.len() dict abort "{{{
        return len(self.list_)
    endfunction "}}}

    " Method: empty 
    function! s:class.empty() dict abort "{{{
        return empty(self.list_)
    endfunction "}}}

    " Method: join 
    function! s:class.join(...) dict abort "{{{
        return join(self.list_, get(a:,0,' '))
    endfunction "}}}

    " Method: call 
    function! s:class.call(func, ...) dict abort "{{{
        return a:0 ? call(a:func, self.list_, a:1) : call(a:func, self.list_)
    endfunction "}}}

    " Method: index 
    function! s:class.index(val, ...) dict abort "{{{
        reutrn a:0 ? call('index', [self.list_, a:val] + a:) : index(self.list_, a:val)
    endfunction "}}}

    " Method: max 
    function! s:class.max() dict abort "{{{
        return max(self.list_)
    endfunction "}}}

    " Method: min 
    function! s:class.min() dict abort "{{{
        return min(self.list_)
    endfunction "}}}

    " Method: count 
    function! s:class.count(val, ...) dict abort "{{{
        reutrn a:0 ? call('count', [self.list_, a:val] + a:) : count(self.list_, a:val)
    endfunction "}}}

    " Method: insert 
    function! s:class.insert(item, ...) dict abort "{{{
        call insert(self.list_, get(a:,0,0), a:item)
        return self
    endfunction "}}}

    " Method: add 
    function! s:class.add(item) dict abort "{{{
        call add(self.list_, a:item)
        return self
    endfunction "}}}

    " Method: extend 
    function! s:class.extend(list) dict abort "{{{
        call extend(self.list_, a:list, get(a:,0,len(self.list_)))
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

    return s:class
endfunction "}}}

" Func: s:new 
function! s:new(list, ...) abort "{{{
    let l:obj = copy(s:class)
    if a:0 == 0
        let l:list = a:list
    else
        let l:list = [a:list] + a:000
    endif
    let l:obj.list_ = l:list
    return l:obj
endfunction "}}}
