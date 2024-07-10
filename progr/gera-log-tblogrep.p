def var i as int.
output to /admcom/logs/tblogrep.txt.
do i = 1 to 200:
    find last tblogrep where 
              tblogrep.tipo   = "REPLICA" and
              tblogrep.etbcod = i and
              tblogrep.data  <= today and
              tblogrep.banco = ""
              no-lock no-error.
    if avail tblogrep
    then put  
         tblogrep.etbcod  " "
         tblogrep.data    " "
         string(tblogrep.tempo,"hh:mm:ss")
        skip .
end.

output close.

pause 0.

quit.


