{admcab.i}
def shared var vprocimp as char format "x(20)".
def shared var vempcod         like titulo.empcod.
def shared var vetbcod         like titulo.etbcod.
def shared var vmodcod         like titulo.modcod.
def shared var vmod-ctb        like titulo.modcod. 
def shared var vtitnat         like titulo.titnat.
def shared var vsetcod like setaut.setcod.
def shared var vclifor         like titulo.clifor.

def var vtitnum like titulo.titnum.
def var vtitpar like titulo.titpar.

def buffer btitulo for titulo.
def buffer btitudesp for titudesp.


def new shared temp-table tt-titudesp like titudesp.

def temp-table tt-csv
    field inclusao as date
    field emissao  as date
    field documento as char
    field val-liq   as dec
    field venc      as date
    field ad-info   as char
    .

def temp-table tt-gnre
    field Emit_CNPJ           as char
    field Data_Emissap        as char
    field Num_Documento       as char
    field Serie               as char
    field chaveDfe            as char
    field tipo                as char
    field Cod_receita         as char
    field Dest_CNPJ           as char
    field Dest_UF             as char
    field Detalhe_rceita      as char
    field Convenio            as char
    field Produto             as char
    field Val_principal       as char
    field Val_juros           as char
    field Val_multa           as char
    field Val_atu             as char
    field Val_outros          as char
    field Valor_Guia          as char
    field Num_controle        as char
    field Codigo_barras       as char
    field Data_Vencimento     as char
    field Pagador             as char
    field ind_status          as char
    field Data_Movimento      as char
    .
    
/*****************************
def temp-table tt-gnre
    field Data_Movimento      as char
    field Data_Emissap        as char
    field Num_Documento       as char
    field Serie               as char
    field Emit_UF             as char
    field Emit_CNPJ           as char
    field Dest_UF             as char
    field Dest_CNPJ           as char
    field Dest_IE             as char
    field Dest_Raz_Soc        as char
    field Num_Controle        as char
    field ID_Guia             as char
    field Documento_Origem    as char
    field Cod_receita         as char
    field Detalhe_Receita     as char
    field Convenio            as char
    field Data_Vencimento     as char
    field Valor_Guia          as char
    field Base_ST             as char
    field EStatus             as char
    field Codigo_barras       as char
    field Banco               as char
    field Agencia             as char
    field Conta               as char
    field Data_Pagamento      as char
    field Data_Emissao_relatorio as char
    field CNPJ_pagador           as char
    field Autenticacao           as char
    .
*********************/

form
    /*tt-gnre.Data_Movimento    format "x(10)"*/
    tt-gnre.Data_Emissap      format "x(10)"
    tt-gnre.Data_Vencimento   format "x(10)"
    Num_Documento     format "x(15)"
    Valor_Guia        format "x(15)"
    with frame f-linha width 80 row 6 down.
        
def var varquivo as char.
def var vtotal as char.
def var dc-total as dec.
def var vgera-despesa as log.
def var vatualiza-info as log.

{setbrw.i}

repeat.

    update varquivo 
        format "x(65)" label "Arquivo"
    with        
        row 11
        centered 
        1 down
        side-labels.
        
    if search(varquivo) = ?
    then do:
        message "Arquivo não existe...".
        pause.    
        undo.
    end.

    for each tt-csv.
        delete tt-csv.
    end.

    input from value(varquivo).
    repeat transaction.
        create tt-gnre.
        import delimiter ";" tt-gnre.
        tt-gnre.Data_Movimento = tt-gnre.Data_Emissap.
    end.
    input close.

    for each tt-gnre:
        if tt-gnre.Data_Movimento begins "Data"
        then delete tt-gnre.
        else if tt-gnre.Data_Movimento begins "Relato"
        then delete tt-gnre.
        else if length(tt-gnre.Codigo_barras) < 40
        then delete tt-gnre.
        else if avail tt-gnre
        then do:
            tt-gnre.valor_guia = replace(tt-gnre.valor_guia,".","").
            tt-gnre.valor_guia = replace(tt-gnre.valor_guia,",",".").
            if tt-gnre.Data_Movimento = "" and
               tt-gnre.valor_guia <> ""
            then do:
                vtotal = tt-gnre.valor_guia.
                delete tt-gnre.
            end.       
            else dc-total = dc-total + dec(tt-gnre.valor_guia).
        end.
    end.
        
    vgera-despesa = no.
    
    l1:
    repeat:
        disp varquivo  format "x(65)" label "Arquivo"
        with frame f2 side-label no-box row 4.       
        disp dc-total label "Total" vtotal no-label with frame f-l 1 down
            row 5 side-label no-box.
        pause 0.    
        {sklclstb.i  
            &color = with/cyan
            &help  = "F4-Cancelar F1-Gerar despesas F8-Atualizar Informacoes"
            &file = tt-gnre   
            &cfield = tt-gnre.Data_Movimento
            &noncharacter = /* 
            &ofield = " Data_Movimento    
                        Data_Emissap      
                        Data_Vencimento
                        Num_Documento     
                        dec(Valor_Guia) @ Valor_Guia
                        "  
            &aftfnd1 = " "
            &where  = " true "
            &aftselect1 = " if keyfunction(lastkey) = ""GO""
                            then leave keys-loop.
                            "
            &go-on = TAB 
            &naoexiste1 = " leave l1. " 
            &otherkeys1 = "  "
            &locktype = " "
            &form   = " frame f-linha "
        }   
        if keyfunction(lastkey) = "end-error"
        then DO:
            sresp = no.
            message color red/with
            "Confirma sair sem gerar despesas?" update sresp.
            if sresp 
            then leave l1.    
            else next l1.   
        END.
        if keyfunction(lastkey) = "GO"
        then do:
            sresp = no.
            vgera-despesa = no.
            message color red/with
            "Confirma gerar despesas?" update sresp.
            if not sresp then next l1.
            else do:
                vgera-despesa = yes.
                leave l1.
            end.    
        end.
        if keyfunction(lastkey) = "CLEAR"
        then do:
            sresp = no.
            vatualiza-info = no.
            message color red/with
            "Confirma atualizar informacoes adicionais?" update sresp.
            if not sresp then next l1.
            else do:
                vatualiza-info = yes.
                leave l1.
            end. 
        end.
    end.

    if vatualiza-info
    then do:
        for each tt-gnre:
            create tt-csv.
            assign
                tt-csv.inclusao = date(substr(tt-gnre.Data_Movimento,1,10))
                tt-csv.emissao  = date(substr(tt-gnre.Data_Emissap,1,10))
                tt-csv.documento = tt-gnre.Num_Documento
                tt-csv.venc      = date(substr(tt-gnre.Data_Vencimento,1,10))
                tt-csv.val-liq   = dec(tt-gnre.Valor_Guia)
                tt-csv.ad-info   = 
                "GNRE=SIM" + "|" +
                "MOVIMENTO=" + string(tt-gnre.Data_Movimento) + "|" +
                "EMISSAO="   + string(tt-gnre.Data_Emissap)   + "|" +
                "VENCIMENTO=" + string(tt-gnre.Data_Vencimento) + "|" +
                "VALOR=" + tt-gnre.Valor_Guia + "|" +
                "DOCUMENTO=" + string(tt-gnre.Num_Documento) + "|" +
                "SERIE=" + tt-gnre.serie + "|" +
                /*"UFEMITE=" + tt-gnre.Emit_UF + "|" +*/
                "CNPJEMITE=" + tt-gnre.Emit_CNPJ + "|" +
                "UFDESTI=" + tt-gnre.Dest_UF + "|" +
                "CNPJDESTI=" + tt-gnre.Dest_CNPJ + "|" +
                /*"IEDESTI=" + tt-gnre.Dest_IE + "|" +*/
                /*"DESTIRAZAO=" + tt-gnre.Dest_Raz_Soc + "|" +*/
                "NCONTROLE=" + tt-gnre.Num_Controle + "|" +
                /*"IDGUIA=" + tt-gnre.ID_Guia + "|" +  */
                /*"DOCORIGEN=" + tt-gnre.Documento_Origem + "|" +*/
                "CODRECEITA=" + tt-gnre.Cod_receita + "|" +
                "CONVENIO=" + tt-gnre.Convenio + "|" +
                /*"BASEST=" + tt-gnre.Base_ST + "|" +*/
                /*"ESTATUS=" + tt-gnre.EStatus + "|" + */
                "CBARRAS=" + tt-gnre.Codigo_barras + "|" /*+
                "PAGAMENTO=" + tt-gnre.Data_Pagamento + "|" +
                "DTEMIREL=" + tt-gnre.Data_Emissao_relatorio + "|"*/
                .

        end.
        for each tt-csv.
            if tt-csv.documento = "" or
               tt-csv.documento = ?
            then do:
                delete tt-csv.
                next.
            end.

            find first fatudesp where
                   fatudesp.clicod = vclifor and
                   fatudesp.fatnum = int(tt-csv.documento)
                   no-error.
            if avail fatudesp
            then do on error undo:
                fatudesp.char2 = tt-csv.ad-info.
                find titulo2 where
                                titulo2.empcod = 19 and
                                titulo2.titnat = yes and
                                titulo2.modcod = fatudesp.modcod and
                                titulo2.etbcod = 999 and
                                titulo2.clifor = fatudesp.clicod and
                                titulo2.titnum = string(fatudesp.fatnum) and
                                titulo2.titpar = 1 and
                                titulo2.titdtemi = fatudesp.emissao
                                no-error.
                if avail titulo2
                then titulo2.codbar = "Bar=" + acha("CBARRAS",fatudesp.char2).
            end.
        end.       
    end.
    
    if vgera-despesa
    then do :
        for each tt-gnre:
            create tt-csv.
            assign
                tt-csv.inclusao = date(substr(tt-gnre.Data_Movimento,1,10))
                tt-csv.emissao  = date(substr(tt-gnre.Data_Emissap,1,10))
                tt-csv.documento = tt-gnre.Num_Documento
                tt-csv.venc      = date(substr(tt-gnre.Data_Vencimento,1,10))
                tt-csv.val-liq   = dec(tt-gnre.Valor_Guia)
                tt-csv.ad-info   = 
                "GNRE=SIM" + "|" +
                "MOVIMENTO=" + string(tt-gnre.Data_Movimento) + "|" +
                "EMISSAO="   + string(tt-gnre.Data_Emissap)   + "|" +
                "VENCIMENTO=" + string(tt-gnre.Data_Vencimento) + "|" +
                "VALOR=" + tt-gnre.Valor_Guia + "|" +
                "DOCUMENTO=" + string(tt-gnre.Num_Documento) + "|" +
                "SERIE=" + tt-gnre.serie + "|" +
                /*"UFEMITE=" + tt-gnre.Emit_UF + "|" +*/
                "CNPJEMITE=" + tt-gnre.Emit_CNPJ + "|" +
                "UFDESTI=" + tt-gnre.Dest_UF + "|" +
                "CNPJDESTI=" + tt-gnre.Dest_CNPJ + "|" +
                /*"IEDESTI=" + tt-gnre.Dest_IE + "|" + */
                /*"DESTIRAZAO=" + tt-gnre.Dest_Raz_Soc + "|" +*/
                "NCONTROLE=" + tt-gnre.Num_Controle + "|" +
                /*"IDGUIA=" + tt-gnre.ID_Guia + "|" +*/
                /*"DOCORIGEN=" + tt-gnre.Documento_Origem + "|" +*/
                "CODRECEITA=" + tt-gnre.Cod_receita + "|" +
                "CONVENIO=" + tt-gnre.Convenio + "|" +
                /*"BASEST=" + tt-gnre.Base_ST + "|" +*/
                /*"ESTATUS=" + tt-gnre.EStatus + "|" +*/
                "CBARRAS=" + tt-gnre.Codigo_barras + "|" /*+
                "PAGAMENTO=" + tt-gnre.Data_Pagamento + "|" +
                "DTEMIREL=" + tt-gnre.Data_Emissao_relatorio + "|"*/
                .

        end.
        for each tt-csv.
            if tt-csv.documento = "" or
               tt-csv.documento = ?
            then do:
                delete tt-csv.
                next.
            end.   
            run dd-nfser.
            delete tt-csv.
        end.    
    end.
    
    leave.
    
end.
hide frame farq no-pause.
    return.


procedure dd-nfser:

        find first fatudesp where 
            /*fatudesp.etbcod = vetbcod and*/
            fatudesp.fatnum = int(tt-csv.documento) and
            fatudesp.clicod = vclifor 
            no-error.
        if avail fatudesp
        then do:
            find first titulo where
                       titulo.clifor = fatudesp.clicod and
                       titulo.titnum = string(int(fatudesp.fatnum)) and
                       titulo.titdtemi = fatudesp.inclusao
                       no-lock no-error.
            if avail titulo and fatudesp.situacao <> "P"
            then do:
        
                bell.
                message color red/with
                "Documento ja existe com"
                " Filial " fatudesp.etbcod
                " Fornecedor " fatudesp.clicod
                " Documento " fatudesp.fatnum
                view-as alert-box.
                return.
            end.           
        end.            
        
            for each tt-titudesp: delete tt-titudesp. end.
            run gera-titulo.
            
    hide message no-pause.
    message "Gravando dados AGUARDE...".
    
    PAUSE 0.
    do on error undo:
        find first fatudesp where
                   /*fatudesp.etbcod = vetbcod and*/
                   fatudesp.clicod = vclifor and
                   fatudesp.fatnum = int(tt-csv.documento)
                   no-error.
        if not avail fatudesp
        then do:
            create fatudesp.
            assign
                fatudesp.numerodi   = vprocimp
                fatudesp.etbcod     = vetbcod
                fatudesp.fatnum     = int(tt-csv.documento)
                fatudesp.clicod     = vclifor
                fatudesp.situacao   = "A" 
                fatudesp.setcod = vsetcod
                fatudesp.modcod = vmodcod
                fatudesp.modctb = vmod-ctb
                .

        end.
        assign
            fatudesp.emissao    = tt-csv.emissao
            fatudesp.inclusao   = tt-csv.inclusao
            fatudesp.val-total  = tt-csv.val-liq
            fatudesp.val-liquido = tt-csv.val-liq 
            fatudesp.qtd-parcela = 1
            fatudesp.situacao    = ""
            fatudesp.char1 = "FILIAL=" + string(setbcod,"999") +
                             "|FUNC=" + string(sfuncod,"9999999999")
            fatudesp.char2 = tt-csv.ad-info
                             .
           

        for each tt-titudesp where
                 tt-titudesp.titnum = string(int(fatudesp.fatnum))
                 :
               
            create titudesp.
            buffer-copy tt-titudesp to titudesp.
            
            find first titulo where 
                       titulo.empcod = wempre.empcod and
                       titulo.titnat = vtitnat         and
                       titulo.modcod = fatudesp.modcod and
                       titulo.etbcod = fatudesp.etbcod and
                       titulo.clifor = fatudesp.clicod       and
                       titulo.titnum = string(int(fatudesp.fatnum)) and
                       titulo.titpar = titudesp.titpar
                        no-error.
            if not avail titulo
            then do:
                create titulo.
                buffer-copy titudesp to titulo.
            end.
            find first tituctb where 
                       tituctb.empcod = wempre.empcod and
                       tituctb.titnat = vtitnat         and
                       tituctb.modcod = vmod-ctb and
                       tituctb.etbcod = fatudesp.etbcod and
                       tituctb.clifor = fatudesp.clicod       and
                       tituctb.titnum = string(int(fatudesp.fatnum)) and
                       tituctb.titpar = titudesp.titpar
                        no-error.
            if not avail tituctb
            then do:
                create tituctb.
                buffer-copy titudesp to tituctb.
                tituctb.modcod = vmod-ctb.
            end.
            else  tituctb.titvlcob = 
                        tituctb.titvlcob + titudesp.titvlcob  .
 
        end.
        
            fatudesp.situacao = "A".
    end.
end.  

procedure gera-titulo:

    def var vdtini as date.
    def var vdtfin as date.
    def var vtotmodal as dec.
    
    
    assign
        vtitpar = 1
        vtitnum = string(tt-csv.documento).
        
    do:
        
        
        find first btitulo where btitulo.empcod = wempre.empcod and
                                 btitulo.titnat = vtitnat       and
                                 btitulo.modcod = vmodcod       and
                                 btitulo.etbcod = vetbcod       and
                                 btitulo.clifor = vclifor       and
                                 btitulo.titnum = vtitnum       and
                                 btitulo.titpar = vtitpar       and
                                 btitulo.titdtemi = tt-csv.emissao
                           NO-LOCK no-error.
        if avail btitulo
        then do:
            find first btitudesp where btitudesp.empcod = wempre.empcod and
                                     btitudesp.titnat = vtitnat       and
                                     btitudesp.modcod = vmodcod       and
                                     btitudesp.etbcod = vetbcod       and
                                     btitudesp.clifor = vclifor       and
                                     btitudesp.titnum = vtitnum       and
                                     btitudesp.titpar = vtitpar       and
                                     btitudesp.titdtemi = tt-csv.emissao   and
                                     btitudesp.titbanpag = vsetcod    
                                     NO-LOCK no-error.
            if avail btitudesp
            then do:                         
                message "Titulo ja Existe".
                pause.
                return.
            end.
        end.
      
            do on error undo:
                create tt-titudesp.
                assign tt-titudesp.exportado = yes
                   tt-titudesp.empcod = wempre.empcod
                   tt-titudesp.titsit = "LIB"
                   tt-titudesp.titnat = vtitnat
                   tt-titudesp.modcod = vmodcod
                   tt-titudesp.etbcod = vetbcod
                   tt-titudesp.datexp = today
                   tt-titudesp.clifor = vclifor
                   tt-titudesp.titnum = vtitnum
                   tt-titudesp.titpar = 1
                   tt-titudesp.titdtemi = tt-csv.emissao
                   tt-titudesp.titdtven = tt-csv.venc
                   tt-titudesp.titvlcob = tt-csv.val-liq
                   tt-titudesp.titbanpag = vsetcod.
            
                
            end.
    end.
    hide frame f-par no-pause.       
 end procedure.
 


procedure informa-obs:
    def var vobs like titulo.titobs.
    
    update vobs no-label
            WITH FRAME F-titobs 1 down row 16 title " OBSERVAÇÃO ".
            
    if vobs[1] <> "" or
       vobs[2] <> ""
    then do :         
        for each titulo where
             titulo.empcod = 19 and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp.fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             :
                     
            titulo.titobs = vobs.
        end.
        for each titudesp where
             titudesp.empcod = 19 and
             titudesp.clifor = fatudesp.clicod and
             titudesp.titnum = string(fatudesp.fatnum) and
             titudesp.titdtemi = fatudesp.inclusao
             :
            titudesp.titobs = vobs.
        end. 
        for each tituctb where
             tituctb.empcod = 19 and
             tituctb.clifor = fatudesp.clicod and
             tituctb.titnum = string(fatudesp.fatnum) and
             tituctb.titdtemi = fatudesp.inclusao
             :
                     
            tituctb.titobs = vobs.
        end.
    
    end.         
end procedure.
