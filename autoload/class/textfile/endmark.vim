" Class: class#textfile#endmark
" Author: lymslive
" Description: a type of easy dynamic file, 
"   with end mark name, and option slot marks
" Create: 2017-07-20
" Modify: 2017-07-29

" Text File Format:
" 1. line orient
" 2. at end of line, mark name as <name>, if ommit, default <LINE_no>
" 3. may have middle slot pieces with <slot/i=value>content<%>
"    the optional slot mark can be name(before %) or number(after %)
"    minum mark: </>content</> </=0>content</>
" 4. used for update specific line dynamiclly in program.

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#textfile#old()
let s:class._name_ = 'class#textfile#endmark'
let s:class._version_ = 1

" manage array of line-itme, and hash of line-name to line-itme
let s:class.array = []
let s:class.hash = {}
" the lines in show
let s:class.view = []

" line-item seems like inner class
let s:item = {}
" line number in source file
let s:item.line = 0
" show/hide in buffer window
let s:item.show = 1
" full origin text with <marks>
let s:item.text = ''
" line-name
let s:item.name = ''

" show/hide constant
let s:class.SHOW = 1
let s:class.HIDE = 0

" Strip: 
function! s:Strip(item) abort "{{{
    return substitute(a:item.text, '<[^>]\+>', '', 'g')
endfunction "}}}

function! class#textfile#endmark#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(path)
function! class#textfile#endmark#new(...) abort "{{{
    if a:0 < 1 || empty(a:1)
        :ELOG 'class#textfile expect a path'
        return v:none
    endif

    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}
" CTOR:
function! class#textfile#endmark#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:1)
    let a:this.array = []
    let a:this.hash = {}
endfunction "}}}

" ISOBJECT:
function! class#textfile#endmark#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Init: parse the input file
function! s:class.Init() dict abort "{{{
    let l:lsText = readfile(self.path)
    if empty(l:lsText)
        return
    endif

    let l:line = 0
    for l:text in l:lsText
        let l:line += 1
        let l:item = copy(s:item)
        let l:item.line = l:line
        let l:item.show = 1
        let l:item.text = l:text

        let l:name = matchstr(l:text, '<\zs[^>]\+\ze>$')
        if empty(l:name)
            let l:name = 'LINE' . l:line
        endif

        if has_key(self.hash, l:name)
            let l:msg = printf('line name repeated: <%s> ! rename to <LINE%d>', l:name, l:line)
            : WLOG l:msg
            let l:name = 'LINE' . l:line
        endif

        let l:item.name = l:name
        call add(self.array, l:item)
        let self.hash[l:name] = l:item
    endfor
endfunction "}}}

" Output: 
function! s:class.Output() dict abort "{{{
    let self.view = []
    let l:lsText = []
    for l:item in self.array
        if !l:item.show
            continue
        endif
        call add(self.view, l:item)
        let l:sText = s:Strip(l:item)
        call add(l:lsText, l:sText)
    endfor
    return l:lsText
endfunction "}}}

" GetLine: 
function! s:class.GetLine(name) dict abort "{{{
    return self.hash[a:name]
endfunction "}}}

" SetLine: 
function! s:class.SetLine(name, text) dict abort "{{{
    let l:item = self.GetLine(a:name)
    let l:item.text = a:text
endfunction "}}}

" UpdateSlot: update the first slot text and value(optional)
" only support one slot now
function! s:class.UpdateSlot(name, text, ...) dict abort "{{{
    let l:value = get(a:000, 0, '')
    let l:item = self.GetLine(a:name)
    let l:text = l:item.text
    let l:text = substitute(l:text, '<.*/.*>\zs.*\ze</>', a:text, '')
    if !empty(l:value)
        let l:text = substitute(l:text, '</=\zs[^>]*\ze>', l:value, '')
    endif
    let l:item.text = l:text
endfunction "}}}

" GetSlotText: 
function! s:class.GetSlotText(name) dict abort "{{{
    let l:item = self.GetLine(a:name)
    let l:text = l:item.text
    return matchstr(l:text, '<.*/.*>\zs.*\ze</>')
endfunction "}}}

" GetSlotValue: 
function! s:class.GetSlotValue(name) dict abort "{{{
    let l:item = self.GetLine(a:name)
    let l:text = l:item.text
    return matchstr(l:text, '</=\zs[^>]*\ze>')
endfunction "}}}

" ShowLine: 
" a:name, the line name
" a:show, 0/1, show value
" a:1, a shift number list, relate to line with a:name
" default only set a:name line
function! s:class.ShowLine(name, show, ...) dict abort "{{{
    let l:item = self.GetLine(a:name)
    if a:0 <= 0
        let l:item.show = a:show
    else
        let l:len = len(self.array)
        let l:liShift = a:1
        for l:i in l:liShift
            let l:line = l:item.line + l:i
            if l:line >= 1 && l:line <= l:len
                let self.array[l:line-1].show = a:show
            else
                let l:msg = printf('line number[%d] beyond range[%d, %d]', l:line, 1, l:len)
                : WLOG l:msg
            endif
        endfor
    endif

    return self
endfunction "}}}

" ShowLineReg: 
" set all line show/hide that match a:regexp
function! s:class.ShowLineReg(regexp, show) dict abort "{{{
    for l:item in self.array
        if l:item.text =~# a:regexp
            let l:item.show = a:show
        endif
    endfor

    return self
endfunction "}}}

" GetShowNumber: the line number(1-based) in the output buffer
" return 0 if the line is not show
function! s:class.GetShowNumber(name) dict abort "{{{
    let l:iLine = 0
    for l:i in range(len(self.view))
        if self.view[l:i].name ==# a:name
            let l:iLine = l:i + 1
            break
        endif
    endfor
    return l:iLine
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#textfile#endmark is loading ...'
function! class#textfile#endmark#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#textfile#endmark#test(...) abort "{{{
    return 0
endfunction "}}}
