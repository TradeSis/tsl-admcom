def output parameter par-num as int.
find last tdocbase no-lock no-error.
if not avail tdocbase
then par-num = 1.
else par-num = tdocbase.dcbcod + 1.

 