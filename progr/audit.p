
def var vequ as char format "x(20)".
def temp-table tt-equ
    field etbcod like estab.etbcod
    field cxacod like caixa.cxacod
    field numequ as int.

for each mapcxa use-index ind-2 no-lock:
    find first tt-equ where tt-equ.etbcod = mapcxa.etbcod and
                            tt-equ.cxacod = mapcxa.de1    no-error.
                                
    if not avail tt-equ
    then create tt-equ.
    assign tt-equ.etbcod =  mapcxa.etbcod
           tt-equ.cxacod =  mapcxa.de1 
           tt-equ.numequ =  mapcxa.cxacod.

end.

output to l:\progr\numecf.txt.
for each tt-equ:
    if tt-equ.cxacod = 0
    then do:
        delete tt-equ.
        next.
    end.    
    put chr(34)
        tt-equ.etbcod format ">>9"
        tt-equ.numequ format "99"
        tt-equ.cxacod format "99" chr(34) skip.
end.
output close.



