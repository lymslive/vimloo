let s:save_cpo = &cpo
set cpo&vim

let s:registry = {}
let s:thisdir = expand('<sfile>:p:h')

" load: 
function! jp#System#Cache#load() abort "{{{
  let s:P = package#import('jp#Prelude')
  call s:register('dummy',      'Cache.Dummy')
  call s:register('memory',     'Cache.Memory')
  call s:register('file',       'Cache.File')
  call s:register('singlefile', 'Cache.SingleFile')
endfunction "}}}

function! s:_vital_depends() abort
  return [
        \ 'Prelude',
        \ 'System.Cache.Dummy',
        \ 'System.Cache.Memory',
        \ 'System.Cache.File',
        \ 'System.Cache.SingleFile',
        \]
endfunction

function! s:new(name, ...) abort
  if !has_key(s:registry, a:name)
    throw printf(
          \ 'vital: System.Cache: A cache system "%s" is not registered.',
          \ a:name,
          \)
  endif
  let class = s:registry[a:name]
  return call(class.new, a:000, class)
endfunction

function! s:register(name, class) abort
  let class = s:P.is_string(a:class) ? package#rimport(s:thisdir, a:class) : a:class
  let s:registry[a:name] = class
endfunction
function! s:unregister(name) abort
  unlet! s:registry[a:name]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
"vim: sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker
