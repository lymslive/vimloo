" File: dict
" Author: lymslive
" Description: dict util
" Create: 2018-09-29
" Modify: 2018-09-29

" Func: s:list 
" Desc: flat a dict to list with key and value by turn.
function! s:list(dict) abort "{{{
    let l:list = []
    for [l:key, l:Val] in items(a:dict)
        call extend(l:list, [l:key, l:Val])
    endfor
    return l:list
endfunction "}}}

" Func: s:dict 
" Desc: return a new dict with only data key, may cut off from object.
function! s:dict(dict) abort "{{{
    let l:dict = {}
    for [l:key, l:Val] in items(a:dic)
        if type(l:Val) != v:t_func
            let l:dict[l:key] = l:Val
        endif
    endfor
    return l:dict
endfunction "}}}

" Func: s:zeros 
function! s:zeros(dict) abort "{{{
    call map(a:dict, '0')
endfunction "}}}

" Func: s:class 
function! s:class() abort "{{{
    if exists('s:class')
        return s:class
    endif

    let s:class = {}

    " SECTION: four primary data type conversion.

    " Method: number 
    function! s:class.number() dict abort "{{{
        return len(self.dict())
    endfunction "}}}

    " Method: string 
    function! s:class.string() dict abort "{{{
        return string(self.dict())
    endfunction "}}}

    " Method: list 
    function! s:class.list() dict abort "{{{
        return s:list(self.dict())
    endfunction "}}}

    " Method: dict 
    function! s:class.dict() dict abort "{{{
        return s:dict(self)
    endfunction "}}}

    " SECTION: builtin wrapper

    " Method: len 
    function! s:class.len() dict abort "{{{
        return len(self.dict())
    endfunction "}}}

    " Method: empty 
    function! s:class.empty() dict abort "{{{
        return empty(self.dict())
    endfunction "}}}

    " Method: max 
    function! s:class.max() dict abort "{{{
        return max(self.dict())
    endfunction "}}}

    " Method: min 
    function! s:class.min() dict abort "{{{
        return min(self.dict())
    endfunction "}}}

    " Method: count 
    function! s:class.count(val, ...) dict abort "{{{
        reutrn a:0 ? call('count', [self.dict(), a:val] + a:) : count(self.dict(), a:val)
    endfunction "}}}

    " Method: has_key 
    function! s:class.has_key(key) dict abort "{{{
        return has_key(self.dict(), a:key)
    endfunction "}}}

    " Method: keys 
    function! s:class.keys() dict abort "{{{
        return keys(self.dict())
    endfunction "}}}

    " Method: values 
    function! s:class.values() dict abort "{{{
        return values(self.dict())
    endfunction "}}}

    " Method: items 
    function! s:class.items() dict abort "{{{
        return items(self.dict())
    endfunction "}}}

    " Method: copy 
    function! s:class.copy() dict abort "{{{
        return deepcopy(self)
    endfunction "}}}

    " Method: remove 
    function! s:class.remove(key) dict abort "{{{
        call remove(self, a:key)
        return self
    endfunction "}}}

    " Method: extend 
    function! s:class.extend(dict, ...) dict abort "{{{
        call extend(self, a:dict, get(a:000,0,'force'))
        return self
    endfunction "}}}

    " Method: filter 
    function! s:class.filter(exp) dict abort "{{{
        let l:dict = filter(self.dict(), a:exp)
        return s:new(l:dict)
    endfunction "}}}

    " Method: map 
    function! s:class.map(exp) dict abort "{{{
        let l:dict = map(self.dict(), a:exp)
        return s:new(l:dict)
    endfunction "}}}

    " SECTION: extra custom function

endfunction "}}}

" Func: s:new 
" Desc: make the wrapper object of a dict, attatch methods to it.
function! s:new(dict) abort "{{{
    call extend(a:dict, s:class())
    return a:dict
endfunction "}}}
