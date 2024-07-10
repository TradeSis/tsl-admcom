/*      aberto
*
*    titulo.p    -    Esqueleto de Programacao    com esqvazio

* #1 Agosto/2017 - Rotina foi refeita com esquema
*/
{admcab.i}

def input parameter par-rec as recid.

def var vtotalproduto  as dec.
def var vpercitem      as dec.
def var vunititem      as dec.

def buffer bcontrsitem for contrsitem.

def var psaldo as dec.

    
find contrsite where recid(contrsite) = par-rec no-lock.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 4
    initial [" frete "," baixas"," contrato"," notas"].

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels col 32.

form
    contrsite.codigoPedido colon 13 
    with frame f-contrsite1 width 80 title " Crediario Digital " side-label row 3.

    form
        contrsitem.codigoProduto column-label "cod"
        contrsitem.descricao format "x(30)"
        contrsitem.qtd           column-label "qtd"     format  ">>9"
        contrsitem.valortotal    column-label "total"   format ">>>>9.99"
        contrsitem.valorFrete    column-label "frete"   format ">>>>9.99"
        contrsitem.valorAcres    column-label "acres"    format ">>>>9.99"
        contrsitem.valorPeso     column-label "financ"    format ">>>>9.99"
        

        
        with frame frame-a 7 down
              row 10 width 80
              overlay centered no-box.

    
        find clien of contrsite no-lock no-error.
        find contrato of contrsite no-lock.
        display
            contrsite.codigoPedido colon 13
                        contrsite.datatransacao label "Data"
            contrsite.etbcod  label "Fil"

            contrsite.clicod colon 13 label "Cliente"
                format ">>>>>>>>>9"
            clien.clinom no-label when avail clien format "x(41)"
            clien.ciccgc no-label when avail clien format "x(11)"
            contrato.contnum format ">>>>>>>>>>9" colon 13
            contrato.vltotal  
            contrsite.valorFrete  colon 13
            contrsite.saldocredito
            
            with frame f-contrsite1.
    pause 0.

   
    assign
        recatu1 = ?
        esqpos1 = 1.
def var vtotal as dec.
def var vfrete as dec.
def var vpeso as dec.
def var vacres as dec.
def var vdevol as int.
bl-princ:
repeat:
    vtotal = 0.
    vfrete = 0.
    vpeso = 0.
    vacres = 0.
    vdevol = 0.
        for each bcontrsitem of contrsite no-lock.
            vtotal = vtotal + bcontrsitem.valorTotal.
            vpeso  = vpeso  + bcontrsitem.valorPeso.
            vfrete = vfrete  + bcontrsitem.valorFrete.
            vacres = vacres  + bcontrsitem.valoracres.
            vdevol = vdevol + bcontrsitem.qtddevol.
         end.   
         if vdevol> 0 then esqcom1[1] = "".
         pause 0.
            disp 
                space(45)
                vtotal    no-label format ">>>>9.99"
                vFrete    no-label format ">>>>9.99"
                vacres    no-label format ">>>>9.99"
                vPeso     no-label format ">>>>9.99"
 
                    with frame ftot
                        row screen-lines - 1
                        width 80
                        no-box.
        if vfrete > contrsite.valorFrete
        then color disp messages vFrete with frame ftot.
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

            disp esqcom1 with frame f-com1.                         


            
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
                esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
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

            if esqcom1[esqpos1] = " frete"
            then do on error undo:
                find current contrsitem exclusive.
                update contrsitem.valorfrete 
                                with frame frame-a.
                
                run crd/acertacontrsitemov.p (input recid(contrsite)).
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " baixas"
            then do:
                hide frame ftot no-pause.
                run crd/contrsitebai.p (recid(contrsite)).
            
            end.
            if esqcom1[esqpos1] = " contrato "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.  
                run conco_v1701.p(input string(contrsite.contnum)).
            end.
            if esqcom1[esqpos1] = " notas "
            then do.
                find contrato where contrato.contnum = contrsite.contnum no-lock.
                pause 0.
                run con_ass.p (recid(contrato)).
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
hide frame ftot no-pause.



procedure frame-a.

    display
        contrsitem.codigoProduto
        contrsitem.descricao 
        contrsitem.qtd 
        contrsitem.valortotal  
        contrsitem.valorFrete 
        contrsitem.valorPeso  
        contrsitem.valoracres 
        with frame frame-a.

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





