
def var rec-plani as recid.
def var ventrada as dec.
def var vcfop as int init 5102 format ">>>9".
def buffer btabdac for tabdac17.
def var vl-total as dec.
def var vp as int.
def var vplatot like plani.platot.
def var vnumero as char.
def var vetbcod like estab.etbcod.

{retorna-pacnv.i new}

def shared var vmes as int format "99".
def shared var vano as int format "9999".

def var vdti as date.
def var vdtf as date.
vdti = date(vmes,01,vano).
vdtf = date(if vmes = 12 then 01 else vmes + 1,
            01,
            if vmes = 12 then  vano + 1 else vano) - 1.
def temp-table tt-movim like movim.
def var vtot-mov as dec.
def var t-movim as dec.
def var a-movim as dec.

def temp-table tt-acres
    field etbcod like estab.etbcod
    field val_m as dec
    field val_c as dec
    field val_p as dec
    index i1 etbcod.

def temp-table tt-pla
    field etbcod like plani.etbcod
    field placod like plani.placod
    field pladat like plani.pladat
    .

def var vindex as int.
def var vtipo as char extent 2  format "x(15)"
    init["    EMISSAO","  VENCIMENTO"].
disp vtipo with frame f-tipo column 40 row 17 no-label.
choose field vtipo with frame f-tipo.
vindex = frame-index.

    
form "Aguarde processamento... " 
    tabdac17.numlan no-label with frame f-processa
    1 down column 40 row 20 overlay no-box color message.
pause 0.

def var d-catcod  as int.

if vindex = 1
then run acre-emissao.
else if vindex = 2
    then run acre-vencimento.

procedure acre-emissao:

for each tabdac17 where
         tabdac17.meslan = vmes and
         tabdac17.anolan = vano and
         tabdac17.tiplan = "ACRESCIMO" and 
         tabdac17.sitlan = "LEBES"
         no-lock.
    if tabdac17.vallan = 0 then next.
    disp tabdac17.numlan no-label with frame f-processa.
    pause 0.
    find first btabdac where btabdac.etbcod = tabdac17.etbcod and
                           btabdac.clicod = tabdac17.clicod and
                           btabdac.numlan = tabdac17.numlan and
                           btabdac.tiplan = "EMISSAO"
                           no-lock no-error.
    if not avail btabdac then next.
    find fin.contrato where fin.contrato.contnum = int(tabdac17.numlan) 
                no-lock no-error.
    rec-plani = ?.
    if avail fin.contrato
    then
    for each fin.contnf where
             fin.contnf.etbcod = fin.contrato.etbcod and
             fin.contnf.contnum = fin.contrato.contnum
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.pladat = fin.contrato.dtinicial and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.
    else if avail btabdac
    then for each fin.contnf where
             fin.contnf.etbcod = btabdac.etblan and
             fin.contnf.contnum = int(btabdac.numlan)
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.

    d-catcod = ?.
    vtot-mov = 0.
    find plani where recid(plani) = rec-plani no-lock no-error.
    if avail plani
    then do:
        for each movim where
                 movim.etbcod = plani.etbcod and
                 movim.placod = plani.placod and
                 movim.movtdc = plani.movtdc and
                 movim.movdat = plani.pladat
                 no-lock,
            first produ where produ.procod = movim.procod no-lock:         
            if produ.proipiper = 98
            then next.
            if d-catcod = ?
            then do:
                d-catcod = produ.catcod.
                leave.
            end.
            vtot-mov = vtot-mov + (movim.movpc * movim.movqtm). 
        end. 
        find first tt-acres where
                   tt-acres.etbcod = plani.etbcod  no-error. 
        if not avail tt-acres
        then do:
            create tt-acres.
            tt-acres.etbcod = plani.etbcod.
        end.
        if d-catcod = 81
        then tt-acres.val_p = tt-acres.val_p + tabdac17.vallan.
        else if d-catcod = 31
            then tt-acres.val_m = tt-acres.val_m + tabdac17.vallan.
            else tt-acres.val_c = tt-acres.val_c + tabdac17.vallan.
    end.
end.
for each tabdac17 where
         tabdac17.meslan = vmes and
         tabdac17.anolan = vano and
         tabdac17.tiplan = "ACRESCIMO" and 
         tabdac17.sitlan = "FINANCEIRA"
         no-lock.
    if tabdac17.vallan = 0 then next.
    disp tabdac17.numlan no-label with frame f-processa.
    pause 0.
    find first btabdac where btabdac.etbcod = tabdac17.etbcod and
                           btabdac.clicod = tabdac17.clicod and
                           btabdac.numlan = tabdac17.numlan and
                           btabdac.tiplan = "EMISSAO"
                           no-lock no-error.
    if not avail btabdac then next.
    find fin.contrato where fin.contrato.contnum = int(tabdac17.numlan) 
                no-lock no-error.
    rec-plani = ?.
    if avail fin.contrato
    then
    for each fin.contnf where
             fin.contnf.etbcod = fin.contrato.etbcod and
             fin.contnf.contnum = fin.contrato.contnum
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.pladat = fin.contrato.dtinicial and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.
    else if avail btabdac
    then for each fin.contnf where
             fin.contnf.etbcod = btabdac.etblan and
             fin.contnf.contnum = int(btabdac.numlan)
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.

    d-catcod = ?.
    vtot-mov = 0.
    find plani where recid(plani) = rec-plani no-lock no-error.
    if avail plani
    then do:
        for each movim where
                 movim.etbcod = plani.etbcod and
                 movim.placod = plani.placod and
                 movim.movtdc = plani.movtdc and
                 movim.movdat = plani.pladat
                 no-lock,
            first produ where produ.procod = movim.procod no-lock:         
            if produ.proipiper = 98
            then next.
            if d-catcod = ?
            then do:
                d-catcod = produ.catcod.
                leave.
            end.    
            vtot-mov = vtot-mov + (movim.movpc * movim.movqtm). 
        end. 
        find first tt-acres where
                   tt-acres.etbcod = plani.etbcod  no-error. 
        if not avail tt-acres
        then do:
            create tt-acres.
            tt-acres.etbcod = plani.etbcod.
        end.
        if d-catcod = 81
        then tt-acres.val_p = tt-acres.val_p + tabdac17.vallan.
        else if d-catcod = 31
            then tt-acres.val_m = tt-acres.val_m + tabdac17.vallan.
            else tt-acres.val_c = tt-acres.val_c + tabdac17.vallan.
    end.
end.

def buffer s-classe for clase.

for each clase where clase.clasup = 801010000 no-lock,
    each s-classe where s-classe.clasup = clase.clacod no-lock,
    each produ where produ.clacod = s-classe.clacod no-lock.
    
    for each movim where movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= vdti and
                         movim.movdat <= vdtf
                         no-lock:
        find first tt-pla where
                   tt-pla.etbcod = movim.etbcod and
                   tt-pla.placod = movim.placod and
                   tt-pla.pladat = movim.movdat
                   no-error.
        if not avail tt-pla
        then do:
            create tt-pla.
            assign
            tt-pla.etbcod = movim.etbcod
            tt-pla.placod = movim.placod
            tt-pla.pladat = movim.movdat
            .
        end.           
    end.
end.                         
    
for each tt-pla no-lock:
    find plani where    plani.etbcod = tt-pla.etbcod and
                        plani.placod = tt-pla.placod and
                        plani.pladat = tt-pla.pladat
                        no-lock no-error.
        find first tt-acres where
                   tt-acres.etbcod = plani.etbcod  no-error. 
        if not avail tt-acres
        then do:
            create tt-acres.
            tt-acres.etbcod = plani.etbcod.
        end.
        tt-acres.val_p = 
            tt-acres.val_p + (plani.biss - plani.platot).
end. 
end procedure.

procedure acre-vencimento:
    for each fin.titulo where titulo.titnat = no and
                              titulo.titdtven >= vdti and
                              titulo.titdtven <= vdtf and
                              titulo.modcod <> "VVI"
                              no-lock:
        disp titulo.titnum @ tabdac17.numlan with frame f-processa.
        pause 0.
        pacnv-acrescimo = 0.
        find first titpacnv where
               titpacnv.modcod = titulo.modcod and
               titpacnv.etbcod = titulo.etbcod and 
               titpacnv.clifor = titulo.clifor and
               titpacnv.titnum = titulo.titnum and
               titpacnv.titdtemi = titulo.titdtemi
                       no-lock no-error.
        if avail titpacnv
        then pacnv-acrescimo = titpacnv.acrescimo.
        else run /admcom/custom/Claudir/retorna-pacnv-valores.p 
                    (input ?, 
                     input ?, 
                     input recid(titulo)).

        if titulo.modcod = "CRE"
        then do:
        find fin.contrato where fin.contrato.contnum = int(titulo.titnum) 
                no-lock no-error.
        rec-plani = ?.
        if avail fin.contrato
        then
        for each fin.contnf where
             fin.contnf.etbcod = fin.contrato.etbcod and
             fin.contnf.contnum = fin.contrato.contnum
             no-lock:
            find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.pladat = fin.contrato.dtinicial and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
            if avail plani
            then do:
                rec-plani = recid(plani).
                leave.
            end.                       
        end.
        else if avail btabdac
        then for each fin.contnf where
             fin.contnf.etbcod = btabdac.etblan and
             fin.contnf.contnum = int(btabdac.numlan)
             no-lock:
            find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
            if avail plani
            then do:
                rec-plani = recid(plani).
                leave.
            end.                       
        end.

        d-catcod = ?.
        vtot-mov = 0.
        find plani where recid(plani) = rec-plani no-lock no-error.
        if avail plani
        then do:
            for each movim where
                 movim.etbcod = plani.etbcod and
                 movim.placod = plani.placod and
                 movim.movtdc = plani.movtdc and
                 movim.movdat = plani.pladat
                 no-lock,
                first produ where produ.procod = movim.procod no-lock:         
                if produ.proipiper = 98
                then next.
                if d-catcod = ?
                then do:
                    d-catcod = produ.catcod.
                    leave.
                end.    
                vtot-mov = vtot-mov + (movim.movpc * movim.movqtm). 
            end. 
            find first tt-acres where
                   tt-acres.etbcod = plani.etbcod  no-error. 
            if not avail tt-acres
            then do:
                create tt-acres.
                tt-acres.etbcod = plani.etbcod.
            end.
            if d-catcod = 81
            then tt-acres.val_p = tt-acres.val_p + pacnv-acrescimo.
            else if d-catcod = 31
                then tt-acres.val_m = tt-acres.val_m + pacnv-acrescimo.
                else tt-acres.val_c = tt-acres.val_c + pacnv-acrescimo.
        end.
        end.
        else if titulo.modcod begins "CP"
        then do:
            find first titpacnv where
               titpacnv.modcod = titulo.modcod and
               titpacnv.etbcod = titulo.etbcod and 
               titpacnv.clifor = titulo.clifor and
               titpacnv.titnum = titulo.titnum and
               titpacnv.titdtemi = titulo.titdtemi
                       no-lock no-error.
            if avail titpacnv
            then pacnv-acrescimo = titpacnv.acrescimo.
            else run /admcom/custom/Claudir/retorna-pacnv-valores.p 
                    (input ?, 
                     input ?, 
                     input recid(titulo)).

            find first tt-acres where
                   tt-acres.etbcod = titulo.etbcod  no-error. 
            if not avail tt-acres
            then do:
                create tt-acres.
                tt-acres.etbcod = titulo.etbcod.
            end.
            tt-acres.val_p = tt-acres.val_p + pacnv-acrescimo.
            
        end.
    end.
end procedure.

procedure acre-recebimento:                                      

for each tabdac17 where
         tabdac17.meslan = vmes and
         tabdac17.anolan = vano and
         tabdac17.tiplan = "RECEBIMENTO" and 
         tabdac17.sitlan = "LEBES"
         no-lock.
    if tabdac17.acrescimo = 0 then next.
    disp tabdac17.numlan no-label with frame f-processa.
    pause 0.
    find first btabdac where btabdac.etbcod = tabdac17.etbcod and
                           btabdac.clicod = tabdac17.clicod and
                           btabdac.numlan = tabdac17.numlan and
                           btabdac.tiplan = "EMISSAO"
                           no-lock no-error.
    if not avail btabdac then next.
    find fin.contrato where fin.contrato.contnum = int(tabdac17.numlan) 
                no-lock no-error.
    rec-plani = ?.
    if avail fin.contrato
    then
    for each fin.contnf where
             fin.contnf.etbcod = fin.contrato.etbcod and
             fin.contnf.contnum = fin.contrato.contnum
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.pladat = fin.contrato.dtinicial and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.
    else if avail btabdac
    then for each fin.contnf where
             fin.contnf.etbcod = btabdac.etblan and
             fin.contnf.contnum = int(btabdac.numlan)
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.

    d-catcod = ?.
    vtot-mov = 0.
    find plani where recid(plani) = rec-plani no-lock no-error.
    if avail plani
    then do:
        for each movim where
                 movim.etbcod = plani.etbcod and
                 movim.placod = plani.placod and
                 movim.movtdc = plani.movtdc and
                 movim.movdat = plani.pladat
                 no-lock,
            first produ where produ.procod = movim.procod no-lock:         
            if produ.proipiper = 98
            then next.
            if d-catcod = ?
            then do:
                d-catcod = produ.catcod.
                leave.
            end.    
            vtot-mov = vtot-mov + (movim.movpc * movim.movqtm). 
        end. 
        find first tt-acres where
                   tt-acres.etbcod = tabdac17.etblan  no-error. 
        if not avail tt-acres
        then do:
            create tt-acres.
            tt-acres.etbcod = tabdac17.etblan.
        end.
        if d-catcod = 81
        then tt-acres.val_p = tt-acres.val_p + tabdac17.vallan.
        else if d-catcod = 31
            then tt-acres.val_m = tt-acres.val_m + tabdac17.vallan.
            else tt-acres.val_c = tt-acres.val_c + tabdac17.vallan.
    end.
end.
for each tabdac17 where
         tabdac17.meslan = vmes and
         tabdac17.anolan = vano and
         tabdac17.tiplan = "RECEBIMENTO" and 
         tabdac17.sitlan = "FINANCEIRA"
         no-lock.
    if tabdac17.acrescimo = 0 then next.
    disp tabdac17.numlan no-label with frame f-processa.
    pause 0.
    find first btabdac where btabdac.etbcod = tabdac17.etbcod and
                           btabdac.clicod = tabdac17.clicod and
                           btabdac.numlan = tabdac17.numlan and
                           btabdac.tiplan = "EMISSAO"
                           no-lock no-error.
    if not avail btabdac then next.
    find fin.contrato where fin.contrato.contnum = int(tabdac17.numlan) 
                no-lock no-error.
    rec-plani = ?.
    if avail fin.contrato
    then
    for each fin.contnf where
             fin.contnf.etbcod = fin.contrato.etbcod and
             fin.contnf.contnum = fin.contrato.contnum
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.pladat = fin.contrato.dtinicial and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.
    else if avail btabdac
    then for each fin.contnf where
             fin.contnf.etbcod = btabdac.etblan and
             fin.contnf.contnum = int(btabdac.numlan)
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.

    d-catcod = ?.
    vtot-mov = 0.
    find plani where recid(plani) = rec-plani no-lock no-error.
    if avail plani
    then do:
        for each movim where
                 movim.etbcod = plani.etbcod and
                 movim.placod = plani.placod and
                 movim.movtdc = plani.movtdc and
                 movim.movdat = plani.pladat
                 no-lock,
            first produ where produ.procod = movim.procod no-lock:         
            if produ.proipiper = 98
            then next.
            if d-catcod = ?
            then do:
                d-catcod = produ.catcod.
                leave.
            end.    
            vtot-mov = vtot-mov + (movim.movpc * movim.movqtm). 
        end. 
        find first tt-acres where
                   tt-acres.etbcod = tabdac17.etblan  no-error. 
        if not avail tt-acres
        then do:
            create tt-acres.
            tt-acres.etbcod = tabdac17.etblan.
        end.
        if d-catcod = 81
        then tt-acres.val_p = tt-acres.val_p + tabdac17.acrescimo.
        else if d-catcod = 31
            then tt-acres.val_m = tt-acres.val_m + tabdac17.acrescimo.
            else tt-acres.val_c = tt-acres.val_c + tabdac17.acrescimo.
    end.
end.

for each fin.titulo where
         titulo.titnat = no and
         titulo.titdtpag >= vdti and
         titulo.titdtpag <= vdtf and
         titulo.modcod begins "CP"
            no-lock:

    find first titpacnv where
               titpacnv.modcod = titulo.modcod and
               titpacnv.etbcod = titulo.etbcod and 
               titpacnv.clifor = titulo.clifor and
               titpacnv.titnum = titulo.titnum and
               titpacnv.titdtemi = titulo.titdtemi
                       no-lock no-error.
    if avail titpacnv
    then pacnv-acrescimo = titpacnv.acrescimo.
    else run /admcom/custom/Claudir/retorna-pacnv-valores.p 
                    (input ?, 
                     input ?, 
                     input recid(titulo)).

    find first tt-acres where
                   tt-acres.etbcod = titulo.etbcobra no-error. 
    if not avail tt-acres
    then do:
            create tt-acres.
            tt-acres.etbcod = titulo.etbcobra.
    end.
    tt-acres.val_p = tt-acres.val_p + pacnv-acrescimo.
end.

end procedure.


def var varquivo as char.
varquivo = "/admcom/relat/diario-acrescimo-filial-" 
+ vtipo[vindex] + "-" + string(vmes,"99")
                + "-" + string(vano,"9999") + ".csv".
output to value(varquivo).
put vtipo[vindex] skip. 
put "Filial;Moveis;Moda;Credito Pessoal" skip.

for each tt-acres:
    put unformatted tt-acres.etbcod
        ";"
        replace(string(tt-acres.val_m,">>>>>>>>9.99"),".",",")
        ";"
        replace(string(tt-acres.val_c,">>>>>>>>9.99"),".",",")
        ";"
        replace(string(tt-acres.val_p,">>>>>>>>9.99"),".",",")
        skip.
end.
        
output close.

hide frame f-processa no-pause.

message color red/with
    "Arquivo gerado:" skip
    varquivo
    view-as alert-box.
    
    
