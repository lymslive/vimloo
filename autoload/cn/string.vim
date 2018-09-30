" File: string
" Author: lymslive
" Description: string util, usually one line string.
" Create: 2018-09-30
" Modify: 2018-09-30

" Func: s:number 
function! s:number(str) abort "{{{
    return 0 + a:str
endfunction "}}}

" Func: s:list 
function! s:list(str) abort "{{{
    return split(a:str, '\zs')
endfunction "}}}

" Func: s:lines 
function! s:lines(str) abort "{{{
    return split(a:str, '\r\?\n')
endfunction "}}}

" Func: s:dict 
function! s:dict(str) abort "{{{
    let l:dict = {}
    for l:char in s:list(a:str)
        let l:dict[l:char] = 1
    endfor
    return l:dict
endfunction "}}}

" Func: s:zeros 
function! s:zeros(str) abort "{{{
    return repeat('0', len(a:str))
endfunction "}}}

" Func: s:blank 
function! s:blank(stri) abort "{{{
    return repeat(' ', len(a:str))
endfunction "}}}

" Func: s:reverse 
function! s:reverse(str) abort "{{{
    return join(reverse(split(a:str), '\zs'a), '')
endfunction "}}}

" Func: s:resize 
function! s:resize(str, size) abort "{{{
    let l:iend = len(a:str)
    if l:iend >= a:size
        return strpart(a:str, 0, a:size)
    else
        return a:str . repeat(' ', a:size - l:iend)
    endif
endfunction "}}}

" Func: s:replace 
" Desc: plain substitute, not regexp.
function! s:replace(str, from, to, flags) abort "{{{
  return substitute(a:str, '\V'.escape(a:from, '\'), escape(a:to, '\'), a:flags)
endfunction "}}}

" Func: s:has_prefix 
function! s:has_prefix(str, prefix) abort "{{{
    return stridx(a:str, a:prefix) == 0
endfunction "}}}

" Func: s:has_suffix 
function! s:has_suffix(str, suffix) abort "{{{
    let l:idx = strridx(a:str, a:suffix)
    return 0 <= l:idx && l:idx + len(a:suffix) == len(a:str)
endfunction "}}}

" Func: s:chop 
" Desc: remove last character
function! s:chop(str) abort "{{{
    return substitute(a:str, '.$', '', '')
endfunction "}}}

" Func: s:chomp 
" Desc: only remove last newline character
function! s:chomp(str) abort "{{{
    return substitute(a:str, '\%(\r\n\|[\r\n]\)$', '', '')
endfunction "}}}

" Func: s:class 
function! s:class() abort "{{{
    if exists('s:class')
        return s:class
    endif

    let s:class = {}
    let s:class.str_ = {}

    " SECTION: four primary data type conversion.

    " Method: number 
    function! s:class.number() dict abort "{{{
        return s:number(self.str_)
    endfunction "}}}

    " Method: sring 
    function! s:class.sring() dict abort "{{{
        return self.str_
    endfunction "}}}

    " Method: list 
    function! s:class.list() dict abort "{{{
        return s:list(self.str_)
    endfunction "}}}

    " Method: dict 
    function! s:class.dict() dict abort "{{{
        return s:dict(self.str_)
    endfunction "}}}

    " Method: int
    function! s:class.int(base) dict abort "{{{
        return str2nr(self.str_, a:base)
    endfunction "}}}

    " Method: float 
    function! s:class.float() dict abort "{{{
        return str2float(self.str_)
    endfunction "}}}

    " SECTION: builtin wrapper modify self

    " Method: repeat 
    function! s:class.repeat(count) dict abort "{{{
        let self.str_ = repeat(self.str_, a:count)
        return self
    endfunction "}}}

    " Method: format 
    function! s:class.forman(...) dict abort "{{{
        let self.str_ = call('printf', [self.str_] + a:000)
        return self
    endfunction "}}}

    " Method: escape 
    function! s:class.escape(chars) dict abort "{{{
        let self.str_ = escape(self.str_, a:chars)
        return self
    endfunction "}}}

    " Method: shellescape 
    function! s:class.shellescape(...) dict abort "{{{
        let self.str_ = shellescape(self.str_, (a:0?a:1:0))
        return self
    endfunction "}}}

    " Method: fnameescape 
    function! s:class.fnameescape() dict abort "{{{
        let self.str_ = fnameescape(self.str_)
        return self
    endfunction "}}}

    " Method: fnamemodify 
    function! s:class.fnamemodify(mods) dict abort "{{{
        let self.str_ = fnamemodify(self.str_, a:mods)
        return self
    endfunction "}}}

    " Method: expand 
    function! s:class.expand(...) dict abort "{{{
        let self.str_ = expand(self.str_, (a:0 ? a:1 : 0))
        return self
    endfunction "}}}

    " Method: printable 
    function! s:class.printable() dict abort "{{{
        let self.str_ = strtrans(self.str_)
        return self
    endfunction "}}}

    " Method: lower 
    function! s:class.lower() dict abort "{{{
        let self.str_ = tolower(self.str_)
        return self
    endfunction "}}}

    " Method: upper 
    function! s:class.upper() dict abort "{{{
        let self.str_ = toupper(self.str_)
        return self
    endfunction "}}}

    " Method: tr 
    function! s:class.tr(from, to) dict abort "{{{
        let self.str_ = tr(a:from, a:to)
        return self
    endfunction "}}}

    " Method: trim 
    function! s:class.trim(...) dict abort "{{{
        let self.str_ = a:0 ? trim(self.str_, a:1) : trim(self.str_)
        return self
    endfunction "}}}

    " Method: filter 
    function! s:class.filter(regexp) dict abort "{{{
        let self.str_ = a:0 ? call('matchstr', [self.str_, a:regexp] + a:000) : matchstr(self.str_, a:regexp)
        return self
    endfunction "}}}

    " Method: slice 
    function! s:class.slice(start, ...) dict abort "{{{
        let self.str_ = a:0 ? strpart(self.str_, a:start, a:1) : strpart(self.str_, a:start)
        return self
    endfunction "}}}

    " Method: mslice 
    function! s:class.mslice(start, ...) dict abort "{{{
        let self.str_ = a:0 ? strcharpart(self.str_, a:start, a:1) : strcharpart(self.str_, a:start)
        return self
    endfunction "}}}

    " Method: substitute 
    function! s:class.substitute(regexp, replace, flags) dict abort "{{{
        let self.str_ = substitute(self.str_, a:regexp, a:replace, a:flags)
        return self
    endfunction "}}}

    " Method: iconv 
    function! s:class.iconv(from, to) dict abort "{{{
        let self.str_ = iconv(self.str_, a:from, a:to)
        return self
    endfunction "}}}

    " SECTION: builtin wrapper non-modify self

    " Method: empty 
    function! s:class.empty() dict abort "{{{
        return empty(self.str_)
    endfunction "}}}

    " Method: len 
    function! s:class.len() dict abort "{{{
        return strlen(self.str_)
    endfunction "}}}

    " Method: chars 
    function! s:class.chars(...) dict abort "{{{
        return strchars(self.str_, (a:0 ? a:1 : 0))
    endfunction "}}}

    " Method: width 
    function! s:class.width() dict abort "{{{
        return strwidth(self.str_)
    endfunction "}}}

    " Method: width_display 
    function! s:class.width_display(...) dict abort "{{{
        return strdisplaywidth(self.str_, (a:0 ? a:1 :0))
    endfunction "}}}

    " Method: index 
    function! s:class.index(needle, ...) dict abort "{{{
        return stridx(self.str_, a:needle, (a:0 ? a:1 : 0))
    endfunction "}}}

    " Method: last_index 
    function! s:class.last_index(needle, ...) dict abort "{{{
        return strridx(self.str_, a:needle, (a:0 ? a:1 : 0))
    endfunction "}}}

    " Method: matchidx 
    function! s:class.matchidx(regex, ...) dict abort "{{{
        return a:0 ? call('match', [self.str_, a:regexp] + a:000) : match(self.str_, a:regexp)
    endfunction "}}}

    " Method: matchend 
    function! s:class.matchend(regex, ...) dict abort "{{{
        return a:0 ? call('matchend', [self.str_, a:regexp] + a:000) : matchend(self.str_, a:regexp)
    endfunction "}}}

    " Method: matchpos 
    function! s:class.matchpos(regex, ...) dict abort "{{{
        return a:0 ? call('matchstrpos', [self.str_, a:regexp] + a:000) : matchstrpos(self.str_, a:regexp)
    endfunction "}}}

    " Method: matchlist 
    function! s:class.matchlist(regex, ...) dict abort "{{{
        return a:0 ? call('matchlist', [self.str_, a:regexp] + a:000) : matchlist(self.str_, a:regexp)
    endfunction "}}}

    " Method: eval 
    function! s:class.eval() dict abort "{{{
        return eval(self.str_)
    endfunction "}}}

    " Method: execute 
    function! s:class.execute(...) dict abort "{{{
        return execute(self.str_, (a:0 ? a:1 : 'silent'))
    endfunction "}}}

    " SECTION: extra custom function modify self

    " Method: zeros 
    function! s:class.zeros() dict abort "{{{
        let self.str_ = s:zeros(self.str_)
        return self
    endfunction "}}}

    " Method: blank 
    function! s:class.blank() dict abort "{{{
        let self.str_ = s:blank(self.str_)
        return self
    endfunction "}}}

    " Method: reverse 
    function! s:class.reverse() dict abort "{{{
        let self.str_ = s:reverse(self.str_)
        return self
    endfunction "}}}

    " Method: resize 
    function! s:class.resize(size) dict abort "{{{
        let self.str_ = s:resize(a:size)
        return self
    endfunction "}}}

    " Method: replace 
    function! s:class.replace(from, to, flags) dict abort "{{{
        let self.str_ = s:replace(self.str_, a:from, a:to, a:flags)
        return self
    endfunction "}}}

    " Method: chop 
    function! s:class.chop() dict abort "{{{
        let self.str_ = s:chop(self.str_)
        return self
    endfunction "}}}

    " Method: chomp 
    function! s:class.chomp() dict abort "{{{
        let self.str_ = s:chomp(self.str_)
        return self
    endfunction "}}}

endfunction "}}}

" Func: s:new 
" Desc: make the wrapper object of a string, attatch methods to it.
function! s:new(str) abort "{{{
    let l:obj = copy(s:class())
    let l:obj.str_ = a:str
    return l:obj
endfunction "}}}
