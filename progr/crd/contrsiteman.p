 /*      aberto
*
*    titulo.p    -    Esqueleto de Programacao    com esqvazio

* #1 Agosto/2017 - Rotina foi refeita com esquema
*/
{admcab.i}

def input parameter par-menu as char.

/**
def var vtotalproduto  as dec.
def var vpercitem      as dec.
def var vunititem      as dec.
**/
def var vtotoper as char.
def var vtotal as dec.

def buffer bcontrsitem for contrsitem.

def var vqtdemnota as int.
def var vmaxdevol as int.
def var vqtddevol as int.
def var wcodigoPedido like contrsite.codigoPedido.
def var vmenu as log.
/*def var vvlrabertopresente  as dec.*/

def new shared temp-table ttcancela no-undo
    field prec as recid
    field operacao as char    
    field qtddevol as int
    field valordevol as dec.
def buffer bttcancela for ttcancela.    
    
def new shared temp-table ttdevolve no-undo
    field prec as recid
    field qtddevol as int.
    
if par-menu <> "Menu"
then do.
    wcodigoPedido = par-menu no-error.
    if wcodigopedido <> ""
    then do.
        find contrsite where contrsite.codigoPedido = wcodigoPedido 
                      no-lock no-error.
        if avail contrsite
        then vmenu = yes.
    end.
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 5
    initial [" detalhes", "consulta "," ",""].

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels col 22.

form
    wcodigoPedido colon 13 validate (wcodigoPedido <> "", "")
    with frame f-contrsite1 width 80 title " Crediario Digital " side-label row 3.

repeat:
    if not vmenu
    then do with frame f-contrsite1.
        update wcodigoPedido.
        find contrsite where contrsite.codigoPedido = wcodigoPedido
                      no-lock no-error.
        if not available contrsite
        then do:
            message "contrsite nao cadastrado".
            undo,retry.
        end.
    end.
    
        find clien of contrsite no-lock no-error.
        find contrato of contrsite no-lock.
        display
            wcodigoPedido colon 13
                        contrsite.datatransacao label "Data"
            contrsite.etbcod  label "Fil"

            contrsite.clicod colon 13 label "Cliente"
                format ">>>>>>>>>9"
            clien.clinom no-label when avail clien format "x(41)"
            clien.ciccgc no-label when avail clien format "x(11)"
            contrato.contnum format ">>>>>>>>>>9" colon 13
            contrato.vltotal  
            contrsite.valorFrete colon 13
            contrsite.saldocredito
            
            with frame f-contrsite1.
    pause 0.

    run crd/acertacontrsitemov.p (input recid(contrsite)).

   
    assign
        recatu1 = ?
        esqpos1 = 1.

bl-princ:
repeat:
    pause 0.
        display
            wcodigoPedido colon 13
                        contrsite.datatransacao label "Data"
            contrsite.etbcod  label "Fil"

            contrsite.clicod colon 13 label "Cliente"
            clien.clinom no-label when avail clien format "x(41)"
            clien.ciccgc no-label when avail clien format "x(11)"
            contrato.contnum format ">>>>>>>>>>9" colon 13
            contrato.vltotal  
            contrsite.valorFrete colon 13
            contrsite.saldocredito
            
            with frame f-contrsite1.
    pause 0.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find contrsitem where recid(contrsitem) = recatu1 no-lock.

    if not available contrsitem
    then do.
        message "Sem contrsitems para o contrsite" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(contrsitem).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available contrsitem
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
                                              repeat with frame frame-a:

            find contrsitem where recid(contrsitem) = recatu1 no-lock.
            vqtdemnota = 0.
            for each contrsitmov of contrsitem no-lock.
                vqtdemnota = vqtdemnota + contrsitmov.qtd.
            end.
            find first ttcancela where ttcancela.operacao = "cancela" no-error. 
            find first bttcancela where bttcancela.operacao = "devolve" no-error.

            if avail bttcancela
            then do:
                esqcom1[3] = " simula".
            end.    
            else do: 
                esqcom1[2] = if contrsitem.qtd - vqtdemnota > 0 and contrsitem.qtd - contrsitem.qtddevol > 0
                         then " cancela"
                         else "".
            end.
            if avail ttcancela
            then do:
                esqcom1[3] = " simula".
            end.    
            else do:
                esqcom1[2] = if vqtdemnota > 0 and contrsitem.qtd - contrsitem.qtddevol > 0
                         then " devolve"
                         else esqcom1[2].
            end.
            disp esqcom1 with frame f-com1.                         

            vtotoper = "".
            vtotal = 0.
            for each ttcancela.
                vtotoper = ttcancela.operacao.
                vtotal   = vtotal + ttcancela.valordevol.
            end.
             
            if vtotal <> 0
            then
            disp 
                space(36)
                vtotoper  no-label
                vtotal    label " total devolver" format "-zzzz,zzz,zz9.99" 
 
                    with frame ftot
                        side-labels
                        row screen-lines - 1
                        width 80
                        no-box.



            
            status default "".
            run color-message.
            choose field contrsitem.codigoProduto help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
                    if not avail contrsitem
                    then leave.
                    recatu1 = recid(contrsitem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail contrsitem
                    then leave.
                    recatu1 = recid(contrsitem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail contrsitem
                then next.
                color display white/red contrsitem.codigoProduto with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail contrsitem
                then next.
                color display white/red contrsitem.codigoProduto with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            
            if esqcom1[esqpos1] = " simula"
            then do:
                hide frame frame-a no-pause.
                hide frame ftot no-pause.
                run crd/contrsitesimbai.p (recid(contrsite)).
                recatu1 = ?.
                leave.
            end.    
        
            
            if esqcom1[esqpos1] = " cancela "
            then do on error undo with frame fcancela
                    row 12 overlay color messages centered side-labels.
                
                
                /****
                vtotalproduto = 0.
                for each bcontrsitem of contrsite no-lock.
                    vtotalproduto = vtotalproduto + (bcontrsitem.valorunitario * bcontrsitem.qtd).
                end.
                vpercitem = (contrsitem.valorunitario * contrsitem.qtd) / vtotalproduto.
                vunititem = (contrato.vltotal * vpercitem) / contrsitem.qtd.   
                ***/
                
                vqtdemnota = 0.
                for each contrsitmov of contrsitem no-lock.
                    vqtdemnota = vqtdemnota + contrsitmov.qtd.
                end.
                
                vmaxdevol = contrsitem.qtd - contrsitem.qtddevol - vqtdemnota.
                pause 0.
                disp vmaxdevol label "maximo a devolver".
                update
                    vqtddevol label "devolver"
                        validate (input vqtddevol <= vmaxdevol and input vqtddevol >= 0,"qtd maxima atingida").
                find first ttcancela where ttcancela.prec = recid(contrsitem) no-error.
                if not avail ttcancela
                then do:
                    create ttcancela.
                    ttcancela.prec = recid(contrsitem).
                end.    
                ttcancela.operacao = trim(esqcom1[esqpos1]).
                ttcancela.qtddevol = vqtddevol.           

                /*era
                ttcancela.valordevol = round(ttcancela.qtddevol * vunititem ,2).
                */
                /**/
                ttcancela.valordevol = round(ttcancela.qtddevol * (contrsitem.valorPeso / contrsitem.qtd) ,2).
                /**/
                
                if ttcancela.qtddevol = 0
                then do:
                    delete ttcancela.    
                    recatu1 = ?.
                    leave.
                end.    
            end.
            if esqcom1[esqpos1] = " devolve "
            then do:
                run crd/contrsitemanmov.p (recid(contrsitem)).
                leave.
                        
            end.
            hide frame frame-a no-pause.

            if esqcom1[esqpos1] = " detalhes "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.  
                run crd/contrsitedet.p (recid(contrsite)).
                recatu1 = ?.
                 leave.
            end.

            view frame f-contrsite1.
            view frame f-com1.
            view frame frame-a.
            pause 0.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(contrsitem).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

if vmenu
then leave.

end. /* repeat */


procedure frame-a.
    vqtdemnota = 0.
    for each contrsitmov of contrsitem no-lock.
        vqtdemnota = vqtdemnota + contrsitmov.qtd.
    end.
    find first ttcancela where ttcancela.prec = recid(contrsitem) no-error.
    if avail ttcancela
    then do:
        
    end.    
    display
        contrsitem.codigoProduto column-label "cod"
        contrsitem.descricao format "x(30)"
        contrsitem.qtd           column-label "qtd"     format  ">>9"
        vqtdemnota               column-label "nf" format ">>9"
        contrsitem.qtddevol      column-label "dev"     format ">>9"
        /*
        contrsitem.valorunitario column-label "unit" format  ">>>>9.99"
        contrsitem.valortotal    column-label "total"   format ">>>>>9.99"
        **/
        space(4) "|"
        ttcancela.operacao format "x(8)" column-label "ope" when avail ttcancela
        
        ttcancela.qtddevol  column-label "qtd" format ">>9" when avail ttcancela
        ttcancela.valordevol column-label "valor" format ">>>>>9.99" when avail ttcancela
        
        with frame frame-a 7 down
              row 10 width 80
              overlay centered no-box.

end procedure.


procedure color-message.
color display message
        contrsitem.codigoProduto
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        contrsitem.codigoProduto
        with frame frame-a.
end procedure.


procedure leitura.
    def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then find first contrsitem of contrsite
                                                no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then find next contrsitem of contrsite
                                                no-lock no-error.
             
    if par-tipo = "up" 
    then find prev contrsitem of contrsite
                                        no-lock no-error.
end procedure.



