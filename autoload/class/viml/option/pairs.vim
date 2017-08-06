" Class: class#viml#option#pairs
" Author: lymslive
" Description: option with argument
" Create: 2017-02-13
" Modify: 2017-08-05

" BASIC:
let s:class = class#viml#option#single#old()
let s:class._name_ = 'class#viml#option#pairs'
let s:class._version_ = 1

" the argument for this option
let s:class.Argument = ''
" user must provide argument for this option?
let s:class.HasDefault = g:class#FALSE
" default value, if not provided, it's argument is must required
let s:class.Default = ''

function! class#viml#option#pairs#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#viml#option#pairs#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR: 4 arguments
function! class#viml#option#pairs#ctor(this, ...) abort "{{{
    if a:0 < 3
        echoerr '[class#viml#option#pairs] expcet at least 3 arguments: (Char, Name, Desc)'
        return
    endif
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:1, a:2, a:3)
    if a:0 > 3
        let a:this.HasDefault = v:true
        let a:this.Default = a:4
    endif
endfunction "}}}

" OLD:
function! class#viml#option#pairs#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#viml#option#pairs#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" Must: 
function! s:class.Must() dict abort "{{{
    return !self.HasDefault
endfunction "}}}

" Value: 
" the value of argument for this option
function! s:class.Value() dict abort "{{{
    if self.Has()
        return self.Argument
    else
        return self.Default
    endif
endfunction "}}}

" SetValue: 
function! s:class.SetValue(arg) dict abort "{{{
    let self.Set = g:class#TRUE
    let self.Argument = a:arg
endfunction "}}}

" STRING: -c, --Name    [+|-]Desc
" a:1, padding Name to this length, to make Desc align right 
" the [+|-] before Desc show if this option has default
" [+] requires user must provided a argument
function! s:class.string(...) dict abort "{{{
    let l:sRet = self.DescName()

    if a:0 > 0 && a:1 > 0
        let l:iPadding = a:1 - len(self.Name)
        if l:iPadding > 0
            let l:sRet .= repeat(' ', l:iPadding)
        endif
    endif

    if self.Must()
        let l:sRet .= '  [+]' . self.Desc
    else
        let l:sRet .= '  [-]' . self.Desc . '('. string(self.Default) . ')'
    endif

    return l:sRet
endfunction "}}}

" LOAD:
function! class#viml#option#pairs#load() abort "{{{
    return 1
endfunction "}}}

" TEST:
function! class#viml#option#pairs#test() abort "{{{
    return 1
endfunction "}}}
