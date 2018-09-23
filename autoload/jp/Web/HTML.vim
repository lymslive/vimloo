let s:save_cpo = &cpo
set cpo&vim

let s:string = package#import('jp#Data#String')
let s:xml = package#import('jp#Web#XML')
let s:http = package#import('jp#Web#HTTP')

function! s:decodeEntityReference(str) abort
  let str = a:str
  let str = substitute(str, '&gt;', '>', 'g')
  let str = substitute(str, '&lt;', '<', 'g')
  let str = substitute(str, '&quot;', '"', 'g')
  let str = substitute(str, '&apos;', "'", 'g')
  let str = substitute(str, '&nbsp;', ' ', 'g')
  let str = substitute(str, '&yen;', '\&#65509;', 'g')
  let str = substitute(str, '&#\(\d\+\);', '\=s:string.nr2enc_char(submatch(1))', 'g')
  let str = substitute(str, '&amp;', '\&', 'g')
  let str = substitute(str, '&raquo;', '>', 'g')
  let str = substitute(str, '&laquo;', '<', 'g')
  return str
endfunction

function! s:encodeEntityReference(str) abort
  let str = a:str
  let str = substitute(str, '&', '\&amp;', 'g')
  let str = substitute(str, '>', '\&gt;', 'g')
  let str = substitute(str, '<', '\&lt;', 'g')
  let str = substitute(str, "\n", '\&#x0d;', 'g')
  let str = substitute(str, '"', '\&quot;', 'g')
  let str = substitute(str, "'", '\&apos;', 'g')
  let str = substitute(str, ' ', '\&nbsp;', 'g')
  return str
endfunction

function! s:parse(content) abort
  let content = substitute(a:content, '<\(area\|base\|basefont\|br\|nobr\|col\|frame\|hr\|img\|input\|isindex\|link\|meta\|param\|embed\|keygen\|command\)\([^>]*[^/]\|\)>', '<\1\2/>', 'g')
  return s:xml.parse(content)
endfunction

function! s:parseFile(fname) abort
  return s:parse(join(readfile(a:fname), "\n"))
endfunction

function! s:parseURL(url) abort
  return s:parse(s:http.get(a:url).content)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
