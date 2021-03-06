let s:save_cpo = &cpo
set cpo&vim

let s:Base = package#import('jp#System#Cache#Base')

let s:cache = {
      \ '_cached': {},
      \ '__name__': 'memory',
      \}
function! s:new(...) abort
  return extend(
        \ call(s:Base.new, a:000, s:Base),
        \ deepcopy(s:cache)
        \)
endfunction

function! s:cache.has(name) abort
  let cache_key = self.cache_key(a:name)
  return has_key(self._cached, cache_key)
endfunction
function! s:cache.get(name, ...) abort
  let default = get(a:000, 0, '')
  let cache_key = self.cache_key(a:name)
  if has_key(self._cached, cache_key)
    return self._cached[cache_key]
  else
    return default
  endif
endfunction
function! s:cache.set(name, value) abort
  let cache_key = self.cache_key(a:name)
  let self._cached[cache_key] = a:value
  call self.on_changed()
endfunction
function! s:cache.remove(name) abort
  let cache_key = self.cache_key(a:name)
  if has_key(self._cached, cache_key)
    unlet self._cached[cache_key]
    call self.on_changed()
  endif
endfunction
function! s:cache.keys() abort
  return keys(self._cached)
endfunction
function! s:cache.clear() abort
  let self._cached = {}
  call self.on_changed()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
"vim: sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker
