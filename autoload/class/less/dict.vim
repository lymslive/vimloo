" Class: module#less#dict
" Author: lymslive
" Description: VimL module frame
" Create: 2017-02-24
" Modify: 2017-08-06

let s:class = {}
function! class#less#dict#export() abort "{{{
    return s:class
endfunction "}}}

" CopyDict: copy keys from a dict into another, see extend()
" a:dTarget, the target dict, may change it's content
" a:dSource, the source dict, readonly
" a:dOption, contry how to copy, accepte keys:
"   data => bool, copy data key from dSource
"   func => bool, copy FuncRef key
"   new  => bool, add key when not in dTarget, if false, not add
"   old  => bool, overide key value that already in dTarget
"   ignores => list of key ignore the keys match any
"   ignorex => a string as regexp
"          ignore default empty, and other default true.
"   copy => number, how to copy list/dict item
"      0, not copy, use = as normal, share reference
"      1, defaut use copy()
"      2, use deepcopy()
" return a:dTarget modified
function! s:class.CopyDict(dTarget, dSource, dOption) dict abort "{{{
    let l:bData = get(a:dOption, 'data', v:true)
    let l:bFunc = get(a:dOption, 'func', v:true)
    let l:bNew  = get(a:dOption, 'new', v:true)
    let l:bOld  = get(a:dOption, 'old', v:true)
    let l:lsIgnore = get(a:dOption, 'ignores', [])
    let l:reIgnore = get(a:dOption, 'ignorex', '')
    let l:xCopy = get(a:dOption, 'copy', 1)

    let l:lsKey = keys(a:dSource)
    for l:sKey in l:lsKey

        if !empty(l:reIgnore) && l:sKey =~# l:reIgnore
            continue
        endif

        if !empty(l:lsIgnore)
            let l:bIgnore = 0
            for l:idx in range(len(l:lsIgnore))
                let l:sIgnore = l:lsIgnore[l:idx]
                if l:sKey ==# l:sIgnore
                    call remove(l:lsIgnore, l:idx)
                    let l:bIgnore = 1
                    break
                endif
            endfor
            if l:bIgnore
                continue
            endif
        endif

        unlet! l:Val
        let l:Val = a:dSource[l:sKey]

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
            " copy list and dict key
            if l:iType == 3 || l:iType == 4
                if l:xCopy == 1
                    let a:dTarget[l:sKey] = copy(l:Val)
                elseif l:xCopy == 2
                    let a:dTarget[l:sKey] = deepcopy(l:Val)
                else
                    let a:dTarget[l:sKey] = l:Val
                endif
            else
                let a:dTarget[l:sKey] = l:Val
            endif
        endif
    endfor

    return a:dTarget
endfunction "}}}

" Print: print a dict in a pretty way, sort key and indented each level
" usage: Print(dict) or Print(dict, 1, [max-level])
" this function is called recursivly, second argument is level, max to 5
" cannot handle cycle reference dictionay now
let s:class.max_print_level = 5
let s:class.print_indent = '  '
function! s:class.Print(dict, ...) dict abort "{{{
    let l:iLevel = get(a:000, 0, 1)
    let l:iLevelMax = get(a:000, 1, s:class.max_print_level)
    let l:sIndent = repeat(s:class.print_indent, l:iLevel)

    let l:lsKey = keys(a:dict)
    call sort(l:lsKey)

    let l:lsText = ['dictionary:']
    for l:sKey in l:lsKey
        if type(a:dict[l:sKey]) == type({})
            if l:iLevel < l:iLevelMax
                let l:subDict = s:class.Print(a:dict[l:sKey], l:iLevel+1, l:iLevelMax)
            else
                let l:subDict = '{...}'
            endif
            let l:sItem = printf('%s%s = %s', l:sIndent, l:sKey, l:subDict)
        else
            let l:sItem = printf('%s%s = %s', l:sIndent, l:sKey, string(a:dict[l:sKey]))
        endif
        call add(l:lsText, l:sItem)
    endfor

    return join(l:lsText, "\n")
endfunction "}}}

" PrintClass: 
" especailly for display class or object dict
" {a:option} may contain letter:
"  'a', include reserved keys such as '_key_'
"  'm', include method keys
function! s:class.PrintClass(class, option) dict abort "{{{
    let l:class = a:class

    let l:sHeader = ''
    if has_key(l:class, '_name_')
        let l:version = get(l:class, '_version_', '')
        let l:sHeader = printf('class %s:%d', l:class._name_, l:version)
        if has_key(l:class, '_mother_') && type(l:class._mother_) == 4
                \ && get(l:class._mother_, '_name_', '')
            let l:sHeader .= ' < ' . l:class._mother_._name_
        endif
    elseif has_key(l:class, '_class_') && type(l:class._class_) == 4
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

    let l:lsBasic = ['_name_', '_version_', '_class_', '_object_', '_mother_']
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

    if match(a:option, 'a') != -1
        for l:sKey in l:lsReserve
            if type(l:class[l:sKey]) != 2
                let l:sMember .= s:FormatField(l:class, l:sKey, '  ')
            else
                let l:sMethod .= s:FormatMethod(l:class, l:sKey, '  ')
            endif
        endfor
    endif

    if match(a:option, 'm') != -1
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

" FromList: [key1, val1, key2, val2, ...]
function! s:class.FromList(lsArgv) dict abort "{{{
    let l:dict = {}

    let l:iEnd = len(a:lsArgv)
    let l:idx = 0
    while l:idx < l:iEnd
        let l:sKey = a:lsArgv[l:idx]
        if type(l:sKey) != type('')
            break
        endif
        let l:idx += 1
        if l:idx < l:iEnd
            let l:dict[l:sKey] = a:lsArgv[l:idx]
        else
            let l:dict[l:sKey] = ''
        endif
        let l:idx += 1
    endwhile

    return l:dict
endfunction "}}}

" TEST:
function! module#less#dict#test(...) abort "{{{
    return 0
endfunction "}}}
