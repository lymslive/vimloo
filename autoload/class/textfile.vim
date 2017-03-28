" Class: class#textfile
" Author: lymslive
" Description: deal with a text file
" Create: 2017-03-22
" Modify: 2017-03-28

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#textfile'
let s:class._version_ = 1

" absolute path of file
let s:class.path = ''
" let self.content_ = []

function! class#textfile#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: new(path)
function! class#textfile#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#textfile#ctor(this, ...) abort "{{{
    if a:0 < 1 || empty(a:1)
        :ELOG 'class#textfile expect a path'
        return -1
    else
        let a:this.path = a:1
    endif
endfunction "}}}

" ISOBJECT:
function! class#textfile#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" string: represent file path
function! s:class.string() dict abort "{{{
    return self.path
endfunction "}}}

" number: represent count of lines
function! s:class.number() dict abort "{{{
    return len(self.list())
endfunction "}}}

" list: represent the content lines
function! s:class.list() dict abort "{{{
    if has_key(self, 'content_')
        return self.content_
    endif

    let l:pFileName = self.string()
    if !filereadable(l:pFileName)
        let self.content_ = []
    else
        let self.content_ = readfile(l:pFileName)
    endif

    return self.content_
endfunction "}}}

" CanRead: 
function! s:class.CanRead() dict abort "{{{
    return filereadable(self.path)
endfunction "}}}
" CanWrite: 
function! s:class.CanWrite() dict abort "{{{
    return filewritable(self.path)
endfunction "}}}
" Read: 
function! s:class.Read() dict abort "{{{
    return readfile(self.pah)
endfunction "}}}
" Write: 
" Write() write self.content_ to file
" Write('flag') write self.content_ to file with flag, such as 'a'
" Write([list]) write list of content to file, overwritten.
function! s:class.Write(...) dict abort "{{{
    if !self.CanWrite()
        return -1
    endif

    let l:pDiretory = fnamemodify(self.path, ':p:h')
    if !isdirectory(l:pDiretory)
        call mkdir(l:pDiretory, 'p')
    endif

    if a:0 == 0 || empty(a:1)
        if has_key(self.content_)
            return writefile(self.content_, self.path)
        else
            return -1
        endif
    endif

    if type(a:1) == type('')
        let l:flag = a:1
        if has_key(self.content_)
            return writefile(self.content_, self.path, l:flag)
        else
            return -1
        endif
    elseif type(a:1) == type([])
        let l:lsContent = a:1
        return writefile(l:lsContent, self.path)
    else
        :ELOG 'class#textfile.write() expect a flag string or list content'
        return -1
    endif
endfunction "}}}

" Clear: 
function! s:class.Clear() dict abort "{{{
    let self.content_ = []
endfunction "}}}

" Append: 
function! s:class.Append(sLine) dict abort "{{{
    call add(self.list(), sLine)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#textfile is loading ...'
function! class#textfile#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#textfile#test(...) abort "{{{
    return 0
endfunction "}}}
