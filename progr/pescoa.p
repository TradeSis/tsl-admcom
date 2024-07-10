/* helio 07022023 - https://trello.com/c/uAKaPFHH/973-pre%C3%A7os-integrando-apenas-at%C3%A9-a-loja-141
    na interface produtoloja, enviado datain para procedure de carga */
/* Projeto Melhorias Mix - Luciano      */
/* #1 TP 29168100 - 06.02.2019 */
/* #2 helio.neto 25.07.2019 - Planejamento - Consulta Prioridades */
{admcab.i}

def var recimp as recid.
def var fila as char.
def var vrel as char.
def var varquivo as char.
def shared var vestatual        like estoq.estatual format "->>>>9".
def shared var vestatual93      like estoq.estatual format "->>>>9".
def shared var vestatual96      like estoq.estatual format "->>>>9".
def shared var vint-ped-abertos like estoq.estatual format "->>>>9".

def buffer sclase for clase.
def var vestilo  as char format "x(30)".
def var vestacao as char format "x(15)".

def shared var vprocod as dec format ">>>>>>>>>>>>9".

def shared temp-table wpro
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field munic  like estab.munic format "x(20)"
    field prounven like produ.prounven
    field estvenda like estoq.estvenda
    field estcusto like estoq.estcusto
    field estatual like estoq.estatual
    field wreserva like estoq.estatual
    field estproper like estoq.estproper
    field estprodat like estoq.estprodat.

def var v-imagem as char.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(11)" extent 6.

find produ where produ.procod = int(vprocod) no-lock.

if produ.catcod = 41
then assign
    esqcom1[1] = "Imagem"  
    esqcom1[2] = "Imprimir"  
    esqcom1[3] = "Compra"  
    esqcom1[4] = " ".
else assign
    esqcom1[1] = "Prioridades"
    esqcom1[2] = "Imagem"  
    esqcom1[3] = "Imprimir"  
    esqcom1[4] = "Compra".

if not sremoto
then assign
    esqcom1[5] = "E-commerce"
    esqcom1[6] = "Ult.compra".
    
form
    esqcom1
    with frame f-com1 no-box no-labels column 1 centered row screen-lines.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find wpro where recid(wpro) = recatu1 no-lock.
    if not available wpro
    then do.
        message "Sem registros de estoque" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(wpro).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available wpro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find wpro where recid(wpro) = recatu1 no-lock.

            find first estoq where estoq.etbcod = wpro.etbcod and estoq.procod = int(vprocod) no-lock no-error.
            def var vhelp as char.
            vhelp = "".
            /* helio 07022023 */
            if avail estoq
            then do: 
                if estoq.dtaltpreco <> ?
                then do:
                    vhelp = "Datas Preco(" + string(estoq.dtaltpreco,"99/99/9999") + ")". 
                end.
                if estoq.dtaltprom <> ?
                then do:
                    vhelp = vhelp + " Promoc(" + string(estoq.dtaltpromo,"99/99/9999") + ")". 
                end.
                if estoq.datexp <> ?
                then do:
                    vhelp = vhelp + " Reg(" + string(estoq.datexp,"99/99/9999") + ")". 
                end.
                 
            end.    
            /**/
            status default vhelp.

            run color-message.
            choose field wpro.etbcod  help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) color white/black.
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail wpro
                    then leave.
                    recatu1 = recid(wpro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail wpro
                    then leave.
                    recatu1 = recid(wpro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail wpro
                then next.
                color display white/red 
                        wpro.etbcod 
                        wpro.munic with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail wpro
                then next.
                color display white/red 
                    wpro.etbcod
                    wpro.munic with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form wpro
                 with frame f-wpro color black/cyan
                      centered side-label row 5.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = "Prioridades"
            then do with frame f-liped on error undo.
                find produ where produ.procod = int(vprocod) no-lock.
                /*#1*/
                run abas/atende.p (input "TELA|" + 
                                   string(produ.procod)).
                /*#1*/                   
                /*#1 run reservpro.p (input "PROCOD=" + string(produ.procod)). */
                leave.
            end.
            if esqcom1[esqpos1] = "Imagem"
            then do with frame f-wpro on error undo.
                 v-imagem = "n:~\pro_im~\" + trim(string(vprocod)) + ".jpg".
                          
                 if search(v-imagem) = ? or opsys = "UNIX"
                 then do:
                    /**/
                    if opsys = "UNIX"
                    then do:
                        sparam = SESSION:PARAMETER.
                        if num-entries(sparam,";") > 1
                        then sparam = entry(2,sparam,";").
 
                            /*
                            message "sparam: " sparam view-as alert-box.
                            */
                        if sparam = "AniTA"
                        then do:
                            unix silent sh value("./img-anita " + "/Pro_Im/" + 
                                trim(string(vprocod)) + ".jpg " +
                                trim(string(vprocod)) + ".jpg").
                        end. 
                        else do:
                            message "Imagem nao Encontrada".
                            pause 2 no-message.
                        end.
                    end.
                 end.
                 else
                     os-command silent start value(v-imagem).
            end.

            if esqcom1[esqpos1] = "Imprimir"
            then do with frame f-wpro on error undo.
                run pro-imprimir.
                leave.
            end.
                
            if esqcom1[esqpos1] = "Compra"
            then do with frame f-wpro on error undo.
                run pro-compra.
                leave.
            end.
            if esqcom1[esqpos1] = "E-commerce"
            then do.
                hide frame f-com1 no-pause.
                hide frame f-ddd  no-pause.
                run pro_ecommerce.
                view frame f-com1.
                view frame f-ddd.
            end.
            if esqcom1[esqpos1] = "Ult.Compra"
            then do.
                find last movim where movim.procod = produ.procod
                                  and movim.movtdc = 4
                                no-lock no-error.
                if avail movim
                then do.
                    find plani where plani.etbcod = movim.etbcod
                                 and plani.placod = movim.placod
                               no-lock.
                    run not_consnota.p(recid(plani)).
                end.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(wpro).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    pause 0.
    find aux_estoq where aux_estoq.etbcod      = wpro.etbcod and
                     aux_estoq.procod      = int(vprocod) and
                     aux_estoq.Nome_Campo  = "PRICE_TYPE" 
                     no-lock no-error.
    display 
        wpro.etbcod column-label "Etb"
        wpro.munic    format "x(20)" column-label "Cidade"
        aux_estoq.Valor_Campo when avail aux_estoq no-label format "x"
        wpro.estvenda                column-label "Preco Venda"
        wpro.estatual column-label "Estoque" format "->>>>>9"
        (wpro.estatual - wpro.wreserva) 
            column-label "Disponivel" format "->>>>>9"
        wpro.estproper when wpro.estprodat >= today 
            column-label "Promocao" format ">,>>9.99" 
        wpro.estprodat when wpro.estprodat >= today  
            column-label "Periodo" 
        with frame frame-a 4 down centered color white/red row 12.

    hide frame f-ddd no-pause.
end procedure.

procedure color-message.
    color display message
        wpro.etbcod
        wpro.munic
        with frame frame-a.
    hide message no-pause.
    disp "Total ->" at 2
        (vestatual - vint-ped-abertos) format "->>>>9"  to 70 
        with frame f-ddd row 20 no-box side-labels.

end procedure.

procedure color-normal.
    color display normal
        wpro.etbcod
        wpro.munic
        with frame frame-a.
    hide frame f-ddd no-pause.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first wpro where true
                                                no-lock no-error.
    else  
        find last wpro  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next wpro  where true
                                                no-lock no-error.
    else  
        find prev wpro   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev wpro where true  
                                        no-lock no-error.
    else   
        find next wpro where true 
                                        no-lock no-error.
        
end procedure.
         

procedure pro-imprimir:

    sresp = yes.
    message "Confirma impressao da consulta" update sresp.
    if sresp
    then do:
        if opsys = "unix"
        then do:
            find first impress where 
                       impress.codimp = setbcod no-lock no-error. 
            if avail impress
            then do: 
                run acha_imp.p (input recid(impress),  
                                output recimp). 
                find impress where recid(impress) = recimp no-lock no-error.
                assign fila = string(impress.dfimp).
            end.    
        
            varquivo = "/admcom/relat/pesco" + string(time).
        end.    
        else assign fila = ""
                    varquivo = "l:\relat\pesco" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "100"
            &Page-Line = "0"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """SALDO DE PRODUTO"""
            &Width     = "100"
            &Form      = "frame f-cabcab"}
            
        find produ where produ.procod = int(vprocod) no-lock no-error.        
        display produ.procod
                produ.pronom with frame f-pro side-label width 80.
                
        for each wpro by wpro.etbcod:
            find estab where estab.etbcod = wpro.etbcod no-lock no-error.
            display wpro.etbcod
                    estab.munic  format "x(20)" column-label "Cidade"
                    wpro.estvenda  column-label "Preco!Venda"
                    wpro.estcusto  column-label "Preco!Custo"
                    wpro.estatual(total) 
                        column-label "Saldo!Estoque" format "->>>>>9"
/***                (wpro.estatual - wpro.wreserva) (total)
                        column-label "Saldo!Disponivel" format "->>>>>9" ***/
                    wpro.wreserva (total)
                        column-label "Pedidos" format "->>>>>9"
                    wpro.estproper when wpro.estprodat >= today
                       column-label "Promocao" format ">,>>9.99"
                    wpro.estprodat when wpro.estprodat >= today 
                    column-label "Periodo!Promocao" 
                            with width 130 frame f4 down.
        end.
     END.
     OUTPUT CLOSE.

     if opsys = "UNIX"
     then do:
        message "Deseja visualizar em tela?" update sresp.
        if not sresp
        then os-command silent lpr value(fila + " " + varquivo).
        else run visurel.p (input varquivo, input "").
     end.   
     else do:
        {mrod.i}
     end.
end.

def temp-table tt-ped
    field etbcod    like pedid.etbcod
    field pednum like pedid.pednum
    field data as date
    field entrega as date
    field qtd as int
    field lipent as int.
 

procedure pro-compra:
    for each tt-ped:
        delete tt-ped.
    end.  
    find produ where produ.procod = int(vprocod) no-lock no-error.
    
    /*** se alterar aqui alterar tabmbem interface ITIM 1008.p ***/
    for each liped where  liped.procod = produ.procod and
                                 liped.pedtdc = 1 and
                                 (liped.predtf = ? or
                                 liped.predtf >= today - 180) no-lock,
              first pedid of liped where pedid.pedsit = yes and
                            pedid.sitped <> "F"  and
                            pedid.peddat > today - 210   no-lock:
              
              /***              
              find first bpedid where 
                        (bpedid.pedtdc = 4 or
                         bpedid.pedtdc = 6) and
                         bpedid.pedsit = yes and
                         bpedid.comcod = pedid.pednum
                         no-lock no-error.
              if avail bpedid
              then next.
              ***/
        create tt-ped.
        assign
            tt-ped.etbcod  = liped.etbcod
            tt-ped.pednum = liped.pednum
            tt-ped.data   = liped.predt
            tt-ped.entrega = pedid.peddtf /*liped.predtf*/
            tt-ped.qtd     = liped.lipqtd
            tt-ped.lipent  = liped.lipent.
    end.
    find first tt-ped where tt-ped.pednum > 0 no-error. 
    if not avail tt-ped
    then do:
        message color red/with
         "Nenhum pedido de compra pendente encontrado."
         view-as alert-box.
    end.
    else do:
         for each tt-ped where tt-ped.pednum > 0:
            disp tt-ped.etbcod       column-label "Etb" format ">>>"
                 tt-ped.pednum    column-label "Pedido"
                 tt-ped.data      column-label "Data Pedido"
                 tt-ped.entrega   column-label "Previsao"
                 tt-ped.qtd(total) column-label "Qtd Ped." format ">>>>>>9"
              tt-ped.lipent(total) column-label "Qtd Ent." format ">>>>>>9"
                (tt-ped.qtd - tt-ped.lipent) (total) column-label "Saldo" 
                           format "->>>>>>9"
                with frame f-disp down centered overlay.      
        end.
        pause.
    end.
    hide frame f-disp.
end procedure.

/* #1 */

/*** helio 07022023
{/admcom/web/progr_e/expestoque.i}
***/
procedure pro_ecommerce.
/**** helio 07022023
    def var vestoque      as int format "->>>>>9".
    def var vestoq_depos  as int format "->>>>>9".
    def var vdisponivel   as int format "->>>>>9".
    def var vreservas     as int format "->>>>>9".

    run calc_estoque (output vestoque,
                      output vestoq_depos,
                      output vdisponivel,
                      output vreservas).

    find first produaux where produaux.nome_campo  = "exporta-e-com"
                          and produaux.Valor_Campo = "yes" 
                          and produaux.procod = produ.procod
                        no-lock no-error.

    disp
        produ.proipival = 0 label "Pedido Especial" format "Nao/Sim"
        produ.ind_vex label "VEX"
        with frame f-ecom side-label centered title " E-commerce ".

    if (produ.ind_vex and produ.catcod = 41) or
       produ.proipival = 1
    then disp vestoque label "Estoq.Enviado"
              with frame f-estoq1 with 1 col centered.

    else if produ.catcod <> 41
    then disp
            /*
            vestoq_depos colon 22 label "Estoq.Depos"
            skip(1)
            */
            vdisponivel  colon 22 label "Disponivel (+)"
            vreserv_ecom colon 22 label "Reserv.Ecom (+)"
            "Diminiu unidades (-): 2" at 2
            vestoque colon 22 label "Estoq.a Enviar"
            with frame f-ecom-31 with 1 col side-label centered.
    else disp
            vestoque label "Estoq.a Enviar" "(Res ECOM)"
            with frame f-ecom-41 side-label centered.

    disp produaux.tipo_campo format "x(60)" label "Ultimo envio"
         when avail produaux
         with frame f-produaux side-label no-box centered.

    if avail produaux
    then do.
        do on endkey undo.
            message "F3 reenvia o produto para o E-commerce".
            readkey.
            if keyfunction(lastkey) = "ENTER-MENUBAR"
            then do.
                message "Confirma liberar produto para integração com Abacos?"
                        update sresp.
                if sresp
                then do on error undo:
                    find first produaux
                                 where produaux.nome_campo  = "exporta-e-com"
                                   and produaux.Valor_Campo = "yes" 
                                   and produaux.procod = produ.procod.
                    produaux.tipo_campo = "".
                    message "Produto liberado para proxima integração."
                    view-as alert-box.
                end.
            end.
        end.
    end.    
    else pause.
***/
end procedure.

