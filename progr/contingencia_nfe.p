{admcab.i}

{setbrw.i}

assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    .
    
def var vdt-ini as date.
def var vdt-fim as date.
def var vhr-ini as char.
def var vhr-fim as char.
def var vmotivo as char.

form contingenci.dtinicio column-label "Inicio"
     vhr-ini  no-label
     contingencia.dtfim column-label "Fim"
     vhr-fim  no-label
     contingencia.motivo[1] column-label "Motivo" format "x(36)"
      with frame f-linha.

find first contingencia where contingencia.dtfim = ? no-error.
if not avail contingencia
then do:
    sresp = no.
    message "Confirma entrar em CONTINGENCIA ?" update sresp.
    if sresp 
    then do:
            scroll from-current down with frame f-linha.
            create contingencia.
            contingencia.dtinicio = today.
            contingencia.hrinicio = time.
            vhr-ini = string(contingencia.hrinicio,"hh:mm:ss").
            disp contingencia.dtinicio 
                        vhr-ini 
                        with frame f-linha.
            vhr-fim = string(contingencia.hrfim,"hh:mm:ss").
            disp vhr-fim with frame f-linha.
            repeat:
                update        contingencia.motivo[1]
                   with frame f-linha.
                if contingencia.motivo[1] <> ""
                then leave.
            end.
            if contingencia.motivo[1] = ""
            then delete contingencia.
            
     end.
end.
else do:
    vhr-ini = string(contingencia.hrinicio,"hh:mm:ss").
            disp contingencia.dtinicio 
                        vhr-ini 
                        with frame f-linha.
            vhr-fim = string(contingencia.hrfim,"hh:mm:ss").
            disp vhr-fim with frame f-linha.

    disp contingencia.motivo[1] with frame f-linha.
    sresp = no.
    message "Confirma sair da CONTINGENCIA ?" update sresp.
    if sresp 
    then assign
            contingencia.dtfim = today
            contingencia.hrfim = time.
        
 end.

{sklcls.i
    &file = contingencia
    &cfield = contingencia.dtinicio
    &noncharacter = /*
    &ofield = " vhr-ini
                contingencia.dtfim 
                vhr-fim
                contingencia.motivo[1]
                 "
    &aftfnd1 = "
            vhr-ini = string(contingencia.hrinicio,""hh:mm:ss"").
            vhr-fim = string(contingencia.hrfim,""hh:mm:ss"").
            "
    &where = " true "
    &aftselec1 = "
            if keyfunction(lastkey) = ""RETURN""
            THEN DO:
                update contingencia.dtfim with frame f-linha.
                contingencia.hrfim = time.
                vhr-fim = string(contingencia.hrfim,""hh:mm:ss"").
                disp vhr-fim with frame f-linha.
                next keys-loop.
            END.      "
    &otherkey1 = "
        if keyfunction(lastkey) = ""INSERT-MODE""
        THEN DO:
            scroll from-current down with frame f-linha.
            create contingencia.
            contingencia.dtinicio = today.
            contingencia.hrinicio = time.
            vhr-ini = string(contingencia.hrinicio,""hh:mm:ss"").
            disp contingencia.dtinicio 
                        vhr-ini 
                        with frame f-linha.
            update contingencia.dtfim with frame f-linha.
            contingencia.hrfim = time.
            vhr-fim = string(contingencia.hrfim,""hh:mm:ss"").
            disp vhr-fim with frame f-linha.
            update        contingencia.motivo[1]
                   with frame f-linha.
        END. "
    &form = " frame f-linha 7 down row 7 width 80  overlay "
    
}
hide frame f-linha.
    
