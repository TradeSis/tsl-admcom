def shared var vmes as int format "99".
def shared var vano as int format "9999".
def shared var vdti as date.
def shared var vdtf as date.
def shared var vdtblo as date.

def temp-table tt-titulo like fin.titulo.
def buffer btabdac for tabdac.
def var val-lan as dec.
def var vtotal as dec.
def var v-ano as int format "9999".
def var v-mes as int format "99".
def var v-tipo as char format "x(15)".
def var v-tipo1 as char format "x(15)".
def var vtitpar like fin.titulo.titpar.
def var vtitdtven like fin.titulo.titdtven.
def var vtitdtemi like fin.titulo.titdtemi.
def var vdat-aux as date.
v-mes = vmes.
v-ano = vano.
v-tipo1 = "".
disp v-mes label "Mes"
     v-ano label "Ano"
     v-tipo1 label "Emissao/Recebimento"
     with frame f-ddisp.
update v-tipo1 with frame f-ddisp.

vdat-aux = date(if v-mes = 12 then 01 else v-mes + 1,
                01,
                if v-mes = 12 then v-ano + 1 else v-ano) - 1.
disp vdat-aux label "Data base"
        with frame f-ddisp. 
pause 0.

def var sresp as log format "Sim/Nao".
sresp = no.
message "Confirma processar BASE DE SALDOS?" update sresp.
if not sresp then return.
                
pause 0 before-hide.
def var vi as int.
def var v-sair as log.
repeat:
    v-sair = no.
if v-tipo1 = "EMISSAO" or v-tipo1 = ""
then do:
    disp "PROCESSANDO EMISSAO" with frame f-ddisp1 NO-LABEL
            row 12 no-box color message width 80.
    pause 0.
    v-tipo = "EMI".
    for each tabdac where
         tabdac.anolan = v-ano and
         tabdac.meslan = v-mes and
         tabdac.tiplan begins v-tipo and
         tabdac.sitlan = "LEBES"
         no-lock:

        val-lan = tabdac.vallan.
        find first btabdac where
                  btabdac.etblan  = tabdac.etblan  and
                  btabdac.datlan  = tabdac.datlan  and
                  btabdac.clicod  = tabdac.clicod  and
                  btabdac.numlan  = tabdac.numlan  and
                  btabdac.parlan  = ? and
                  btabdac.tiplan begins "ACR" and
                  btabdac.sitlan = "LEBES"
                  no-lock no-error.
        if avail btabdac
        then val-lan = val-lan + btabdac.vallan.     
        vtotal = 0.
        for each tt-titulo: delete tt-titulo. end.
        if vtotal < val-lan
        then
        for each fin.titulo where
                 fin.titulo.empcod = 19 and
                 fin.titulo.titnat = no and
                 fin.titulo.modcod = "CRE" and
                 fin.titulo.etbcod = tabdac.etblan and
                 fin.titulo.clifor = int(tabdac.clicod) and
                 fin.titulo.titnum = trim(tabdac.numlan)
                 no-lock:
            if  vtotal + fin.titulo.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = fin.titulo.empcod and
                           tt-titulo.titnat = fin.titulo.titnat and
                           tt-titulo.modcod = fin.titulo.modcod and
                           tt-titulo.etbcod = fin.titulo.etbcod and
                           tt-titulo.clifor = fin.titulo.clifor and
                           tt-titulo.titnum = fin.titulo.titnum and
                           tt-titulo.titpar = fin.titulo.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy fin.titulo to tt-titulo.
                    assign
                        tt-titulo.titdtemi = tabdac.datlan
                        tt-titulo.titdtpag = ?
                        tt-titulo.titsit   = "LIB"
                        .
                    vtotal = vtotal + fin.titulo.titvlcob.
                end.
             end.    
        end.
        if vtotal < val-lan
        then
        for each d.titulo where
                 d.titulo.etbcod = 19 and
                 d.titulo.titnat = no and
                 d.titulo.modcod = "CRE" and
                 d.titulo.etbcod = tabdac.etblan and
                 d.titulo.clifor = int(tabdac.clicod) and
                 d.titulo.titnum = trim(tabdac.numlan)
                 no-lock:
            if vtotal + d.titulo.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = d.titulo.empcod and
                           tt-titulo.titnat = d.titulo.titnat and
                           tt-titulo.modcod = d.titulo.modcod and
                           tt-titulo.etbcod = d.titulo.etbcod and
                           tt-titulo.clifor = d.titulo.clifor and
                           tt-titulo.titnum = d.titulo.titnum and
                           tt-titulo.titpar = d.titulo.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy d.titulo to tt-titulo.
                    assign
                        tt-titulo.titdtemi = tabdac.datlan
                        tt-titulo.titdtpag = ?
                        tt-titulo.titsit   = "LIB"
                        .
                    vtotal = vtotal + d.titulo.titvlcob.
                end.
             end.    
        end.
        if vtotal < val-lan
        then 
        for each titulosal where
                 titulosal.empcod = 19 and
                 titulosal.titnat = no and
                 titulosal.modcod = "CRE" and
                 titulosal.etbcod = tabdac.etblan and
                 titulosal.clifor = int(tabdac.clicod) and
                 titulosal.titnum = trim(tabdac.numlan)
                 no-lock:
            if  vtotal + titulosal.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = titulosal.empcod and
                           tt-titulo.titnat = titulosal.titnat and
                           tt-titulo.modcod = titulosal.modcod and
                           tt-titulo.etbcod = titulosal.etbcod and
                           tt-titulo.clifor = titulosal.clifor and
                           tt-titulo.titnum = titulosal.titnum and
                           tt-titulo.titpar = titulosal.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy titulosal to tt-titulo.
                    assign
                        tt-titulo.titdtemi = tabdac.datlan
                        tt-titulo.titdtpag = ?
                        tt-titulo.titsit   = "LIB"
                        .
                    vtotal = vtotal + titulosal.titvlcob.
                end.
             end.    
        end.  
        
        vtotal = 0.
        for each tt-titulo no-lock by tt-titulo.titpar:
            vtotal = vtotal + tt-titulo.titvlcob.
            vtitpar = tt-titulo.titpar.
            vtitdtven = tt-titulo.titdtven.
        end.    
        if val-lan > vtotal 
        then do:
            create tt-titulo.
            assign
                tt-titulo.empcod = 19 
                tt-titulo.titnat = no
                tt-titulo.modcod = "CRE"
                tt-titulo.etbcod = tabdac.etblan 
                tt-titulo.clifor = int(tabdac.clicod) 
                tt-titulo.titnum = trim(tabdac.numlan) 
                tt-titulo.titpar = vtitpar + 1
                tt-titulo.titdtemi = tabdac.datlan
                tt-titulo.titdtven = vtitdtven + 30
                tt-titulo.titsit = "LIB"
                tt-titulo.titvlcob = val-lan - vtotal
                tt-titulo.cobcod  = 22
                .
        end.
        vtotal = 0.
        for each tt-titulo:
            vtotal = vtotal + tt-titulo.titvlcob.
            assign
                tt-titulo.titdtemi = tabdac.datlan
                tt-titulo.titdtpag = ?
                tt-titulo.titsit   = "LIB"
                tt-titulo.etbcobra = 0
                .
        end.    
        disp val-lan vtotal val-lan - vtotal 
            with frame f-ddisp1.
        pause 0.    
        /*if val-lan <> vtotal 
        then do:
            disp val-lan vtotal.
            pause.
        end.    
        else*/ do:
            for each tt-titulo no-lock:
                find first SC2015 where
                           SC2015.empcod = tt-titulo.empcod and
                           SC2015.titnat = tt-titulo.titnat and
                           SC2015.modcod = tt-titulo.modcod and
                           SC2015.etbcod = tt-titulo.etbcod and
                           SC2015.clifor = tt-titulo.clifor and
                           SC2015.titnum = tt-titulo.titnum and
                           SC2015.titpar = tt-titulo.titpar
                           no-error.
                if not avail SC2015
                then do:
                    create SC2015.
                    buffer-copy tt-titulo to SC2015.
                    SC2015.titdtmovref = vdat-aux.
                end.
            end.   
        end.
    end.
    if v-tipo1 <> ""
    then v-sair = yes.
end.    
if v-sair then leave.

if v-tipo1 = "RECEBIMENTO"  or v-tipo1 = "" 
THEN DO:
    disp "PROCESSANDO RECEBIMENTO" with frame f-ddisp2 NO-LABEL
            row 12 no-box color message width 80.
    pause 0.
    v-tipo = "REC".
    for each tabdac where
         tabdac.anolan = v-ano and
         tabdac.meslan = v-mes and
         tabdac.tiplan begins v-tipo and
         tabdac.sitlan = "LEBES"
         no-lock:
        val-lan = tabdac.vallan.
        vtotal = 0.
        for each tt-titulo: delete tt-titulo. end.
        if vtotal < val-lan
        then for each fin.titulo where
                 fin.titulo.titdtpag = tabdac.datpag and
                 fin.titulo.etbcobra = tabdac.etbpag and
                 fin.titulo.clifor = int(tabdac.clicod) and
                 fin.titulo.titnum = trim(tabdac.numlan) and
                 fin.titulo.titpar = tabdac.parlan 
                 no-lock:
            if  vtotal + fin.titulo.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = fin.titulo.empcod and
                           tt-titulo.titnat = fin.titulo.titnat and
                           tt-titulo.modcod = fin.titulo.modcod and
                           tt-titulo.etbcod = fin.titulo.etbcod and
                           tt-titulo.clifor = fin.titulo.clifor and
                           tt-titulo.titnum = fin.titulo.titnum and
                           tt-titulo.titpar = fin.titulo.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy fin.titulo to tt-titulo.
                    vtotal = vtotal + fin.titulo.titvlcob.
                end.
             end.    
        end.
        if vtotal < val-lan
        then
        for each d.titulo where
                 d.titulo.clifor   = int(tabdac.clicod) and
                 d.titulo.titnum   = trim(tabdac.numlan) and
                 d.titulo.titdtpag = tabdac.datpag and
                 d.titulo.etbcobra = tabdac.etbpag and
                 d.titulo.titpar   = tabdac.parlan   
                 no-lock:
            if vtotal + d.titulo.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = d.titulo.empcod and
                           tt-titulo.titnat = d.titulo.titnat and
                           tt-titulo.modcod = d.titulo.modcod and
                           tt-titulo.etbcod = d.titulo.etbcod and
                           tt-titulo.clifor = d.titulo.clifor and
                           tt-titulo.titnum = d.titulo.titnum and
                           tt-titulo.titpar = d.titulo.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy d.titulo to tt-titulo.
                    vtotal = vtotal + d.titulo.titvlcob.
                end.
             end.    
        end. 
        if vtotal < val-lan
        then
        for each titulosal where
                 titulosal.titdtpag = tabdac.datpag and
                 titulosal.etbcobra = tabdac.etbpag and
                 titulosal.clifor = int(tabdac.clicod) and
                 titulosal.titnum = trim(tabdac.numlan) and
                 titulosal.titpar = tabdac.parlan 
                 no-lock:
            if vtotal + titulosal.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = titulosal.empcod and
                           tt-titulo.titnat = titulosal.titnat and
                           tt-titulo.modcod = titulosal.modcod and
                           tt-titulo.etbcod = titulosal.etbcod and
                           tt-titulo.clifor = titulosal.clifor and
                           tt-titulo.titnum = titulosal.titnum and
                           tt-titulo.titpar = titulosal.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy titulosal to tt-titulo.
                    vtotal = vtotal + titulosal.titvlcob.
                end.
             end.    
        end. 
        vtotal = 0.
        for each tt-titulo no-lock by tt-titulo.titpar:
            vtotal = vtotal + tt-titulo.titvlcob.
            vtitpar = tt-titulo.titpar.
            vtitdtven = tt-titulo.titdtven.
        end.    

        if val-lan > vtotal 
        then do:
            /*
            find first mov.titulo where 
                       mov.titulo.empcod = 19 and
                       mov.titulo.titnat = no and
                       mov.titulo.modcod = "CRE" and
                       mov.titulo.etbcod = tabdac.etblan and
                       mov.titulo.clifor = int(tabdac.clicod) and
                       mov.titulo.titnum = trim(tabdac.numlan)
                       no-lock no-error.
            if not avail mov.titulo
            then do: */
                find first d.titulo where
                           d.titulo.empcod = 19 and
                           d.titulo.titnat = no and
                           d.titulo.modcod = "CRE" and
                           d.titulo.etbcod = tabdac.etblan and
                           d.titulo.clifor = int(tabdac.clicod) and
                           d.titulo.titnum = trim(tabdac.numlan)
                           no-lock no-error.
                if not avail d.titulo
                then do:
                    find first fin.titulo where
                            fin.titulo.empcod = 19 and
                            fin.titulo.titnat = no and
                            fin.titulo.modcod = "CRE" and
                            fin.titulo.etbcod = tabdac.etblan and
                            fin.titulo.clifor = int(tabdac.clicod) and
                            fin.titulo.titnum = trim(tabdac.numlan)
                            no-lock no-error.
                    if not avail fin.titulo
                    then vtitdtemi = tabdac.datemi.
                    else vtitdtemi = fin.titulo.titdtemi.
                end.
                else vtitdtemi = d.titulo.titdtemi.
            /*end.
            else vtitdtemi = mov.titulo.titdtemi.        
            */
            create tt-titulo.
            assign
                tt-titulo.empcod = 19 
                tt-titulo.titnat = no
                tt-titulo.modcod = "CRE"
                tt-titulo.etbcod = tabdac.etblan 
                tt-titulo.clifor = int(tabdac.clicod) 
                tt-titulo.titnum = trim(tabdac.numlan) 
                tt-titulo.titpar = tabdac.parlan
                tt-titulo.titdtemi = tabdac.datlan
                tt-titulo.titdtven = tabdac.datlan
                tt-titulo.titsit = "PAG"
                tt-titulo.titvlcob = val-lan - vtotal
                tt-titulo.cobcod  = 22
                tt-titulo.titdtpag = tabdac.datlan
                tt-titulo.titvlpag = val-lan - vtotal
                .
        end.
        
        
        vtotal = 0.
        for each tt-titulo:
            vtotal = vtotal + tt-titulo.titvlcob.
            assign
                tt-titulo.titdtpag = tabdac.datlan
                tt-titulo.titsit   = "PAG"
                tt-titulo.etbcobra = tabdac.etblan
                .
        end.    
        disp val-lan vtotal val-lan - vtotal 
            with frame f-ddisp2.
        pause 0.
            
        /*if val-lan <> vtotal 
        then do:
            disp val-lan vtotal. 
            pause.
            
        end.    
        else*/ do:
            for each tt-titulo no-lock:
                find first SC2015 where
                           SC2015.empcod = tt-titulo.empcod and
                           SC2015.titnat = tt-titulo.titnat and
                           SC2015.modcod = tt-titulo.modcod and
                           SC2015.etbcod = tt-titulo.etbcod and
                           SC2015.clifor = tt-titulo.clifor and
                           SC2015.titnum = tt-titulo.titnum and
                           SC2015.titpar = tt-titulo.titpar
                           no-error.
                if not avail SC2015
                then do: 
                    create SC2015.
                    buffer-copy tt-titulo to SC2015.
                    SC2015.titdtmovref = vdat-aux.
                end.
                else assign
                    SC2015.titdtpag = tt-titulo.titdtpag 
                    SC2015.titsit   = tt-titulo.titsit 
                    SC2015.etbcobra = tt-titulo.etbcobra
                     .
            end.   
        end.
    end.
    disp "PROCESSANDO DEVOLUCOES" with frame f-ddisp3 NO-LABEL
            row 12 no-box color message width 80.
    pause 0.
 
    v-tipo = "DEVOLUCAO" .
    for each tabdac where
         tabdac.anolan = v-ano and
         tabdac.meslan = v-mes and
         tabdac.tiplan = v-tipo and
         tabdac.sitlan = "LEBES"
         no-lock:
        val-lan = tabdac.vallan.
        vtotal = 0.
        for each tt-titulo: delete tt-titulo. end.
        if vtotal < val-lan
        then
        for each fin.titulo where
                 fin.titulo.clifor = int(tabdac.clicod) and
                 fin.titulo.titnum = trim(tabdac.numlan) 
                 no-lock:
            if  vtotal + fin.titulo.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = fin.titulo.empcod and
                           tt-titulo.titnat = fin.titulo.titnat and
                           tt-titulo.modcod = fin.titulo.modcod and
                           tt-titulo.etbcod = fin.titulo.etbcod and
                           tt-titulo.clifor = fin.titulo.clifor and
                           tt-titulo.titnum = fin.titulo.titnum and
                           tt-titulo.titpar = fin.titulo.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy fin.titulo to tt-titulo.
                    vtotal = vtotal + fin.titulo.titvlcob.
                end.
             end.    
        end.
        if vtotal < val-lan
        then
        for each d.titulo where
                 d.titulo.clifor = int(tabdac.clicod) and
                 d.titulo.titnum = trim(tabdac.numlan) 
                 no-lock:
            if  vtotal + d.titulo.titvlcob <= val-lan
            then do:    
                /*vtotal = vtotal + d.titulo.titvlcob.
                */
                find first tt-titulo where
                           tt-titulo.empcod = d.titulo.empcod and
                           tt-titulo.titnat = d.titulo.titnat and
                           tt-titulo.modcod = d.titulo.modcod and
                           tt-titulo.etbcod = d.titulo.etbcod and
                           tt-titulo.clifor = d.titulo.clifor and
                           tt-titulo.titnum = d.titulo.titnum and
                           tt-titulo.titpar = d.titulo.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy d.titulo to tt-titulo.
                    vtotal = vtotal + d.titulo.titvlcob.
                end.
             end.    
        end.
        if vtotal < val-lan 
        then
        for each titulosal where
                 titulosal.titdtpag = tabdac.datlan and
                 titulosal.etbcobra = tabdac.etblan and
                 titulosal.clifor = int(tabdac.clicod) and
                 titulosal.titnum = trim(tabdac.numlan) 
                 no-lock:
            if  vtotal + titulosal.titvlcob <= val-lan
            then do:    
                find first tt-titulo where
                           tt-titulo.empcod = titulosal.empcod and
                           tt-titulo.titnat = titulosal.titnat and
                           tt-titulo.modcod = titulosal.modcod and
                           tt-titulo.etbcod = titulosal.etbcod and
                           tt-titulo.clifor = titulosal.clifor and
                           tt-titulo.titnum = titulosal.titnum and
                           tt-titulo.titpar = titulosal.titpar
                           no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    buffer-copy titulosal to tt-titulo.
                    vtotal = vtotal + titulosal.titvlcob.
                end.
             end.    
        end.  
        vtotal = 0.
        for each tt-titulo no-lock by tt-titulo.titpar:
            vtotal = vtotal + tt-titulo.titvlcob.
            vtitpar = tt-titulo.titpar.
            vtitdtven = tt-titulo.titdtven.
        end.    
        
        if val-lan <> vtotal 
        then do:
            /*
            find first mov.titulo where 
                       mov.titulo.clifor = int(tabdac.clicod) and
                       mov.titulo.titnum = trim(tabdac.numlan)
                       no-lock no-error.
            if not avail mov.titulo
            then do:*/
                find first d.titulo where
                           d.titulo.clifor = int(tabdac.clicod) and
                           d.titulo.titnum = trim(tabdac.numlan)
                           no-lock no-error.
                if not avail d.titulo
                then do:
                    find first fin.titulo where
                            fin.titulo.clifor = int(tabdac.clicod) and
                            fin.titulo.titnum = trim(tabdac.numlan)
                            no-lock no-error.
                    if not avail fin.titulo
                    then vtitdtemi = tabdac.datemi.
                    else vtitdtemi = fin.titulo.titdtemi.
                end.
                else vtitdtemi = d.titulo.titdtemi.
            /*end.
            else vtitdtemi = mov.titulo.titdtemi.        
            */
            create tt-titulo.
            assign
                tt-titulo.empcod = 19 
                tt-titulo.titnat = no
                tt-titulo.modcod = "CRE"
                tt-titulo.etbcod = tabdac.etblan 
                tt-titulo.clifor = int(tabdac.clicod) 
                tt-titulo.titnum = trim(tabdac.numlan) 
                tt-titulo.titpar = ?
                tt-titulo.titdtemi = tabdac.datlan
                tt-titulo.titdtven = tabdac.datlan
                tt-titulo.titsit = "PAG"
                tt-titulo.titvlcob = val-lan - vtotal
                tt-titulo.cobcod  = 22
                tt-titulo.titdtpag = tabdac.datlan
                tt-titulo.titvlpag = val-lan - vtotal
                .
        end.
        
        
        vtotal = 0.
        for each tt-titulo:
            vtotal = vtotal + tt-titulo.titvlcob.
            assign
                tt-titulo.titdtpag = tabdac.datlan
                tt-titulo.titsit   = "PAG"
                tt-titulo.etbcobra = tabdac.etblan
                .
        end.    
        disp val-lan vtotal val-lan - vtotal 
                with frame f-ddisp3.
        pause 0.        
        /*if val-lan <> vtotal 
        then do:
            disp val-lan vtotal. 
            pause.
        end.    
        else*/ do:
            for each tt-titulo no-lock:
                find first SC2015 where
                           SC2015.empcod = tt-titulo.empcod and
                           SC2015.titnat = tt-titulo.titnat and
                           SC2015.modcod = tt-titulo.modcod and
                           SC2015.etbcod = tt-titulo.etbcod and
                           SC2015.clifor = tt-titulo.clifor and
                           SC2015.titnum = tt-titulo.titnum and
                           SC2015.titpar = tt-titulo.titpar
                           no-error.
                if not avail SC2015
                then do: 
                    create SC2015.
                    buffer-copy tt-titulo to SC2015.
                    SC2015.titdtmovref = vdat-aux.
                end.
                else assign
                    SC2015.titdtpag = tt-titulo.titdtpag 
                    SC2015.titsit   = tt-titulo.titsit 
                    SC2015.etbcobra = tt-titulo.etbcobra
                     .
            end.   
        end.
    end.
    v-sair = yes.
end.
if v-sair then leave. 
end.                    

