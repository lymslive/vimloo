" Class: class#viml#tabapp
" Author: lymslive
" Description: VimL class frame
" Create: 2018-05-18
" Modify: 2018-05-18

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#viml#tabapp'
let s:class._version_ = 1

let s:class.tabname = ''
let s:class.winnum = 1
let s:class.needft = ''
let s:class.laycmd = ''

function! class#viml#tabapp#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#viml#tabapp#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#viml#tabapp#ctor(this, ...) abort "{{{
endfunction "}}}

" ISOBJECT:
function! class#viml#tabapp#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" Variable: not for individual object
let s:tvarkey = 'TABNAME'
let s:fullheight = 0
let s:fullwidth = 0

" FrontTab: bring the tabpage to front as current tabpage
" return the tabpagenr or -1 if the tabpage not exists,
" or 0 if current tabpage already is, and so no tab jump needed
" find t:TABNAME with self.tabname in each tabpage
function! s:class.FrontTab() dict abort "{{{
    if get(t:, s:tvarkey, '') ==# self.tabname
        return 0
    endif
    for l:idx in range(1, tabpagenr('$'))
        if gettabvar(l:idx, s:tvarkey, '') ==# self.tabname
            execute l:idx . 'tabnext'
            return l:idx
        endif
    endfor
    return -1
endfunction "}}}

" Layout: split window by laycmd specific.
" suppose a series :wincmd split from a single window to multiply.
" example: '20||' '20%|30%|' '+20|-' '+20||t10:'
"   '|' vsplit, '-' split, suffix
"   '20' number, width or height, 'n%' means pecent
"   '+n' +prefix will set &winfixheight or &winfixwidth
"   'a|' 'b|' prifex, :aboveleft, :belowright
"   't:' 'b:' :topleft or botright split span to full width
" argument:
"   a:1 if not empty, open a new tabpage to layout
" return:
"   the number of window, or -1 when error
function! s:class.Layout(...) dict abort "{{{
    if self.laycmd !~# '[-:|]'
        :ELOG 'invalid laycmd format'
        return -1
    endif
    if a:0 > 0 && !empty(a:1)
        :tabnew
    endif
    if winnr('$') > 1
        :wincmd o
    endif

    " get the full size when only one window
    let s:fullheight = winheight(0)
    let s:fullwidth = winwidth(0)

    let l:patcmd = '^\([abt]\)\(\+\?\)\(\d\+%\?\)\([-:|]\)$'
    let l:wincmd = ''
    let l:sptype = ''
    let l:spdir = ''
    let l:size = 0
    let l:fixed = v:false
    let l:len = strlen(self.laycmd)
    let l:pos = 0
    while l:pos < l:len
        let l:posnext = match(self.laycmd, '[-:|]', l:pos)
        if l:posnext < 0
            break
        endif

        let l:subcmd = self.laycmd[l:pos : l:posnext]
        let l:lsMatch = matchlist(l:subcmd, l:patcmd)
        if emplty(l:lsMatch)
            :ELOG 'invalid laycmd format'
            break
        endif
        let l:spdir = l:lsMatch[1]
        let l:fixed = !empty(l:lsMatch[2])
        let l:size = l:lsMatch[3]
        let l:sptype = l:lsMatch[4]

        if l:spdir ==? ''
            let l:wincmd = ''
        elseif l:spdir ==? 'a'
            let l:wincmd = 'aboveleft'
        elseif l:spdir ==? 't'
            let l:wincmd = 'topleft'
        elseif l:spdir ==? 'b'
            if l:sptype ==? ':'
                let l:wincmd = 'botright'
            else
                let l:wincmd = 'belowright'
            endif
        endif

        if l:size =~ '%$'
            if l:sptype == '|'
                let l:size = (0+l:size) * l:fullwidth / 100
            else
                let l:size = (0+l:size) * l:fullheight / 100
            endif
        endif

        let l:wincmd = l:wincmd . ' ' . l:size
        if l:sptype == '|'
            let l:wincmd .= 'vsplit'
        else
            let l:wincmd .= 'split'
        endif

        execute l:wincmd

        if l:fixed
            if l:sptype == '|'
                setlocal winfixwidth
            else
                setlocal winfixheight
            endif
        endif

        " jump to previous window
        :wincmd W
        l:pos = l:posnext + 1
    endwhile

    self.CheckWinnr()
    return winnr('$')
endfunction "}}}

" CheckWinnr: return true/false whether current layout match winnum
function! s:class.CheckWinnr() dict abort "{{{
    if winnr('$') != self.winnum
        :ELOG 'the number of windows not match'
        return v:false
    endif
    return v:true
endfunction "}}}

" LOAD:
let s:load = 1
function! class#viml#tabapp#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#viml#tabapp#test(...) abort "{{{
    let l:obj = class#viml#tabapp#new()
    call class#echo(l:obj)
endfunction "}}}
