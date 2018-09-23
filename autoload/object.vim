" File: object
" Author: lymslive
" Description: VimL top object design
" Create: 2018-09-19
" Modify: 2018-09-19

" Import Part:
let s:error = package#imports('package', 'error')

" Export Part:
function! object#class() abort "{{{
    return s:object
endfunction "}}}

" Object Class Define: "{{{1
let s:PARENT = '@ISA'
let s:object = {}
let s:object[s:PARENT] = []

" Method API: universal getter.
" will look up field upward in @ISA, and lazy copy down if found.
" when found field if funcref, call it, otherwise return directlly.
" may provide a optional default, return it when filed not found.
function! s:object_get(field, ...) dict abort "{{{
    call s:lazy_check(self, a:field)

    if !has_key(self, a:field) && a:0 > 0
        return a:1
    endif

    " when field not exists, raise abort by vim itself
    let l:Ref = self[a:field]
    if type(l:Ref) == v:t_func
        return l:Ref()
    else
        return l:Ref
    endif
endfunction "}}}
let s:object.get = function('s:object_get')

" Method API: universal setter. much like getter.
" but when found field as funcref, call it with a:value.
" return self.
function! s:object_set(field, value) dict abort "{{{
    call s:lazy_check(self, a:field)
    let l:Ref = self[a:field]
    if type(l:Ref) == v:t_func
        call l:Ref(a:value)
    else
        let self[a:field] = a:value
    endif
    return self
endfunction "}}}
let s:object.set = function('s:object_set')

" Method API: universal caller. much like setter. 
" call the found field with all optional argument.
" return the returned value from the real function.
function! s:object_call(field, ...) dict abort "{{{
    call s:lazy_check(self, a:field)
    let l:Ref = self[a:field]
    return call(l:Ref, a:000)
endfunction "}}}
let s:object.call = function('s:object_call')

" Method API: has
" check whether an object has a list of fields, return true/false.
function! object#has(obj, ...) abort "{{{
    for l:field in a:000
        let l:ok = s:lazy_check(a:obj, l:field)
        if !l:ok
            return v:false
        endif
    endfor
    return v:true
endfunction "}}}
function! s:object.has(...) dict abort "{{{
    return call('object#has', [self] + a:000)
endfunction "}}}

" New Class Derived: "{{{1

" Function API: create a new object or class.
" the optional argument is it's parent list.
" each parent is a dict or string from where can import a dict.
function! object#new(...) abort "{{{
    let l:obj = copy(s:object)
    for l:base in a:000
        if type(l:base) == v:t_string
            let l:base = package#import(l:base)
        endif
        if type(l:base) == v:t_dict
            call add(l:obj[s:PARENT], l:base)
        else
            call s:error('parent must be dict object, or can import form string.')
        endif
    endfor
    return l:obj
endfunction "}}}

" Command API: CLASS name [: baseA baseB]
" create a new class with command, used in script level.
function! s:new_class(dstpack, name, ...) abort "{{{
    if type(a:dstpack) != type('')
        return s:error('argument error, import to where, expect a path')
    endif

    let l:autopath = s:auto_name(a:dstpack)
    " must have #package() to return s:, or let it abort on error
    let l:dstpack = {l:autopath}#package()
    if type(l:dstpack) != v:t_dict
        return s:error('#package() should return a dict')
    endif

    if a:0 == 0
        let l:dstpack[a:name] = object#new();
    elseif a:0 > 2 && a:2 ==# ':'
        let l:dstpack[a:name] = call('object#new', a:000[2:]);
    else
        return s:error('CLASS name [: parent class name list]')
    endif

    return 1
endfunction "}}}
command! -nargs=+ CLASS call s:new_class(expand('<sfile>:p'), <f-args>)

" Helper Utils: "{{{1

" Impletement: lazy_check 
" return true/false if object has fields.
" when checking, maybe copy fields from parent classes.
function! s:lazy_check(obj, field) abort "{{{
    let [l:ok, l:Ref] = s:upsearch(a:obj, a:field)
    if !l:ok
        return v:false
    endif
    if !has_key(a:obj, a:field)
        let a:obj[a:field] = deepcopy(l:Ref)
    endif
    return v:true
endfunction "}}}

" Impletement: upsearch 
" recursively search a filed in object and it's parent tree,
" return list with tow item [ok, Ref].
" when ok is true, Ref is valid value of the field.
function! s:upsearch(obj, field) abort "{{{
    if has_key(a:obj, a:field)
        let l:Ref = a:obj[a:field]
        return [v:true, l:Ref]
    endif

    let l:ok = v:false
    let l:Ref = 0
    let l:isa = get(a:obj, s:PARENT, [])
    for l:base in l:isa
        let [l:ok, l:Ref] = s:upsearch(l:base, a:field)
        if l:ok
            break
        endif
    endfor

    return [l:ok, l:Ref]
endfunction "}}}

