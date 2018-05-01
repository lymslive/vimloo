" Class: module#less#list
" Author: lymslive
" Description: VimL module frame, list util
" Create: 2017-02-25
" Modify: 2017-08-21

let s:class = {}
function! class#less#list#export() abort "{{{
    return s:class
endfunction "}}}

" IsListof: 
function! s:class.IsListof(list, type) dict abort "{{{
    if type(a:list) != type([])
        return v:false
    endif
    for l:item in a:list
        if type(l:item) != a:type
            return v:false
        endif
    endfor
    return v:true
endfunction "}}}

" BreakString: split a string in individual characters
function! s:class.BreakString(string) dict abort "{{{
    return split(a:string, '\zs')
endfunction "}}}

" BackIndex: return a hash from value to index
" each item in list should be string or number that fit for dict key
function! s:class.BackIndex(list) dict abort "{{{
    let l:hash = {}
    for i in range((a:list))
        let l:item = a:list[i]
        let l:hash[l:item] = i
    endfor
    return l:hash
endfunction "}}}

" Flat: 
" > a:lsArgv, a list
" > a:1, deepth
" < return, a flattend list
function! s:class.Flat(lsArgv, ...) dict abort "{{{
    let l:iDeepth = get(a:000, 0, 1)
    if l:iDeepth == 0
        return a:lsArgv
    endif

    let l:lsRet = []
    let l:iDeepth -= 1
    for l:arg in a:lsArgv
        if type(l:arg) == type([])
            let l:lsRet += self.Flat(l:arg, l:iDeepth)
        elseif  type(l:arg) == type({})
            for [l:key, l:val] in items(l:arg)
                let l:lsRet += [l:key, l:val]
                unlet l:key  l:val
            endfor
        else
            let l:lsRet += [larg]
        endif
    endfor

    return l:lsRet
endfunction "}}}

" Swap: swap two items in list
" not check index beyond range, let it go die in that case
function! s:class.Swap(list, idx, jdx) dict abort "{{{
    if a:idx == a:jdx
        return
    endif
    let l:tmp = a:list[a:idx]
    let a:list[a:idx] = a:list[a:jdx]
    let a:list[a:jdx] = l:tmp
endfunction "}}}

" Prompt: return a string than can be used in prompt, as:
" 0 \t item[0]
" 1 \t item[1]
function! s:class.PromptString(list) dict abort "{{{
    let l:lsOutput = []
    let l:iPrefix = 0
    for l:item in a:list
        call add(l:lsOutput, printf("%d\t%s", l:iPrefix, l:item))
        let l:iPrefix += 1
    endfor
    return join(l:lsOutput, "\n")
endfunction "}}}

" TEST:
function! class#less#list#test(...) abort "{{{
    call s:testPromptList()
    return 0
endfunction "}}}

" testPrompt: 
function! s:testPromptList() abort "{{{
    let l:list = ['aaaaa', 'bbbbb', 'ccccc']
    let l:display = s:class.PromptString(l:list)
    echo l:display
    let l:reply = input('Select: ', 0)
    let l:result = l:list[0+l:reply]
    echo 'you have select:' l:result
endfunction "}}}
