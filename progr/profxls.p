def temp-table ttprof
    field prof as char
    index iprof prof.

def var i as i format ">>>>>>>>>>>9".

for each clien no-lock:

    i = i + 1.
    
    if i mod 10000 = 0
    then do:
        disp i with 1 down. pause 0.
    end.    

    find first ttprof where ttprof.prof = clien.proprof[1] no-error.

    if not avail ttprof
    then do:

        create ttprof.
        assign ttprof.prof = clien.proprof[1].

    end.
end.

output to /admcom/work/profissao.xls .
for each ttprof by ttprof.prof:

    put ttprof.prof format "x(50)" skip.

end.
output close.