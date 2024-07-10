/*
*
*    cad_itemserv.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}



def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial ["Inclusao","Alteracao"," ", " ", "     "].
def var esqcom2         as char format "x(16)" extent 5
 init ["Impostos Retidos","Processos Associados"," ", " " , " "].

def var esqhel1         as char format "x(80)" extent 5
    initial ["Inclusao de item","Alteracao de item","  ","  ","  "].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bservi_titulo       for adm.servi_titulo.
def buffer servi_titulo for adm.servi_titulo.

def new shared temp-table tt-titudesp like titudesp.
form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vfatnum as int format ">>>>>>>>>9".
 
bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ? then run leitura (input "pri").
    else find servi_titulo where recid(servi_titulo) = recatu1 no-lock.
    if not available servi_titulo then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    if not esqvazio then run frame-a.
    
    recatu1 = recid(servi_titulo).

    if esqregua then 
        color disp message esqcom1[esqpos1] with frame f-com1.
    else 
        color disp message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio then repeat:
        run leitura (input "seg").
        if not available servi_titulo then leave.
        if frame-line(frame-a) = frame-down(frame-a) then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio then 
        up frame-line(frame-a) - 1 with frame frame-a.
    
    repeat with frame frame-a:
        
        if not esqvazio then do:
            /*run pi-ajusta-status.*/
            
            find servi_titulo where recid(servi_titulo) = recatu1 no-lock.
                
            status default
                if esqregua then 
                    esqhel1[esqpos1] + if esqpos1 > 1            and 
                                          esqhel1[esqpos1] <> "" then  
                                            string(servi_titulo.Descricao)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> "" then
                                            string(servi_titulo.Descricao)
                                        else "".
            run color-message.
            choose field servi_titulo.TipoOperacao help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".
            
        end.
        if keyfunction(lastkey) = "TAB" then do:
            if esqregua then do:
                color disp normal esqcom1[esqpos1] with frame f-com1.
                color disp message esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                color disp normal esqcom2[esqpos2] with frame f-com2.
                color disp message esqcom1[esqpos1] with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right" then do:
            if esqregua then do:
                color disp normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color disp messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color disp normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                color disp messages esqcom2[esqpos2] with frame f-com2.
            end.                                  
            next.
        end.
        if keyfunction(lastkey) = "cursor-left" then do:
            if esqregua then do:
                color disp normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color disp messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color disp normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                color disp messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "page-down" then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "down").
                if not avail servi_titulo then leave.
                recatu1 = recid(servi_titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up" then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "up").
                if not avail servi_titulo then leave.
                recatu1 = recid(servi_titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down" then do:
            run leitura (input "down").
            if not avail servi_titulo then next.
            if frame-line(frame-a) = frame-down(frame-a) then 
                scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up" then do:
            run leitura (input "up").
            if not avail servi_titulo then next.
            if frame-line(frame-a) = 1 then 
                scroll down with frame frame-a.
            else up with frame frame-a.
        end.
 
        if keyfunction(lastkey) = "end-error" then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form with frame f-servi_titulo 
                color black/cyan centered side-label row 5.
            hide frame frame-a no-pause.
            if esqregua then do:
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Inclusao" or esqvazio
                then do with frame f-servi-titulo with 2 col on error undo.
                    find last bservi_titulo no-error.
                    create servi_titulo.

                    do on error undo, retry:
                        prompt-for servi_titulo.TipoOperacao.
                        
                        if input servi_titulo.TipoOperacao <> "P" and 
                           input servi_titulo.TipoOperacao <> "R" then do:
                            message "Tipo de Operacao deve ser [P]agar ou"
                                    "[R]eceber." view-as alert-box.
                            undo, retry.                                    
                        end.                           
                    end.

                    prompt-for servi_titulo.CodEstabelecimento.

                    do on error undo, retry:
                        prompt-for servi_titulo.CodParceiro. 
                        
                        find first serv_forne where
                                   serv_forne.forcod =
                                   int(input servi_titulo.CodParceiro) 
                                   no-lock no-error.
                        if not avail serv_forne then do:
                            message "O participante informado nao esta"
                                    "cadastrado. Verifique."
                                    view-as alert-box .
                            undo.                                    
                        end.
                    end.
                    
                    prompt-for servi_titulo.DataOperacao.
                    prompt-for servi_titulo.NumeroDocumento.
                    prompt-for servi_titulo.NumeroParcela.
                           
                    prompt-for servi_titulo.CodGrupoContabil. 
                    prompt-for servi_titulo.CodPlanoConta.   
                    prompt-for servi_titulo.Descricao format "x(60)".
                    prompt-for servi_titulo.ValorOperacao. 
                    prompt-for servi_titulo.TipoDocumento. 
                    prompt-for servi_titulo.ValorOriginalTitulo. 
                    prompt-for servi_titulo.DataEmissaoDocumento. 
                    prompt-for servi_titulo.DataVencimento. 
                    prompt-for servi_titulo.NumeroArquivamento. 
                    prompt-for servi_titulo.Tipo.
                    prompt-for servi_titulo.CodigoObra format "x(60)".

                    do on error undo, retry:
                        prompt-for servi_titulo.EfeitoMovimento.
                        
                        if input servi_titulo.EfeitoMovimento <> "+" and
                           input servi_titulo.EfeitoMovimento <> "-" then do:
                           message "Informe + ou - neste campo."
                                    view-as alert-box.
                            undo, retry.                                    
                        end.
                    end. 
                    assign servi_titulo.TipoOperacao
                           servi_titulo.CodEstabelecimento
                           servi_titulo.CodParceiro
                           servi_titulo.DataOperacao
                           servi_titulo.NumeroDocumento
                           servi_titulo.NumeroParcela
                           servi_titulo.CodGrupoContabil
                           servi_titulo.CodPlanoConta
                           servi_titulo.DataOperacao
                           servi_titulo.Descricao
                           servi_titulo.ValorOperacao
                           servi_titulo.TipoDocumento
                           servi_titulo.ValorOriginalTitulo
                           servi_titulo.DataEmissaoDocumento
                           servi_titulo.DataVencimento
                           servi_titulo.NumeroArquivamento
                           servi_titulo.Tipo
                           servi_titulo.CodigoObra
                           servi_titulo.EfeitoMovimento
                           servi_titulo.NumeroParcela.
                           
                    run pi-gera-titulo.       
                    
                    recatu1 = recid(servi_titulo).
                    leave.
                end.
                
                if esqcom1[esqpos1] = "Alteracao"
                then do with frame f-servi_titulo with 2 col on error undo.
                    find servi_titulo where 
                   recid(servi_titulo) = recatu1 exclusive-lock.
                    
                    disp servi_titulo.TipoOperacao
                         servi_titulo.CodEstabelecimento
                         servi_titulo.CodParceiro.
                    
                    disp servi_titulo.DataOperacao
                         servi_titulo.NumeroDocumento
                         servi_titulo.NumeroParcela
                         servi_titulo.CodGrupoContabil
                         servi_titulo.CodPlanoConta
                         servi_titulo.DataOperacao
                         servi_titulo.Descricao
                         servi_titulo.ValorOperacao
                         servi_titulo.TipoDocumento
                         servi_titulo.ValorOriginalTitulo
                         servi_titulo.DataEmissaoDocumento
                         servi_titulo.DataVencimento
                         servi_titulo.NumeroArquivamento
                         servi_titulo.Tipo
                         servi_titulo.CodigoObra
                         servi_titulo.EfeitoMovimento
                         servi_titulo.NumeroParcela.
                    
                    prompt-for servi_titulo.CodGrupoContabil.
                    prompt-for servi_titulo.CodPlanoConta.
                    prompt-for servi_titulo.Descricao format "x(60)".
                    prompt-for servi_titulo.ValorOperacao.
                    prompt-for servi_titulo.TipoDocumento.
                    prompt-for servi_titulo.ValorOriginalTitulo.
                    prompt-for servi_titulo.DataEmissaoDocumento.
                    prompt-for servi_titulo.DataVencimento.
                    prompt-for servi_titulo.NumeroArquivamento.
                    prompt-for servi_titulo.Tipo.
                    prompt-for servi_titulo.CodigoObra format "x(60)".

                    do on error undo, retry:
                        prompt-for servi_titulo.EfeitoMovimento.
                        
                        if input servi_titulo.EfeitoMovimento <> "+" and
                           input servi_titulo.EfeitoMovimento <> "-" then do:
                            message "Informe + ou - neste campo."
                                    view-as alert-box.
                            undo, retry.
                        end.
                    end.                                
                    
                    assign servi_titulo.CodGrupoContabil
                           servi_titulo.CodPlanoConta
                           servi_titulo.DataOperacao
                           servi_titulo.Descricao
                           servi_titulo.ValorOperacao
                           servi_titulo.TipoDocumento
                           servi_titulo.ValorOriginalTitulo
                           servi_titulo.DataEmissaoDocumento
                           servi_titulo.DataVencimento
                           servi_titulo.NumeroArquivamento
                           servi_titulo.Tipo
                           servi_titulo.CodigoObra
                           servi_titulo.EfeitoMovimento
                           servi_titulo.NumeroParcela.
                    
                    
~                end.
                
            end.
            else do:
                disp caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = "Impostos Retidos" then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run conta_pag01a.p(recid(servi_titulo)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Processos Associados" then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run conta_pag01b.p (recid(servi_titulo)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                                
                leave.
            end.
        end.
         
        if not esqvazio then run frame-a.
       
        if esqregua then 
            disp esqcom1[esqpos1] with frame f-com1.
        else 
            disp esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(servi_titulo).
       
    end.
    
    if keyfunction(lastkey) = "end-error" then do:
        view frame fc1.
        view frame fc2.
    end.
    
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
     disp servi_titulo.TipoOperacao
          format "x(1)" column-label "Tipo Oper."
          servi_titulo.CodEstabelecimento
          format "x(10)" column-label "Estab."
          servi_titulo.CodParceiro  
          format "x(10)" column-label "Parceiro"
          servi_titulo.DataOperacao
          column-label "Dt Operacao"
          servi_titulo.NumeroDocumento
          format "x(15)" column-label "Num Doc"
          servi_titulo.NumeroParcela
          column-label "Parcela"
          with frame frame-a 11 down width 80 color white/red row 5.
end procedure.


procedure color-message.
    color disp message servi_titulo.TipoOperacao 
        format "x(1)"  column-label "Tipo"
    with frame frame-a.
end procedure.


procedure color-normal.
    color disp normal servi_titulo.TipoOperacao 
        format "x(1)"  column-label "Tipo"
    with frame frame-a.
end procedure.


procedure leitura.
    def input parameter par-tipo as char.
        
    if par-tipo = "pri" then  
        if esqascend then  
            find first servi_titulo where true no-lock no-error.
        else  
            find last servi_titulo where true  no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" then  
        if esqascend then  
            find next servi_titulo where true no-lock no-error.
        else  
            find prev servi_titulo where true no-lock no-error.
             
    if par-tipo = "up" then                  
        if esqascend then   
            find prev servi_titulo where true no-lock no-error.
        else   
            find next servi_titulo where true no-lock no-error.
        
end procedure.
         
procedure pi-ajusta-status:
    /*
    find servi_titulo where recid(servi_titulo) = recatu1 no-lock.
    
    status default
        if esqregua then
            esqhel1[esqpos1] + if esqpos1 > 1            and
                                  esqhel1[esqpos1] <> "" then
                                    string(servi_titulo.Descricao)
                                else ""
        else esqhel2[esqpos2] + if esqhel2[esqpos2] <> "" then
                                    string(servi_titulo.Descricao)
                                                                                                                else "".
    run color-message.
    
    choose field servi_titulo.CodEstabelecimento help ""
        go-on(cursor-down cursor-up
              cursor-left cursor-right
              page-down   page-up
              tab PF4 F4 ESC return).
    
    run color-normal.
    status default "".
    */                                          
end procedure.

procedure pi-gera-titulo:
    create tt-titudesp.
    assign tt-titudesp.exportado = yes 
           tt-titudesp.empcod = 19  
           tt-titudesp.titsit = "BLO"
           tt-titudesp.titnat = if Servi_Titulo.TipoOperacao = 'P' then true
                                else false
           tt-titudesp.modcod = "SFE"
           tt-titudesp.etbcod = int(Servi_Titulo.codEstabelecimento)
           tt-titudesp.datexp = today            
           tt-titudesp.clifor = int(Servi_titulo.CodParceiro) 
           tt-titudesp.titnum = Servi_Titulo.NumeroDocumento
           tt-titudesp.titpar = Servi_Titulo.NumeroParcela
           tt-titudesp.titdtemi = Servi_Titulo.DataEmissaoDocumento
           tt-titudesp.titdtven = Servi_Titulo.DataVencimento 
           tt-titudesp.titvlcob = Servi_Titulo.ValorOperacao           
           /*tt-titudesp.titbanpag = vsetcod*/
           .
     run pi-nfser.
end procedure.

procedure pi-nfser:
    
    def var vtot-tit as dec.
    def var t-impostos as log init no.
    def var v-extra as log.
    /*
    for each tt-nfser: delete tt-nfser. end.
    
    create tt-nfser.
           tt-nfser.inclusao = today.
                            
    disp tt-nfser.documento
         tt-nfser.emissao
         tt-nfser.val-total  format ">>>>>>>>9.99" label "Val. Documento"
         tt-nfser.val-icms   format ">>>>>>>>9.99"
         tt-nfser.val-ipi    format ">>>>>>>>9.99"
         tt-nfser.val-acr    format ">>>>>>>>9.99"
         tt-nfser.val-des    format ">>>>>>>>9.99"
         tt-nfser.val-iR     format ">>>>>>>>9.99"
         tt-nfser.val-iss    format ">>>>>>>>9.99"
         tt-nfser.val-inss   format ">>>>>>>>9.99"
         tt-nfser.val-pis    format ">>>>>>>>9.99"
         tt-nfser.val-cofins format ">>>>>>>>9.99"
         tt-nfser.val-csll   format ">>>>>>>>9.99"
         tt-nfser.val-liq    format ">>>>>>>>9.99" label "Val. Liquido"
         tt-nfser.qtd-par
        with frame f-doc 1 down side-label 1 column
        row 5 title " " + vsel-sit1[vtipo-documento] + " ".
    repeeat on endkey undo, return:
        update tt-nfser.documento
               tt-nfser.emissao
            with frame f-doc.
                                          
        find first fatudesp where
                   /*fatudesp.etbcod = vetbcod and*/
                   fatudesp.fatnum = int(tt-nfser.documento) and
                   fatudesp.clicod = vclifor no-error.
        if avail fatudesp then do:              
                   
       
            find first titulo where
                       titulo.clifor = fatudesp.clicod and
                       titulo.titnum = string(int(fatudesp.fatnum)) and
                       titulo.titdtemi = fatudesp.inclusao no-lock no-error.
            if avail titulo and fatudesp.situacao <> "P" then do:
                bell.
                message color red/with "Documento ja existe com"
                    " Filial " fatudesp.etbcod
                    " Fornecedor " fatudesp.clicod
                    " Documento " fatudesp.fatnum
                    view-as alert-box.
                return.
            end.
                                        
            assign tt-nfser.inclusao   = fatudesp.inclusao
                   tt-nfser.val-icms   = fatudesp.val-icms
                   tt-nfser.val-ipi    = fatudesp.val-ipi
                   tt-nfser.val-acr    = fatudesp.val-acr
                   tt-nfser.val-des    = fatudesp.val-des
                   tt-nfser.val-total  = fatudesp.val-total
                   tt-nfser.val-ir     = fatudesp.val-ir
                   tt-nfser.val-iss    = fatudesp.val-iss
                   tt-nfser.val-inss   = fatudesp.val-inss
                   tt-nfser.val-pis    = fatudesp.val-pis
                   tt-nfser.val-cofins = fatudesp.val-cofins
                   tt-nfser.val-csll   = fatudesp.val-csll
                   tt-nfser.val-liq    = fatudesp.val-liquido
                   tt-nfser.qtd-par    = fatudesp.qtd-parcela
                   tt-nfser.situacao   = fatudesp.situacao.
                                                                
                                                                            
            disp tt-nfser.val-total
                 tt-nfser.val-icms
                 tt-nfser.val-ipi
                 tt-nfser.val-acr
                 tt-nfser.val-des
                 tt-nfser.val-iR
                 tt-nfser.val-iss
                 tt-nfser.val-inss
                 tt-nfser.val-pis
                 tt-nfser.val-cofins
                 tt-nfser.val-csll
                 tt-nfser.val-liq
                 tt-nfser.qtd-par
                 with frame f-doc.
            if tt-nfser.qtd-par = 0 then 
                update tt-nfser.qtd-par with frame f-doc.
        end.
        else do:
            find first titulo where
                       titulo.clifor = vclifor and
                       titulo.titnum = string(int(tt-nfser.documento)) and
                       titulo.titdtemi = tt-nfser.inclusao
                       no-lock no-error.
            if avail titulo then do:
                bell.
                message color red/with
                    "Documento ja existe com Numero " tt-nfser.documento
                    view-as alert-box.
                return.
            end.
                                                        
            update tt-nfser.val-total
                   tt-nfser.val-icms
                   tt-nfser.val-ipi
                   tt-nfser.val-acr
                   tt-nfser.val-des
                   tt-nfser.val-iR
                   tt-nfser.val-iss
                   tt-nfser.val-inss
                   tt-nfser.val-pis
                   tt-nfser.val-cofins
                   tt-nfser.val-csll
                   tt-nfser.val-liq
                   with frame f-doc.

            update tt-nfser.qtd-par with frame f-doc.
        end.
                            
        if tt-nfser.val-liq <> (tt-nfser.val-total - (tt-nfser.val-iR +
           tt-nfser.val-iss + tt-nfser.val-inss + tt-nfser.val-pis +
           tt-nfser.val-cofins + tt-nfser.val-csll + tt-nfser.val-des)
           + tt-nfser.val-acr) then do:
            bell.
            message color red/with
                "Valor liquido diverge de valor total menos impostos".
            pause.
        end.                                    
        else do:
            empty temp-table tt-titudesp.
            if tt-nfser.situacao = "P" then
                run gera-titulo-parcial.
            else
                if vqtd-lj > 1 then do:
                    run rateio-cria-titulo.
                    tt-nfser.situacao = "P". /*** 19.01.2017 "R" ***/
                    run rateio-fatura.p(vtotal).
                end.
                else do:
                    sresp = no.
                    message "Lançamento parcial?" update sresp.
                    if sresp then do:
                        run gera-titulo-parcial.
                        tt-nfser.situacao = "P".
                    end.
                    else do:
                        run gera-titulo.
                    end.
                end.
            
                hide frame f-par no-pause.
                clear frame f-par all.
                if keyfunction(lastkey) = "end-error" then.
                else leave.
        end.
    end.
                                        
    message "Gravando dados AGUARDE...".
    PAUSE 0.
    find first tt-nfser where
               tt-nfser.documento <> 0 no-error.
    if avail tt-nfser then do on error undo:                                                    
    
    
        find first fatudesp where
                   /*fatudesp.etbcod = vetbcod and*/
                   fatudesp.clicod = vclifor and
                   fatudesp.fatnum = int(tt-nfser.documento) no-error.
        if not avail fatudesp then do:
            create fatudesp.
            assign fatudesp.numerodi   = vprocimp
                   fatudesp.etbcod     = vetbcod
                   fatudesp.fatnum     = int(tt-nfser.documento)
                   fatudesp.clicod     = vclifor
                   fatudesp.situacao   = "A"
                   fatudesp.setcod = vsetcod
                   fatudesp.modcod = vmodcod
                   fatudesp.modctb = vmod-ctb.
                                                            
        end.
                                                                            
        assign fatudesp.emissao    = tt-nfser.emissao
               fatudesp.inclusao   = tt-nfser.inclusao
               fatudesp.val-total  = tt-nfser.val-total
               fatudesp.val-icms   = tt-nfser.val-icms
               fatudesp.val-ipi    = tt-nfser.val-ipi
               fatudesp.val-acr    = tt-nfser.val-acr
               fatudesp.val-des    = tt-nfser.val-des
               fatudesp.val-ir     = tt-nfser.val-ir
               fatudesp.val-iss    = tt-nfser.val-iss
               fatudesp.val-inss   = tt-nfser.val-inss
               fatudesp.val-pis    = tt-nfser.val-pis
               fatudesp.val-cofins = tt-nfser.val-cofins
               fatudesp.val-csll   = tt-nfser.val-csll
               fatudesp.val-liquido = tt-nfser.val-liq
               fatudesp.qtd-parcela = tt-nfser.qtd-par
               fatudesp.situacao    = tt-nfser.situacao
               fatudesp.char1 = "FILIAL=" + string(setbcod,"999") +
                                "|FUNC=" + string(sfuncod,"9999999999").
    
                                         
        vfatnum = fatudesp.fatnum.       
        v-extra = no.
        vtot-tit = 0.
        */
        for each tt-titudesp:
                 
            create titudesp.
            buffer-copy tt-titudesp to titudesp.
                                                    
            find first titulo where
                       titulo.empcod = tt-titudesp.empcod and                                          titulo.titnat = tt-titudesp.titnat and
                       titulo.modcod = tt-titudesp.modcod and
                       titulo.etbcod = tt-titudesp.etbcod and
                       titulo.clifor = tt-titudesp.clifor and
                       titulo.titnum = tt-titudesp.titnum and
                       titulo.titpar = tt-titudesp.titpar no-error.
            if not avail titulo then do:
            
                create titulo.
                buffer-copy titudesp to titulo.     
                /*
                create wtit.
                assign wtit.wrec = recid(titulo).
                if titulo.modcod = "LIK" then run pi-vincula-circui.

                if month(titulo.titdtemi) <> month(titulo.titdtven) then 
                    v-extra = yes.
                vtot-tit =  vtot-tit + titulo.titvlcob .
                */
            end.
            else do:
                assign titulo.titvlcob = titulo.titvlcob + titudesp.titvlcob
                       vtot-tit =  vtot-tit + titudesp.titvlcob .
                                                .
            end.
            /*
            find first tituctb where
                       tituctb.empcod = wempre.empcod   and
                       tituctb.titnat = vtitnat         and
                       tituctb.modcod = vmod-ctb        and
                       tituctb.etbcod = fatudesp.etbcod and
                       tituctb.clifor = fatudesp.clicod and
                       tituctb.titnum = string(int(fatudesp.fatnum)) and
                       tituctb.titpar = titudesp.titpar no-error.
            if not avail tituctb then do:
                                                                                               create tituctb.
                buffer-copy titudesp to tituctb.
                tituctb.modcod = vmod-ctb.
            end.
            else tituctb.titvlcob = tituctb.titvlcob + titudesp.titvlcob.
            */
        end.
    /*    
    end.
    */
        
end procedure.
