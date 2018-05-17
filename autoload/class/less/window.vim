" Class: module#less#window
" Author: lymslive
" Description: VimL class frame
" Create: 2017-02-27
" Modify: 2017-08-13

let s:class = {}
function! class#less#window#export() abort "{{{
    return s:class
endfunction "}}}

" FindWindow: find a window by &filetype
" > a:1, bOtherTab, also find in other tab
" < return winnr
" < return [tabnr, winnr] if bOtherTab
" < return empty if not found
function! s:class.FindWindow(sFileType, ...) dict abort "{{{
    let l:count = winnr('$')
    for l:win in range(1, l:count)
        if getwinvar(l:win, '&filetype') ==# a:sFileType
            return l:win
        endif
    endfor

    let l:bOtherTab = get(a:000, 0, v:false)
    if !l:bOtherTab
        return 0
    endif

    for l:tab in range(1, tabpagenr('$'))
       if l:tab == tabpagenr()
           continue
       endif 
       for l:win in range(1, tabpagewinnr(l:tab, '$'))
           if gettabwinvar(l:tab, l:win, '&filetype') ==# a:sFileType
               return [l:tab, l:win]
           endif
       endfor
    endfor

    return [0, 0]
endfunction "}}}

" GotoWindow: find and goto a window by &filetype
function! s:class.GotoWindow(sFileType, ...) dict abort "{{{
    let l:bOtherTab = get(a:000, 0, v:false)
    let l:target = self.FindWindow(a:sFileType, l:bOtherTab)
    if type(l:target) == type(0)
        let l:win = l:target
        if l:win != 0 && l:win != winnr()
            execute l:win . 'wincmd w'
        endif
        return l:win
    elseif type(l:target) == type([])
        let l:tab = get(l:target, 0, 0)
        let l:win = get(l:target, 1, 0)
        if l:tab != 0 && l:tab != tabpagenr()
            execute l:tab . 'tabnext'
            if l:win != 0 && l:win != winnr()
                execute l:win . 'wincmd w'
            endif
        endif
        return [l:tab, l:win]
    endif
endfunction "}}}

" FindTabpage: find a tab that have t:varname=value
function! s:class.FindTabpage(varname, value) dict abort "{{{
    let l:iTabCount = tabpagenr('$')
    for i in range(1, l:iTabCount)
        if gettabvar(i, a:varname, '') ==# a:value
            return i
        endif
    endfor
    return 0
endfunction "}}}

" FindBufwinnr: find a window by bufnr name or bufnr
" > a:1, bOtherTab, also find in other tab
" < return winnr
" < return [tabnr, winnr] if bOtherTab
" < return empty if not found
" when this function finish, will back to origin tab&win
function! s:class.FindBufwinnr(buffer, ...) dict abort "{{{
    let l:iWindow = bufwinnr(a:buffer)
    if l:iWindow != -1
        return l:iWindow
    endif

    let l:bOtherTab = get(a:000, 0, v:false)
    if !l:bOtherTab
        return 0
    endif

    let l:iTabOld = tabpagenr()
    let l:Ret = []
    for l:tab in range(1, tabpagenr('$'))
        if l:tab == l:iTabOld
            continue
        endif 

        : execute l:tab . 'tabnext'

        let l:win = bufwinnr(a:buffer)
        if l:iWindow != -1
            let l:Ret = [l:tab, l:win]
            break
        endif
    endfor

    : execute l:iTabOld . 'tabnext'
    return l:Ret
endfunction "}}}
