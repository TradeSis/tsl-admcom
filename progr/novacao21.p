{admcab.i}

def new shared temp-table d-titulo like fin.titulo.

def new shared temp-table tpb-contrato like contrato
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char
    .
    
def new shared temp-table tpb-titulo like fin.titulo
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.

def new shared var vjuro-ac as dec.

def var juro-alt as dec.
def var vjuro-ori as dec.
def var vcond as char format "x(40)"  extent 5.
def var valor_cobrado as dec extent 5. 
def var valor_juro    as dec extent 5.
def var valor_novacao as dec extent 5.
          
def var  vok as log.
def var vtit as char format "x(30)". 
def var vv as int.
def var per_cor as dec.
def var nov31 as log.
def temp-table ttservidor
    field etbcod like estab.etbcod
    field servidor like estab.etbcod.
def buffer bttservidor for ttservidor.

def new shared temp-table tt-recib
        field rectit as recid
        field titnum like titulo.titnum
        field ordpre as int.

def var esqcom1 as char extent 5 format "x(15)"
        init["","","","",""].

def var esqcom2 as char extent 5 format "x(15)"
        init["","","","",""].

def var esqhel1         as char format "x(80)" extent 5
    initial ["Marca ou Desmarca um item",
             "Marca ou Desmarca todos os itens",
             "Gera ocordo de Renegociação",
             "Gera e efetiva uma Renegociação",
             "Faz Repactuação - Altera vencimento ou troca de plano"]
             .
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

def var esqregua as log.
def var esqpos1 as int.
def var esqpos2 as int.

def var q-m as int.

def buffer btp-contrato for tpb-contrato.

form esqcom1 with frame f-esqcom1 
        no-box no-labels side-labels column 1 row 6.

form esqcom2 with frame f-esqcom2
        row screen-lines no-box no-labels side-labels column 1.

/***********************/

def var per_acr as dec.
def var per_des as dec.
def var vdia as int.
def var vdesc as dec.
def var vdata like plani.pladat.
def var ventrada like contrato.vlentra.
def var i as int.
def var varq  as char.
def new shared var vtot like titulo.titvlcob.
def var vtitvlp like titulo.titvlcob.
def var vtitj like titulo.titvlcob.
def var vnumdia as i.
def var ljuros  as l.

def var vdata-futura as date format "99/99/9999".

def temp-table wf-tit like fin.titulo.
def new shared temp-table wf-titulo like fin.titulo.
def new shared temp-table wf-contrato like fin.contrato.
def var vokj as log.
def var vplano as int format "99".
def var vgera like contrato.contnum.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.
def var vezes as int format ">9".
def var vdtven like titulo.titdtven.
def var lp-ok as log.
def var vliquido as dec.
def var vparcelas as int.

def var p4-semjuro as log.
def var vclifor like fin.titulo.clifor.
update vclifor with frame f-cb 1 down side-label width 80
    row 3.
find clien where clien.clicod = vclifor no-lock no-error.
if not avail clien then return.
disp clien.clinom no-label with frame f-cb.
pause 0.

def var vdia-atr as int.
def var vdat-atr as date.
def var ac-ok as log.

find first novacordo where
           novacordo.clicod = vclifor and
           novacordo.situacao = "PENDENTE"
           no-lock no-error.
if avail novacordo
then do:
    run novacordo.p(input vclifor, input "PENDENTE").
end.
else repeat:

    for each tpb-titulo:
        delete tpb-titulo.
    end.
    for each tpb-contrato:
        delete tpb-contrato.
    end.    

    for each wf-titulo.
        delete wf-titulo.
    end.

    for each wf-tit.
        delete wf-tit.
    end.

    assign vtot    = 0
           vtitj   = 0
           vtitvlp = 0.

    vdtven = today.
    vdata-futura = today.
            
    find clien where clien.clicod = vclifor no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao cadastrado".
        undo, retry.
    end.
    
    for each titulo where titulo.clifor = vclifor no-lock:
        if titulo.modcod <> "CRE" then next.
        
        find first tpb-contrato where
                       tpb-contrato.contnum = int(titulo.titnum)
                       no-error.
        if not avail tpb-contrato
        then do:            
            create tpb-contrato.
            tpb-contrato.clicod  = titulo.clifor.
            tpb-contrato.contnum = int(titulo.titnum).
            tpb-contrato.etbcod = titulo.etbcod.
            if titulo.cobcod = 10
            then tpb-contrato.banco = 10.
            if titulo.titpar < 50
            then tpb-contrato.origem = "ADM".
            else tpb-contrato.origem = "LEP".
        end.
        tpb-contrato.vltotal = tpb-contrato.vltotal + titulo.titvlcob.
            
        if titulo.titsit = "LIB"
        then do:
            create tpb-titulo.
            buffer-copy titulo to tpb-titulo.
            tpb-contrato.vlpendente = tpb-contrato.vlpendente + titulo.titvlcob.
            if (today - titulo.titdtven) > tpb-contrato.atraso
            then tpb-contrato.atraso = (today - titulo.titdtven).
        end.            
        else do:
            if titulo.titpar = 0
            then tpb-contrato.vlentra = tpb-contrato.vlentra + titulo.titvlcob.
            else tpb-contrato.vlpago = tpb-contrato.vlpago + titulo.titvlcob.
        end.
    end.
    for each d-titulo: delete d-titulo. end.
    run conecta_d.p.
    run pega-titulo-dragao.p(input vclifor).
    run desconecta_d.p.
    pause 0.

    for each d-titulo where d-titulo.clifor = vclifor no-lock:
        if d-titulo.modcod <> "CRE" then next.
        
        find first tpb-contrato where
                       tpb-contrato.contnum = int(d-titulo.titnum)
                       no-error.
        if not avail tpb-contrato
        then do:            
            create tpb-contrato.
            tpb-contrato.clicod  = d-titulo.clifor.
            tpb-contrato.contnum = int(d-titulo.titnum).
        end.
        tpb-contrato.vltotal = tpb-contrato.vltotal + d-titulo.titvlcob.

        if d-titulo.titsit = "LIB"
        then do:
            create tpb-titulo.
            buffer-copy d-titulo to tpb-titulo.
            tpb-contrato.vlpendente = 
                        tpb-contrato.vlpendente + d-titulo.titvlcob.
            if (today - d-titulo.titdtven) > tpb-contrato.atraso
            then tpb-contrato.atraso = (today - d-titulo.titdtven).
        end.            
    end.
    
    for each tpb-contrato:
        vdat-atr = today.
        for each tpb-titulo where
                 tpb-titulo.clifor = tpb-contrato.clicod and
                 tpb-titulo.titnum = string(tpb-contrato.contnum) and
                 tpb-titulo.titsit = "LIB"
                 no-lock:
            vtot = vtot + tpb-titulo.titvlcob.
            if vdat-atr > tpb-titulo.titdtven
            then vdat-atr = tpb-titulo.titdtven.
        end.             
        
        vdia-atr = today - vdat-atr.
        
        if tpb-contrato.atraso > 270 or
           tpb-contrato.origem = "LEP"
        then tpb-contrato.destino = "LEP".
        else tpb-contrato.destino = "ADM".

        /*if vdia-atr < 60
        then delete tpb-contrato.
          */

    end. 
    
    ac-ok = no.
    

    run sel-contrato.

    if keyfunction(lastkey) = "end-error"
    then leave.

    if ac-ok then leave.
    
    vtot = 0.
    for each tpb-contrato where tpb-contrato.exportado no-lock:
        for each tpb-titulo where
                 tpb-titulo.clifor = tpb-contrato.clicod and
                 tpb-titulo.titnum = string(tpb-contrato.contnum) and
                 tpb-titulo.titsit = "LIB"
                 no-lock:
            vtot = vtot + tpb-titulo.titvlcob.
        end.             
    end.             

    if vtot = 0 then leave.

    vdata-futura = today.
    sresp = no.        
    message "Confirma gerar ACORDO?" update sresp.
    if sresp = no
    then next.
    
    if vdata-futura <> today
    then do:
    
        message "Operacao negada, alterar data para HOJE.".
        pause 3 no-message.
        next.

    end.
    
    hide frame fpag99 no-pause.
    hide frame f-esqcom1 no-pause.
    hide frame f-esqcom2 no-pause.

    ventrada = 0.

    ac-ok = no.
    vjuro-ac = 0.
    run gera-novacordo.p(input vclifor, input 0, input "", output ac-ok).
    if ac-ok = no
    then do:
        undo.
    end.
    if ac-ok
    then do:
        bell.
        message color red/with
        "ACORDO GERADO COM SUCESSO!"
        view-as alert-box.
        leave.
    end.     
    
end.    

def var t-cobrado as dec format ">>,>>>,>>9.99".
def var t-pago as dec    format ">>>,>>>,>>9.99".
def var t-saldo as dec   format ">,>>>,>>9.99".
def var t-atraso as dec format ">>>>>9".
def var t-entrada as dec format ">>>>,>>9.99".

procedure totaliza:
    assign
        t-cobrado = 0 t-pago = 0 t-saldo = 0 t-atraso = 0
        t-entrada = 0.
            
    for each tpb-contrato where tpb-contrato.exportado no-lock:
        t-cobrado = t-cobrado + tpb-contrato.vltotal.
        t-entrada = t-entrada + tpb-contrato.vlentra.
        t-saldo   = t-saldo   + tpb-contrato.vlpendente.
        if tpb-contrato.atraso > t-atraso
        then t-atraso  = tpb-contrato.atraso.
        t-pago    = t-pago    + tpb-contrato.vlpago.
        /* 
        for each tpb-titulo where
                 tpb-titulo.clifor = tpb-contrato.clicod   and
                 tpb-titulo.titnum = string(tpb-contrato.contnum)
                 no-lock:
            if tpb-titulo.titsit = "LIB"
            then do:
                t-saldo = t-saldo + tpb-titulo.titvlcob.
                if today - tpb-titulo.titdtven > t-atraso
                then t-atraso = today - tpb-titulo.titdtven.
            end.    
        end.
                 */
    end.
    /*
    t-pago = t-pago + (t-cobrado - t-saldo).
    */
    disp " TOTAL MARCADO    "   
         t-cobrado no-label 
         t-entrada no-label 
         t-pago    no-label
         t-saldo   no-label
         t-atraso  no-label   
         with frame ftt 1 down no-box width 80 row 20
         .
end procedure.
 
procedure sel-contrato:
    {setbrw.i}

    if setbcod = 999
    then
        assign
            esqcom1[1] = "Marca/Desmarca"
            esqcom1[2] = "Marca/Desm/Tudo"
            esqcom1[3] = "  Gera Acordo"
            /*esqcom1[4] = "  Renegociacao"
            esqcom1[5] = "  Repactuacao"*/
            .
    else         
        assign
            esqcom1[1] = "Marca/Desmarca"
            esqcom1[2] = "Marca/Desm/Tudo"
            esqcom1[3] = ""
            /*esqcom1[4] = "  Renegociacao"
            esqcom1[5] = "  Repactuacao"*/
            .

    esqcom2[1] = "Ver parcelas".
    
    def var vmarca as char.
    clear frame f-esqcom1 all.
    disp esqcom1 with frame f-esqcom1.
    disp esqcom2 with frame f-esqcom2.     
    pause 0.
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ? 
        esqpos1 = 1
        esqpos2 = 1
        esqregua = yes
        .
        
    color disp message esqcom1[esqpos1] with frame f-esqcom1.  
    run estatus-default.
      
    def var vpago as dec.
    def var vpend as dec.
    def var dest-adm as log.
    def var dest-lep as log.
    def var dest-marca as char.
    dest-adm = no.
    dest-lep = no.
    for each tpb-contrato no-lock:
        find first tpb-titulo where
            tpb-titulo.titnum = string(tpb-contrato.contnum)
            no-error.
        if avail tpb-titulo
        then do:
            tpb-contrato.exportado = no.
            if tpb-contrato.destino = "ADM"
            then dest-adm = yes.
            else if tpb-contrato.destino = "LEP"
                then dest-lep = yes.
        end.
        else delete tpb-contrato.
    end.

        
    if dest-adm = yes and
       dest-lep = yes
    then esqcom1[2] = "".
        
    def var vdown as int.
    /*
    run totaliza.
    */

    form vmarca no-label format "x"
         tpb-contrato.contnum     format ">>>>>>>>>9"
         tpb-contrato.etbcod      column-label "Fil"
         tpb-contrato.vltotal     format ">>>,>>>,>>9.99"  
                    column-label "Val Contrato"
         tpb-contrato.vlentra     format ">>>,>>9.99"
                    column-label "Val Entrada"
         tpb-contrato.vlpago 
                    column-label "Parcelas Pagas"  format ">,>>>,>>9.99"
         tpb-contrato.vlpendente
          column-label "Val Pendente"  format ">,>>>,>>9.99"
         tpb-contrato.atraso column-label "Atraso" format ">>>>9"
         with frame f-linha screen-lines - 12 down.

    l1: repeat:    
    
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ? 
        esqpos1 = 1
        esqpos2 = 1
        .
    
    if esqregua
    then
    color disp message esqcom1[esqpos1] with frame f-esqcom1.
    pause 0.
    
    for each tpb-contrato:
        tpb-contrato.exportado = no.
    end.    
    pause 0.
    {sklcls.i
        &file = tpb-contrato
        &cfield = tpb-contrato.contnum
        &noncharacter = /*
        &ofield = " vmarca
                    tpb-contrato.etbcod
                    tpb-contrato.vltotal
                    tpb-contrato.vlentra
                    tpb-contrato.vlpago
                    tpb-contrato.vlpendente
                    tpb-contrato.atraso
                  " 
        &aftfnd1 = " if tpb-contrato.exportado
                     then vmarca = ""*"".
                     else vmarca = """".
                     vpend = 0.
                     /*
                     for each tpb-titulo where
                        tpb-titulo.clifor = tpb-contrato.clicod and
                        tpb-titulo.titnum = string(tpb-contrato.contnum) and
                        tpb-titulo.titsit = ""LIB""
                        :
                        vpend = vpend + tpb-titulo.titvlcob.
                    end.
                    if tpb-contrato.vltotal > 0
                    then vpago = tpb-contrato.vltotal - vpend.
                    else vpago = 0.   */
                                       "         
        &where = true
        &naoexiste1 = "
            bell.
            message color red/with
            SKIP ""Nenhum registro encontrado""
            skip
            view-as alert-box
            .
            leave l1. "
        &aftselect1 = " 
                    if keyfunction(lastkey) = ""RETURN""
                    then do:
                        if esqcom1[esqpos1] = ""Marca/Desmarca""
                            and esqregua
                        then do:
                            if tpb-contrato.exportado = yes
                            then    assign
                                tpb-contrato.exportado = no
                                vmarca = """"
                                .
                            else do:
                                if dest-marca <> """" and
                                    dest-marca <> tpb-contrato.destino
                                then do:
                                    bell.
                                end.    
                                else assign
                                        tpb-contrato.exportado = yes
                                        vmarca = ""*"".
                            end.
                            disp vmarca with frame f-linha.
                            
                            run totaliza.
                            
                            next keys-loop. 
                        end.
                        else if esqcom1[esqpos1] = ""Marca/Desm/Tudo""
                            and esqregua
                        then do:
                            find first tpb-contrato where
                                       tpb-contrato.exportado = yes no-error.
                            if avail tpb-contrato 
                            then vmarca = ""*"". else vmarca = """".
                            for each tpb-contrato:
                                if vmarca = ""*""
                                then tpb-contrato.exportado = no.
                                else tpb-contrato.exportado = yes.                                          end.
                            run totaliza.
                            a-seeid = -1.
                            next keys-loop.
                        end.
                        else if esqcom1[esqpos1] = ""  Repactuacao""
                                and esqregua
                        then do:
                            q-m = 0.
                            for each btp-contrato where
                                    btp-contrato.exportado = yes:
                                q-m = q-m + 1.
                            end.        
                            if q-m  = 1 
                            then do:
                                hide frame f-cb no-pause.  
                                hide frame f-esqcom1 no-pause.
                                hide frame f-esqcom2 no-pause.
                                run alt-contrato.p
                                        (input tpb-contrato.contnum). 
                                disp with frame f-cb.
                                view frame f-esqcom1.
                                view frame f-esqcom2.
                                view frame f-linha.
                                color disp normal esqcom1[esqpos1] 
                                    with frame f-esqcom1.
                                run totaliza.
                            end.
                            else do:
                                bell.
                                message color red/with
                                ""Para alterar marcar apenas um(1) contrato.""
                                view-as alert-box.
                                color disp normal esqcom1[esqpos1] with frame
                                    f-esqcom1.
                            end.
                            next l1.
                        end.
                        else if esqcom2[esqpos2] = ""Ver parcelas""
                            and not esqregua
                        then do:
                            for each titulo where 
                                titulo.empcod = 19 and
                                titulo.titnat = no and
                                titulo.modcod = ""CRE"" and
                                titulo.etbcod = tpb-contrato.etbcod and
                                titulo.clifor = tpb-contrato.clicod and
                                titulo.titnum = string(tpb-contrato.contnum)                                 no-lock:
                                disp titulo.titnum titulo.titpar 
                                        titulo.titdtven titulo.titvlcob
                                        titulo.etbcod 
                                        titulo.titsit
                                    with frame f-conp down centered overlay
                                    color message
                                    title "" Parcelas do contrato "" +
                                    string(tpb-contrato.contnum).
                            end.    
                            pause.
                 
                        end.
                        else leave keys-loop.
                    end.
                    "
        &otherkeys1 = " run esqcom-i.
                         "
        &form  = " frame f-linha "
    }         

    if keyfunction(lastkey) = "end-error"
    then leave l1.
    
    if keyfunction(lastkey) = "TAB"
    then do:
        run esqcom-i.
        next l1.
    end.
    if esqcom1[esqpos1] = "  Gera Acordo"
    then do:
        find first tpb-contrato where 
            tpb-contrato.exportado no-error.
        if not avail tpb-contrato
        then do:
            bell.
            message color red/with
                skip
                "   NECESSARIO MARCAR CONTRATO   "
                skip
                view-as alert-box.
                
            color disp normal esqcom1[esqpos1] with frame f-esqcom1.
            
            next l1.
        end.
        leave l1.
    end.
    if esqcom1[esqpos1] = "  Renegociacao"
    then do:
        find first tpb-contrato where 
            tpb-contrato.exportado no-error.
        if not avail tpb-contrato
        then do:
            bell.
            message color red/with
                skip
                "   NECESSARIO MARCAR CONTRATO   "
                skip
                view-as alert-box.
            color disp normal esqcom1[esqpos1] with frame f-esqcom1.
            next l1.
        end.
        sresp = no.
        message "Gerar ACORDO ?" update sresp.
        if sresp
        then run gera-novacordo-filial.p(yes, vclifor, output ac-ok).
        else run gera-novacordo-filial.p(no, vclifor, output ac-ok).
        if ac-ok then leave l1.
        view frame f-esqcom1.
        view frame f-esqcom2.
        view frame f-linha .
        color disp normal esqcom1[esqpos1] with frame f-esqcom1.
        next l1.
    end.
    end.
end procedure.   

procedure esqcom-i:

        if  keyfunction(lastkey) = "TAB" 
        then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right" 
        then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
                
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
            end.
            run estatus-default.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left" 
        then do:
            if esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
            end.
            run estatus-default.
            next.
        end.
end procedure.

procedure estatus-default:
    status default 
    if esqregua
    then esqhel1[esqpos1]
    else esqhel2[esqpos2].
end procedure.
