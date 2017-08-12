" Class: class#textfile#csv
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-06
" Modify: 2017-08-12

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#textfile#old()
let s:class._name_ = 'class#textfile#csv'
let s:class._version_ = 1

" the first headNum lines is considered as header, left is data cell
" support multiple head line
" header and cell are all matrix, index 0-based
let s:class.headNum = 0
let s:class.header = []
let s:class.cell = []

let s:class._master_ = ['class#more#matrix']
let s:class._static_ = ['Column2Letter', 'Letter2Column']

function! class#textfile#csv#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: new(filepath, [headline])
function! class#textfile#csv#new(...) abort "{{{
    if a:0 < 1 || empty(a:1) || !filereadable(a:1)
        : ELOG '[class#textfile#csv#new] need a file path argument'
        return {}
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#textfile#csv#ctor(this, path, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:path)
    if a:0 > 0 && !empty(a:1)
        let a:this.headNum = a:1 + 0
    endif
    call a:this.ParseFile()
endfunction "}}}

" OLD:
function! class#textfile#csv#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#textfile#csv#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" matrix: 
function! s:class.matrix() dict abort "{{{
    return self.cell
endfunction "}}}

" ParseFile: 
" a:1, force re-parse
function! s:class.ParseFile(...) dict abort "{{{
    if !empty(self.cell)
        if a:0 < 1 || empty(a:1)
            :WLOG '[class#textfile#csv.ParseFile] already parsed'
            return self
        endif
    endif

    let l:lsContent = self.list()
    if empty(l:lsContent)
        return self
    endif

    if !empty(self.header)
        let self.header = []
    endif

    let l:iEnd = len(l:lsContent)
    let l:idx = 0
    while l:idx < l:iEnd
        let l:sLine = l:lsContent[l:idx]
        let l:row = split(l:sLine, ',')
        if l:idex < self.headNum
            call add(self.header, l:row)
        else
            call add(self.cell, l:row)
        endif
    endwhile

    if self.headNum > 0
        call self.HashTitle()
    endif

    return self
endfunction "}}}

" HeadLine: 
" set head lines of csv, or split if already parsed
function! s:class.HeadLine(number) dict abort "{{{
    if empty(self.cell)
        let self.headNum = a:number
        return self.ParseFile()
    else
        if a:number < len(self.cell)
            let self.header = remove(self.cell, 0, a:number-1)
            let self.headNum = a:number
        else
            : ELOG '[class#textfile#csv.HeadLine] two many head line?'
        endif
    endif
    return self
endfunction "}}}

" HashTitle: title name => colum index
" support the first header line is title
function! s:class.HashTitle() dict abort "{{{
    let self.title = {}
    let l:lsTitle = self.header[0]
    for l:idx in range(len(l:lsTitle))
        let l:sKey = l:lsTitle[l:idx]
        let self.title[l:sKey] = l:idx
    endfor
    return self
endfunction "}}}

" TitleIndex: get index by title name, -1 if non-exist 
function! s:class.TitleIndex(name) dict abort "{{{
    if has_key(self, 'title')
        return get(self.title, a:name, -1)
    endif
    return -1
endfunction "}}}

" Letter2Column: 
function! s:class.Letter2Column(letter) dict abort "{{{
    let l:idx = 0
    let l:col = 0
    let l:letter = toupper(a:letter)
    let l:Anumber = char2nr("A")
    while l:idx < len(a:letter) && l:idx < 3
        let l:number = char2nr(l:letter[l:idx]) - l:Anumber + 1
        let l:col = 26 * l:col + l:number
        let l:idx += 1
    endwhile

    return l:col - 1
endfunction "}}}

" Column2Letter: 
let s:LETTER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
function! s:class.Column2Letter(col) dict abort "{{{
    let l:col = a:col + 1
    if l:col <= 26
        return s:LETTER[l:col - 1]
    endif

    let l:lsLetter = []
    while l:col > 0
        let l:mod = l:col % 26
        let l:col = l:col / 26
        let l:letter = s:LETTER[l:mod-1]
        if l:mod == 0
            let l:col -= 1
            let l:letter = s:LETTER[26-1]
        endif
        call add(l:lsLetter, l:letter)
    endwhile

    return join(reverse(l:lsLetter), '')
endfunction "}}}

" USE:
function! class#textfile#csv#use(...) abort "{{{
    return class#use(s:class, a:000)
endfunction "}}}

" LOAD:
let s:load = 1
function! class#textfile#csv#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#textfile#csv#test(...) abort "{{{
    " call s:RunTestLetter()
    return 0
endfunction "}}}

finish " ignore furthur test {{{1
" RunTestLetter: 
function! s:RunTestLetter() abort "{{{
    echo 'some convert sample: '
    call s:TestLetter('A')
    call s:TestLetter('G')
    call s:TestLetter('Z')
    call s:TestLetter('AA')
    call s:TestLetter('Az')
    call s:TestLetter('ba')
    call s:TestLetter('zz')
    call s:TestLetter('aaa')
    call s:TestLetter('ZZZ')
    call s:TestLetter(26)
    call s:TestLetter(27)
    call s:TestLetter(26+7)
    call s:TestLetter(26*2)
    call s:TestLetter(26*3)
    call s:TestLetter(26*26)
    call s:TestLetter(26*26 + 4)
    call s:TestLetter(26*26*26)

    echo 'test loop'
    let l:LETTER = split(s:LETTER, '\zs')
    for i in l:LETTER
        let l:let = i
        call s:BackConvert(l:let)
    endfor
    for i in l:LETTER
        for j in l:LETTER
            let l:let = i . j
            call s:BackConvert(l:let)
        endfor
    endfor
    for i in l:LETTER
        for j in l:LETTER
            for k in l:LETTER
                let l:let = i . j . k
                call s:BackConvert(l:let)
            endfor
        endfor
    endfor
endfunction "}}}

" TestLetter: 
function! s:TestLetter(...) abort "{{{
    if type(a:1) == type(0)
        let l:col = a:1 - 1
        let l:let = s:class.Column2Letter(l:col)
        echo a:1 l:col l:let
    elseif type(a:1) == type('')
        let l:let = a:1
        let l:col = s:class.Letter2Column(l:let)
        echo l:let l:col l:col+1
    endif
endfunction "}}}

" BackConvert: 
function! s:BackConvert(letter) abort "{{{
    let l:col = s:class.Letter2Column(a:letter)
    let l:letter = s:class.Column2Letter(l:col)
    if l:letter !=# a:letter
        echo printf('input[%s]-->[%d]-->[%s]', a:letter, l:col, l:letter)
        return v:fasle
    else
        echo printf('input[%s]-->[%d]-->[%s]', a:letter, l:col, l:letter)
    endif
    return v:true
endfunction "}}}
