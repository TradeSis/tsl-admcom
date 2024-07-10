def temp-table ttmun
    field ci as char
    index imun ci.

def var i as i format ">>>>>>>>>>>9".

for each clien no-lock:

    i = i + 1.
    
    if i mod 10000 = 0
    then do:
        disp i with 1 down. pause 0.
    end.    

    find first ttmun where ttmun.ci = clien.cidade[1] no-error.

    if not avail ttmun
    then do:

        create ttmun.
        assign ttmun.ci = clien.cidade[1].
    end.
end.

output to /admcom/work/cidade.xls .
for each ttmun by ci:

    put ttmun.ci format "x(50)" skip.

end.
output close.