{admcab.i}
def var vltotven like plani.platot.
def var vtotpre  like plani.platot.
def var vltotdes like plani.platot.
def var vpercmed like plani.platot.
def var vdti as date.
def var vdtf as date.
assign vltotven = 0
       vltotdes = 0
       vdtf = today
       vdti = today - 30 .

def var vetbcod like estab.etbcod.
update vetbcod label "Filial"
    with frame f1 1 down width 80 side-label.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f1.  
disp vdti at 1 label "Periodo de"
     vdtf label "ate"
     with frame f3 centered no-box side-label.
      
for each plani where plani.movtdc = 5
                 and plani.etbcod = vetbcod
                 and plani.pladat >= vdti
                 and plani.pladat <= vdtf
                 no-lock.
    
    vltotven = vltotven + (if plani.biss > 0
                           then plani.biss else plani.platot).

    if plani.notobs[2] <> ""
    then do:
        if substr(plani.notobs[2],1,1) <> "J"
        then assign vltotdes = vltotdes + dec(plani.notobs[2]).
    end.
end.

for each plani where plani.movtdc = 30
                 and plani.etbcod = vetbcod
                 and plani.pladat = vdtf
                     no-lock:
    if plani.serie <> "U"
    then next.
    
    vltotven = vltotven + (if plani.biss > 0
                               then plani.biss else plani.platot).

 
    if plani.notobs[2] <> "" 
    then do:
        if substr(plani.notobs[2],1,1) <> "J"
        then vltotdes = vltotdes + dec(plani.notobs[2]).
    end.
end.

vpercmed = ((vltotdes / vltotven) * 100).

disp " "
     vltotven label "Total Venda   " skip(1)
     vltotdes label "Total Desconto" skip(1)
     vpercmed label "Desconto medio" 
     " "
     with frame f2 centered side-label 1 column color message no-box
     row 8 .

pause 20 no-message.