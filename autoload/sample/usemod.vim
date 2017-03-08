let s:List = module#import('unite.Data.List')
let s:array = [1, 2, 3]
echo s:array

:DLOG 'call pop ...'
echo s:List.pop(s:array)
echo s:array

:DLOG 'call push ...'
echo s:List.push(s:array, 4)
echo s:array
