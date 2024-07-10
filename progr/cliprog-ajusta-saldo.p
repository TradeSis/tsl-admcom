def var sresp as log format "Sim/Nao".
def var vtotal as dec format ">>>,>>>,>>9.99".
def var vajuste as dec format ">>>,>>>,>>9.99".
def var vdatref as date.

def var vt as dec.
def var vclidec as dec.
def var vsaldo as dec format ">>>,>>>,>>9.99".
def var vdifer as dec format ">>>,>>>,>>9.99".

def var vdti as date.
def var vdtf as date.
update vdti label "Periodo de referencia"
       vdtf no-label
       vsaldo at 8 label "Saldo contabil"
       with frame f-ajuste side-label 1 down.

vdatref = vdtf.
def var vdisp as dec.
for each SC2015 use-index INDX2  where 
                        SC2015.titnat = no and
                            SC2015.titdtemi <= vdatref
                and  ((SC2015.titdtpag > vdatref and
                      SC2015.titsit = "PAG") or
                      SC2015.titsit = "LIB")
                      no-lock:
        
                      if sc2015.titdtmovref > vdatref or
                         sc2015.titdtmovref = ?
                      then next.

        vtotal = vtotal + sc2015.titvlcob.
        vdisp = vdisp +   sc2015.titvlcob.
        if vdisp > 100000
        then do:
            disp vtotal with frame f-ajuste.
            pause 0.
            vdisp = 0.
        end.
end.

vdifer = vtotal - vsaldo.
disp vtotal at 11 label "Saldo atual"
     vdifer at 9  label "Valor ajustar"
     with frame f-ajuste.
.
def buffer bsc2015 for sc2015.
vajuste = 0.
if vdifer > 0
then do:
    sresp = no.
    message "Confirma ajustar saldo?" update sresp.
    if sresp
    then do:       
        for each sc2015 where
             sc2015.titdtmovref >= vdti and
             sc2015.titdtmovref <= vdtf and
             sc2015.titsit = "LIB" and
             sc2015.titdtven > vdtf and
             sc2015.titpar = 1 no-lock
             :
             
            find first bsc2015 of sc2015 where
                    bsc2015.titpar = 0
                    no-lock no-error.
            if avail bsc2015
            then next.
                    
            for each  bsc2015 where
              bsc2015.clifor =  sc2015.clifor and
              bsc2015.titnum =  sc2015.titnum
              :
                if vajuste + bsc2015.titvlcob <= vdifer
                then do:
                    vajuste = vajuste + bsc2015.titvlcob.
                    bsc2015.titsit  = "EXCAJ".
                end. 
            end.
        end.
        disp vajuste at 8 label "Valor ajustado" with frame f-ajuste.
    end.
end.
def var new-difer as dec format "->>>,>>>,>>9.99".
def var val-ajustar as dec format "->>>,>>>,>>9.99".
def var val-ajustado as dec format "->>>,>>>,>>9.99".
new-difer = vdifer - vajuste.

disp new-difer at 8 label "Nova diferenca" with frame f-ajuste.

if new-difer > 0
then do:
    sresp = no.
    message "Deseja ajustar?" update sresp.
    if sresp
    then do:
        for each sc2015 where
             sc2015.titdtmovref >= vdti and
             sc2015.titdtmovref <= vdtf and
             sc2015.titsit = "LIB" and
             sc2015.cobcod = 22 and
             sc2015.titvlcob >= new-difer
             :
            disp sc2015.titvlcob column-label "Valor!parcela"
                    with frame f-altera with down.
            update val-ajustar column-label "Valor!ajustar"
                    with frame f-altera.
            if val-ajustar <> 0
            then do:
                hide message no-pause.
                sresp = no.
                message "Confirma ajuste?" update sresp.
                if sresp
                then do:
                    sc2015.titvlcob = sc2015.titvlcob - val-ajustar.
                    val-ajustado = val-ajustado + val-ajustar.
                end.
            end.
            disp val-ajustado column-label "Valor!ajustado"
                            with frame f-altera.
            if val-ajustado = new-difer
            then leave.
        end.
    end.
end.
if new-difer - val-ajustado = 0
then do:
    message color red/with
    "Saldo contabil de " vsaldo "ajustado"
    view-as alert-box.
end.
else do:
    message color red/with    
    "Saldo contabil divergente de " new-difer - val-ajustado
    view-as alert-box.
end.    


