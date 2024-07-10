{admcab.i new}

def temp-table tt-infoecf
    field etbcod like estab.etbcod
    field ecf as int
    field fab as char
    field posic as char extent 5
    index i1 etbcod ecf
    .

def var vecf as char extent 5.
def var vfab as char extent 5.
def var vcam1 as char extent 5.
def var vcam2 as char extent 5.
def var vcam3 as char extent 5.
def var vcam4 as char extent 5.
def var vcam5 as char extent 5.
def var vc as int.

input from /admcom/work/tt-infoecf.txt.
repeat:
    create tt-infoecf.
    import tt-infoecf.
end.
input close.
    
def var varqsai as char.
varqsai = "/admcom/relat/aliquotasecf." + string(time).
 
output to value(varqsai). 
for each estab where estab.etbcod <= 189 no-lock:
disp estab.etbcod with frame f1.
for each tt-infoecf where tt-infoecf.etbcod = estab.etbcod and
                        tt-infoecf.ecf <> 0:
    vc = vc + 1.
    disp tt-infoecf.ecf
         tt-infoecf.fab format "x(20)"
         tt-infoecf.posic[1]
         tt-infoecf.posic[2]
         tt-infoecf.posic[3]
         tt-infoecf.posic[4]
         tt-infoecf.posic[5]
     with frame f1 down width 100.
    down with frame f1.
end.
    
    put fill("-",100) format "x(85)" skip.
    

end.
output close.

run visurel.p(input varqsai, "").
