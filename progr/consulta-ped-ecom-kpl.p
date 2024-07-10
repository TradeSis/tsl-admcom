

/*
*
*    pedecom.p    -    Esqueleto de Programacao    com esqvazio

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

def new shared temp-table tt-pedid like pedid.
def new shared temp-table tt-liped like liped.


/*
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
*/

def var esqcom1         as char format "x(14)" extent 5
   initial ["Busca Ped","Confirma Receb","Conf Check-Out" , "Conf Manual"
            , "Protocolo"].


def var esqcom2         as char format "x(12)" extent 5
            initial [" Excluir "," Lib. Pedido","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["  ",
             " Liberar Pedido ",
             " Cancelar Pedido ",
             " Consulta  da pedecom ",
             " Listagem  Geral de pedecom "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer bpedecom       for pedecom.
def buffer bpedid         for pedid.
def buffer bliped         for liped.
def var vpedecom         like pedecom.pednum.

def var vval-boletopag-aux    as char .

def var vcont        as integer.
def var vcep-aux     as char.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
form 
     pedecom.pednum   label "Pedido"                    colon 11          
     pedid.peddat     label "Data"                      colon 40         skip
     pedid.clfcod     label "Cliente"  format ">>>>>>>>>9"  colon 11            
     clien.clinom     label "Nome"     format "x(15)"       colon 40     skip
     pedecom.cidade       label "Cidade" format "x(20)"     colon 11
     pedecom.uf           label "UF"                    colon 40         skip
     pedecom.valfrete     label "Val.Frete"             colon 11
     pedecom.tipofrete    label "Tip.Frete"  format "x(15)"  colon 40    skip
     pedecom.formapagto   label "Form.Pagto" format "x(15)"  colon 11
     pedecom.qtdparcelas  label "Qtd.Parc."                  colon 40 skip
     pedecom.valor        label "Valor"                      colon 11        
     vval-boletopag-aux   label "Vl.Pag Boleto"              colon 40 skip
         with frame f-libera side-labels centered row 05.

                 
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find pedecom where recid(pedecom) = recatu1 no-lock.
    if not available pedecom
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(pedecom).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pedecom
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            
            find pedecom where recid(pedecom) = recatu1 no-lock.
            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(pedecom.pednum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(pedecom.pednum)
                                        else "".
            run color-message.
            choose field pedecom.pednum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail pedecom
                    then leave.
                    recatu1 = recid(pedecom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pedecom
                    then leave.
                    recatu1 = recid(pedecom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pedecom
                then next.
                color display white/red pedecom.pednum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.                        
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pedecom
                then next.
                color display white/red pedecom.pednum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if esqvazio
        then do:
        
            hide frame f-pedecom.

            display "(( Nao existem pedidos pendentes para o E-Commerce. ))"
                        with frame f-sem-pedidos color black/cyan
                                 no-box no-labels centered row 11.

            pause.
            return "end-error".
        
        end.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pedecom.pednum
                 pedecom.valor
                 with frame f-pedecom color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-pedecom on error undo.
                    create pedecom.
                    update pedecom.pednum.
                    recatu1 = recid(pedecom).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-pedecom.
                    disp pedecom.pednum
                         pedecom.valor
                         pedecom.pedtdc.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-pedecom on error undo.
                    find pedecom where
                            recid(pedecom) = recatu1 
                        exclusive.
                    update pedecom.pednum
                           pedecom.valor.
                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de " pedecom.pednum.
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next pedecom where true no-error.
                    if not available pedecom
                    then do:
                        find pedecom where recid(pedecom) = recatu1.
                        find prev pedecom where true no-error.
                    end.
                    recatu2 = if available pedecom
                              then recid(pedecom)
                              else ?.
                    find pedecom where recid(pedecom) = recatu1
                            exclusive.
                    delete pedecom.
                    recatu1 = recatu2.
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lpedecom.p (input 0).
                    else run lpedecom.p (input pedecom.pednum).
                    leave.
                end.
                if esqcom1[esqpos1] = " Liberar Pedido "
                then do with frame f-libera:
                    
                    release pedid.
                    release boletopag.
                    release clien.
                    
                    hide frame f-libera.
                    
                    find first pedid where pedid.etbcod = pedecom.etbcod
                                       and pedid.pedtdc = pedecom.pedtdc
                                       and pedid.pednum = pedecom.pednum
                                            no-lock no-error.

                    find first boletopag where boletopag.bolcod = pedid.pednum
                                              no-lock no-error.

                    find first clien where clien.clicod = pedid.clfcod
                                            no-lock no-error.

                    if not avail clien or pedid.clfcod <= 3
                    then do:
                    
                        message "Pedido " pedid.pednum
                                 " com codigo de Cliente inválido! Entre "                                      "em contato com o setor de TI." 
                                        view-as alert-box.
                                        
                        next bl-princ.                
                    
                    end.

                    if can-find (first bliped of pedid
                                 where bliped.lippreco = 0)
                    then do:
                        
                        message "Pedido " pedid.pednum
                                 " contem item com valor Zerado!" skip
                                 " Verifique se algum dos produtos possui "                                 " cadastro de produto complementar. " skip
                                 " ou entre em contato com o setor de TI." 
                                        view-as alert-box.
                                        
                        next bl-princ.                
                    
                    end.                    

                    if pedecom.tipofrete = ""
                    then do:
                    
                        message "Pedido " pedid.pednum
                                " com Tipo de Frete inválido! Entre "
                                "em contato com o setor de TI." 
                                        view-as alert-box.
                                        
                        next bl-princ.                
                    
                    end.
                    
                    assign vcont = 0.

                    do vcont = 1 to length(pedecom.cep):

                        assign vcep-aux = substr(pedecom.cep,vcont,1).
    
                        if vcep-aux <> "1"
                            and vcep-aux <> "2"
                            and vcep-aux <> "3"
                            and vcep-aux <> "4"
                            and vcep-aux <> "5"
                            and vcep-aux <> "6"
                            and vcep-aux <> "7"
                            and vcep-aux <> "8"
                            and vcep-aux <> "9"
                            and vcep-aux <> "0"
                        then do:
        
                       message "O campo CEP contém caracteres inválidos" skip  
                        "Entre em contato com o Setor de TI" view-as alert-box.          
                            next bl-princ.
            
                        end.    
   
                    end.
                    
                    if avail boletopag
                   then assign vval-boletopag-aux = string(boletopag.bolvalpag).
                   else assign vval-boletopag-aux = "".
                                    
                    display pedecom.pednum
                            pedid.peddat
                            pedid.clfcod
                            clien.clinom
                            pedecom.cidade
                            pedecom.uf
                            pedecom.valfrete
                            pedecom.tipofrete
                            pedecom.formapagto
                            pedecom.qtdparcelas
                            pedecom.valor
                            vval-boletopag-aux
                           with frame f-libera.
                     
                    for each liped where liped.pedtdc = pedid.pedtdc and
                                         liped.etbcod = pedid.etbcod and
                                         liped.pednum = pedid.pednum no-lock,
                                         
                        first produ where produ.procod = liped.procod no-lock:    
                       display
                            liped.procod        label "Cod."
                            produ.pronom        label "Nome"   format "x(40)"
                            liped.lipqtd        label "Qtde."
                            liped.lippreco      label "Preco"
                             with frame f-produtos-lib 5 down row 13 centered                                     title "Produtos".
 
                    end.
                    
                    sresp = no.

                    message "".
                    message "".
                    pause 0.
                    
                    if pedecom.formapagto = "boleto"
                    then do:    
                        
                        if not avail boletopag
                            or boletopag.bolvalpag
                                 <= (pedecom.valor + pedecom.valfrete - 10000.00)
                        then do:
                                 
                            message "O pedido ainda não foi pago, portanto não "                                     "pode ser liberado para listagem.".
                            pause.
                           
                        end.
                        else if boletopag.bolvalpag >= (pedecom.valor +                                                     pedecom.valfrete - 10000.00)
                                 and boletopag.bolvalpag < (pedecom.valor +
                                                    pedecom.valfrete)
                        then do:
                           
                           sresp = no. 
                            
                           message "ATENCAO! Este pedido NAO teve pagamento"                                   " total, Deseja liberar mesmo assim?"
                                   update sresp.
                           
                           if sresp
                           then do:
                           
                               run p-libera-ped.
                           
                               output to /admcom/work/guardian.031 append.
                               put today skip
                           "Inicio rodando DG031 " string(time,"hh:mm:ss") skip.
                            run /admcom/progr/dg031.p (input pedid.pednum).
                          put "Fim rodando DG031 " string(time,"hh:mm:ss") skip.
                                output close.
    

                           end.
                           pause.
                                                    
                        end.                            
                        else if boletopag.bolvalpag >= (pedecom.valor +
                                              pedecom.valfrete)
                        then do:

                            message "Deseja liberar este pedido para listagem?"                                     skip update sresp .
   
                            if sresp
                            then do:
                        
                                run p-libera-ped.
                                pause.
                                
                            end.
                            
                        end.

                    end. 
                    else do:
                    
                        sresp = no.
                        message "Deseja liberar este pedido para listagem?"                                 skip update sresp .
                                    
                        if sresp
                        then do:
             
                            run p-libera-ped.

                        end.

                        next bl-princ.
                        
                    end.
                    
                end.
                
                if esqcom1[esqpos1] = "Busca Ped"
                then do with frame f-busca-ped:
                
                    sresp = no.
                    message "Deseja Conectar no Ábacos e buscar novos pedidos?"
                                update sresp.
                                
                    if sresp
                    then do:
                
                        run /admcom/web/progr_e/busca_ped_disp.p.

                        next bl-princ.

                    end.
                
                end.
                
                if esqcom1[esqpos1] = "Confirma Receb"
                then do with frame f-conf-receb:
                
                    sresp = no.
                    message "Deseja confirmar o recebimento do Pedido "
                            pedid.pednum  "?"    
                                update sresp.
                                
                    if sresp
                    then do:
                
                        run /admcom/web/progr_e/confirma_receb_ped.p
                                        (input pedid.pednum,
                                         input pedid.pedtdc).

                        next bl-princ.

                    end.
                
                end.
                
                if esqcom1[esqpos1] = "Conf Check-Out"
                then do with frame f-conf-check-out:
                
                    sresp = no.
                    message "Deseja confirmar o Checkout do Pedido "
                            pedid.pednum  "?"    
                                update sresp.
                                
                    if sresp
                    then do:
                
                        assign sresp = no.
                        run /admcom/web/progr_e/finaliza-pedidos-abacos.p
                                        (input pedid.pednum,
                                         input pedid.pedtdc,
                                         output sresp).
                                         

                        next bl-princ.

                    end.
                
                end.
                
                if esqcom1[esqpos1] = "Conf Manual"
                then do with frame f-conf-manual:

                    run /admcom/web/progr_e/confirma_receb_ped_manual.p.

                    next bl-princ.
                
                end.
                if esqcom1[esqpos1] = "Protocolo"
                then do with frame f-protocolo:

                    message " Protocolo: "
                            acha("ProtocoloPedido",pedid.pedobs[1])
                                            view-as alert-box.

                end.
                
                if esqcom1[esqpos1] = " Cancelar Pedido "
                then do with frame f-libera:
                    find first pedid where pedid.etbcod = pedecom.etbcod
                                       and pedid.pedtdc = pedecom.pedtdc
                                       and pedid.pednum = pedecom.pednum
                                            no-lock no-error.

                    find first boletopag where boletopag.bolcod = pedid.pednum
                                              no-lock no-error.
                                              
                    find first clien where clien.clicod = pedid.clfcod
                                            no-lock no-error.

                    if avail boletopag
                   then assign vval-boletopag-aux = string(boletopag.bolvalpag).
                   else assign vval-boletopag-aux = "".
                    display pedecom.pednum
                            pedid.peddat
                            pedid.clfcod
                            clien.clinom
                            pedecom.cidade
                            pedecom.uf
                            pedecom.valfrete
                            pedecom.tipofrete
                            pedecom.formapagto
                            pedecom.qtdparcelas
                            pedecom.valor
                            vval-boletopag-aux
                     with frame f-libera.

                    for each liped where liped.pedtdc = pedid.pedtdc and
                                         liped.etbcod = pedid.etbcod and
                                         liped.pednum = pedid.pednum no-lock,

                        first produ where produ.procod = liped.procod no-lock:  
                        display liped.procod
                                produ.pronom
                                liped.lipqtd
                                liped.lippreco
                                    with frame f-produtos.
                    end.
                    
                    sresp = no.
                                        
                    message "Deseja cancelar o pedido?"
                    update sresp.
                    
                    if sresp
                    then do:
                                                            
                        find bpedid where rowid(bpedid) = rowid(pedid)
                                            exclusive-lock no-error.
                                            
                        if available bpedid
                        then do:
                        
                            bpedid.pedobs[3] = bpedid.pedobs[3]
                               + "|DATA_EXCLUSAO=" + string(today,"99/99/9999")
                               + "|HORA_EXCLUSAO=" + string(time,"HH:MM:SS")
                               + "|ETB_EXCLUSAO="  + string(setbcod)
                               + "|USUARIO_EXCLUSAO=" + string(sfuncod)
                               + "|PROG_EXCLUSAO=" + program-name(1)
                               + "|".
                    
                            assign bpedid.sitped = "C".
                        
                            run /admcom/progr/atu-status-pedecom.p (input pedecom.pednum,
                                input "Aprovação negada, pedido cancelado."). 
                            /*
                            next bl-princ.
                            */
                            leave.
                        end.


                    end.
                    else do:
                    
                        leave.
                    
                    end.
                                                
                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = " Lib. Pedido"
                then do with frame f-liberar-pedido-novo  row 5 1 column centered
                              on error undo.
                    sresp = no.
                                                            
                    run p-libera-ped.
                
                
                end.
                
                if esqcom2[esqpos2] = " Excluir "
                then do with frame f-exclusao  row 5 1 column centered
                        on error undo.
                    sresp = no.
                    
                    if acha("ProtocoloPedido",pedid.pedobs[1]) = ?
                    then do:
                    
                       message "Impossível excluir pedido do E-Commerce Atual"
                        view-as alert-box.
                        
                       undo, next bl-princ. 
                    
                    end.
                    
                    message "Use essa opção com muito cuidado, Deseja"
                                "excluir o pedido " pedid.pednum "?"
                    update sresp.
                    if not sresp
                    then undo, leave.
                    find next pedecom where true no-error.
                    if not available pedecom
                    then do:
                        find pedecom where recid(pedecom) = recatu1.
                        find prev pedecom where true no-error.
                    end.
                    recatu2 = if available pedecom
                              then recid(pedecom)
                              else ?.
                    find pedecom where recid(pedecom) = recatu1
                            exclusive.
                    
                    find first pedid where pedid.etbcod = pedecom.etbcod
                                       and pedid.pedtdc = pedecom.pedtdc
                                       and pedid.pednum = pedecom.pednum
                                                exclusive-lock no-error.

                    if avail pedid then                            
                    for each liped where liped.etbcod = pedid.etbcod
                                     and liped.pedtdc = pedid.pedtdc
                                     and liped.pednum = pedid.pednum
                                     and liped.predt = pedid.peddat
                                            exclusive-lock.

                        delete liped.

                    end.

                    if avail pedid
                    then delete pedid.
                                        
                    delete pedecom.
                    
                    recatu1 = recatu2.
                    leave.
                    
                end.
                
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedecom).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

define variable vcha-boleto-pago as character. /* guarda o asterisco dos boletos pagos*/

find first pedid where pedid.etbcod = pedecom.etbcod
                   and pedid.pedtdc = pedecom.pedtdc 
                   and pedid.pednum = pedecom.pednum no-lock no-error.     

find first clien where clien.clicod = pedid.clfcod no-lock no-error.

/********
find first boletopag where boletopag.bolcod = pedid.pednum no-lock no-error. 

if avail boletopag and boletopag.bolvalpag >= pedecom.valor + pedecom.valfrete
then assign vcha-boleto-pago = "*".
********/

display pedecom.pednum column-label "Ped."
        pedid.clfcod format ">>>>>>>>>9" column-label "Cod.Cli" when avail pedid
        clien.clinom format "x(20)" column-label "Nome"  when avail clien
        pedid.peddat column-label "Data"
        pedid.pedtdc format ">>>9" column-label "Tipo"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        pedecom.pednum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        pedecom.pednum
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first pedecom where can-find(first pedid
                                          where pedid.etbcod = pedecom.etbcod
                                            and pedid.pedtdc = pedecom.pedtdc
                                            and pedid.pednum = pedecom.pednum
                                            and pedid.sitped = "A")
                                                   no-lock no-error.
    else  
        find last pedecom  where can-find(first pedid
                                          where pedid.etbcod = pedecom.etbcod
                                            and pedid.pedtdc = pedecom.pedtdc
                                            and pedid.pednum = pedecom.pednum
                                            and pedid.sitped = "A")
                                                   no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next pedecom where can-find(first pedid
                                         where pedid.etbcod = pedecom.etbcod
                                           and pedid.pedtdc = pedecom.pedtdc
                                           and pedid.pednum = pedecom.pednum
                                           and pedid.sitped = "A")
                                                  no-lock no-error.
    else  
        find prev pedecom where can-find(first pedid
                                         where pedid.etbcod = pedecom.etbcod
                                           and pedid.pedtdc = pedecom.pedtdc
                                           and pedid.pednum = pedecom.pednum
                                           and pedid.sitped = "A")
                                                  no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev pedecom where can-find(first pedid
                                         where pedid.etbcod = pedecom.etbcod
                                           and pedid.pedtdc = pedecom.pedtdc
                                           and pedid.pednum = pedecom.pednum
                                           and pedid.sitped = "A")
                                                  no-lock no-error.
    else   
        find next pedecom where can-find(first pedid
                                         where pedid.etbcod = pedecom.etbcod
                                           and pedid.pedtdc = pedecom.pedtdc
                                           and pedid.pednum = pedecom.pednum
                                           and pedid.sitped = "A")
                                                  no-lock no-error.
        
end procedure.
         
         
procedure p-libera-ped:

    find bpedid where rowid(bpedid) = rowid(pedid)
                      exclusive-lock no-error.
                    
    if available bpedid
    then do:
                      
        assign bpedid.sitped = "E"
               bpedid.vencod = sfuncod.
                        
    end.
         
end procedure.         


