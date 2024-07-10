{admcab.i}

def var par-clicod like clien.clicod.
/*H*/
def var p-segue as log.
def var par-valor as char.
def var vtot as dec.
/*H*/

def new shared temp-table tp-contrato no-undo like contrato 
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char
    .
    
def new shared temp-table tp-titulo no-undo like titulo 
    field precid as recid
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.


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
    initial ["",
            /*,"Marca ou Desmarca um item",
             "Marca ou Desmarca todos os itens",
             */
             "",
             ""]
             .
def var esqhel2         as char format "x(12)" extent 5
   initial ["Consulta as Parcelas do Contrato",
            " ",
            " ",
            " ",
            " "].

def var esqregua as log.
def var esqpos1 as int.
def var esqpos2 as int.

def var q-m as int.

def buffer btp-contrato for tp-contrato.

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
def var vtitvlp like titulo.titvlcob.
def var vtitj like titulo.titvlcob.
def var vnumdia as i.
def var ljuros  as l.

def var vdata-futura as date format "99/99/9999".

def temp-table wf-tit like titulo.
def new shared temp-table wf-titulo like titulo.
def new shared temp-table wf-contrato like contrato.
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

def var vdia-atr as int.
def var vdat-atr as date.
def var ac-ok as log.

          
    update par-clicod label "Conta"
          with frame fcli row 3 side-labels 
        title "Conta do Cliente" 1 down.
    find clien where clien.clicod = par-clicod no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao cadastrado".
        undo, retry.
    end.
    
    disp clien.clinom no-label format "x(49)"
         clien.dtcad no-label format "99/99/9999"
         with frame fcli.
 

repeat:

    for each tp-titulo:
        delete tp-titulo.
    end.
    for each tp-contrato:
        delete tp-contrato.
    end.    

    for each wf-titulo.
        delete wf-titulo.
    end.

    for each wf-tit.
        delete wf-tit.
    end.

    assign 
           vtitj   = 0
           vtitvlp = 0.

    vdtven = today.
    vdata-futura = today.
            
    
    for each titulo where titulo.clifor = par-clicod no-lock:
        /* Ajustado 08/07/2021 ID 74736 */
        if titulo.titnat = no
        then.
        else next.

        if titulo.modcod = "CRE" or titulo.modcod begins "CP"
        then.
        else next. /* 08/06/2021 helio retirado ID 74736 */
        /* ajustado 08/07/2021 */
        
        if titulo.titsit = "LIB"
        then.
        else next.
             
        p-segue = yes.    
        
        for each tit_novacao where 
            titulo.empcod = tit_novacao.ori_empcod and
            titulo.titnat = tit_novacao.ori_titnat and
            titulo.modcod = tit_novacao.ori_modcod and
            titulo.etbcod = tit_novacao.ori_etbcod and
            titulo.clifor = tit_novacao.ori_clifor and
            titulo.titnum = tit_novacao.ori_titnum and
            titulo.titpar = tit_novacao.ori_titpar and
            titulo.titdtemi = tit_novacao.ori_titdtemi
            no-lock.
            find novacordo where
                    novacordo.id_acordo = dec(tit_novacao.id_acordo)
                    no-lock no-error.
            if avail novacordo
            then do:
                if novacordo.situacao = "PENDENTE"          
                then p-segue = no.
            end.            
        end.
        if p-segue = no
        then next.
                     
            
        find first tp-contrato where
                       tp-contrato.contnum = int(titulo.titnum)
                       no-error.
        if not avail tp-contrato
        then do:            
            create tp-contrato.
            tp-contrato.clicod  = titulo.clifor.
            tp-contrato.contnum = int(titulo.titnum).
            tp-contrato.etbcod = titulo.etbcod.
            tp-contrato.modcod = titulo.modcod.
            if titulo.cobcod = 10
            then tp-contrato.banco = 10.
            if titulo.tpcontrato <> "L" /*titpar < 50*/
            then tp-contrato.origem = "ADM".
            else tp-contrato.origem = "LEP".
        end.
        tp-contrato.vltotal = tp-contrato.vltotal + titulo.titvlcob.
            
        if titulo.titsit = "LIB"
        then do:
            create tp-titulo.
            buffer-copy titulo to tp-titulo.
            tp-titulo.precid = recid(titulo).
            tp-contrato.vlpendente = tp-contrato.vlpendente + titulo.titvlcob.
            if (today - titulo.titdtven) > tp-contrato.atraso
            then tp-contrato.atraso = (today - titulo.titdtven).
        end.            
        else do:
            if titulo.titpar = 0
            then tp-contrato.vlentra = tp-contrato.vlentra + titulo.titvlcob.
            else tp-contrato.vlpago = tp-contrato.vlpago + titulo.titvlcob.
        end.
    end.

    
    ac-ok = no.


    run sel-contrato_21.
                

    if keyfunction(lastkey) = "end-error"
    then leave.

    if ac-ok 
    then do:
        leave.
    end.    
    
    vtot = 0.
    for each tp-contrato where tp-contrato.exportado no-lock:
        for each tp-titulo where
                 tp-titulo.clifor = tp-contrato.clicod and
                 tp-titulo.titnum = string(tp-contrato.contnum) and
                 tp-titulo.titsit = "LIB"
                 no-lock:
            vtot = vtot + tp-titulo.titvlcob.
        end.             
    end.             

    if vtot = 0 
    then do:
        leave.
    end.    

    vdata-futura = today.
    /*
    sresp = no.        
    message "Confirma gerar REPACTUACAO?" update sresp.
    if sresp = no
    then next.
    
    if vdata-futura <> today
    then do:
    
        message "Operacao negada, alterar data para HOJE.".
        pause 3 no-message.
        next.

    end.
    **/
    
    hide frame fpag99 no-pause.
    hide frame f-esqcom1 no-pause.
    hide frame f-esqcom2 no-pause.

    ventrada = 0.

    ac-ok = no.
    hide message no-pause.
    message color normal  "confirma?" update sresp.
    if sresp 
    then run fin/repactua-create.p(input par-clicod, output ac-ok).
    if ac-ok = no
    then do:
        undo.
    end.
    if ac-ok
    then do:
        bell.
        message color red/with
        "REPACTUACAO GERADO COM SUCESSO!"
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
            
    for each tp-contrato where tp-contrato.exportado no-lock:
        t-cobrado = t-cobrado + tp-contrato.vltotal.
        t-entrada = t-entrada + tp-contrato.vlentra.
        t-saldo   = t-saldo   + tp-contrato.vlpendente.
        if tp-contrato.atraso > t-atraso
        then t-atraso  = tp-contrato.atraso.
        t-pago    = t-pago    + tp-contrato.vlpago.
        /* 
        for each tp-titulo where
                 tp-titulo.clifor = tp-contrato.clicod   and
                 tp-titulo.titnum = string(tp-contrato.contnum)
                 no-lock:
            if tp-titulo.titsit = "LIB"
            then do:
                t-saldo = t-saldo + tp-titulo.titvlcob.
                if today - tp-titulo.titdtven > t-atraso
                then t-atraso = today - tp-titulo.titdtven.
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

procedure sel-contrato_21:

    {setbrw.i}

    if setbcod = 999
    then DO:
        assign
            /*esqcom1[1] = "Marca/Desmarca"
            esqcom1[2] = "Marca/Desm/Tudo"*/
            esqcom1[1] = "  Repactua".
    end.
    else do:         
        return.
        
    END.

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
    for each tp-contrato no-lock:
        find first tp-titulo where
            tp-titulo.titnum = string(tp-contrato.contnum)
            no-error.
        if not avail tp-titulo
        then do:
            delete tp-contrato.
        end.    
    end.

        
    def var vdown as int.

    form vmarca no-label format "x"
         tp-contrato.contnum     format ">>>>>>>>>9"
         tp-contrato.etbcod      column-label "Fil"
         tp-contrato.modcod      column-label "Mod"   
         tp-contrato.vltotal     format ">>>>,>>9.99"  
                    column-label "Valor"
         tp-contrato.vlentra     format ">>>>9.99"
                    column-label "Entrada"
         tp-contrato.vlpago 
                    column-label "Pagas"  format ">>>,>>9.99"
         tp-contrato.vlpendente
          column-label "Val Pendente"  format ">>>,>>9.99"
         tp-contrato.atraso column-label "Atraso" format ">>>>9"
         with frame f-linha screen-lines - 12 down
            title " REPACUACAO ".

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
    


    l1: repeat:    

    disp with frame f-esqcom1.
    
    if esqregua
    then
    color disp message esqcom1[esqpos1] with frame f-esqcom1.
    pause 0.

    pause 0.
    
    {sklcls.i
        &file = tp-contrato
        &cfield = tp-contrato.contnum
        &noncharacter = /*
        &ofield = " vmarca
                    tp-contrato.etbcod
                    tp-contrato.modcod
                    tp-contrato.vltotal
                    tp-contrato.vlentra
                    tp-contrato.vlpago
                    tp-contrato.vlpendente
                    tp-contrato.atraso
                  " 
        &aftfnd1 = " if tp-contrato.exportado
                     then vmarca = ""*"".
                     else vmarca = """".
                     vpend = 0.
                     /*
                     for each tp-titulo where
                        tp-titulo.clifor = tp-contrato.clicod and
                        tp-titulo.titnum = string(tp-contrato.contnum) and
                        tp-titulo.titsit = ""LIB""
                        :
                        vpend = vpend + tp-titulo.titvlcob.
                    end.
                    if tp-contrato.vltotal > 0
                    then vpago = tp-contrato.vltotal - vpend.
                    else vpago = 0.   */
                                       "         
        &where = true
        &naoexiste1 = "
            bell.
            message color red/with
            ""Nenhum Parcela em Aberto encontrada!""
            skip
            view-as alert-box
            .
            leave l1. "
        &aftselect1 = " 
                    if keyfunction(lastkey) = ""RETURN""
                    then do:
                        if esqcom1[esqpos1] = ""  Repactua"" 
                            and esqregua
                        then do:
                            if tp-contrato.exportado = yes
                            then    assign
                                tp-contrato.exportado = no
                                vmarca = """"
                                .
                            else do:
                                assign
                                        tp-contrato.exportado = yes
                                        vmarca = ""*"".
                                leave keys-loop.        
                            end.
                            disp vmarca with frame f-linha.
                            
                            run totaliza.
                            
                            next keys-loop. 
                        end.
                        else if esqcom1[esqpos1] = ""Marca/Desm/Tudo""
                            and esqregua
                        then do:
                            if tp-contrato.exportado = yes
                            then vmarca = ""*"". 
                            else vmarca = """".
                            for each tp-contrato:
                                if vmarca = ""*""
                                then tp-contrato.exportado = no.
                                else tp-contrato.exportado = yes.                                          
                            end.
                            run totaliza.
                            a-seeid = -1.
                            leave keys-loop.
                        end.
                        else if esqcom2[esqpos2] = ""Ver parcelas""
                            and not esqregua
                        then do:
                            for each titulo where 
                                titulo.empcod = 19 and
                                titulo.titnat = no and
                                titulo.modcod = tp-contrato.modcod and
                                titulo.etbcod = tp-contrato.etbcod and
                                titulo.clifor = tp-contrato.clicod and
                                titulo.titnum = string(tp-contrato.contnum)                                 no-lock:
                                disp titulo.titnum titulo.titpar 
                                        titulo.titdtven titulo.titvlcob
                                        titulo.etbcod 
                                        titulo.titsit
                                    with frame f-conp down centered overlay
                                    color message
                                    title "" Parcelas do contrato "" +
                                    string(tp-contrato.contnum).
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
    if esqcom1[esqpos1] = "  repactua" 
    then do:

        find first tp-contrato where 
            tp-contrato.exportado no-error.
        if not avail tp-contrato
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
