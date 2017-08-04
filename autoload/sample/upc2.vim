" update tempclass v1 to v2
" batch substitute some api code

g/let l:obj = copy(s:class)/delete
g/let l:class = copy(s:class)/delete
%s/call l:obj._new_(a:000.*)/let l:obj = class#new(s:class, a:000)/
%s/let l:Suctor = s:class._suctor_()/let l:Suctor = class#Suctor(s:class)/
%s/call l:class._old_()/let l:class = class#old(s:class)/
%s/return s:class._isobject_(a:that)/return class#isobject(s:class, a:that)/
%s/return s:class._isa_(a:that)/return class#isa(s:class, a:that)/
