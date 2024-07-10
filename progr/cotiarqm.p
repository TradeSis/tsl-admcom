def temp-table tt-contarq like contrato
    index i2 vltotal .
def temp-table tt-recebe like titulo
    index i2 titvlpag.
def temp-table tt-titarq like titulo
    index i1 empcod titnat modcod etbcod clifor titnum titpar.

def temp-table cont-recebe like contrato.
def temp-table tit-recebe like titulo.

def temp-table tt-contrato like contrato.
def temp-table tt-titulo like titulo.

def var sresp as log format "Sim/Nao".
def var vdti as date.
def var vdtf as date.
def var vdata as date.
def var t-valor as dec.
def var i-valor as dec.
def var q-par as dec.
def var v-par as dec.
def var i-venda as dec.
def var i-devol as dec.
def var i-acres as dec.
def var i-receb as dec.
def var i-juros as dec. 
def var vqtd as int.
def var vlpraz as dec.
def var vlvist as dec.
def var totecf as dec.
def var tprazo as dec.
def var tvist  as dec.

def temp-table tt-devol like plani.
def temp-table tt-contdev like contarqm.

update vdti label "Data Inicial" 
    vdtf label "Data Final" 
    i-venda at 1 label "Venda Prazo "   format ">>>,>>>,>>9.99"
    i-acres at 1 label "Acrecimo    "   format ">>>,>>>,>>9.99"
    i-devol at 1 label "Devolucao   "   format ">>>,>>>,>>9.99"
    i-receb at 1 label "Recebimento "   format ">>>,>>>,>>9.99"
    i-juros at 1 label "Juros       "   format ">>>,>>>,>>9.99"
    with frame f1 centered side-label.

message "Confirma os dados digitados acima?" update sresp.
if not sresp
then return.
/**
if i-venda = 0
then do:
    sresp = no.
    message "Processar vendas ?" update sresp.
    if sresp
    then do:
        run venda-prazo.
        i-venda = tprazo.
        disp i-venda with frame f1.
        pause 0.
    end.
end.
sresp = no.
message "Confirma valores informados ?" update sresp.
if not sresp then undo.
**/

def var vcontinua as log.
def buffer btitulo for titulo.

if i-venda > 0
then do:
disp "Processando Venda Prazo"
      with frame f-pvp 1 down no-box no-label
      row 12 centered.
      pause 0.
do vdata = vdti to vdtf:
    disp vdata with frame f-pvp. pause 0.
    for each contrato where contrato.dtinicial = vdata no-lock:
        find estab where estab.etbcod = contrato.etbcod no-lock no-error.
        if not avail estab or
            substr(string(estab.etbnom),1,10) <> "DREBES-FIL"
        then next.
        disp contrato.contnum format ">>>>>>>>>>>9"
        with frame f-pvp. pause 0.
        
        find contarqm where contarqm.contnum = contrato.contnum
                            no-error.
        if avail contarqm 
        then do transaction:
            for each tituarqm where tituarqm.empcod = 19 and
                              tituarqm.titnat = no and
                              tituarqm.modcod = "CRE" and
                              tituarqm.etbcod = contarqm.etbcod and
                              tituarqm.clifor = contarqm.clicod and
                              tituarqm.titnum = string(contarqm.contnum)
                              :
                delete tituarqm.                          
            end.
            delete contarqm.
        end.
                           
        find clien where clien.clicod = contrato.clicod
                    no-lock no-error.
        if not avail clien or clien.clicod = 0
        then next.
        vcontinua = yes.             
        for each titulo where titulo.empcod = 19 and
                                titulo.titnat = no and
                                titulo.modcod = "CRE" and
                                titulo.etbcod = contarqm.etbcod and
                                titulo.clifor = contarqm.clicod and
                                titulo.titnum = string(contarqm.contnum)
                                no-lock .
            if titulo.moecod = "NOV" or
               titulo.moecod = "DEV"
            then do:
                vcontinua = no.
                leave.
            end.   
        end.
        if vcontinua = no then next.
                                        
        find first contnf where contnf.etbcod = contrato.etbcod and
                          contnf.contnum = contrato.contnum
                          no-lock no-error.
        if not avail contnf then next.                  
        find first plani where plani.etbcod = contnf.etbcod and
                         plani.placod = contnf.placod
                          no-lock.
        if plani.crecod = 1
        then next.
        if plani.platot > contrato.vltotal
        then t-valor = contrato.vltotal.
        else t-valor = plani.platot.
        if t-valor < 10
        then next.
        create tt-contarq.
        buffer-copy contrato to tt-contarq.
        tt-contarq.vltotal = t-valor.
        v-par = 0.
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum)
                              no-lock:
            create tt-titarq.
            buffer-copy titulo to tt-titarq.
            if v-par + titulo.titvlcob > t-valor
            then tt-titarq.titvlcob = tt-titarq.titvlcob -
                    ((v-par + titulo.titvlcob) - t-valor).
            assign        
                v-par = v-par + tt-titarq.titvlcob
                tt-titarq.titvlpag = ?
                tt-titarq.titsit = "LIB".
            if v-par >= t-valor
            then leave.
        end.
        if v-par < t-valor
        then tt-contarq.vltotal = v-par.
    end.
end.            
def var t-venda as dec.
def var vdifer as dec.
disp "Selecionando titulos ... >>> "
    with frame f-st 1 down no-label row 13 centered no-box.
    pause 0.
for each tt-contarq use-index i2:
    vdifer = 0.
    if (t-venda + tt-contarq.vltotal) > (i-venda + i-acres)
    then do:
        vdifer = (t-venda + tt-contarq.vltotal) - (i-venda + i-acres).
        tt-contarq.vltotal = tt-contarq.vltotal - vdifer.
    end.
    t-venda = t-venda + tt-contarq.vltotal. 
    disp t-venda format ">>>,>>>,>>9.99"
        with frame f-st.
    pause 0.
    find contarqm where 
         contarqm.contnum = tt-contarq.contnum no-error.
    if not avail contarqm
    then do:     
        create contarqm.
        buffer-copy tt-contarq to contarqm.
    end.
    contarqm.situacao = 9.
    v-par = 0.
    for each  tt-titarq where tt-titarq.empcod = 19 and
                              tt-titarq.titnat = no and
                              tt-titarq.modcod = "CRE" and
                              tt-titarq.etbcod = tt-contarq.etbcod and
                              tt-titarq.clifor = tt-contarq.clicod and
                              tt-titarq.titnum = string(tt-contarq.contnum)
                              no-lock:
        if v-par + tt-titarq.titvlcob > tt-contarq.vltotal
            then tt-titarq.titvlcob = tt-titarq.titvlcob -
                    ((v-par + tt-titarq.titvlcob) - tt-contarq.vltotal).
        v-par = v-par + tt-titarq.titvlcob .
        find tituarqm where tituarqm.empcod = tt-titarq.empcod and
                            tituarqm.titnat = tt-titarq.titnat and
                            tituarqm.modcod = tt-titarq.modcod and
                            tituarqm.etbcod = tt-titarq.etbcod and
                            tituarqm.clifor = tt-titarq.clifor and
                            tituarqm.titnum = tt-titarq.titnum and
                            tituarqm.titpar = tt-titarq.titpar
                            no-error.
        if not avail tituarqm
        then do:
            create tituarqm.
            buffer-copy tt-titarq to tituarqm.
        end.
        if tituarqm.titdtemi = tituarqm.titdtpag
        then do:
            assign
                tituarqm.titvlpag = tituarqm.titvlcob
                tituarqm.titsit   = "PAG"
                tt-titarq.titvlpag = tt-titarq.titvlcob
                tt-titarq.titsit = "PAG".

        end.
    end.
    if v-par < contarqm.vltotal
    then do:
        t-venda = t-venda - contarqm.vltotal.
        contarqm.vltotal = v-par.
        t-venda = t-venda + contarqm.vltotal.
    end.
    if (i-venda > 0 or i-acres > 0) and
         t-venda >= (i-venda + i-acres)
    then do:
        if t-venda > (i-venda + i-acres)
        then do:
            contarqm.vltotal = contarqm.vltotal +
                        ((i-venda + i-acres) - t-venda).
            tituarqm.titvlcob = tituarqm.titvlcob +
                        ((i-venda + i-acres) - t-venda).
            if tituarqm.titvlpag > 0
            then tituarqm.titvlpag = tituarqm.titvlcob.            
        end.
        leave.
    end.
end.
end.

/*** DEVOLUCAO DE VENDA ***/
def var tt-devol as dec.
def var vv-devol as dec.
def var ti-devol as dec.
if i-devol > 0
then do:
    disp "Processando Devolucao de venda"
         with frame f-devol 1 down centered row 19 no-label
         no-box.
    do vdata = vdti to vdtf:
        for each tituarqm where
             tituarqm.empcod = 19 and
             tituarqm.titnat = yes and
             tituarqm.modcod = "DEV" and
             tituarqm.titdtven = vdata
             :
            delete tituarqm.
        end.
    end.                     
    for each fiscal where fiscal.movtdc = 12 and 
                    fiscal.plarec >= vdti and
                    fiscal.plarec <= vdtf and
                    fiscal.serie = "U" no-lock:
        find plani where plani.movtdc = fiscal.movtdc and
                     plani.etbcod = fiscal.emite and
                     plani.numero = fiscal.numero and
                     plani.pladat = fiscal.plaemi
                     no-lock.
        if plani.desti = 1
        then do:
            create tt-devol.
            buffer-copy plani to tt-devol.
        end.
        else do:
        find first tituarqm where
             tituarqm.empcod = 19 and
             tituarqm.titnat = yes and
             tituarqm.modcod = "DEV" and
             tituarqm.etbcod = fiscal.emite and
             tituarqm.clifor = plani.desti and
             tituarqm.titnum = string(fiscal.numero)
             no-error.
        if not avail tituarqm
        then do:
            create tituarqm.
            assign
            tituarqm.empcod = 19 
            tituarqm.titnat = yes
            tituarqm.modcod = "DEV"
            tituarqm.etbcod = fiscal.emite
            tituarqm.clifor = plani.desti
            tituarqm.titnum = string(fiscal.numero)
            .
        end.
        assign
            tituarqm.titvlcob = fiscal.platot
            tituarqm.titdtemi = fiscal.plaemi
            tituarqm.titdtven = fiscal.plarec
            .
        tt-devol = tt-devol + tituarqm.titvlcob.
        disp tt-devol format ">>>,>>>,>>9.99"
            with frame f-devol.
        pause 0.
        end.    
    end.      
    for each tt-devol:
        if tt-devol > i-devol
        then leave. 
        find first contarqm where 
                   contarqm.dtinicial >= vdti and
                   contarqm.dtinicial <= vdtf and
                   contarqm.vltotal    = tt-devol.platot and
                   not can-find (first tt-contdev where
                            tt-contdev.contnum = contarqm.contnum)
                   no-lock no-error.
        if avail contarqm
        then do:
            create tt-contdev.
            buffer-copy contarqm to tt-contdev.            
            for each tituarqm where tituarqm.empcod = 19 and
                                    tituarqm.modcod = "CRE" and
                                    tituarqm.titnat = no and
                                    tituarqm.etbcod = contarqm.etbcod and
                                    tituarqm.clifor = contarqm.clicod and
                                    tituarqm.titnum = string(contarqm.contnum)
                                    :
                tituarqm.moecod = "DEV".   
                tt-devol = tt-devol + tituarqm.titvlcob.
                    disp tt-devol format ">>>,>>>,>>9.99"
                    with frame f-devol.
                    pause 0.
                      
           end.                         
           delete tt-devol.
        end.           
        else do:
            find first contarqm where 
                   contarqm.dtinicial >= vdti and
                   contarqm.dtinicial <= vdtf and
                   contarqm.vltotal    > tt-devol.platot and
                   not can-find (first tt-contdev where 
                            tt-contdev.contnum = contarqm.contnum)
                   no-lock no-error.
            if avail contarqm
            then do:
                create tt-contdev.
                buffer-copy contarqm to tt-contdev.  
                for each tituarqm where tituarqm.empcod = 19 and
                                    tituarqm.modcod = "CRE" and
                                    tituarqm.titnat = no and
                                    tituarqm.etbcod = contarqm.etbcod and
                                    tituarqm.clifor = contarqm.clicod and
                                    tituarqm.titnum = string(contarqm.contnum)
                                    :
                    
                    tituarqm.moecod = "DEV".
                    
                    tt-devol = tt-devol + tituarqm.titvlcob.
                    disp tt-devol format ">>>,>>>,>>9.99"
                    with frame f-devol.
                    pause 0.
                end. 
                delete tt-devol.
            end.
            /***
            else do:
                find first contarqm where 
                   contarqm.dtinicial >= vdti and
                   contarqm.dtinicial <= vdtf and
                   contarqm.vltotal    < tt-devol.platot and
                   contarqm.vltotal - 20 <= tt-devol.platot  and
                   not can-find (first tt-contdev where 
                            tt-contdev.contnum = contarqm.contnum)
                   no-lock no-error.
                if avail contarqm
                then do:
                    find first tt-contdev where
                        tt-contdev.contnum = contarqm.contnum
                        no-error.
                    if not avail tt-contdev
                    then do:
                    create tt-contdev.
                    buffer-copy contarqm to tt-contdev.  
                    for each tituarqm where tituarqm.empcod = 19 and
                                    tituarqm.modcod = "CRE" and
                                    tituarqm.titnat = no and
                                    tituarqm.etbcod = contarqm.etbcod and
                                    tituarqm.clifor = contarqm.clicod and
                                    tituarqm.titnum = string(contarqm.contnum)
                                    :
                        tituarqm.moecod = "DEV".  
                        tt-devol = tt-devol + tituarqm.titvlcob.
                        disp tt-devol format ">>>,>>>,>>9.99"
                        with frame f-devol.
                        pause 0.
                    end. 
                    delete tt-devol.
                    end.
                end.
                else do:
                    find first contarqm where 
                       contarqm.dtinicial >= vdti and
                       contarqm.dtinicial <= vdtf and
                       contarqm.vltotal    > tt-devol.platot and
                       not can-find (first tt-contdev where 
                            tt-contdev.contnum = contarqm.contnum)
                       no-lock no-error.
                    if avail contarqm
                    then do:
                        find first tt-contdev where
                            tt-contdev.contnum = contarqm.contnum
                            no-error.
                        if not avail tt-contdev
                        then do:
                        create tt-contdev.
                        buffer-copy contarqm to tt-contdev.  
                        for each tituarqm where tituarqm.empcod = 19 and
                                    tituarqm.modcod = "CRE" and
                                    tituarqm.titnat = no and
                                    tituarqm.etbcod = contarqm.etbcod and
                                    tituarqm.clifor = contarqm.clicod and
                                    tituarqm.titnum = string(contarqm.contnum)
                                    :
                            tituarqm.moecod = "DEV".  
                            tt-devol = tt-devol + tituarqm.titvlcob.
                            disp tt-devol format ">>>,>>>,>>9.99"
                                with frame f-devol.
                            pause 0.
                        end. 
                        delete tt-devol.
                        end.
                    end.
                end.
            end.
            **/
        end.
    end.          
    for each tituarqm where
         tituarqm.empcod = 19 and
         tituarqm.titnat = yes and
         tituarqm.modcod = "DEV" and
         tituarqm.titdtven >= vdti and
         tituarqm.titdtven <= vdtf
         no-lock:
        if tituarqm.clifor = 1
        then next.
        find clien where clien.clicod = tituarqm.clifor no-lock no-error.
        if not avail clien or
            clien.clicod = 0 then next.
        vv-devol = vv-devol + tituarqm.titvlcob.
    end.
    for each tituarqm where
         tituarqm.empcod = 19 and
         tituarqm.titnat = no and
         tituarqm.modcod = "CRE" and
         tituarqm.titdtemi >= vdti and
         tituarqm.titdtemi <= vdtf and
         tituarqm.moecod = "DEV" :
        if tituarqm.clifor = 1
        then next.
        find clien where clien.clicod = tituarqm.clifor no-lock no-error.
        if not avail clien or
            clien.clicod = 0 then next.
        if vv-devol < i-devol
        then  vv-devol = vv-devol + tituarqm.titvlcob.
        if vv-devol >= i-devol
        then do:
            if vv-devol > i-devol
            then do:
                ti-devol = ti-devol + tituarqm.titvlcob.
                tituarqm.titvlcob = tituarqm.titvlcob +
                         (i-devol - vv-devol).
                vv-devol = vv-devol + tituarqm.titvlcob - ti-devol.         
            end.
            else delete tituarqm.
        end.
    end.        
end.
/*** FIM DEVOLUCAO DE VENDA ***/

/*** RECEBIMENTOS ***/
def var t-recebe as dec.
def var t-juro as dec.
def var t-pctjuro as dec.
def var vv-receb as dec.
def var ti-receb as dec.

if i-receb > 0
then do:
    disp "Selecionando recebimentos"
         with frame f-stp 1 down centered row 16 no-label
         no-box.
    pause 0. 
    do vdata = vdti to vdtf:
        disp vdata with frame f-stp.
        pause 0.
    for each titulo use-index titdtpag where   titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = "CRE" and
                            titulo.titdtpag = vdata
                          no-lock:
        if titulo.moecod = "NOV" or
           titulo.moecod = "DEV"
        then next.    
        if titulo.titdtemi = titulo.titdtpag then next.
        find contrato where contrato.contnum = int(titulo.titnum)
                    no-lock no-error.
        if  not avail contrato or
        contrato.vltotal <= 20  then next.
                    
        find estab where estab.etbcod = contrato.etbcod no-lock no-error.
        if not avail estab or
            substr(string(estab.etbnom),1,10) <> "DREBES-FIL"
        then next.
        vcontinua = yes.
        for each btitulo where btitulo.empcod = 19 and
                                btitulo.titnat = no and
                                btitulo.modcod = "CRE" and
                                btitulo.etbcod = titulo.etbcod and
                                btitulo.clifor = titulo.clifor and
                                btitulo.titnum = titulo.titnum
                                no-lock .
            if btitulo.moecod = "NOV" or
               btitulo.moecod = "DEV"
            then do:
                vcontinua = no.
                leave.
            end.   
        end.
        if vcontinua = no then next.
        
        disp titulo.titnum with frame f-stp.
        pause 0.
        create tt-recebe.
        buffer-copy titulo to tt-recebe. 
    end.  
    end.
    disp "Processando Recebimentos"
         with frame f-pr 1 down centered row 17 no-label
         no-box.
    pause 0. 
    t-recebe = 0.    
    for each tituarqm where tituarqm.titdtpag >= vdti and
                            tituarqm.titdtpag <= vdtf
                            no-lock:
        if tituarqm.titnat <> no 
            or tituarqm.moecod = "DEV" 
        then next.
        if tituarqm.titdtemi <> tituarqm.titdtpag then next.
        
        find contarqm where contarqm.contnum = int(tituarqm.titnum)
                    no-lock no-error.
        if not avail contarqm or
                    contarqm.situacao <> 9
        then next.            
        
        if tituarqm.titsit = "PAG"
        then t-recebe = t-recebe + tituarqm.titvlpag.
        disp t-recebe no-label format ">>>,>>>,>>9.99"
             with frame f-pr.
        pause 0.

    end.    
    for each tt-recebe use-index i2:
         find clien where clien.clicod = tt-recebe.clifor
                             no-lock no-error.
         if not avail clien or clien.clicod = 0
         then next.                       
         find tituarqm where tituarqm.empcod = 19 and
                              tituarqm.titnat = no and
                              tituarqm.modcod = "CRE" and
                              tituarqm.etbcod = tt-recebe.etbcod and
                              tituarqm.clifor = tt-recebe.clifor and
                              tituarqm.titnum = tt-recebe.titnum and
                              tituarqm.titpar = tt-recebe.titpar
                              no-error.
        if not avail tituarqm
        then do:
            create tituarqm.
            buffer-copy tt-recebe to tituarqm.
        end.
        if tituarqm.moecod = "DEV"
        then next.
        if t-recebe >= i-receb
        then do:
                tituarqm.titsit = "LIB".
                tituarqm.titvlpag = 0.
                tituarqm.titvljur = 0.
                tituarqm.titjuro = 0.
                next.
        end.
        else do:
            assign
                 tituarqm.titvlpag = tituarqm.titvlcob
                 tituarqm.titsit   = "PAG"
                 tituarqm.titjuro  = tt-recebe.titjuro.
                 .
                 
            if t-recebe + tituarqm.titvlpag > i-receb
            then tituarqm.titvlpag = tituarqm.titvlpag -
                    ((t-recebe + tituarqm.titvlpag) - i-receb).
            
            t-recebe = t-recebe + tituarqm.titvlpag. 
            t-juro   = t-juro + tituarqm.titjuro.
            
            disp  t-recebe format ">>>,>>>,>>9.99"
                with frame f-pr.
            pause 0. 
        
            if t-recebe >= i-receb
            then do:
                if t-recebe > i-receb
                then do:
                    t-recebe = t-recebe + (i-receb - t-recebe).
                    tituarqm.titvlpag = tituarqm.titvlpag +
                                    (i-receb - t-recebe).
                end.
            end.                 
        end.
    end.
    t-juro = 0.
    for each tituarqm where 
            tituarqm.titdtpag >= vdti and
            tituarqm.titdtpag <= vdtf no-lock:
        if tituarqm.titnat = yes
        then next.
        if tituarqm.titsit <> "PAG"
        then next.
        find clien where clien.clicod = tituarqm.clifor no-lock no-error.
        if not avail clien or
            clien.clicod = 0 then next.
        if vv-receb < i-receb
        then vv-receb = vv-receb + tituarqm.titvlpag.
        if vv-receb >= i-receb
        then do:
            if vv-receb > i-receb
            then  do:
                ti-receb = tituarqm.titvlpag.
                tituarqm.titvlpag = tituarqm.titvlpag +
                        (i-receb - vv-receb).
                vv-receb = vv-receb + tituarqm.titvlpag - ti-receb.        
            end.
            else tituarqm.titsit = "LIB".
        end.
        if tituarqm.titsit = "PAG"
        then t-juro = t-juro + tituarqm.titjuro.
    end.
end.
def var tt-juro as dec.
if i-juros > 0  and t-juro > 0
then do:
    disp "Processando Juros"
         with frame f-juro 1 down centered row 18 no-label
         no-box.
 
    t-pctjuro = (i-juros / t-juro) * 100.
    for each tituarqm where tituarqm.titdtpag >= vdti and
                            tituarqm.titdtpag <= vdtf and
                            tituarqm.titjuro > 0
                            :
        if tituarqm.titnat <> no or
           tituarqm.moecod = "DEV"
        then next.
        if tituarqm.titsit <> "PAG"
        then next.
        tituarqm.titvljur = (tituarqm.titjuro * t-pctjuro) / 100.
        
        tt-juro = tt-juro + tituarqm.titvljur.
        disp tt-juro format ">>>,>>>,>>9.99"
                with frame f-juro.
        pause 0. 
    end.       
end.

def var varqsai as char.

/**
if opsys = "UNIX"
then varqsai = "/admcom/Claudir/contarqm." + string(day(vdtf),"99") +
                string(month(vdtf),"99") + string(year(vdtf),"9999").
else varqsai = "..\Claudir\contarqm." + string(day(vdtf),"99") +
                string(month(vdtf),"99") + string(year(vdtf),"9999").
                
output to value(varqsai).
for each tt-contarq no-lock:
    export tt-contarq.
end.
output close.

if opsys = "UNIX"
then varqsai = "/admcom/Claudir/tituarqm." + string(day(vdtf),"99") +
                string(month(vdtf),"99") + string(year(vdtf),"9999").
else varqsai = "..\Claudir\tituarqm." + string(day(vdtf),"99") +
                string(month(vdtf),"99") + string(year(vdtf),"9999").
 
output to value(varqsai).
for each tt-titarq no-lock.
    export tt-titarq.
end.
output close.    
**/  
procedure venda-prazo:
    disp "Processando Vendas"
        with frame f-pv 1 down centered row 10 no-label.
    pause 0.    
    do vdata = vdti to vdtf.
        disp vdata with frame f-pv.
        pause 0.
        vlvist = 0.
        vlpraz = 0.
        totecf = 0.
        for each estab no-lock:
        disp estab.etbcod with frame f-pv.
        for each plani use-index pladat 
                   where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.pladat = vdata
                         no-lock.

            disp plani.numero format ">>>>>>>>>>>>9" with frame f-pv.
            if plani.crecod = 1
            then do:
                vlvist = vlvist + plani.platot.
            end.
            else vlpraz = vlpraz  + plani.platot.
                      
        end.                    
        for each mapctb where mapctb.etbcod = estab.etbcod and
                                  mapctb.datmov = vdata
                                    no-lock.

                if mapctb.ch2 = "E"                 
                then next.
                 
                totecf = totecf + 
                        (mapctb.t01 + 
                         mapctb.t02 + 
                         mapctb.t03 +
                         mapctb.vlsub).
            
        end.
        if vlpraz > 0
        then do:
            if vlvist < vlpraz
            then do:
                    vlvist = (vlvist / vlpraz) * totecf.
                    vlpraz = totecf - vlvist.
            end.
            else do:
                    vlpraz = (vlpraz / vlvist) * totecf.
                    vlvist = totecf - vlpraz.
            end.
        end.
        else vlvist = totecf.

        tprazo = tprazo + vlpraz.
        tvist = tvist + vlvist.
        vlpraz = 0.
        vlvist = 0.
        totecf = 0.
        end.
    end.

end procedure.

