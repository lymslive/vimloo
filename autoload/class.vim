" File: class.vim 
" Author: lymslive
" Description: base class for vimL
" Create: 2017-02-07
" Modify: 2017-08-04

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

" GetClass: 
function! s:GetClass(class) abort "{{{
    if type(a:class) == type({})
        let l:class = a:class
    elseif type(a:class) == type('')
        let l:class = class#class(a:class)
    else
        let l:class = {}
    endif
    return l:class
endfunction "}}}

" ctor: dummy function
function! class#ctor(this, ...) abort "{{{
endfunction "}}}

" dector: 
function! class#dector(this) abort "{{{
endfunction "}}}

" CopyDict: copy keys from a dict into another, see extend()
" a:dTarget, the target dict, may change it's content
" a:dSource, the source dict, readonly
" a:dOption, contry how to copy, accepte keys:
"   data => bool, copy data key from dSource
"   func => bool, copy FuncRef key
"   new  => bool, add key when not in dTarget, if false, not add
"   old  => bool, overide key value that already in dTarget
"   ignore => regexp, ignore the key match regexp
"     ignore default empty, and other default true.
" return a:dTarget modified
function! s:CopyDict(dTarget, dSource, dOption) abort "{{{
    let l:bData = get(a:dOption, 'data', v:true)
    let l:bFunc = get(a:dOption, 'func', v:true)
    let l:bNew  = get(a:dOption, 'new', v:true)
    let l:bOld  = get(a:dOption, 'old', v:true)
    let l:sIgnore = get(a:dOption, 'ignore', '')

    for [l:sKey, l:Val] in items(a:dSource)
        if !empty(l:sIgnore) && l:sKey =~# l:sIgnore
            continue
        endif

        let l:iType = type(l:Val)
        if l:iType == 2 
            if !l:bFunc
                continue
            endif
        else
            if !l:bData
                continue
            endif
        endif

        let l:bCopy = v:false
        if has_key(a:dTarget, l:sKey)
            if l:bOld
                let l:bCopy = v:true
            endif
        else
            if l:bNew
                let l:bCopy = v:true
            endif
        endif

        if l:bCopy
            if l:iType == 3 || l:iType == 4
                let a:dTarget[l:sKey] = copy(l:Val)
            else
                let a:dTarget[l:sKey] = l:Val
            endif
        endif
    endfor

    return a:dTarget
endfunction "}}}

let s:dNewOption = {'ignore': '^_.*_$'}
let s:dOldOption = {'ignore': '.*_$'}
let s:dFatherOption = {'ignore': '.*_$', 'func': v:false, 'new': v:false}
let s:dMasterOption = {'ignore': '.*_$', 'data': v:false}

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

    " from single mother, mult father and master to create child
    let l:obj = s:CopyDict({}, l:class, s:dNewOption)
    if has_key(l:class, '_static_')
        for l:sKey in l:class._static_
            unlet! l:obj[l:sKey]
        endfor
    endif
    let l:obj._class_ = l:class

    if has_key(l:class, '_father_')
        for l:sFather in l:class._father_
            let l:CFather = s:GetClass(l:sFather)
            call s:CopyDict(l:obj, l:CFather, s:dFatherOption)
        endfor
    endif

    if has_key(l:class, '_master_')
        for l:sFather in l:class._master_
            let l:CMaster = s:GetClass(l:sMaster)
            call s:CopyDict(l:obj, l:CMaster, s:dMasterOption)
        endfor
    endif

    " call #ctor function
    try
        let l:Ctor = function(l:class._name_ . '#ctor')
        let l:argv = extend([l:obj], l:argv)
        call call(l:Ctor, l:argv)
    catch 
        " no #ctor is allowed
    endtry

    return l:obj
endfunction "}}}

let class#father = s:dFatherOption
let class#master = s:dMasterOption
" extend: 
function! class#extend(CTarget, CSource, ...) abort "{{{
    let l:dOption = get(a:000, 0, {})
    return s:CopyDict(CTarget, CSource, l:dOption)
endfunction "}}}

" old: create a new class from base class
" a:1, base class name or class dict, when empty, use this s:class
" return, child class, _mother_ is set to base class name
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

    let l:class = s:CopyDict({}, l:CBase, s:dOldOption)
    if has_key(l:CBase, '_protect_')
        for l:sKey in l:class._protect_
            unlet! l:class[l:sKey]
        endfor
    endif
    let l:class._mother_ = l:CBase._name_

    return l:class
endfunction "}}}

" delete: 
function! class#delete(this) abort "{{{
    let l:class = a:this._class_

    let l:Dector = function(l:class._name_ . '#dector')
    if exists('*l:Dector')
        call l:Dector(a:this)
    endif

    let l:lsSuper = class#Supers(l:class)
    for l:sBase in l:lsSuper
        let l:Dector = function(l:sBase . '#dector')
        if exists('*l:Dector')
            call l:Dector(a:this)
        endif
    endfor
endfunction "}}}
" free: 
function! class#free(this) abort "{{{
    call class#delete(a:this)
endfunction "}}}

" Supers: return a list of super classes in derived path upto top
" a:class, class name or already class dict
function! class#Supers(class) abort "{{{
    let l:class = s:GetClass(a:class)

    let l:lsSuper = []
    let l:CBase = l:class

    while has_key(l:CBase, '_mother_') && l:CBase._mother_ !=# l:CBase._name_
        let l:sBase = l:CBase._mother_
        let l:CBase = class#class(l:sBase)
        if empty(l:CBase)
            return l:lsSuper
        else
            call add(l:lsSuper, l:sBase)
        endif
    endwhile

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
    let l:Dector = function(l:class._name_ . '#dector')
    if !exists('*l:Dector')
        let l:Dector = function('class#dector')
    endif
    return l:Dector
endfunction "}}}

" Suctor: 
function! class#Suctor(class) abort "{{{
    let l:class = s:GetClass(a:class)

    if !has_key(l:class, '_mother_')
        return function('class#ctor')
    endif

    let l:Ctor = function(l:class._mother_ . '#ctor')
    if !exists('*l:Ctor')
        let l:Ctor = function('class#ctor')
    endif
    return l:Ctor
endfunction "}}}

" Sudector: 
function! class#Sudector(class) abort "{{{
    let l:class = s:GetClass(a:class)

    if !has_key(l:class, '_mother_')
        return function('class#dector')
    endif

    let l:Dector = function(l:class._mother_ . '#dector')
    if !exists('*l:Dector')
        let l:Dector = function('class#dector')
    endif
    return l:Dector
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

    if type(l:object) != type({})
        return s:false
    endif

    let l:CObject = get(l:object, '_class_', {})
    if empty(l:CObject)
        return s:false
    endif

    if empty(get(l:class, '_name_', ''))
        return s:false
    endif

    let l:lsSuper = class#Supers(l:CObject)
    if index(l:lsSuper, l:class._name_) != -1
        return s:true
    endif

    if has_key(l:CObject, '_father_')
        if index(l:CObject._father_, l:class_name_) != -1
            return s:true
        endif
    endif

    if has_key(l:CObject, '_master_')
        if index(l:CObject._master_, l:class_name_) != -1
            return s:true
        endif
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

    let l:sHeader = ''
    if has_key(l:class, '_name_') && has_key(l:class, '_version_')
        let l:sHeader = printf('class %s:%d', l:class._name_, l:class._version_)
    elseif has_key(l:class, '_class_')
        let l:name = get(l:class._class_, '_name_', '')
        let l:version = get(l:class._class_, '_version_', 0)
        if !empty(l:name)
            let l:sHeader = printf('objcet of %s:%d', l:name, l:version)
        else
            let l:sHeader = 'Object as dictionary'
        endif
    endif

    echo l:sHeader

    let l:sMember = "member:\n"
    let l:sMethod = "method:\n"

    let l:lsBasic = ['_name_', '_version_', '_class_']
    let l:lsReserve = []

    for l:sKey in sort(keys(l:class))
        if index(l:lsBasic, l:sKey) != -1
            continue
        endif

        " save other reserve keys: _xxx_
        if match(l:sKey, '^_.*_$') != -1
            call add(l:lsReserve, l:sKey)
            continue
        endif

        if type(l:class[l:sKey]) != 2
            let l:sMember .= s:FormatField(l:class, l:sKey, '  ')
        else
            let l:sMethod .= s:FormatMethod(l:class, l:sKey, '  ')
        endif
    endfor
    
    " option -a, also print reserve keys
    if match(a:000, 'a') != -1
        for l:sKey in l:lsReserve
            if type(l:class[l:sKey]) != 2
                let l:sMember .= s:FormatField(l:class, l:sKey, '  ')
            else
                let l:sMethod .= s:FormatMethod(l:class, l:sKey, '  ')
            endif
        endfor
    endif

    if match(a:000, 'm') != -1
        echo l:sMember . l:sMethod
    else
        echo l:sMember
    endif
endfunction "}}}

" FormatField: 
function! s:FormatField(obj, key, lead) abort "{{{
    let l:str = a:lead . a:key . ' = ' . string(a:obj[a:key]) . "\n"
    return l:str
endfunction "}}}
function! s:FormatMethod(obj, key, lead) abort "{{{
    let l:iFuncNumber = matchstr(string(a:obj[a:key]), '\d\+')
    let l:sFuncLabel = printf("function('%s')", l:iFuncNumber)
    let l:str = a:lead . a:key . ' = ' .  l:sFuncLabel . "\n"
    return l:str
endfunction "}}}

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

" triggle to load this vimL file
function! class#load() abort "{{{
    return 1
endfunction "}}}

" load micros command
call vimloo#micros#load()

" unit test for this vimL file
function! class#test() abort "{{{
    let l:obj = class#new()
    let l:sub = class#old()
    echo 'l:obj = ' l:obj
    echo 'l:sub = ' l:sub
    return 1
endfunction "}}}

