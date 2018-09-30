" File: dict
" Author: lymslive
" Description: dict util
" Create: 2018-09-29
" Modify: 2018-09-29

" Func: s:valid_key 
function! s:valid_key(key) abort "{{{
    return !empty(a:key) && (type(a:key) == v:t_string || type(a:key) == v:t_dict)
endfunction "}}}

" Func: s:list 
" Desc: flat a dict to list with key and value by turn.
function! s:list(dict) abort "{{{
    let l:list = []
    for [l:key, l:Val] in items(a:dict)
        call extend(l:list, [l:key, l:Val])
    endfor
    return l:list
endfunction "}}}

" Func: s:struct 
" Desc: return a new dict with only data keys, may cut off from object.
function! s:struct(dict) abort "{{{
    let l:dict = {}
    for [l:key, l:Val] in items(a:dic)
        if type(l:Val) != v:t_func
            let l:dict[l:key] = l:Val
        endif
    endfor
    return l:dict
endfunction "}}}

" Func: s:method 
" Desc: return a new dict with only funcref keys.
function! s:method(dict) abort "{{{
    let l:dict = {}
    for [l:key, l:Val] in items(a:dic)
        if type(l:Val) == v:t_func
            let l:dict[l:key] = l:Val
        endif
    endfor
    return l:dict
endfunction "}}}

" Func: s:dict 
" Desc: make a dict from a list keys and another list of values, or use a:1
" as default value for some keys.
function! s:dict(key, val, ...) abort "{{{
    let l:dict = {}
    let l:default = a:0 ? a:1 : 0
    if type(a:key) == v:t_list && type(a:val) == v:t_list
        for l:idx in range(len(a:key))
            let l:dict[l:key[l:idx]] = get(a:val, l:idx, l:default)
        endfor
    endif
    return l:dict
endfunction "}}}

" Func: s:set 
" Desc: make a dict as set, with keys from a list and fill value with 1 by default.
function! s:set(list, ...) abort "{{{
    let l:val = a:0 ? a:1 : 1
    return s:dict(a:list, [], l:val)
endfunction "}}}

" Func: s:reverse 
function! s:reverse(dict) abort "{{{
    return s:dict(values(a:dict), keys(a:dict))
endfunction "}}}

" Func: s:zeros 
function! s:zeros(dict) abort "{{{
    call map(a:dict, '0')
endfunction "}}}

" Func: s:clear 
function! s:clear(dict) abort "{{{
    for l:key in keys(a:dict)
        call remove(a:dict, l:key)
    endfor
    return a:dict
endfunction "}}}

" Func: s:resize 
" Desc: make a new dict with only such keys, can also add new keys with
" optional value which default 1.
function! s:resize(dict, keys, ...) abort "{{{
    let l:dict = {}
    let l:val = a:0 ? a:1 : 1
    for l:key in a:keys
        if has_key(a:dict, l:key)
            let l:dict[l:key] = a:dict[l:key]
        else
            let l:dict[l:key] = l:val
        endif
    endfor
    return l:dict
endfunction "}}}

" Func: s:class 
function! s:class() abort "{{{
    if exists('s:class')
        return s:class
    endif

    let s:class = {}
    let s:class.dict_ = {}

    " SECTION: four primary data type conversion.

    " Method: number 
    function! s:class.number() dict abort "{{{
        return len(self.dict_)
    endfunction "}}}

    " Method: string 
    function! s:class.string() dict abort "{{{
        return string(self.dict_)
    endfunction "}}}

    " Method: list 
    function! s:class.list() dict abort "{{{
        return s:list(self.dict_)
    endfunction "}}}

    " Method: dict 
    function! s:class.dict() dict abort "{{{
        return self.dict_
    endfunction "}}}

    " SECTION: builtin wrapper

    " Method: len 
    function! s:class.len() dict abort "{{{
        return len(self.dict_)
    endfunction "}}}

    " Method: empty 
    function! s:class.empty() dict abort "{{{
        return empty(self.dict_)
    endfunction "}}}

    " Method: get 
    function! s:class.get(key, ...) dict abort "{{{
        return get(self.dict_, a:key, get(a:000,0,0))
    endfunction "}}}

    " Method: max 
    function! s:class.max() dict abort "{{{
        return max(self.dict_)
    endfunction "}}}

    " Method: min 
    function! s:class.min() dict abort "{{{
        return min(self.dict_)
    endfunction "}}}

    " Method: count 
    function! s:class.count(val, ...) dict abort "{{{
        reutrn a:0 ? call('count', [self.dict_, a:val] + a:) : count(self.dict_, a:val)
    endfunction "}}}

    " Method: has_key 
    function! s:class.has_key(key) dict abort "{{{
        return has_key(self.dict_, a:key)
    endfunction "}}}

    " Method: keys 
    function! s:class.keys() dict abort "{{{
        return keys(self.dict_)
    endfunction "}}}

    " Method: values 
    function! s:class.values() dict abort "{{{
        return values(self.dict_)
    endfunction "}}}

    " Method: items 
    function! s:class.items() dict abort "{{{
        return items(self.dict_)
    endfunction "}}}

    " Method: copy 
    function! s:class.copy() dict abort "{{{
        return deepcopy(self)
    endfunction "}}}

    " Method: remove 
    function! s:class.remove(key) dict abort "{{{
        call remove(self.dict_, a:key)
        return self
    endfunction "}}}

    " Method: extend 
    function! s:class.extend(dict, ...) dict abort "{{{
        call extend(self.dict_, a:dict, get(a:000,0,'force'))
        return self
    endfunction "}}}

    " Method: filter 
    function! s:class.filter(exp) dict abort "{{{
        call filter(self.dict_, a:exp)
        return self
    endfunction "}}}

    " Method: map 
    function! s:class.map(exp) dict abort "{{{
        call map(self.dict_, a:exp)
        return self
    endfunction "}}}

    " SECTION: extra custom function

    " Method: zeros 
    function! s:class.zeros() dict abort "{{{
        call s:zeros(self.dict_)
        return self
    endfunction "}}}

    " Method: clear 
    function! s:class.clear() dict abort "{{{
        call s:clear(self.dict_)
        return self
    endfunction "}}}

    " Method: resize 
    function! s:class.resize(kyes, ...) dict abort "{{{
        let self.dict_ = s:resize(self.dict_, a:keys, get(a:000, 0, 1))
        return self
    endfunction "}}}

    " Method: reverse 
    function! s:class.reverse() dict abort "{{{
        let self.dict_ = s:reverse(self.dict_)
        return self
    endfunction "}}}

endfunction "}}}

" Func: s:new 
" Desc: make the wrapper object of a dict, attatch methods to it.
function! s:new(dict) abort "{{{
    let l:obj = copy(s:class())
    let l:obj.dict_ = a:dict
    return l:obj
endfunction "}}}
