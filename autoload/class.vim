" File: class.vim 
" Author: lymslive
" Description: base class for vimL
" Create: 2017-02-07
" Modify: 2017-03-14

let s:class = {}
let s:class._name_ = 'class'
let s:class._version_ = 1
let s:class._super_ = 'class'

" class: with no arg, return the class dict of this base class
" with one arg, get the class dict by class name, or empty dict
function! class#class(...) abort "{{{
    if a:0 == 0
        return s:class
    endif

    let l:name = a:1
    if type(l:name) != type('') || empty(a:1)
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
function! class#ctor(this, argv) abort "{{{
endfunction "}}}

" dector: 
function! class#dector() abort "{{{
endfunction "}}}

" new: create a instance object of named class
" if name is empty or 0, use this base class
function! class#new(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        let l:class = class#class(a:1)
        if empty(l:class)
            echoerr 'may not class: ' . a:1
            return {}
        endif
        let l:obj = copy(l:class)
    else
        let l:obj = copy(s:class)
    endif

    if a:0 > 1
        let l:argv = a:000[1:]
    else
        let l:argv = []
    endif

    call l:obj._new_(l:argv)
    return l:obj
endfunction "}}}

" old: create a new class from super class
" if super(a:1) is empty or 0, the super is this base class
" more argument as interface names
function! class#old(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:class = copy(s:class)
    else
        let l:super = class#class(a:1)
        if empty(l:super)
            echoerr 'may not class: ' . a:1
            return {}
        endif
        let l:class = copy(l:super)
    endif

    call l:class._old_()

    if a:0 > 1
        for l:sInterface in a:000[1:]
            let l:interface = class#class(l:sInterface)
            if !empty(l:interface)
                call l:class._merge_(l:interface)
            endif
        endfor
    endif

    return l:class
endfunction "}}}

" delete: 
function! class#delete(this) abort "{{{
    call a:this._del_()
endfunction "}}}

" isobject: 
" isobect(class_name, objcet_variable)
function! class#isobject(...) abort "{{{
    if a:0 == 0
        return v:false
    elseif a:0 == 1
        return s:class._isobject_(a:1)
    else
        let l:class = class#class(a:1)
        if empty(l:class)
            return v:false
        endif
        return l:class._isobject_(a:2)
    endif
endfunction "}}}

" isa: 
" isa(class_name, objcet_variable)
function! class#isa(...) abort "{{{
    if a:0 == 0
        return v:false
    elseif a:0 == 1
        return s:class._isa_(a:1)
    else
        let l:class = class#class(a:1)
        if empty(l:class)
            return v:false
        else
            return l:class._isa_(a:2)
        endif
    endif
endfunction "}}}

" convert object to string
function! s:class.string() dict abort "{{{
    return self._name_
endfunction "}}}

" convert object to number
function! s:class.number() dict abort "{{{
    return self._version_
endfunction "}}}

" return a list of super classes in derived path
function! s:class._supers_() dict abort "{{{
    let l:liSuper = []
    let l:super_class = self

    while has_key(l:super_class, '_super_')
            \ && l:super_class._super_ !=# l:super_class._name_
        let l:super_name = l:super_class._super_
        let l:super_class = class#class(l:super_name)
        if empty(l:super_class)
            return l:liSuper
        else
            call add(l:liSuper, l:super_name)
        endif
    endwhile

    return l:liSuper
endfunction "}}}

" _ctor_: return #ctor function, or the dummy class#ctor()
function! s:class._ctor_() dict abort "{{{
    let l:Ctor = function(self._name_ . '#ctor')
    if !exists('*l:Ctor')
        let l:Ctor = function('class#ctor')
    endif
    return l:Ctor
endfunction "}}}

" _suctor_: 
function! s:class._suctor_() dict abort "{{{
    if !has_key(self, '_super_')
        return function('class#ctor')
    endif

    let l:Ctor = function(self._super_ . '#ctor')
    if !exists('*l:Ctor')
        let l:Ctor = function('class#ctor')
    endif
    return l:Ctor
endfunction "}}}

" _dector_: 
function! s:class._dector_() dict abort "{{{
    let l:Dector = function(self._name_ . '#dector')
    if !exists('*l:Dector')
        let l:Dector = function('class#dector')
    endif
    return l:Dector
endfunction "}}}

" _sudector_: 
function! s:class._sudector_() dict abort "{{{
    let l:Dector = function(self._super_ . '#dector')
    if !exists('*l:Dector')
        let l:Dector = function('class#dector')
    endif
    return l:Dector
endfunction "}}}

" _new_: 
function! s:class._new_(argv) dict abort "{{{
    let l:Ctor = self._ctor_()
    if exists('*l:Ctor')
        call l:Ctor(self, a:argv)
    endif
endfunction "}}}

" class._old_: 
" set the right name of super and self relation
function! s:class._old_() dict abort "{{{
    let self._super_ = self._name_
    let self._name_ = ''
endfunction "}}}

" _copy_: only copy normal data field, but method
function! s:class._copy_(that) dict abort "{{{
    if type(a:that) != 4
        return
    endif

    for l:sKey in keys(a:that)
        if !has_key(self, l:sKey)
            continue
        endif

        " ignore reserve fields: _xxxx_
        if match(l:sKey, '^_.*_$') != -1
            continue
        endif

        let l:iType = type(self[l:sKey])
        " Funcref = 2
        if l:iType == 2
            continue
        endif

        " List = 3, Dict = 4
        if l:iType == 3 || l:iType == 4
            let self[l:sKey] = copy(a:that[l:sKey])
        else
            let self[l:sKey] = a:that[l:sKey]
        endif
    endfor
endfunction "}}}

" _merge_: copy all fields, but not overide already existed key
" make a:that as an interface class of slef
function! s:class._merge_(that) dict abort "{{{
    if type(a:that) != 4 || !has_key(a:that, '_name_')
        return
    endif

    if has_key(self, '_interface_')
        if index(self._interface_, a:that._name_) != -1
            return
        endif 
    endif

    for l:sKey in keys(a:that)
        if has_key(self, l:sKey)
            continue
        endif
        let self[l:sKey] = a:that[l:sKey]
    endfor

    if !has_key(self, '_interface_')
        let self._interface_ = [a:that._name_]
    else
        call add(self._interface_, a:that._name_)
    endif
endfunction "}}}

" class._del_: 
" call echa dector from bottom upwise
function! s:class._del_() dict abort "{{{
    let l:Dector = function(self._name_ . '#dector')
    if exists('*l:Dector')
        call l:Dector()
    endif

    let l:liSuper = self._supers_()
    for l:super in l:liSuper
        let l:Dector = function(l:super . '#dector')
        if exists('*l:Dector')
            call l:Dector()
        endif
    endfor
endfunction "}}}

" _isobject_: 
function! s:class._isobject_(that) dict abort "{{{
    if type(a:that) == 4 && has_key(a:that, '_name_') && a:that._name_ ==# self._name_
        return v:true
    else
        return v:false
    endif
endfunction "}}}

" _isa_: check self if is some super or interface of a:that class
function! s:class._isa_(that) dict abort "{{{
    if type(a:that) != 4 || !has_key(a:that, '_name_')
        return v:false
    endif

    " a:that if object of self
    if self._isobject_(a:that)
        return v:true
    endif

    " self if super of a:that
    if has_key(a:that, '_super_') && a:that._super_ ==# self._name_
        return v:true
    endif

    " self if interface of a:that
    if has_key(a:that, '_interface_')
        if index(a:that._interface_, self._name_) != -1
            return v:true
        endif
    endif

    " recursive check super
    if has_key(a:that, '_super_') && a:that._super_ !=# a:that._name_
        let l:super = class#class(a:that._super_)
        if !empty(l:super) && self._isa_(l:super)
            return v:true
        endif
    endif

    " recursive check interface
    if has_key(a:that, '_interface_')
        for l:sInterface in a:that._interface_
            let l:interface = class#class(l:sInterface)
            if !empty(l:interface) && self._isa_(l:interface)
                return v:true
            end
        endfor
    endif

    return v:false
endfunction "}}}

" the shared instance: 
let s:instance = {}
function! class#instance() abort "{{{
    if empty(s:instance)
        let s:instance = class#new(0)
    endif
    return s:instance
endfunction "}}}

" class.hello: 
function! s:class.hello(...) dict abort "{{{
    if a:0 == 0
        let l:word = 'world'
    else
        let l:word = a:1
    endif
    echo self.string() . '[' . self.number() . ']: hello ' . l:word . '!'
endfunction "}}}

" echo: display class meber
" -a, include reserved keys, -m, include method keys
function! s:class.echo(...) dict abort "{{{
    let l:sMember = "class member:\n"
    let l:sMethod = "class method:\n"

    let l:sMember .= s:FormatField(self, '_name_', '  ')
    let l:sMember .= s:FormatField(self, '_version_', '  ')

    if has_key(self, '_super_')
        let l:sMember .= s:FormatField(self, '_super_', '  ')
    endif
    if has_key(self, '_interface_')
        let l:sMember .= s:FormatField(self, '_interface_', '  ')
    endif

    let l:lsBasic = ['_name_', '_version_', '_super_', '_interface_']
    let l:lsReserve = []

    for l:sKey in sort(keys(self))
        if index(l:lsBasic, l:sKey) != -1
            continue
        endif

        " save other reserve keys: _xxx_
        if match(l:sKey, '^_.*_$') != -1
            call add(l:lsReserve, l:sKey)
            continue
        endif

        if type(self[l:sKey]) != 2
            let l:sMember .= s:FormatField(self, l:sKey, '  ')
        else
            let l:sMethod .= s:FormatField(self, l:sKey, '  ')
        endif
    endfor
    
    " option -a, also print reserve keys
    if match(a:000, 'a') != -1
        for l:sKey in l:lsReserve
            if type(self[l:sKey]) != 2
                let l:sMember .= s:FormatField(self, l:sKey, '  ')
            else
                let l:sMethod .= s:FormatField(self, l:sKey, '  ')
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

" triggle to load this vimL file
function! class#load() abort "{{{
    return 1
endfunction "}}}

" unit test for this vimL file
function! class#test() abort "{{{
    let l:obj = class#new()
    call l:obj.hello()
    call l:obj.hello('vim')
    return 1
endfunction "}}}

