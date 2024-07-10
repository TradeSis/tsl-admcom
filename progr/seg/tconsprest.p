/* helio 05122023 - INTEGRA플O DE NOVA합ES EFETIVAS DA CSLOG BOLETO - INTEGRA플O PARA O BI */
/* helio 14082023 - ajustes */
/* helio 26072023 NOVA플O COM ENTRADA (BOLETO) + SEGURO PRESTAMISTA . SOLU플O 3 */
{admcab.i}
def var ctitle      as char.

{seg/segprest.i new}

def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["parcelas","csv","","","",""].
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


/*
def var vsel as int.
def var vabe as dec.

def var vtotservico   as dec.
def var vtotsemmoda as dec.
def var vtotcommoda as dec.
def var vtotmoda as dec.
def var vqtdsemmoda as int format ">>>9".
def var vqtdcommoda as int format ">>>9".
def var vqtdmoda as int format ">>>9".

def var vtotsemnova as dec.
def var vtotcomnova as dec.
def var vtotnova as dec.
def var vqtdsemnova as int format ">>>9".
def var vqtdcomnova as int format ">>>9".
def var vqtdnova as int format ">>>9".

def var vtotsememp as dec.
def var vtotcomemp as dec.
def var vtotemp as dec.
def var vqtdsememp as int format ">>>9".
def var vqtdcomemp as int format ">>>9".
def var vqtdemp as int format ">>>9".



def var vqtdsemmoveis as int format ">>>9".
def var vqtdcommoveis as int format ">>>9".
def var vqtdmoveis as int format ">>>9".

def var vtotsemmoveis as dec.
def var vtotcommoveis as dec.
def var vtotmoveis as dec.
def var vtotmarcadomoda as dec.
def var vtotmarcadonova as dec.

def var vtotmarcadomoveis as dec.
def var vtotmarcado as dec.
def var vtotsem as dec.
def var vtotcom as dec.
def var vqtdservico as int format ">>>9".
def var vqtdsem as int format ">>>9".
def var vqtdcom as int format ">>>9".
*/

def var vclinom       as char.        

def var vdtini as date format "99/99/9999" label "Dia".
def var vdtfim as date format "99/99/9999" label "ate".


    form  

        contrato.etbcod
        contrato.dtinicial column-label "Emissao" format "999999"
         contrato.contnum format ">>>>>>>>>9"  
         contrato.modcod 
         contrato.tpcontrato 
         ttcontrato.certifi format "x(11)"
         ttcontrato.SeguroPrestamistaAutomatico format "Aut/  " column-label
                    "Seg"
         ttcontrato.catnom  column-label "Categ"
         contrato.vltotal
         ttcontrato.prseguro  format ">>>9.99" column-label "Seguro"
         

        with frame frame-a 12 down centered row 6
        no-box no-underline.


if true
then do:

    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

    vdtini = date(month(today),01,year(today)).
    vdtfim = today - 1.

    update
        vdtini
        vdtfim
        with frame fperiodo
        centered row 5
        side-labels.
   
   
   ctitle = ctitle + " / periodo: " + string(vdtini,"99/99/9999") + " a " + string(vdtfim,"99/99/9999").

end.    

disp 
    ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.
/*
disp "MARCADO" vtotmarcadomoda format "zzzzz9.99" label "   Moda"
             vtotmarcadomoveis format "zzzzz9.99" label " Moveis"
             vtotmarcadonova format "zzzzz9.99"  label  "Novacao"
                vtotmarcado    format "zzzzz9.99" label "Tot" 

skip "EMPREST"    vtotsememp format "zzzzzz9.99" label "Elegivel"
                   vtotcomemp format "zzzzzz9.99" label "Com Seguro"
                   vtotemp    format "zzzzzz9.99" label "Tot Emp" colon 65    
skip space(18)         vqtdsememp format "zzzzzz9" no-label /* "Qtd" */
                  space(16) vqtdcomemp format "zzzzzz9" no-label /*"Qtd"*/
   vqtdemp no-label /*"Qtd Tot"*/   format "zzzzzz9" colon 65


skip "NOVACAO"         vtotsemnova format "zzzzzz9.99" label "Elegivel"
                   vtotcomnova format "zzzzzz9.99" label "Com Seguro"
                   vtotnova    format "zzzzzz9.99" label "Tot nova" colon 65    
skip space(18)         vqtdsemnova format "zzzzzz9" no-label /* "Qtd" */
                  space(16) vqtdcomnova format "zzzzzz9" no-label /*"Qtd"*/
   vqtdnova no-label /*"Qtd Tot"*/   format "zzzzzz9" colon 65

 
 "   MODA"         vtotsemmoda format "zzzzzz9.99" label "Elegivel"
                   vtotcommoda format "zzzzzz9.99" label "Com Seguro"
                   vtotmoda    format "zzzzzz9.99" label "Tot Moda" colon 65    
skip space(18)         vqtdsemmoda format "zzzzzz9" no-label /* "Qtd" */
                  space(16) vqtdcommoda format "zzzzzz9" no-label /*"Qtd"*/
   vqtdmoda no-label /*"Qtd Tot"*/   format "zzzzzz9" colon 65

" MOVEIS"        vtotsemmoveis format "zzzzzz9.99" label "Elegivel"
                 vtotcommoveis format "zzzzzz9.99" label "Com Seguro"
                 vtotmoveis    format "zzzzzz9.99" label "Tot Moveis" colon 65 
skip space(18)         vqtdsemmoveis format "zzzzzz9" no-label /*"Qtd" */
                  space(16) vqtdcommoveis format "zzzzzz9" no-label /*"Qtd"*/
   vqtdmoveis no-label /*"Qtd Tot"*/   format "zzzzzz9" colon 65

"  TOTAL"              vtotsem format "zzzzzz9.99" 
                  label  "Elegivel"
                       vtotcom format "zzzzzz9.99" label "Com Seguro"
   vtotservico label "Total"   format "zzzzzz9.99" colon 65
skip space(18)         vqtdsem format "zzzzzz9" no-label /*"Qtd" */
                  space(16) vqtdcom format "zzzzzz9" no-label /*"Qtd"*/
   vqtdservico no-label /*"Qtd Tot"*/   format "zzzzzz9" colon 65
        with frame ftot
            side-labels
            row 11
            width 80
            no-box.
*/

empty temp-table ttcontrato.
message "Processando... ". 
run seg/pselsprest.p (input vdtini, input vdtfim).
hide message no-pause.


bl-princ:
repeat:

/*    
   vtotservico = 0.
   vtotcom = 0.
   vtotsem = 0.
   vqtdsem = 0.
   vqtdcom = 0.
   vqtdsemmoda = 0.
   vqtdcommoda = 0.
   vqtdmoda = 0.
   vqtdsemmoveis = 0.
   vqtdcommoveis = 0.
   vqtdmoveis = 0.
   
   vqtdservico = 0.
   vtotcommoda = 0.
   vtotsemmoda = 0.
   vtotmoda = 0.
   vtotcommoveis = 0.
   vtotsemmoveis = 0.
   vtotmoveis = 0.
   vtotmarcadomoveis = 0.
   vtotmarcadomoda = 0.
   vtotmarcado = 0.
   vtotmarcadonova = 0.
   
 vtotsemnova = 0.
 vtotcomnova = 0.
 vtotnova = 0.
 vqtdsemnova = 0.
 vqtdcomnova = 0.
 vqtdnova = 0.

 vtotsememp = 0.
 vtotcomemp = 0.
 vtotemp = 0.
 vqtdsememp = 0.
 vqtdcomemp = 0.
 vqtdemp = 0.

   
    for each ttcontrato.
        find contrato where recid(contrato) = ttcontrato.rec no-lock. 
        vtotservico = vtotservico + ttcontrato.valorTotalSeguroPrestamista.

        if ttcontrato.catnom = "MODA"
        then do:
            if ttcontrato.temseguro
            then do:
                vtotcommoda = vtotcommoda + ttcontrato.valorTotalSeguroPrestamista.
                vqtdcommoda = vqtdcommoda + 1.  
            end.
            else do:
                vtotsemmoda = vtotsemmoda + ttcontrato.valorTotalSeguroPrestamista.
                vqtdsemmoda = vqtdsemmoda + 1.
 
            end.
            vtotmoda = vtotmoda + ttcontrato.valorTotalSeguroPrestamista.
            vqtdmoda = vqtdmoda + 1.
            if ttcontrato.elegivel
            then vtotmarcadomoda = vtotmarcadomoda + ttcontrato.valorTotalSeguroPrestamista.  
        end.
        if ttcontrato.catnom = "moveis"
        then do:
            if ttcontrato.temseguro
            then do:
                vtotcommoveis = vtotcommoveis + ttcontrato.valorTotalSeguroPrestamista.
            vqtdcommoveis = vqtdcommoveis + 1.
                
            end.
            else do:
                vtotsemmoveis = vtotsemmoveis + ttcontrato.valorTotalSeguroPrestamista.
                vqtdsemmoveis = vqtdsemmoveis + 1.

            end.
            vtotmoveis = vtotmoveis + ttcontrato.valorTotalSeguroPrestamista.
            vqtdmoveis = vqtdmoveis + 1.
            
            if ttcontrato.elegivel
            then vtotmarcadomoveis = vtotmarcadomoveis + ttcontrato.valorTotalSeguroPrestamista.  

        end.
        if ttcontrato.catnom = "novacao"
        then do:
            if ttcontrato.temseguro
            then do:
                vtotcomnova = vtotcomnova + ttcontrato.valorTotalSeguroPrestamista.
            vqtdcomnova = vqtdcomnova + 1.
                
            end.
            else do:
                vtotsemnova = vtotsemnova + ttcontrato.valorTotalSeguroPrestamista.
                vqtdsemnova = vqtdsemnova + 1.

            end.
            vtotnova = vtotnova + ttcontrato.valorTotalSeguroPrestamista.
            vqtdnova = vqtdnova + 1.
            
            if ttcontrato.elegivel
            then vtotmarcadonova = vtotmarcadonova + ttcontrato.valorTotalSeguroPrestamista.  

        end.

        if ttcontrato.catnom = "emprestimo"
        then do:
            if ttcontrato.temseguro
            then do:
                vtotcomemp = vtotcomemp + ttcontrato.valorTotalSeguroPrestami~sta.
            vqtdcomemp = vqtdcomemp + 1.
                
            end.
            else do:
                vtotsememp = vtotsememp + ttcontrato.valorTotalSeguroPrestami~sta.
                vqtdsememp = vqtdsememp + 1.

            end.
            vtotemp = vtotemp + ttcontrato.valorTotalSeguroPrestamista.
            vqtdemp = vqtdemp + 1.
            

        end.

        if ttcontrato.elegivel
        then vtotmarcado = vtotmarcado + ttcontrato.valorTotalSeguroPrestamista.  
            if ttcontrato.temseguro
            then do:
                vtotcom = vtotcom + ttcontrato.valorTotalSeguroPrestamista.
                vqtdcom = vqtdcom + 1.
            end.
            else do:
                vtotsem = vtotsem + ttcontrato.valorTotalSeguroPrestamista.
                vqtdsem = vqtdsem + 1.
            end.

        vqtdservico = vqtdservico + 1.
    end.
           
    disp
        vtotmarcadomoveis vtotmarcadomoda vtotmarcado 
        vtotmarcadonova
         vtotsemnova vtotcomnova vtotnova
        vqtdsemnova vqtdcomnova vqtdnova
         vtotsememp vtotcomemp vtotemp
        vqtdsememp vqtdcomemp vqtdemp
        
         vtotsemmoda vtotcommoda vtotmoda
        vqtdsemmoda vqtdcommoda vqtdmoda
         
         vtotsemmoveis vtotcommoveis vtotmoveis
        vqtdsemmoveis vqtdcommoveis vqtdmoveis
         
        vtotcom
                 vtotsem
        vtotservico
        vqtdcom  vqtdsem vqtdservico
        with frame ftot.

    /*vtotsemmoda:label = "MODA " + string(vqtdsemmoda,"zzzzz9").
    */
**/
    

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
    if not available ttcontrato
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttcontrato).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcontrato
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
        find contrato where recid(contrato) = ttcontrato.rec no-lock.


        status default "".
        
                        
        /*             
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
    hide message no-pause.

    

        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field contrato.contnum
                      help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

        hide message no-pause.
                 
        pause 0. 

                                                                
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
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcontrato
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcontrato
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             /*if esqcom1[esqpos1] = "cancela"
             then do: 
                hide message no-pause.
                sresp = no.
                message "Confirma cancelamento adesao numero " contrato.contnum "?"
                    update sresp.
                if sresp
                then do:
                    run api/medcancelaadesao.p (recid(contrato)).
                    leave.
                end.
            end.
            */

            if esqcom1[esqpos1] = "parcelas"
            then do:
                pause 0.
                run conco_v1701.p (Input string(contrato.contnum)).

                disp 
                    ctitle 
                        with frame ftit.
                view frame ftot.                
            end.
            
            if esqcom1[esqpos1] = "csv"
            then run seg/pexpsprest.p (input "csv", input vdtini, input vdtfim).

        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcontrato).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.


    find contrato where recid(contrato) = ttcontrato.rec no-lock.

    display  
contrato.dtinicial
        contrato.etbcod
         contrato.contnum 
         contrato.modcod 
         contrato.tpcontrato
          contrato.vltotal
         ttcontrato.prseguro  
         ttcontrato.catnom  
        ttcontrato.certifi
        ttcontrato.SeguroPrestamistaAutomatico 
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
         contrato.contnum contrato.dtinicial
         contrato.modcod 
         contrato.tpcontrato 
         ttcontrato.prseguro 
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
         contrato.contnum                     contrato.dtinicial
         contrato.modcod 
         contrato.tpcontrato 
         ttcontrato.prseguro 
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
         contrato.contnum 
         contrato.modcod contrato.dtinicial
         contrato.tpcontrato 
         ttcontrato.prseguro 
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttcontrato where 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttcontrato where 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttcontrato where 
            no-lock no-error.

    end.  
        
end procedure.







 






