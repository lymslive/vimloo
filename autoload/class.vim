" File: class.vim 
" Author: lymslive
" Description: base class for vimL
" Create: 2017-02-07
" Modify: 2017-08-14

if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" Universe Dummy Clsss: {{{1
let s:class = {}
let s:class._name_ = 'class'
let s:class._version_ = 2
let s:class._mother_ = 'class'

" class: with no arg, return the class dict of this base class
" with one arg, get the class dict by class name, or empty dict
function! class#class(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        return s:class
    endif

    let l:name = a:1
    if type(l:name) != type('')
        return {}
    endif

    let l:name = substitute(l:name, '[./]\+', '#', 'g')
    try
        let l:class = eval(l:name . '#class()')
    catch
        let l:name = 'class#' . l:name
        try
            let l:class = eval(l:name . '#class()')
        catch
            let l:class = {}
        endtry
    endtry

    return l:class
endfunction "}}}

" ctor: dummy function
function! class#ctor(this, ...) abort "{{{
endfunction "}}}

" dector: 
function! class#dector(this) abort "{{{
endfunction "}}}

" Create Child Object And Class: {{{1

" import helper functions
let s:Fdict = class#less#dict#export()
function! s:CopyDict(dTarget, dSource, dOption) abort "{{{
    if empty(a:dSource)
        return a:dTarget
    endif
    return s:Fdict.CopyDict(a:dTarget, a:dSource, a:dOption)
endfunction "}}}

let s:dNewOption = {'ignorex': '^_.*_$'}
let s:dOldOption = {'ignorex': '^_.*_$'}
let s:dFatherOption = {'ignorex': '.*_$', 'func': v:false, 'old': v:false}
let s:dMasterOption = {'ignorex': '.*_$', 'data': v:false, 'old': v:false}

" GetClass: 
function! s:GetClass(class) abort "{{{
    if type(a:class) == type('')
        let l:class = class#class(a:class)
    elseif type(a:class) == type({})
        let l:class = a:class
    else
        let l:class = {}
    endif
    return l:class
endfunction "}}}

" CreateObject: 
function! s:CreateObject(class) abort "{{{
    let l:class = a:class
    let l:obj = {}

    let l:option = copy(s:dNewOption)
    if has_key(l:class, '_static_')
        let l:option.ignores = l:class._static_
    endif
    " no need copy for s:class._object_
    let l:option.copy = 0
    let l:obj = s:CopyDict(l:obj, l:class, l:option)

    " convert master class name to class reference at the first time
    if has_key(l:class, '_master_')
        for i in range(len(l:class._master_))
            let l:CMaster = l:class._master_[i]
            if type(l:CMaster) != 4
                let l:CMaster = s:GetClass(l:CMaster)
                let l:class._master_[i] = l:CMaster
            endif
            call s:CopyDict(l:obj, l:CMaster, s:dMasterOption)
        endfor
        unlet! i
    endif

    if has_key(l:class, '_father_')
        for i in range(len(l:class._father_))
            let l:CFather = l:class._father_[i]
            if type(l:CFather) != 4
                let l:CFather = s:GetClass(l:CFather)
                let l:class._father_[i] = l:CFather
            endif
            call s:CopyDict(l:obj, l:CFather, s:dFatherOption)
        endfor
        unlet! i
    endif

    return l:obj
endfunction "}}}

" new: create a instance object of named class
" a:1, class name or class dict, when empty, use this s:class
" a:2, argument list for class ctor passed by subclass#new
function! class#new(...) abort "{{{
    if a:0 == 0
        return {}
    endif

    let l:class = s:GetClass(a:1)
    let l:argv = get(a:000, 1, [])
    if empty(l:class)
        echoerr '[class#new] expect class dict or class name'
        return {}
    endif

    " create _object_ at the first time
    if !has_key(l:class, '_object_') || empty(l:class._object_)
        let l:class._object_ = s:CreateObject(l:class)
    endif
    let l:obj = deepcopy(l:class._object_)
    let l:obj._class_ = l:class

    " call #ctor function
    try
        let l:Ctor = function(l:class._name_ . '#ctor')
        let l:argv = extend([l:obj], l:argv)
        call call(l:Ctor, l:argv)
    catch /E117/
        " no #ctor is allowed
    endtry

    return l:obj
endfunction "}}}

" old: create a new class from base class
" class#old(mother, [master-list], [father-list])
" a:1, base class name or class dict, when empty, use this s:class
" a:2, list of master
" a:3, list of father
" return, child class, _mother_ is set to base class reference
function! class#old(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        return {}
        let l:CBase = s:class
    else
        let l:CBase = s:GetClass(a:1)
    endif

    if empty(l:CBase)
        echoerr '[class#old] expect class dict or class name'
        return {}
    endif

    if !has_key(l:CBase, '_protect_')
        let l:class = s:CopyDict({}, l:CBase, s:dOldOption)
    else
        let l:option = copy(s:dOldOption)
        let l:option.ignores = l:class._protect_
        let l:class = s:CopyDict({}, l:CBase, l:option)
    endif
    let l:class._mother_ = l:CBase

    if a:0 >= 2 && type(a:2) == type([])
        let l:class._master_ = a:2
    endif
    if a:0 >= 3 && type(a:3) == type([])
        let l:class._master_ = a:3
    endif

    return l:class
endfunction "}}}

" delete: 
function! class#delete(this) abort "{{{
    let l:class = a:this._class_

    let l:Dector = class#GetDector(l:class)
    if exists('*l:Dector')
        call l:Dector(a:this)
    endif

    let l:lsSuper = class#Supers(l:class)
    for l:CBase in l:lsSuper
        let l:Dector = class#GetDector(l:CBase)
        if exists('*l:Dector')
            call l:Dector(a:this)
        endif
    endfor
endfunction "}}}
" free: 
function! class#free(this) abort "{{{
    call class#delete(a:this)
endfunction "}}}

" Query Class Relation: {{{1

" Supers: return a list of super classes in derived path upto top
" a:class, class name or already class dict
" a:1, defaut return list of class reference, 
"      non-empty a:1 will return class name
function! class#Supers(class, ...) abort "{{{
    let l:class = s:GetClass(a:class)

    let l:lsSuper = []
    let l:CBase = get(l:class, '_mother_', {})
    while !empty(l:CBase)
        call add(l:lsSuper, l:CBase)
        let l:CBase = get(l:CBase, '_mother_', {})
    endwhile

    if a:0 > 0 && !empty(a:1)
        call map(l:lsSuper, "get(v:al, '_name_', '')")
    endif
    return l:lsSuper
endfunction "}}}

" GetCtor: 
function! class#GetCtor(class) abort "{{{
    let l:class = s:GetClass(a:class)

    let l:name = get(l:class, '_name_', '')
    if empty(l:name)
        return function('class#ctor')
    endif

    let l:Ctor = function(l:name . '#ctor')
    if !exists('*l:Ctor')
        let l:Ctor = function('class#ctor')
    endif
    return l:Ctor
endfunction "}}}

" GetDector: 
function! class#GetDector(class) abort "{{{
    let l:class = s:GetClass(a:class)

    let l:name = get(l:class, '_name_', '')
    if empty(l:name)
        return function('class#ctor')
    endif

    let l:Dector = function(l:name . '#dector')
    if !exists('*l:Dector')
        let l:Dector = function('class#dector')
    endif
    return l:Dector
endfunction "}}}

" Suctor: 
function! class#Suctor(class) abort "{{{
    let l:class = s:GetClass(a:class)

    if !has_key(l:class, '_mother_') || empty(l:class._mother_)
        return function('class#ctor')
    else
        return class#GetCtor(l:class._mother_)
    endif
endfunction "}}}

" Sudector: 
function! class#Sudector(class) abort "{{{
    let l:class = s:GetClass(a:class)

    if !has_key(l:class, '_mother_') || empty(l:class._mother_)
        return function('class#dector')
    else
        return class#GetDector(l:class._mother_)
    endif
endfunction "}}}

" extend: 
function! class#extend(CTarget, CSource, ...) abort "{{{
    let l:dOption = get(a:000, 0, {})
    return s:CopyDict(a:CTarget, a:CSource, l:dOption)
endfunction "}}}

let class#father = s:dFatherOption
let class#master = s:dMasterOption
" AddFather: 
function! class#AddFather(CTarget, CSource) abort "{{{
    if !has_key(a:CSource, '_name_')
        echoerr '[class#AddFather] CSource has no class name?'
        return -1
    endif
    if !has_key(a:CTarget, '_father_')
        let a:CTarget._father_ = [a:CSource._name_]
    else
        call add(a:CTarget._father_, a:Source._name_)
    endif
endfunction "}}}
" AsFather: 
function! class#AsFather(CTarget, CSource, ...) abort "{{{
    let l:dOption = get(a:000, 0, class#father)
    if type(l:dOption) != type({})
        let l:dOPtion = class#father
    endif
    return class#extend(a:CTarget, a:CSource, l:dOption)
endfunction "}}}

" AddMaster: 
function! class#AddMaster(CTarget, CSource) abort "{{{
    if !has_key(a:CSource, '_name_')
        echoerr '[class#AddMaster] CSource has no class name?'
        return -1
    endif
    if !has_key(a:CTarget, '_master_')
        let a:CTarget._master_ = [a:CSource._name_]
    else
        call add(a:CTarget._master_, a:Source._name_)
    endif
endfunction "}}}
" AsMaster: 
function! class#AsMaster(CTarget, CSource, ...) abort "{{{
    let l:dOption = get(a:000, 0, class#father)
    if type(l:dOption) != type({})
        let l:dOPtion = class#master
    endif
    return class#extend(a:CTarget, a:CSource, l:dOption)
endfunction "}}}

" isobject: 
" isobect(class/name, objcet_variable)
function! class#isobject(...) abort "{{{
    if a:0 == 0
        return s:false
    elseif a:0 == 1
        let l:class = s:class
        let l:object = a:1
    else
        let l:class = s:GetClass(a:1)
        let l:object = a:2
    endif

    if type(l:object) == type({}) && get(l:object, '_class_', {}) is l:class 
        return s:true
    else
        return s:false
    endif
endfunction "}}}

" isa: 
" isa(class/name, objcet_variable)
function! class#isa(...) abort "{{{
    if a:0 == 0
        return s:false
    elseif a:0 == 1
        let l:class = s:class
        let l:object = a:1
    else
        let l:class = s:GetClass(a:1)
        let l:object = a:2
    endif

    if type(l:object) != 4 || type(l:class) != 4
        return s:false
    endif

    let l:CObject = get(l:object, '_class_', {})
    if empty(l:CObject)
        return s:false
    endif

    if l:CObject is l:class
        return s:true
    endif

    let l:CBase = get(l:COject, '_mother_', {})
    while !empty(l:CBase)
        if l:CBase is l:class
            return s:true
        endif
        let l:CBase = get(l:CBase, '_mother_', {})
    endwhile

    " check any master or father of a:objcet is a:class
    if has_key(l:CObject, '_master_')
        for l:CMaster in l:CObject._master_
            if type(l:CMaster) == 4 && l:CMaster is l:class
                return s:true
            elseif type(l:CMaster) == 1 && l:CMaster ==# get(l:class, '_name_', '')
                return s:true
            endif
        endfor
    endif

    if has_key(l:CObject, '_father_')
        for l:CFather in l:CObject._father_
            if type(l:CFather) == 4 && l:CFather is l:class
                return s:true
            elseif type(l:CFather) == 1 && l:CFather ==# get(l:class, '_name_', '')
                return s:true
            endif
        endfor
    endif

    return s:false
endfunction "}}}

" echo: display class or object meber
" -a, include reserved keys, -m, include method keys
function! class#echo(class, ...) abort "{{{
    let l:class = s:GetClass(a:class)
    if empty(l:class)
        echo 'emplty class/objcet dictionary'
        return
    endif

    call s:Fdict.PrintClass(l:class, get(a:000, 0, ''))
endfunction "}}}

" Class Package Manager: {{{1

" record the used classes in this dictionary, to reuse faster later
let s:used = {}
let s:pack_default = ['new', 'isobject']

" use: pack a class file definition
" a:class, class name or dict var
" a:1, #function name list, default only 'new'
function! class#use(class, ...) abort "{{{
    let l:class = s:GetClass(a:class)
    let l:sName = get(l:class, '_name_', '')
    if empty(l:class) || empty(l:sName)
        return {}
    endif

    if !has_key(s:used, l:sName)
        if a:0 < 1 || empty(a:1)
            let l:lsFunc = s:pack_default
        else
            let l:lsFunc = a:1
        endif

        let l:CPack = {}
        for l:sFunc in l:lsFunc
            let l:CPack[l:sFunc] = function(l:sName . '#' . l:sFunc)
        endfor

        let l:CPack.class = l:class
        let s:used[l:sName] = l:CPack
    else
        let l:CPack = s:used[l:sName]
        if a:0 > 0 && !empty(a:1)
            let l:lsFunc = a:1
            for l:sFunc in l:lsFunc
                " add more func key to the prev used class pack
                if !has_key(l:CPack, l:sFunc)
                    let l:CPack[l:sFunc] = function(l:sName . '#' . l:sFunc)
                endif
            endfor
        endif
    endif

    return CPack
endfunction "}}}

" Predefine Variable And Command: {{{1

" Boolean Value:
if exists('v:false')
    let s:false = v:false
    let s:true = v:true
else
    let s:false = 0
    let s:true = 1
endif

" Constant Defined:
let g:class#TRUE = 1
let g:class#FALSE = 0
let g:class#EMPTY = ''
let g:class#OK = 0
let g:class#ERROR = -1

" load micros command
call vimloo#micros#load()

" Load And Test: {{{1

" triggle to load this vimL file
let s:load = 1
function! class#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" unit test for this vimL file
function! class#test() abort "{{{
    let l:obj = class#new()
    let l:sub = class#old()
    echo 'l:obj = ' l:obj
    echo 'l:sub = ' l:sub
    return 1
endfunction "}}}

