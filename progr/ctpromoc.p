/*helio 15122022 https://trello.com/c/9EGvpVEs/901-alterar-data-fim-cria%C3%A7%C3%A3o-dos-m%C3%B3dulos */
{admcab.i}                                                      
{difregtab.i NEW}
def temp-table tt-ctpromoc like ctpromoc.
def buffer btbpromoc for tbpromoc.
def buffer ectpromoc for ctpromoc.
def buffer fctpromoc for ctpromoc.

def var vtime as int.
def buffer bestab for estab.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var vmes as int.
def var vano as int.
def var vdesmes as char format "x(10)" extent 12
    init["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
         "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
def var esqcom1         as char format "x(12)" extent 6
init["  Inclui","  Altera","  Consulta","  Situacao","  Exclui","  Imprime"]
            .
def var esqcom2         as char format "x(12)" extent 6
init["  Planos","  Filiais","  Produtos","  Mensagem","  Revalidar","  Clonar"].
              
form
        esqcom1
            with frame f-com1
                 row 4 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def var vdti as date.
def var vdtf as date.
def var vdtauxi as date.
def var vdtauxf as date.
vmes = month(today).
vano = year(today).

disp vmes format "99"   label "Mes"
     vdesmes[vmes] no-label
     vano format "9999" label "Ano"
     with frame f-mes 1 down width 80 
     color message no-box side-label.
     
update vmes format "99"   label "Mes"
        with frame f-mes.
        
disp       vdesmes[vmes] no-label     with frame f-mes.
update  vano format "9999" label "Ano"
       with frame f-mes 1 down width 80 no-box side-label.

assign 
    vdti = date(vmes,01,vano)
    vdtf = date(if vmes = 12 then 01 else vmes + 1,01,
            if vmes = 12 then vano + 1 else vano) - 1
    vdtauxi = vdti
    vdtauxf = vdtf        
            .
if vdti < today
then vdtauxi = today. 

disp vdti at 40 format "99/99/9999"   label "Vigencia de"
     vdtf format "99/99/9999"   label "Ate"
     with frame f-mes.

def var vtitle as char.
def var tipo-promoc as log format "Normal/Diaria" init yes.
form ctpromoc.promocod   at 4 label "Promocao"
     tbpromoc.descricao no-label     
     tipo-promoc label "Tipo"
     ctpromoc.dtinicio at 1  validate(ctpromoc.dtinicio >= today and
                                           ctpromo.dtinicio <= vdtf,
                                            "Data nao permitida")
                  label "Data Inicio" format "99/99/9999"
     ctpromoc.dtfim    validate(ctpromoc.dtfim >= ctpromoc.dtinicio and
                                        /*ctpromoc.dtfim <= vdtf and*/
                                        ctpromoc.dtfim >= today - 1,
                                        "Data nao permitida" )
                label "Data Fim"    format "99/99/9999"
     ctpromoc.descricao[1] at 3 label "Descricao" format "x(65)"
     ctpromoc.descricao[2] at 14 no-label    format "x(65)"
     ctpromoc.precoliberado at 1 label "Liberar  preco"
     ctpromoc.liberavenda   at 30   label "Libera plano[ Todos"
     help "Todos os produtos da venda devem estar na promoção."
     ctpromoc.compolog5 label "  Pelo menos um" format "Sim/Nao"
     help "Pelo menos um produto da venda deve estar na promoção."
     "]"
     ctpromoc.precosugerido at 1 label "Preco sugerido"
     ctpromoc.vendaacimade label "Venda acima de R$"
     ctpromoc.campodec2[3] label "Ate R$"
     ctpromoc.campodec2[4] format ">9" label "Qtd Venda"
     ctpromoc.campodec2[5] format ">9" label "a"
     ctpromoc.campolog3    label "Valor a vista? " format "Sim/Nao" to 49
     ctpromoc.campolog4    label "Unitario?" format "Sim/Nao" to 70  
     /*skip(1)*/
     ctpromoc.bonusvalor      at 1 label "Bonus ->Valor  "
                format ">>>9.99"
     ctpromoc.cartaovalor     at 26  label "Cartao ->Valor  "
                format ">>>9.99"     
     ctpromoc.descontovalor   at 52  label "Desconto ->Valor "
                format ">>>9.99"
     ctpromoc.bonusparcela    at 1 label "      ->Parcela"
     ctpromoc.cartaoparcela   at 24  label "         ->Parcela"
     ctpromoc.descontopercentual   at 52  label "        ->Percent"
     ctpromoc.bonuspercentual at 1 label   "      ->Percent"
     ctpromoc.cartaopercentual at 26 label "       ->Percent"
     /*skip(1)*/
     ctpromoc.valvendedor     at 1 label "Vendedor->Valor"
            format ">>>9.99"
     ctpromoc.valgerente           label "Gerente -> Valor"
            format ">>>9.99"
     ctpromoc.valsupervisor        label "Supervisor->Valor"
            format ">>>9.99"
     ctpromoc.pctvendedor     at 1 label "      ->Percent"
     ctpromoc.pctgerente           label "      -> Percent"
     ctpromoc.pctsupervisor        label "       -> Percent"
     ctpromoc.campodec2[1]    at 1 label "Promotor->Valor"
            format ">>>9.99"
     ctpromoc.campodec2[2]    at 1 label "      ->Percent"   
            format ">>9.99%"
     /*skip(1)*/  
     ctpromoc.perguntaprodutousado at 1 label "Exigir produto usado"
     ctpromoc.campolog1    at 40 format "Sim/Nao"  label "Mensagem na tela"
     ctpromoc.geradespesa at 1 label "Gerar Despesa Financeira"
     ctpromoc.recibo      at 40 label "Emitir Recibo da Despesa"
     with frame f-add1 1 down side-label width 80 row 4
                title vtitle overlay.
 
def var vsel-sit as char format "x(15)" extent 3
    init["M = MONTAGEM","L = LIBERADA","C = CANCELADA"].
def var vmarca-sit as char format "x" extent 3.
format "[" space(0) vmarca-sit[1] space(0) "]"  
       vsel-sit[1]             skip
       "[" space(0) vmarca-sit[2] space(0) "]"  
       vsel-sit[2]             skip
       "[" space(0) vmarca-sit[3] space(0) "]"
       vsel-sit[3]            skip
       with frame f-sel-sit
       1 down  centered no-label row 8.

def var forne-vendedor as int   format ">>>>>>>>9".
def var forne-gerente  as int   format ">>>>>>>>9".
def var forne-supervisor as int format ">>>>>>>>9".
def var forne-promotor as int   format ">>>>>>>>9".
def var cod-forne as int        format ">>>>>>>>9".

def buffer pctpromoc for ctpromoc.

def var vsec like ctpromoc.sequencia.

def temp-table tt-produ 
    field procod like produ.procod format ">>>>>>>>9"
    field preco as dec
    index i1 procod.

def buffer bclase for clase.
def buffer cclase for clase.

bl-princ:
repeat:
    if avail func
    then 
    display wempre.emprazsoc + "/" + estab.etbnom + "-" + 
        func.funnom @ wempre.emprazsoc
            wdata with frame fc1.
    else
    display wempre.emprazsoc + "/" + estab.etbnom  @ wempre.emprazsoc
            wdata with frame fc1.

    display wtitulo                with frame fc2.

    status input "Digite os dados ou pressione [F4] para encerrar.".
status default "CUSTOM Business Solutions              - F5 -> Solicitacoes".

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first ctpromoc  where
                    ctpromoc.dtfim >= vdti and
                    /*ctpromoc.dtfim <= vdtf and*/
                    ctpromoc.linha = 0 
                    no-lock no-error.
    else find ctpromoc where recid(ctpromoc) = recatu1 no-lock no-error.

    if not available ctpromoc
    then do:
        if vmes < month(today) or
           vano < year(today) 
        then do:
            message color red/with "Nenum registro encontrado."
                view-as alert-box.
            leave bl-princ.
        end.
        sresp = no.
        message "Nenhum registro encontrado. Deseja incluir ? "
        update sresp.
        if not sresp
        then  leave bl-princ.  
        else do on endkey undo, leave bl-princ.  
            hide frame f-com1 no-pause.
            hide frame f-com2 no-pause.
            run inclui.
        end.
        next bl-princ.
    end.

    clear frame frame-a all no-pause.
    find tbpromoc where
         tbpromoc.promocod = ctpromoc.promocod no-lock.
    display ctpromoc.sequencia column-label "Seq." format ">>>>9"
            tbpromoc.descricao format "x(37)"
            ctpromoc.offer_id column-label "Oferta Itim"
            ctpromoc.dtinicio
            ctpromoc.dtfim
            ctpromoc.situacao
            with frame frame-a 10 down centered width 80.
    disp ctpromoc.descricao[1] label "Descricao" format "x(65)"
         ctpromoc.descricao[2] at 12 no-label    format "x(65)"
         with frame f-descricao no-box 1 down
         row 19 width 80 side-label color message.
         
    recatu1 = recid(ctpromoc).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next ctpromoc where
                    ctpromoc.dtfim >= vdti and
                    /*ctpromoc.dtfim <= vdtf and*/
                    ctpromoc.linha = 0 
                        no-lock no-error.
        
        if not available ctpromoc
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        find tbpromoc where
             tbpromoc.promocod = ctpromoc.promocod no-lock.
        display ctpromoc.sequencia
                tbpromoc.descricao
                ctpromoc.offer_id
                ctpromoc.dtinicio
                ctpromoc.dtfim
                ctpromoc.situacao
            with frame frame-a.
        disp ctpromoc.descricao[1] 
             ctpromoc.descricao[2] 
             with frame f-descricao.
     end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        find ctpromoc where recid(ctpromoc) = recatu1 no-error.
        disp ctpromoc.descricao[1] 
             ctpromoc.descricao[2] 
             with frame f-descricao.
         choose field ctpromoc.sequencia go-on(cursor-down cursor-up 
                                         cursor-left cursor-right 
                                         tab PF4 F4 ESC return p P).

        if keyfunction(lastkey) = "p" or
           keyfunction(lastkey) = "P"
        then do:
            update vsec label "Codigo"
                with frame f-procura side-label
                row 10 centered overlay color message.
            find first ctpromoc where
                       ctpromoc.sequencia = vsec and
                       ctpromoc.dtfim >= vdti and
                       ctpromoc.linha = 0 
                       no-lock no-error.
            if avail ctpromoc
            then recatu1 = recid(ctpromoc).
            else do:
                message color red/with
                "Nenum registro encontrado no periodo."
                view-as alert-box.
            end.
            hide frame f-procura.
            next bl-princ.
        end.

        if keyfunction(lastkey) = "TAB"
        then do:
        
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 6
                          then 6
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        
        if keyfunction(lastkey) = "cursor-down"
        then do:
        
            find next ctpromoc where
                    ctpromoc.dtfim >= vdti and
                    /*ctpromoc.dtfim <= vdtf and*/
                    ctpromoc.linha = 0 
                                            no-lock no-error.
            
            if not avail ctpromoc
            then next.
            
            color display normal ctpromoc.sequencia.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.

        end.

        if keyfunction(lastkey) = "cursor-up"
        then do:
        
            find prev ctpromoc where
                    ctpromoc.dtfim >= vdti and
                    /*ctpromoc.dtfim <= vdtf and*/
                    ctpromoc.linha = 0 
                                                no-lock no-error.
            if not avail ctpromoc
            then next.
            
            color display normal ctpromoc.sequencia
            .
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
            
        end.
        
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        
        hide frame frame-a no-pause.

        if esqregua
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "  Imprime"
            then do:
                def var vsituacao as char.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                if ctpromoc.situacao = "M"
                then vsituacao = " -> Montagem".
                else if ctpromoc.situacao = "C"
                    then vsituacao = " -> Cancelada".
                    else if ctpromoc.situacao = "L"
                        then vsituacao = " -> Liberada".
                        else vsituacao = "".
                find tbpromoc where
                        tbpromoc.promocod = ctpromoc.promocod no-lock.
                display ctpromoc.promocod at 1  label "Promocao"
                        tbpromoc.descricao no-label 
                        ctpromoc.sequencia at 1 label "Sequencia" format ">>>9"
                        ctpromoc.dtinicio
                        ctpromoc.dtfim
                        ctpromoc.situacao
                        vsituacao no-label   format "x(15)"
                        with frame frame-a1 side-label
                        WIDTH 80 no-box color message.
                pause 0.

                sresp = no.
                message "Confirma Imprimir ?" update sresp.
                if sresp then run relatorio.
                recatu1 = recid(ctpromoc).
                leave.
            end.
            
            if esqcom1[esqpos1] = "  Inclui"
            then do on endkey undo, next bl-princ:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run inclui.
                leave.
            end.
            
            if esqcom1[esqpos1] = "  Altera"
            then do: 
                if ctpromoc.situacao <> "C"
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run alteracao.
                end.
                else do:
                    bell.
                    message color red/with
                     "Operacao " esqcom1[esqpos1] 
                     " nao permitida para situacao " ctpromoc.situacao
                      view-as alert-box.
                end.
                recatu1 = recid(ctpromoc).
                leave.
            end.
            if esqcom1[esqpos1] = "  Consulta"
            then do: 
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run consulta.
                recatu1 = recid(ctpromoc).
                leave.
            end.
            if esqcom1[esqpos1] = "  Situacao"
            then do: 
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                if ctpromoc.situacao = "M"
                then vsituacao = " -> Montagem".
                else if ctpromoc.situacao = "C"
                    then vsituacao = " -> Cancelada".
                    else if ctpromoc.situacao = "L"
                        then vsituacao = " -> Liberada".
                        else vsituacao = "".
                find tbpromoc where
                        tbpromoc.promocod = ctpromoc.promocod no-lock.
                display ctpromoc.promocod at 1  label "Promocao"
                        tbpromoc.descricao no-label 
                        ctpromoc.sequencia at 1 label "Sequencia" format ">>>9"
                        ctpromoc.dtinicio
                        ctpromoc.dtfim
                        ctpromoc.situacao
                        vsituacao no-label   format "x(15)"
                        with frame frame-a1 side-label
                        WIDTH 80 no-box color message.
                pause 0.

                def var vsit-promo like ctpromoc.situacao.
                vsit-promo = ctpromoc.situacao.
                def var vi as in init 0. 
                def var va as int init 0.    
                if vsit-promo = "M"
                then vi = 1.
                else if vsit-promo = "L"
                    then vi = 2.
                    else if vsit-promo = "C"
                       then vi = 3.
 
                if vi = 0
                then next.
                vmarca-sit = "".
                vmarca-sit[vi] = "*".    
                disp     vmarca-sit
                         vsel-sit with frame f-sel-sit.
                va = vi.    
                
                repeat:
                    choose field vsel-sit with frame f-sel-sit.
                    if (vi = 1 and frame-index = 3) or
                       (vi = 2 and frame-index = 1) or
                       (vi = 3 and frame-index = 2) or
                       (vi = 3 and frame-index = 1)
                    then do:
                        /*
                        bell.
                        message "Operacao nao permitida"  .
                        */
                        next.
                    end.
                    vmarca-sit[va] = "". 
                    vmarca-sit[frame-index] = "*".
                    va = frame-index.    
                        
                    disp vmarca-sit
                         with frame f-sel-sit.
                end.
                if keyfunction(lastkey) = "END-ERROR"
                    and vi <> va
                then do:
                    bell.
                    sresp = no.
                    message color red/with
                        "Confirma alterar situacao da promocao ? "
                        update sresp.
                    if sresp
                    then do:
                        if (ctpromoc.promocod <> 20 and
                            ctpromoc.promocod <> 22) or
                            va <> 2
                        then ctpromoc.situacao = substr(vsel-sit[va],1,1).
                        else if (ctpromoc.promocod = 20 or
                                 ctpromoc.promocod = 22) and
                            va = 2
                        then do:
                            
                            vtime = time.
                            for each pctpromoc where
                                 pctpromoc.sequencia = ctpromoc.sequencia and
                                 pctpromoc.linha > 0 and
                                 pctpromoc.procod > 0
                                 no-lock:
                                disp "Aguarde.... " pctpromoc.procod format ">>>>>>>>9"
                                    with frame f-pro row 16 1 down 
                                    no-label no-box.
                                pause 0.  
                                find first fctpromoc where
                                   fctpromoc.sequencia = ctpromoc.sequencia and
                                   fctpromoc.linha > 0 and
                                   fctpromoc.etbcod > 0 and
                                   fctpromoc.situacao <> "I" and
                                   fctpromoc.situacao <> "E"
                                   no-lock no-error.
                                if not avail fctpromoc
                                then do:   
                                    for each estab no-lock:
                                        find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod = estab.etbcod and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                                        if avail fctpromoc then next.
 
                                    run cria-hispre.p(
                                        input estab.etbcod, 
                                        input pctpromoc.procod,
                                        input 0,
                                        input pctpromoc.precosugerido,
                                        input 0, input vtime).
                                        end.
                                end.
                                else
                                for each fctpromoc where
                                   fctpromoc.sequencia = ctpromoc.sequencia and
                                   fctpromoc.linha > 0 and
                                   fctpromoc.etbcod > 0 and
                                   fctpromoc.situacao <> "I" and
                                   fctpromoc.situacao <> "E"
                                   no-lock :
                                    run cria-hispre.p(
                                        input fctpromoc.etbcod,
                                        input pctpromoc.procod,
                                        input 0,
                                        input pctpromoc.precosugerido,
                                        input 0, input vtime).
                                end.
 
                            end.
                            run lib-20-22.
                            hide frame f-pro no-pause.
                            /*
                            create table-raw.
                            raw-transfer ctpromoc to table-raw.registro2.
                            run grava-tablog.p 
                                (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "ALTERA-SITUACAO").
                            */
                            ctpromoc.situacao = substr(vsel-sit[va],1,1).
                         end.

                     end.    
                end. 
                hide frame f-sel-sit no-pause.
                clear frame f-sel-sit all.        
                recatu1 = recid(ctpromoc).
                leave.
            end.
            if esqcom1[esqpos1] = "  Exclui"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                if ctpromoc.situacao = "M"
                then vsituacao = " -> Montagem".
                else if ctpromoc.situacao = "C"
                    then vsituacao = " -> Cancelada".
                    else if ctpromoc.situacao = "L"
                        then vsituacao = " -> Liberada".
                        else vsituacao = "".
                find tbpromoc where
                        tbpromoc.promocod = ctpromoc.promocod no-lock.
                display ctpromoc.promocod at 1  label "Promocao"
                        tbpromoc.descricao no-label 
                        ctpromoc.sequencia at 1 label "Sequencia" format ">>>9"
                        ctpromoc.dtinicio
                        ctpromoc.dtfim
                        ctpromoc.situacao
                        vsituacao no-label   format "x(15)"
                        with frame frame-a1 side-label
                        WIDTH 80 no-box color message.
                pause 0.
 
                if ctpromoc.situacao <> "M"
                then do:
                    bell.
                    message "Opcao " esqcom1[esqpos1] "nao permitida para situacao " ctpromoc.situacao view-as alert-box.
                    next bl-princ.
                end.
                sresp = no.
                message "Confirma excluir promoção ?" update sresp.
                if sresp
                then do:
                    /*
                    create table-raw.
                    raw-transfer ctpromoc to table-raw.registro2.
                    run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "EXCLUI").
                    */ 
                     for each ectpromoc where 
                             ectpromoc.sequencia = ctpromoc.sequencia :
                             delete ectpromoc.
                    end.
                     message color red/with
                        "Exclusão concluida." view-as alert-box.
                    recatu1 = ?.
                    next bl-princ.
                end.
                             
                recatu1 = recid(ctpromoc).
                leave.
            end.
        end. 
        else do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                if ctpromoc.situacao = "M"
                then vsituacao = " -> Montagem".
                else if ctpromoc.situacao = "C"
                    then vsituacao = " -> Cancelada".
                    else if ctpromoc.situacao = "L"
                        then vsituacao = " -> Liberada".
                        else vsituacao = "".
                find tbpromoc where
                        tbpromoc.promocod = ctpromoc.promocod no-lock.
                display ctpromoc.promocod at 1  label "Promocao"
                        tbpromoc.descricao no-label 
                        ctpromoc.sequencia at 1 label "Sequencia" format ">>>>9"
                        ctpromoc.dtinicio
                        ctpromoc.dtfim
                        ctpromoc.situacao
                        vsituacao no-label   format "x(15)"
                        with frame frame-a1 side-label
                        WIDTH 80 no-box color message.
                pause 0.

            if esqcom2[esqpos2] = "  Planos"
            then do:
                run plpromoc.p(recid(ctpromoc)).
                recatu1 = recid(ctpromoc).
                next bl-princ.
            end.
            if esqcom2[esqpos2] = "  Filiais" 
            then do: 
                run fipromoc.p(recid(ctpromoc)).
                recatu1 = recid(ctpromoc).
                next bl-princ.
            end.
            if esqcom2[esqpos2] = "  Produtos" 
            then do: 
                run prpromoc.p(recid(ctpromoc)).
                recatu1 = recid(ctpromoc).
                next bl-princ.
            end.
            if esqcom2[esqpos2] = "  Mensagem" 
            then do: 
                if ctpromoc.campolog1
                then  run mensagem.
                recatu1 = recid(ctpromoc).
                next bl-princ.
            end.
            if esqcom2[esqpos2] = "  Revalidar" 
            then do: 
                if ctpromoc.situacao <> "L"
                then do:
                    bell.
                    message "Opcao " esqcom2[esqpos2] 
                    "nao permitida para situacao " ctpromoc.situacao 
                    view-as alert-box.
                    next bl-princ.
                end.
                run revalidar.
                recatu1 = recid(ctpromoc).
                next bl-princ.
            end.
            if esqcom2[esqpos2] = "  Clonar" 
            then do: 
                /**
                if ctpromoc.situacao <> "M"
                then do:
                    bell.
                    message "Opcao " esqcom2[esqpos2] 
                    "nao permitida para situacao " ctpromoc.situacao 
                    view-as alert-box.
                    next bl-princ.
                end. **/
                run clonar.

                find last ctpromoc  where ctpromoc.linha = 0 
                    no-lock no-error.
 
                recatu1 = recid(ctpromoc).
                next bl-princ.
            end.

            if esqcom2[esqpos2] = "   CRM" 
            then do: 
                run campanha.
                recatu1 = recid(ctpromoc).
                next bl-princ.
            end.
        end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        find tbpromoc where
             tbpromoc.promocod = ctpromoc.promocod no-lock.
        display ctpromoc.sequencia
            ctpromoc.offer_id
            tbpromoc.descricao
            ctpromoc.dtinicio
            ctpromoc.dtfim
            ctpromoc.situacao
            with frame frame-a.
        disp ctpromoc.descricao[1] 
             ctpromoc.descricao[2]
             with frame f-descricao.
         if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ctpromoc).
   end.
end.

form ectpromoc.promocod at 1  label "Promocao"
     tbpromoc.descricao no-label 
     ectpromoc.sequencia at 1 label "Sequencia" format ">>>9"
     ectpromoc.dtinicio label "Inicio" format "99/99/9999"
     ectpromoc.dtfim label "Fim"    format "99/99/9999"
     ectpromoc.situacao
     vsituacao no-label   format "x(15)"
     ectpromoc.descricao[1] at 3 label "Descricao" format "x(65)"
     ectpromoc.descricao[2] at 14 no-label    format "x(65)"
     skip(1)
     ectpromoc.precoliberado at 1 label "Liberar  preco"
     ectpromoc.liberavenda   at 43     label "Libera plano[ "
     ectpromoc.compolog5               label " Pelo menos um"
      "]"
     ectpromoc.precosugerido at 1 label "Preco sugerido"
     ectpromoc.vendaacimade label "Venda acima de R$"
     ectpromoc.campodec2[3] label "Ate R$"
     ectpromoc.campodec2[4] format ">9" label "Qtd Venda"
     ectpromoc.campodec2[5] format ">9" label "a"
     ectpromoc.campolog3    label "Valor a vista?" format "Sim/Nao" to 49
     ectpromoc.campolog4    label "Unitario?" format "Sim/Nao" to 70 
     /*skip(1)*/
     ectpromoc.bonusvalor      at 1 label "Bonus ->Valor  "
                format ">>>9.99"
     ectpromoc.cartaovalor     at 26  label "Cartao ->Valor  "
                format ">>>9.99"     
     ectpromoc.descontovalor   at 52  label "Desconto ->Valor "
                format ">>>9.99"
     ectpromoc.bonusparcela    at 1 label "      ->Parcela"
     ectpromoc.cartaoparcela   at 24  label "         ->Parcela"
     ectpromoc.descontopercentual   at 52  label "        ->Percent"
     ectpromoc.bonuspercentual at 1 label   "      ->Percent"
     ectpromoc.cartaopercentual at 26 label "       ->Percent"
     /*skip(1)*/
     ectpromoc.valvendedor     at 1 label "Vendedor->Valor"
            format ">>>9.99"
     ectpromoc.valgerente           label "Gerente -> Valor"
            format ">>>9.99"
     ectpromoc.valsupervisor        label "Supervisor->Valor"
            format ">>>9.99"
     ectpromoc.pctvendedor     at 1 label "      ->Percent"
     ectpromoc.pctgerente           label "      -> Percent"
     ectpromoc.pctsupervisor        label "       -> Percent"
     ectpromoc.campodec2[1]    at 1 label "Promotor->Valor"
            format ">>>9.99"
     ectpromoc.campodec2[2]    at 1 label "      ->Percent"   
            format ">>9.99%"
     /*skip(1)*/ 
     ectpromoc.perguntaprodutousado at 1 label "Exigir produto usado"
     ectpromoc.campolog1    at 40 format "Sim/Nao"  label "Mensagem na tela"
     ectpromoc.geradespesa at 1 label "Gerar Despesa Financeira"
     ectpromoc.recibo      at 40 label "Emitir Recibo da Despesa"
     with frame f-add2 1 down side-label width 80 row 5
                .

procedure relatorio:
    
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
    else varquivo = "..\relat\prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""ctpromoc"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """LISTAGEM DE PROMOCOES""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    find ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequencia and
             ectpromoc.linha = 0 no-lock no-error.
    if avail ectpromoc
    then do: 
            find tbpromoc where
                tbpromoc.promocod = ectpromoc.promocod no-lock.
            if ectpromoc.situacao = "M"
            then vsituacao = " -> Montagem".
            else if ectpromoc.situacao = "C"
                then vsituacao = " -> Cancelada".
                else if ectpromoc.situacao = "L"
                then vsituacao = " -> Liberada".
                else vsituacao = "".
            
            display ectpromoc.promocod 
                    tbpromoc.descricao 
                    ectpromoc.sequencia 
                    ectpromoc.dtinicio
                    ectpromoc.dtfim
                    ectpromoc.situacao
                    vsituacao no-label
                    ectpromoc.descricao[1]
                    ectpromoc.descricao[2]
                    with frame f-add2.

            disp  
                ectpromoc.precoliberado 
                ectpromoc.liberavenda
                ectpromoc.compolog5
                ectpromoc.precosugerido 
                ectpromoc.vendaacimade
                ectpromoc.campodec2[3]
                ectpromoc.campodec2[4] 
                ectpromoc.campodec2[5] 
                ectpromoc.campolog3
                ectpromoc.campolog4
                with frame f-add2.

            disp  
                ectpromoc.bonusvalor      
                ectpromoc.bonusparcela    
                ectpromoc.bonuspercentual 
                ectpromoc.cartaovalor      
                ectpromoc.cartaoparcela   
                ectpromoc.cartaopercentual 
                ectpromoc.descontovalor
                ectpromoc.descontopercentual
                ectpromoc.perguntaprodutousado 
                ectpromoc.campolog1
                ectpromoc.geradespesa 
                ectpromoc.recibo
                with frame f-add2 . 

            disp 
                ectpromoc.valvendedor      
                ectpromoc.pctvendedor    
                ectpromoc.valgerente 
                ectpromoc.pctgerente      
                ectpromoc.valsupervisor   
                ectpromoc.pctsupervisor 
                ectpromoc.campodec2[1]
                ectpromoc.campodec2[2]
                with frame f-add2 .       
    end.
    if ectpromoc.campochar[3] <> ""
    then do:
        put skip
            fill("-",80) format "x(80)" skip
            ectpromoc.campochar[3] skip.
    end.
    if ectpromoc.campochar[2] <> ""
    then do:
        assign
        cod-forne = int(acha("FORNECEDOR",ectpromoc.campochar[2]))
        forne-vendedor   = int(acha("FORNE-VENDEDOR",ectpromoc.campochar[2]))
        forne-gerente    = int(acha("FORNE-GERENTE",ectpromoc.campochar[2]))
        forne-supervisor = int(acha("FORNE-SUPERVISOR",ectpromoc.campochar[2]))
        forne-promotor   = int(acha("FORNE-PROMOTOR",ectpromoc.campochar[2]))
        .
        put skip 
            fill("-",80) format "x(80)" skip
            "FORNECEDOR:" .
        if cod-forne <> ?
        then put "      GERAL= " cod-forne skip.
        if forne-vendedor <> ?
        then put space(12) "   VENDEDOR= " forne-vendedor  skip.
        if forne-gerente <> ?
        then put space(12) "    GERENTE= " forne-gerente   skip.
        if forne-supervisor <> ?
        then put space(12) " SUPERVISOR= " forne-supervisor skip.
        if forne-supervisor <> ?
        then put "   PROMOTOR= " forne-promotor skip.
    end. 
    
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.fincod <> ? no-lock no-error.
    if avail ectpromoc
    then do:         
        put skip
            fill("-",80) format "x(80)" skip
             "PLANOS: " .
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.fincod <> ? no-lock:
            find finan where finan.fincod = ectpromoc.fincod
             no-lock.
            put ectpromoc.fincod to 20 " - " finan.finnom skip
            .
        end.
    end.             
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.etbcod > 0 no-lock no-error.
    if avail ectpromoc
    then do:         
        put skip
            fill("-",80) format "x(80)" skip
            "FILIAIS: " .
        def var vi as int.
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.etbcod > 0 no-lock:
            find bestab where bestab.etbcod = ectpromoc.etbcod no-lock.     
            put ectpromoc.etbcod to 20 " - " bestab.etbnom format "x(15)" .
            if ectpromoc.cxacod[1] <> 0
            then do:
                put " Caixas ( "    .
                do vi = 1 to 10:
                    if ectpromoc.cxacod[vi] = 0
                    then do:
                        put ")".
                        leave.
                    end.
                    put ectpromoc.cxacod[vi] format "99" ", ".       
                end.
            end.
            put skip.
        end.     
    end.
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.procod > 0 no-lock no-error.
    if avail ectpromoc
    then do:
        put skip
            fill("-",80) format "x(80)" skip
            "PRODUTOS: " .
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.procod > 0 no-lock:
            find produ where produ.procod = ectpromoc.procod no-lock.
            put ectpromoc.procod to 20 " - " produ.pronom space(2).
            if ectpromoc.precosugerido > 0
            then put ectpromoc.precosugerido.
            put  skip.
        end.    
    end.
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.clacod > 0 no-lock no-error.
    if avail ectpromoc
    then do:         
        put skip
            fill("-",80) format "x(80)" skip
            "CLASSES: " .
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.clacod > 0 no-lock:
            find clase where clase.clacod = ectpromoc.clacod no-lock.
            put ectpromoc.clacod to 20 " - " clase.clanom skip.
        end.
    end.
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.setcod > 0 no-lock no-error.
    if avail ectpromoc
    then do:         
        put skip
            fill("-",80) format "x(80)" skip
            "SETOR: " .
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.setcod > 0 no-lock:
            find categoria where categoria.catcod = ectpromoc.setcod no-lock.
            put ectpromoc.setcod to 20 " - " categoria.catnom skip.
        end.
    end.
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.fabcod > 0 no-lock no-error.
    if avail ectpromoc
    then do:         
        put skip
            fill("-",80) format "x(80)" skip
            "FABRICANTE: " .
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.fabcod > 0 no-lock:
            find fabri where fabri.fabcod = ectpromoc.fabcod no-lock.
            put ectpromoc.fabcod to 20 " - " fabri.fabnom skip.
        end.
    end.
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequencia and
             ectpromoc.probrinde > 0 no-lock no-error.
    if avail ectpromoc
    then do:
        put skip
            fill("-",80) format "x(80)" skip
            "BRINDES: " .
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.probrinde > 0 no-lock:
            find produ where produ.procod = ectpromoc.probrinde no-lock.
            put ectpromoc.probrinde to 20 " - " produ.pronom skip.
        end.         
    end.
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequencia and
             ectpromoc.produtovendacasada > 0  
             no-lock no-error.
    if avail ectpromoc
    then do:         
        put skip
            fill("-",80) format "x(80)" skip
            "CASADINHA: " .
        def var vok as log.    
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequencia and
             ectpromoc.produtovendacasada > 0  
             no-lock:
            find produ where produ.procod =
                    ectpromoc.produtovendacasada no-lock.
            if ectpromoc.fincod = ?
            then do:
                vok = no.
                put ectpromoc.produtovendacasada to 20 " - " 
                produ.pronom skip.
            end.
            else do:
                if vok = no
                then do:
                    put "Plano:"  to 27
                        ectpromoc.fincod to 35  
                        "Valor:"  to 45
                        ectpromoc.valorprodutovendacasada to 55 skip.
                    vok = yes.
                end.
                else do:
                    put ectpromoc.fincod to 35  
                        ectpromoc.valorprodutovendacasada to 55 skip.
                end.
            end.
        end.
    end.
    find first ectpromoc where 
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.probrinde = 0 and
                   (ectpromoc.campodec1[2] > 0 or
                    ectpromoc.campodec1[3] > 0)
                   no-lock no-error.
    if avail ectpromoc
    then do:
        put skip
           fill("-",80) format "x(80)" skip
           "VINCULADO: " .
        if ctpromoc.campodec1[1] = 0
        then do:
            put  "      PRECO DE         ATE" SKIP.
            for each ectpromoc where 
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.probrinde = 0 and
                   (ectpromoc.campodec1[2] > 0 or
                    ectpromoc.campodec1[3] > 0)
                   no-lock.

                put space(15) 
                    ectpromoc.campodec1[2] space(2)
                    ectpromoc.campodec1[3]    
                    skip.
                       
            end.
        end.
        else do:   
            put  "    PRODUTO  " skip.
            for each ectpromoc where 
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.probrinde = 0 and
                   ectpromoc.campodec1[2] > 0 no-lock
                   .
                find produ where 
                        produ.procod = int(ectpromoc.campodec1[2])
                        no-lock no-error.
                if avail produ
                then put space(15) produ.procod  space(3) produ.pronom 
                     skip.         
            end.
        end.        
    end.
    find first ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.acaocod > 0 no-lock no-error.
    if avail ectpromoc
    then do:
        put skip
            fill("-",80) format "x(80)" skip
            "ACAO CRM: " .
        for each ectpromoc where 
             ectpromoc.sequencia = ctpromoc.sequenci and
             ectpromoc.acaocod > 0 no-lock:
        
            put "Campanha   : " to 25 ectpromoc.acaocod skip.
            if ectpromoc.segmentacao > 0
            then put  "Segmentacao: " to 25 ectpromoc.segmentacao skip .
            if ectpromoc.publico > 0
            then put "Publico    : " to 25 ectpromoc.publico skip.
            if ectpromoc.perfil > 0
            then put "Perfil     : " to 25 ectpromoc.perfil skip .
            if ectpromoc.apelo > 0
            then put "Apelo      : " to 25 ectpromoc.apelo skip.
            if ectpromoc.canal > 0
            then put "Canal      : " to 25 ectpromoc.canal skip.
        end.            
    end.
    put skip
        fill("-",80) format "x(80)" skip
        .
    output close.
    
    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"") .
    end.
    else do:
        {mrod.i}
    end.

end procedure.

procedure inclui:
    clear frame f-add1 all.
    vtitle = "     I N C L U S A O    ".
    def buffer bctpromoc for ctpromoc.
    
    find last bctpromoc  where bctpromoc.linha = 0  no-error.
 
    repeat transaction on endkey undo, leave:
        create ctpromoc.
        assign
            ctpromoc.sequencia = if avail bctpromoc
                then bctpromoc.sequencia + 1 else 1
            ctpromo.dtinicio = today /*helio 15122022 vdtauxi */
            ctpromo.dtfim    = today /*helio 15122022 vdtauxf */
            ctpromoc.fincod = ?
             .
        update ctpromoc.promocod  with frame f-add1.
        find tbpromoc where
             tbpromoc.promocod = ctpromoc.promocod no-lock .
        disp tbpromoc.descricao with frame f-add1. 
        tipo-promoc = yes.
        update tipo-promoc with frame f-add1.
        if not tipo-promoc
        then ctpromoc.tipo = "Diaria".    
        update  ctpromoc.dtinicio
                ctpromoc.dtfim 
                with frame f-add1 .
        update ctpromoc.descricao[1]
               ctpromoc.descricao[2]
               with frame f-add1.
        if ctpromoc.promocod <> 54
        then do:
        update  
                ctpromoc.precoliberado 
                ctpromoc.liberavenda   when ctpromoc.precoliberado = no
                ctpromoc.compolog5     
                with frame f-add1.
        update  ctpromoc.precosugerido 
                ctpromoc.vendaacimade  when ctpromoc.precoliberado = no
                ctpromoc.campodec2[3]  when ctpromoc.precoliberado = no
                with frame f-add1.
        if ctpromoc.vendaacimade > 0 or
           ctpromoc.campodec2[3] > 0
        then update ctpromoc.campodec2[4] 
                    ctpromoc.campodec2[5] 
                    ctpromoc.campolog3 
                    with frame f-add1.
        update ctpromoc.campolog4
                    with frame f-add1. 
        if ctpromoc.precoliberado = no and
           ctpromoc.liberavenda = no
        then do:   
        update  
                ctpromoc.bonusvalor with frame f-add1.
        if ctpromoc.bonusvalor > 0
        then run tipo-valor.
                      
        update  ctpromoc.bonusparcela    
                ctpromoc.bonuspercentual 
                ctpromoc.cartaovalor      
                ctpromoc.cartaoparcela   
                ctpromoc.cartaopercentual
                ctpromoc.descontovalor
                ctpromoc.descontopercentual
                  with frame f-add1.
              
        update
                ctpromoc.valvendedor      
                ctpromoc.pctvendedor    
                ctpromoc.valgerente 
                ctpromoc.pctgerente      
                ctpromoc.valsupervisor   
                ctpromoc.pctsupervisor 
                ctpromoc.campodec2[1]
                ctpromoc.campodec2[2]
                with frame f-add1 . 
                
        update        
                ctpromoc.perguntaprodutousado
                ctpromoc.campolog1
                ctpromoc.geradespesa 
                ctpromoc.recibo
                with frame f-add1 . 
        if ctpromoc.geradespesa = yes
        then do:
            sretorno = "ALTERA".
            run forne-despesa.
            sretorno = "".
        end.
        else ctpromoc.campochar[2] = "".
        end.
        end.
        else if ctpromoc.promocod = 54
        then do:
            update ctpromoc.descontopercentual
                              with frame f-add1.
        end.
        recatu1 = recid(ctpromoc).  
        
        /*
        create table-raw.
        raw-transfer ctpromoc to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "INCLUI").
        */
        leave.    
    end. 
end procedure.

procedure alteracao:
    vtitle = "    A L T E R A C A O   ".
    repeat on endkey undo, leave:
        /*
        CREATE table-raw.
        raw-transfer ctpromoc to table-raw.registro1.
        run grava-tablog.p (input 1, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "ALTERA").
        */                 
        find tbpromoc where
             tbpromoc.promocod = ctpromoc.promocod no-lock .
        if ctpromoc.tipo = ""
        then tipo-promoc = yes.
        else tipo-promoc = no.
        disp    ctpromoc.promocod
                tbpromoc.descricao  
                tipo-promoc    
                ctpromoc.dtinicio
                ctpromoc.dtfim 
                with frame f-add1 .
        disp    ctpromoc.descricao[1]
                ctpromoc.descricao[2]
                with frame f-add1.
        disp  
                ctpromoc.precoliberado 
                ctpromoc.liberavenda
                ctpromoc.compolog5
                ctpromoc.precosugerido 
                ctpromoc.vendaacimade 
                ctpromoc.campodec2[3]
                ctpromoc.campodec2[4] 
                ctpromoc.campodec2[5] 
                ctpromoc.campolog3
                ctpromoc.campolog4
                with frame f-add1.
        disp  
                ctpromoc.bonusvalor      
                ctpromoc.bonusparcela    
                ctpromoc.bonuspercentual 
                ctpromoc.cartaovalor      
                ctpromoc.cartaoparcela   
                ctpromoc.cartaopercentual 
                ctpromoc.descontovalor
                ctpromoc.descontopercentual
                with frame f-add1 . 

        disp 
                ctpromoc.valvendedor      
                ctpromoc.pctvendedor    
                ctpromoc.valgerente 
                ctpromoc.pctgerente      
                ctpromoc.valsupervisor   
                ctpromoc.pctsupervisor 
                ctpromoc.campodec2[1]
                ctpromoc.campodec2[2]
                ctpromoc.perguntaprodutousado 
                ctpromoc.campolog1
                ctpromoc.geradespesa 
                ctpromoc.recibo
                with frame f-add1 . 
        if ctpromoc.promocod <> 54 and ctpromoc.situacao = "M"
        then do:        
        update  ctpromoc.dtinicio with frame f-add1.
        update ctpromoc.dtfim  with frame f-add1 .
        update  ctpromoc.descricao[1]
                ctpromoc.descricao[2]
                with frame f-add1.
         
        update  
                ctpromoc.precoliberado 
                ctpromoc.liberavenda    when ctpromoc.precoliberado = no
                ctpromoc.compolog5      when ctpromoc.liberavenda = no
                with frame f-add1.
                
        update
                ctpromoc.precosugerido 
                ctpromoc.vendaacimade   when ctpromoc.precoliberado = no
                ctpromoc.campodec2[3]   when ctpromoc.precoliberado = no
                with frame f-add1.
        if ctpromoc.vendaacimade > 0 or
           ctpromoc.campodec2[3] > 0
        then update ctpromoc.campodec2[4] 
                    ctpromoc.campodec2[5] 
                    ctpromoc.campolog3 
                    with frame f-add1.
        update ctpromoc.campolog4
                    with frame f-add1.
        end.        

        if ctpromoc.promocod <> 54 and
           ctpromoc.precoliberado = no and
           ctpromoc.liberavenda = no
        then do: 
            if ctpromoc.situacao = "M" 
            then do: 
                update  
                    ctpromoc.bonusvalor with frame f-add1.
                if ctpromoc.bonusvalor > 0
                then run tipo-valor.
                update 
                    ctpromoc.bonusparcela    
                    ctpromoc.bonuspercentual 
                    ctpromoc.cartaovalor      
                    ctpromoc.cartaoparcela   
                    ctpromoc.cartaopercentual
                    ctpromoc.descontovalor
                    ctpromoc.descontopercentual
                    with frame f-add1.
                update
                    ctpromoc.valvendedor      
                    ctpromoc.pctvendedor    
                    ctpromoc.valgerente 
                    ctpromoc.pctgerente      
                    ctpromoc.valsupervisor   
                    ctpromoc.pctsupervisor 
                    ctpromoc.campodec2[1]
                    ctpromoc.campodec2[2]
                    with frame f-add1 . 
            end.             
            update       
                ctpromoc.perguntaprodutousado 
                ctpromoc.campolog1
                ctpromoc.geradespesa 
                ctpromoc.recibo
                with frame f-add1 . 
            if ctpromoc.geradespesa = yes
            then do:
                run forne-despesa.
            end.
            else ctpromoc.campochar[2] = "".
        end.
        else if ctpromoc.promocod = 54
        then do:
            update  ctpromoc.descontopercentual
                        with frame f-add1.
                                    
        end.
        recatu1 = recid(ctpromoc).   
        /*
        raw-transfer ctpromoc to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "ALTERA").
        */
        leave.    
    end. 
end procedure.

procedure consulta:
    vtitle = "    C O N S U L T A    ".
    repeat on endkey undo, leave:
        find tbpromoc where
             tbpromoc.promocod = ctpromoc.promocod no-lock .
        disp    ctpromoc.promocod
                tbpromoc.descricao      
                ctpromoc.dtinicio
                ctpromoc.dtfim 
                ctpromoc.descricao[1]
                ctpromoc.descricao[2]
                with frame f-add1 .
        disp  
                ctpromoc.precoliberado 
                ctpromoc.liberavenda
                ctpromoc.compolog5
                ctpromoc.precosugerido 
                ctpromoc.vendaacimade 
                ctpromoc.campodec2[3]
                ctpromoc.campodec2[4] 
                ctpromoc.campodec2[5] 
                ctpromoc.campolog3
                ctpromoc.campolog4
                with frame f-add1.
        disp  
                ctpromoc.bonusvalor      
                ctpromoc.bonusparcela    
                ctpromoc.bonuspercentual 
                ctpromoc.cartaovalor      
                ctpromoc.cartaoparcela   
                ctpromoc.cartaopercentual 
                ctpromoc.descontovalor
                ctpromoc.descontopercentual
                ctpromoc.valvendedor      
                ctpromoc.pctvendedor    
                ctpromoc.valgerente 
                ctpromoc.pctgerente      
                ctpromoc.valsupervisor   
                ctpromoc.pctsupervisor 
                ctpromoc.campodec2[1]
                ctpromoc.campodec2[2]
                ctpromoc.perguntaprodutousado 
                ctpromoc.campolog1
                ctpromoc.geradespesa 
                ctpromoc.recibo
                with frame f-add1 . 
        pause.
        if ctpromoc.geradespesa = yes
        then do:
            sretorno = "".
            run forne-despesa.
            sretorno = "".
        end.
        
        recatu1 = recid(ctpromoc).   
        leave.    
    end. 
end procedure.
procedure revalidar:
    def buffer rctpromoc for ctpromo.
    def buffer bctpromoc for ctpromoc.
    def var vdtir like tt-ctpromoc.dtinicio.
    def var vdtfr like tt-ctpromoc.dtfim.
    /*
    create table-raw.
    raw-transfer ctpromoc to table-raw.registro1.
    run grava-tablog.p (input 1, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "REVALIDOU").
    */                                
    update vdtir validate(vdtir >= today  and vdtir > ctpromoc.dtfim
                         ,"Data inicio não permitida")
                  label "Revalidar para" format "99/99/9999"
           with frame f-revalida.
    update vdtfr validate(vdtfr >= vdtir and
                          vdtfr <= date(if month(vdtir) = 12 then 01
                          else month(vdtir) + 1,01,if month(vdtir) = 12
                                then year(vdtir) + 1 else year(vdtir)) - 1 ,
                                        "Data final não permitida" )
                label "Ate"    format "99/99/9999"
                with frame f-revalida
                centered 1 down row 10 side-label.

    sresp = no.
    message "Confirma revalidar promocao ?" update sresp.
    if sresp
    then do:
        for each    rctpromoc where 
                    rctpromoc.sequencia = ctpromoc.sequencia  no-lock.
            create  tt-ctpromoc.
            buffer-copy rctpromoc to tt-ctpromoc.
        end.
        for each tt-ctpromoc where
                 tt-ctpromoc.sequencia = 0:
            delete tt-ctpromoc.
        end.             
        find last bctpromoc  where bctpromoc.linha = 0 no-error. 
        for each tt-ctpromoc:
            assign
                 tt-ctpromoc.sequencia = if avail bctpromoc
                        then bctpromoc.sequencia + 1 else 1
                 tt-ctpromoc.dtinicio = vdtir
                 tt-ctpromoc.dtfim = vdtfr
                 tt-ctpromoc.situacao = "M"
                .
        end.
        for each tt-ctpromoc:
            create rctpromoc.
            buffer-copy tt-ctpromoc to rctpromoc.
        end.
        /*
        raw-transfer ctpromoc to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "REVALIDAR").
        */
        message color red/with
            "Promocao revalidada" view-as alert-box.
    end. 
    hide frame f-revalida no-pause.
end procedure.

procedure clonar:
    message color red/with
        "Opcao esta bloqueada para revisao."
        view-as alert-box.
    /*****    
    def buffer rctpromoc for ctpromo.
    def buffer bctpromoc for ctpromoc.
    def var vdtir like tt-ctpromoc.dtinicio.
    def var vdtfr like tt-ctpromoc.dtfim.
    /*
    update vdtir validate(vdtir >= today  and vdtir > ctpromoc.dtfim
                         ,"Data inicio não permitida")
                  label "Revalidar para" format "99/99/9999"
           with frame f-revalida.
    update vdtfr validate(vdtfr >= vdtir and
                          vdtfr <= date(if month(vdtir) = 12 then 01
                          else month(vdtir) + 1,01,if month(vdtir) = 12
                                then year(vdtir) + 1 else year(vdtir)) - 1 ,
                                        "Data final não permitida" )
                label "Ate"    format "99/99/9999"
                with frame f-revalida
                centered 1 down row 10 side-label.
    */
    if today > ctpromoc.dtinicio
    then vdtir = today.
    else vdtir = ctpromoc.dtinicio.
    if today > ctpromoc.dtfim
    then vdtfr = today.
    else vdtfr = ctpromoc.dtfim.
    sresp = no.
    message "Confirma clonar promocao " ctpromoc.sequencia "?" update sresp.
    if sresp
    then do:
        /*
        create table-raw.
        raw-transfer ctpromoc to table-raw.registro1.
        run grava-tablog.p (input 1, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "CLONAR").
        */
        for each    rctpromoc where 
                    rctpromoc.sequencia = ctpromoc.sequencia  no-lock.
            create  tt-ctpromoc.
            buffer-copy rctpromoc to tt-ctpromoc.
        end.
        for each tt-ctpromoc where
                 tt-ctpromoc.sequencia = 0:
            delete tt-ctpromoc.
        end.             
        find last bctpromoc  where bctpromoc.linha = 0  no-error. 
        for each tt-ctpromoc:
            assign
                 tt-ctpromoc.sequencia = if avail bctpromoc
                        then bctpromoc.sequencia + 1 else 1
                 tt-ctpromoc.dtinicio = vdtir
                 tt-ctpromoc.dtfim = vdtfr
                 tt-ctpromoc.situacao = "M"
                .
        end.
        for each tt-ctpromoc:
            create rctpromoc.
            buffer-copy tt-ctpromoc to rctpromoc.
        end.
        /*
        raw-transfer ctpromoc to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", input "CLONAR").
        */
        message color red/with
            "Promocao clonada" bctpromoc.sequencia + 1 view-as alert-box.
    end. 
    hide frame f-conagem no-pause.
    ***/
end procedure.

procedure campanha:
    def buffer rctpromoc for ctpromo.
    def buffer bctpromoc for ctpromoc.
    def var vdtir like tt-ctpromoc.dtinicio.
    def var vdtfr like tt-ctpromoc.dtfim.
    
    disp   ctpromoc.acaocod label "Campanha"
           ctpromoc.segmentacao
           ctpromoc.publico
           ctpromoc.perfil
           ctpromoc.apelo
           ctpromoc.canal
           with frame f-campanha 1 column centered side-label
           row 10 overlay.

    if ctpromoc.situacao = "M"
    then do:
    update ctpromoc.acaocod label "Campanha"
           ctpromoc.segmentacao
           ctpromoc.publico
           ctpromoc.perfil
           ctpromoc.apelo
           ctpromoc.canal
           with frame f-campanha 1 down centered side-label
           row 10.
    end.
    else pause.
    hide frame f-campanha no-pause.
end procedure.

procedure mensagem:
    def buffer rctpromoc for ctpromo.
    def buffer bctpromoc for ctpromoc.
    def var vdtir like tt-ctpromoc.dtinicio.
    def var vdtfr like tt-ctpromoc.dtfim.
    def var vmens as char extent 6.

    disp  "  INFORME A MENSAGEM QUE APARECERA NA TELA DA VENDA  " 
        WITH FRAME FM1 NO-LABEL CENTERED ROW 7 NO-BOX
        COLOR MESSAGE .
    
    def var i as int.
    
    do i = 1 to 220:
        if i = 1
        then vmens[1] = substr(ctpromoc.campochar[1],i,40).
        if i = 42
        then vmens[2] = substr(ctpromoc.campochar[1],i,40).
        if i = 83
        then vmens[3] = substr(ctpromoc.campochar[1],i,40).
        if i = 124
        then vmens[4] = substr(ctpromoc.campochar[1],i,40).
        if i = 165
        then vmens[5] = substr(ctpromoc.campochar[1],i,40).
        if i = 206
        then vmens[6] = substr(ctpromoc.campochar[1],i,40).
    end.
    disp vmens[1] format "x(40)"
               vmens[2] format "x(40)"
               vmens[3] format "x(40)"
               vmens[4] format "x(40)"
               vmens[5] format "x(40)"
               vmens[6] format "x(40)"
           with frame f-mensagem centered side-label
           row 8 overlay no-label.
    if ctpromoc.situacao = "M"
    then do:
        update vmens[1] format "x(40)"
               vmens[2] format "x(40)"
               vmens[3] format "x(40)"
               vmens[4] format "x(40)"
               vmens[5] format "x(40)"
               vmens[6] format "x(40)"
           with frame f-mensagem.
        ctpromoc.campochar[1] = string(vmens[1],"x(40)") + "!" + 
                                string(vmens[2],"x(40)") + "!" +
                                string(vmens[3],"x(40)") + "!" + 
                                string(vmens[4],"x(40)") + "!" + 
                                string(vmens[5],"x(40)") + "!" +
                                string(vmens[6],"x(40)") .
    end.
    else pause.
    hide frame fm1 no-pause.
    hide frame f-mensagem no-pause.
end procedure.

procedure forne-despesa:
assign
        cod-forne = int(acha("FORNECEDOR",ctpromoc.campochar[2]))
        forne-vendedor   = int(acha("FORNE-VENDEDOR",ctpromoc.campochar[2]))
        forne-gerente    = int(acha("FORNE-GERENTE",ctpromoc.campochar[2]))
        forne-supervisor = int(acha("FORNE-SUPERVISOR",ctpromoc.campochar[2]))
        forne-promotor   = int(acha("FORNE-PROMOTOR",ctpromoc.campochar[2]))
        .
if sretorno = "altera"
then do.
    update cod-forne          label "FORNECEDOR PARA DESPESA --> GERAL     "
           forne-vendedor     label "                        --> VENDEDOR  "
           forne-gerente      label "                        --> GERENTE   "
           forne-supervisor   label "                        --> SUPERVISOR"
           forne-promotor     label "                        --> PROMOTOR  "
           with frame f-forne width 80 row 14 side-label overlay.
    
    ctpromoc.campochar[2] = "".
    if cod-forne <> ?
    then  ctpromoc.campochar[2] = "FORNECEDOR=" + string(cod-forne) + "|".
    if forne-vendedor <> ?
    then  
    ctpromoc.campochar[2] = ctpromoc.campochar[2] +
                    "FORNE-VENDEDOR=" + string(forne-vendedor) + "|".
    if forne-gerente <> ?
    then   ctpromoc.campochar[2] = ctpromoc.campochar[2] + 
                    "FORNE-GERENTE=" + string(forne-gerente) + "|".
    if forne-supervisor <> ?
    then   ctpromoc.campochar[2] = ctpromoc.campochar[2] +
                    "FORNE-SUPERVISOR=" + string(forne-supervisor) + "|".
    if forne-promotor <> ?
    then   ctpromoc.campochar[2] = ctpromoc.campochar[2] +
                    "FORNE-PROMOTOR=" + string(forne-promotor) + "|".
end.
else do.
    display    
           cod-forne          label "FORNECEDOR PARA DESPESA --> GERAL     "
           forne-vendedor     label "                        --> VENDEDOR  "
           forne-gerente      label "                        --> GERENTE   "
           forne-supervisor   label "                        --> SUPERVISOR"
           forne-promotor     label "                        --> PROMOTOR  "
           with frame f-forne width 80 row 14 side-label overlay.
    pause.
end.    
end  procedure.

procedure tipo-valor:

    def var vsel-sit1 as char format "x(15)" extent 3
        init["DINHEIRO","RECARGA",""].
    def var vmarca-sit1 as char format "x" extent 3.
    format "[" space(0) vmarca-sit1[1] space(0) "]"  
       vsel-sit1[1]             skip
       "[" space(0) vmarca-sit1[2] space(0) "]"  
       vsel-sit1[2]             skip
       "[" space(0) vmarca-sit1[3] space(0) "]"
       vsel-sit1[3]            skip
       with frame f-sel-sit1
       1 down  centered no-label row 12 overlay
       width 30.

    def var vtip-valor as char.

    vtip-valor = "DINHEIRO".
    def var vi as in init 0. 
    def var va as int init 0.    
    if vtip-valor = "DINHEIRO"
    then vi = 1.
    else if vtip-valor = "RECARGA"
        then vi = 2.
        else if vtip-valor = ""
            then vi = 3.
 
    if vi = 0
    then next.
    vmarca-sit1 = "".
    vmarca-sit1[vi] = "*".    
    disp     vmarca-sit1
         vsel-sit1 with frame f-sel-sit1.
    va = vi.    
                
    repeat:
        choose field vsel-sit1 with frame f-sel-sit1.
        vmarca-sit1[va] = "". 
        vmarca-sit1[frame-index] = "*".
        va = frame-index.    
                        
        disp vmarca-sit1 with frame f-sel-sit1.
    end.
    
    ctpromoc.campochar[3] = vsel-sit1[va] + "=SIM|".

end procedure.

procedure lib-20-22:
    /**
    for each tt-produ: delete tt-produ. end.

    for each pctpromoc where
                                 pctpromoc.sequencia = ctpromoc.sequencia and
                                 pctpromoc.linha > 0 and
                                 pctpromoc.clacod > 0 
                                  no-lock:
        if pctpromoc.situacao = "I" or
           pctpromoc.situacao = "E"
        then next.
         
        for each produ where produ.clacod = pctpromoc.clacod no-lock:
            create tt-produ.
            tt-produ.procod = produ.procod.
            tt-produ.preco = pctpromoc.precosugerido.
        end.

        for each clase where clase.clasup = pctpromoc.clacod no-lock:
            for each produ where produ.clacod = clase.clacod no-lock:
                create tt-produ.
                tt-produ.procod = produ.procod.
                tt-produ.preco = pctpromoc.precosugerido.
            end.
            for each bclase where bclase.clasup = clase.clacod no-lock:
                for each produ where 
                         produ.clacod = bclase.clacod no-lock:
                    create tt-produ.
                    tt-produ.procod = produ.procod.
                    tt-produ.preco = pctpromoc.precosugerido.
                end.
                for each cclase where cclase.clasup = bclase.clacod no-lock:
                    for each produ where 
                             produ.clacod = cclase.clacod no-lock:
                        create tt-produ.
                        tt-produ.procod = produ.procod.
                        tt-produ.preco = pctpromoc.precosugerido.
                    end.
                end.
            end.        
        end.
    end.
    for each tt-produ no-lock:
             
        disp "Aguarde.... " tt-produ.procod
                                    with frame f-pro1 row 16 1 down 
                                    no-label no-box.
                                pause 0.   

                find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod > 0 and
                                 fctpromoc.situacao <> "I" and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                if not avail fctpromoc
                then do:
                    for each estab no-lock:
                        find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod = estab.etbcod and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                        if avail fctpromoc then next.
                        
                        run cria-hispre.p(  input estab.etbcod,
                                        input tt-produ.procod,
                                        input 0,
                                        input tt-produ.preco,
                                        input 0, input vtime).
                     end.        
                end.                 
                else   
                for each fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod > 0 
                                  no-lock:
                    if pctpromoc.situacao = "I" or
                         pctpromoc.situacao = "E"
                    then next.  
                    
                    run cria-hispre.p(  input fctpromoc.etbcod,
                                        input tt-produ.procod,
                                        input 0,
                                        input tt-produ.preco,
                                        input 0, input vtime).
                end.
    end.
    **/
end procedure.
