/* helio 16012023 - ajuste para incluir pasta de saida nos parametros */
/* helio 24112022 - correcoes */
/* 112022 - helio - campanhas seguro prestamista gratis */

{admcab.i}

def var ctitle      as char.

def temp-table ttcontrato no-undo
    field rec as recid
    field temseguro    as log
    field elegivel     as log format "*/ "
    field catnom       as char
    field valortotal   as dec
    field placod       as int
    field valorTotalSeguroPrestamista as dec
    field codigoSeguro as int
    field contnum      as int 
    field tpseguro as int
    field certifi      as char .
    
def buffer bttcontrato    for ttcontrato.
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["parcelas","elegiveis","marca","GERA","marca todos","desmarca todos"].
def var velegiveis as log.
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

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

def var vclinom       as char.        

def var vdtini as date format "99/99/9999" label "Dia".
def var vdtfim as date format "99/99/9999" label "ate".


    form  
       ttcontrato.elegivel  column-label "*"

        contrato.etbcod
        contrato.dtinicial column-label "Emissao"
         contrato.contnum format ">>>>>>>>>9"  
         contrato.modcod 
         contrato.tpcontrato 
         ttcontrato.temseguro format "Tem Seguro/Elegivel"
         ttcontrato.catnom  column-label "Categ"
         contrato.vlseguro  format ">>>9.99" column-label "Contrato"
         
         ttcontrato.valorTotalSeguroPrestamista format ">>>9.99" column-label "Seguro"

        with frame frame-a 5 down centered row 5
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
    vdtfim = vdtini.

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

empty temp-table ttcontrato.
message "Processando... ". 
run montatt.
hide message no-pause.


bl-princ:
repeat:
    
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
    /*    
    if contrato.titdescjur <> 0
    then do:
        if contrato.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" contrato.dtinc "de R$" trim(string(contrato.titvljur + contrato.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(contrato.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" contrato.dtinc "de R$" trim(string(contrato.titvljur + contrato.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(contrato.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */  
    

        if ttcontrato.temseguro
        then esqcom1[3] = "".
        else
            if ttcontrato.elegivel
            then esqcom1[3] = "desmarca".
            else esqcom1[3] = "marca". 
        
        find first bttcontrato where bttcontrato.temseguro = no and bttcontrato.elegivel = yes no-error.
        if avail bttcontrato
        then esqcom1[4] = "gerar".
        else esqcom1[4] = "".
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

            if esqcom1[esqpos1] = "marca" and ttcontrato.elegivel = no 
            then do:
                
                ttcontrato.elegivel = yes.
                if ttcontrato.catnom = "MODA"
                then     vtotmarcadomoda = vtotmarcadomoda + ttcontrato.valorTotalSeguroPrestamista.  
                if ttcontrato.catnom = "MOveis"
                then     vtotmarcadomoveis = vtotmarcadomoveis + ttcontrato.valorTotalSeguroPrestamista.  
                if ttcontrato.catnom = "NOVACAO"
                then     vtotmarcadonova = vtotmarcadonova + ttcontrato.val~orTotalSeguroPrestamista.  

                vtotmarcado = vtotmarcado + ttcontrato.valorTotalSeguroPrestamista.  
                disp
                    vtotmarcadomoda vtotmarcadomoveis vtotmarcado
                    vtotmarcadonova
                    with frame ftot.
                                
            end.
            if esqcom1[esqpos1] = "desmarca" and ttcontrato.elegivel = yes
            then do:
                ttcontrato.elegivel = no.
                if ttcontrato.catnom = "MODA"
                then     vtotmarcadomoda = vtotmarcadomoda - ttcontrato.valorTotalSeguroPrestamista.  
                if ttcontrato.catnom = "MOveis"
                then     vtotmarcadomoveis = vtotmarcadomoveis - ttcontrato.valorTotalSeguroPrestamista.  
                vtotmarcado = vtotmarcado - ttcontrato.valorTotalSeguroPrestamista.  
                if ttcontrato.catnom = "NOVACAO"
                then     vtotmarcadonova = vtotmarcadonova - ttcontrato.valorTotalSeguroPrestamista.  
                
                ttcontrato.elegivel = no.
                 disp
                                     vtotmarcadomoda vtotmarcadomoveis vtotmarcado
        vtotmarcadonova
                                                         with frame ftot.
                                                         
            end.
            if esqcom1[esqpos1] = "marca todos"
            then do:
                for each ttcontrato where ttcontrato.temseguro = no.
                    ttcontrato.elegivel = yes.
                end.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = "desmarca todos"
            then do:
                for each ttcontrato where ttcontrato.temseguro = no.
                    ttcontrato.elegivel = no.
                end.
                recatu1 = ?.
                leave.
            end.
            

            
            if esqcom1[esqpos1] = "elegiveis"
            then do:
                velegiveis = yes.
                recatu1 = ?.
                esqcom1[esqpos1] = "todos".
                leave.
            end.
            if esqcom1[esqpos1] = "todos"
            then do:
                velegiveis = no.
                recatu1 = ?.
                esqcom1[esqpos1] = "elegiveis".
                leave.
            end.

            if esqcom1[esqpos1] = "parcelas"
            then do:
                pause 0.
                run conco_v1701.p (Input string(contrato.contnum)).

                disp 
                    ctitle 
                        with frame ftit.
                view frame ftot.                
            end.

            if esqcom1[esqpos1] = "gerar"
            then do:
                message "confirma gerar seguro prestamista para contratos marcados?" update sresp.
                if sresp
                then do:
                    run pgerar.
                    empty temp-table ttcontrato.
                    run montatt.
                    velegiveis = no.
                    recatu1 = ?.
                    leave.
                end.
            end.
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
       ttcontrato.elegivel 
contrato.dtinicial
        contrato.etbcod
         contrato.contnum 
         contrato.modcod 
         contrato.tpcontrato 
         contrato.vlseguro  
         ttcontrato.temseguro when ttcontrato.temseguro <> ? 
         ttcontrato.catnom  
         ttcontrato.valorTotalSeguroPrestamista 

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
         contrato.contnum contrato.dtinicial
         contrato.modcod 
         contrato.tpcontrato 
         contrato.vlseguro 
         ttcontrato.temseguro 
         ttcontrato.elegivel
         ttcontrato.valorTotalSeguroPrestamista
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
         contrato.contnum                     contrato.dtinicial
         contrato.modcod 
         contrato.tpcontrato 
         contrato.vlseguro 
         ttcontrato.temseguro 
         ttcontrato.elegivel
         ttcontrato.valorTotalSeguroPrestamista
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
         contrato.contnum 
         contrato.modcod contrato.dtinicial
         contrato.tpcontrato 
         contrato.vlseguro 
         ttcontrato.temseguro 
         ttcontrato.elegivel
         ttcontrato.valorTotalSeguroPrestamista
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttcontrato where (if velegiveis then ttcontrato.temseguro = no else true)
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttcontrato where (if velegiveis then ttcontrato.temseguro = no else true)
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttcontrato where (if velegiveis then ttcontrato.temseguro = no else true)
            no-lock no-error.

    end.  
        
end procedure.








procedure montatt.

def var vqtdpar as int.
for each contrato where contrato.dtinicial >= vdtini and dtinicial <= vdtfim
    no-lock.

    if contrato.etbcod < 500
    then.
    else next.
    /*
    if contrato.tpcontrato = "N" or contrato.modcod = "CPN"
    then next.
    */
    /* helio 24112022 - ajustes
    if contrato.modcod begins "CP"
    then next.
    */
    
    vqtdpar = 0.
    for each titulo where titnat = no and 
        titulo.clifor = contrato.clicod and
        titulo.titnum = string(contrato.contnum) no-lock.
        if titulo.titpar = 0 then next.
        vqtdpar = vqtdpar + 1.        
    end.
    if vqtdpar = 0
    then next.
    
    create ttcontrato.
    ttcontrato.contnum      = contrato.contnum.
    ttcontrato.rec         = recid(contrato).
    ttcontrato.temseguro    = ?.
    ttcontrato.elegivel     = no.

    ttcontrato.tpseguro = 1.
    /* helio 24112022 - correcoes */
    if contrato.modcod = "CP1" or contrato.modcod = "CP0"
    then do:
        if contrato.vlseguro = 0
        then do:
            delete ttcontrato.
            next.
        end.
        ttcontrato.catnom = "EMPRESTIMO".
        ttcontrato.elegivel     = no.
        ttcontrato.valortotal   = contrato.vltotal. 
        ttcontrato.tpseguro = 3.
    end.    
    /**/
    
    if contrato.tpcontrato = "N" or contrato.modcod = "CPN"
    then do:    
        ttcontrato.catnom = "NOVACAO".
        ttcontrato.valortotal   = contrato.vltotal. 
    end.
    else ttcontrato.valortotal   = 0.            
    ttcontrato.placod       = ?.   
    ttcontrato.valorTotalSeguroPrestamista = 0.

    for each vndseguro where vndseguro.contnum = contrato.contnum and
                             vndseguro.tpseguro = ttcontrato.tpseguro no-lock.
        ttcontrato.temseguro = yes.
        ttcontrato.valorTotalSeguroPrestamista  = ttcontrato.valorTotalSeguroPrestamista + vndseguro.prseguro.
        ttcontrato.certifi  = vndseguro.certifi.   
    end.
    
        for each contnf where contnf.etbcod = contrato.etbcod and
                              contnf.contnum = contrato.contnum no-lock.
            find first plani where plani.etbcod = contnf.etbcod and
                                   plani.placod = contnf.placod
                                     no-lock no-error.
            if avail plani
            then do:
                ttcontrato.placod = plani.placod.
                for each movim where movim.etbcod = plani.etbcod and
                                    movim.placod  = plani.placod
                                    no-lock .
                    find produ of movim no-lock no-error.
                    if avail produ
                    then do:
                        find categoria of produ no-lock no-error.
                        if avail categoria
                        then do:
                            if produ.catcod = 31 or produ.catcod = 41
                            then do:
                                if ttcontrato.catnom = ""
                                then ttcontrato.catnom = trim(categoria.catnom).
                                ttcontrato.valortotal = ttcontrato.valortotal + (movim.movqtm * movim.movpc) - movim.movdes.
                            end.    
                            if produ.procod = 8011 or produ.procod = 8015 or produ.procod = 8012
                            then do:
                                 ttcontrato.valortotal =  ttcontrato.valortotal + (movim.movqtm * movim.movpc) - movim.movdes.
                            end.
                        end.
                    end.         
                end.                                    
            end.
        end.        
    
    if ttcontrato.temseguro = ? or ttcontrato.temseguro = no
    then do:
        
        if ttcontrato.catnom <> ""
        then do: 
            find first segprestpar where 
                        segprestpar.tpseguro  = ttcontrato.tpseguro and
                        segprestpar.categoria = 
                                (if ttcontrato.catnom = "NOVACAO"
                                 then "MOVEIS"
                                 else ttcontrato.catnom ) and
                        segprestpar.etbcod    = contrato.etbcod
                    no-lock no-error.
            if not avail segprestpar
            then do:
                    find first segprestpar where 
                            segprestpar.tpseguro  = ttcontrato.tpseguro and
                            segprestpar.categoria = 
                                 (if ttcontrato.catnom = "NOVACAO"
                                 then "MOVEIS"
                                 else ttcontrato.catnom ) and
                            segprestpar.etbcod    = 0
                        no-lock no-error.
            end.     
                
                        
            if avail segprestpar 
            then do: 
                ttcontrato.codigoSeguro = segprestpar.codigoSeguro.
                    
                if segprestpar.valorPorParcela > 0 
                then ttcontrato.valorTotalSeguroPrestamista     = (contrato.nro_parcelas * segprestpar.valorPorParcela). 
                else ttcontrato.valorTotalSeguroPrestamista    = ttcontrato.valortotal * segprestpar.percentualSeguro / 100. 
                ttcontrato.valorTotalSeguroPrestamista = truncate(ttcontrato.valorTotalSeguroPrestamista,2).                        
                ttcontrato.elegivel = yes.
                ttcontrato.temseguro = no. 
            end.
            
        
        end.
        
          
    end.
    
    /* helio 24112022 - correcoes */
    if (ttcontrato.catnom = "NOVACAO" or
        ttcontrato.catnom = "MOVEIS"  or
        ttcontrato.catnom = "MODA" or
        ttcontrato.catnom = "EMPRESTIMO") or
       ttcontrato.temseguro 
    then.
    else delete ttcontrato.
    /**/

end.



end procedure.



 



procedure pgerar.

def var pnumeroApolice as char.
def var pnumeroSorteio as char.

def var precseguro as recid.

    for each ttcontrato where ttcontrato.elegivel = yes.
        find contrato where recid(contrato) = ttcontrato.rec no-lock.
                       
            find plani where plani.etbcod = contrato.etbcod and    
                            plani.placod  = ttcontrato.placod 
                            no-lock no-error.

            run gera-certificado ( input ttcontrato.tpseguro,
                                   input ttcontrato.codigoSeguro,
                                   output pnumeroApolice,
                                   output pnumeroSorteio).
                                                      
            run gera-seguro (input recid(plani),
                             input ttcontrato.codigoSeguro,
                             input pnumeroApolice,
                             input pnumeroSorteio,
                             input ttcontrato.valorTotalSeguroPrestamista,
                             output precseguro).
            /* helio 16012023 - retirada para incluir pasta de saida nos parametros
            * run termo/imptermoseguro.p (input precseguro,0).
            */
            /* helio 16012023 */
            run termo/imptermoseguro.p (recid(vndseguro), 1, "/admcom/relat-prestamista/").
            
            
        end.



end procedure.



procedure gera-certificado.
def input param vtpseguro as int.
def input param pcodigoSeguro as int.
def output param vcertifi as char.
def output param vnsorte  as char.

def var vdtinimes as date.
def var vdtfimmes as date.

        if pcodigoSeguro = 559910 or
           pcodigoSeguro = 559911 or
           pcodigoSeguro = 578790 or
           pcodigoSeguro = 579359
        then do on error undo.
            /* Gerar Numero do Certificado */
            find geraseguro where geraseguro.tpseguro = 
                            (if vtpseguro = 1
                            then 2
                            else 3)
                              and geraseguro.etbcod = contrato.etbcod
                exclusive-lock 
                no-wait 
                no-error.
            if not avail geraseguro
            then do:
                if not locked geraseguro
                then do.
                    create geraseguro.
                    assign
                        geraseguro.tpseguro = if vtpseguro = 1
                                              then 2
                                              else 3
                        geraseguro.etbcod   = contrato.etbcod.
                end.
                /*
                else do: /** LOCADO **/
                    vstatus = "E".
                    vmensagem_erro = "Tente Novamente".
                end.
                */
            end.
            else do:
                assign
                    geraseguro.sequencia = geraseguro.sequencia + 1.
                vcertifi = string(contrato.etbcod, "999") +
                       "2" /* tpserv P2K */ +
                       string(geraseguro.sequencia, "9999999").
                find current geraseguro no-lock.
            end.
        end.
    
    if pcodigoSeguro = 559911 or
       pcodigoSeguro = 578790 or
       pcodigoSeguro = 579359
    then do:
        vdtinimes = date(month(contrato.dtinicial),1,year(contrato.dtinicial)).
        vdtfimmes = date(if month(contrato.dtinicial) + 1 > 12 then 1 else month(contrato.dtinicial) + 1,
                         1,
                         if month(contrato.dtinicial) + 1 > 12
                         then year(contrato.dtinicial) + 1 else year(contrato.dtinicial))
                         - 1.

        do on error undo.
            find first segnumsorte use-index venda-ordem /*#1venda*/
                where segnumsorte.dtivig = vdtinimes and
                      segnumsorte.dtfvig = vdtfimmes and
                      segnumsorte.dtuso  = ?
                exclusive-lock
                no-wait 
                no-error.
            if not avail segnumsorte
            then do:
                /*
                if not locked segnumsorte
                then assign /* INEXISTENTE **/
                        vstatus = "E"
                        vmensagem_erro = "Numeros da sorte esgotados".
                else assign /** LOCADO **/
                        vstatus = "E"
                        vmensagem_erro = "Tente Novamente".
                */                        
            end.
            else do:
                assign
                    segnumsorte.dtuso   = today
                    segnumsorte.hruso   = time
                    segnumsorte.etbcod  = contrato.etbcod
                    segnumsorte.contnum = contrato.contnum
                    segnumsorte.certifi = vcertifi
                    /*
                    segnumsorte.nsu     = int(buscadadoscontratonf.nsu_venda)
                    segnumsorte.cxacod  = int(buscadadoscontratonf.numero_pdv)*/ .
                vnsorte = string(segnumsorte.serie,"999") +
                          string(segnumsorte.nsorteio,"99999").
                find current segnumsorte no-lock.
            end.
        end.            
    end.
end procedure.



procedure gera-seguro.
    def input param pplani as recid.
    def input param pcodigoSeguro as int.
    def input param pnumeroApolice as char.
    def input param pnumeroSorteio as char.
    def input param pvalorSeguro as dec.
    def output param precseguro as recid.
    
    
    find plani where recid(plani) = pplani no-lock no-error.
                    
                create vndseguro.  
                precseguro = recid(vndseguro).
                
                vndseguro.tpseguro = ttcontrato.tpseguro. 
                vndseguro.certifi  = string(dec(pnumeroApolice),"9999999999999999").  
                vndseguro.etbcod   = contrato.etbcod.

                assign  
                    vndseguro.placod   = if avail plani
                                         then plani.placod
                                         else ?.

                    vndseguro.prseguro = dec(pvalorSeguro).
                    vndseguro.pladat   = contrato.dtinicial .
                    vndseguro.dtincl   = contrato.dtinicial .
                    vndseguro.procod   = int(pcodigoSeguro).
                    vndseguro.clicod   = contrato.clicod.
                                        /* helio 24112022 ajustes
                                        if avail plani
                                         then plani.desti
                                         else if avail contrato
                                              then contrato.clicod
                                              else ?.
                                        */
                    vndseguro.codsegur = 9839.
                    vndseguro.contnum  = int(contrato.contnum) .
                    vndseguro.dtivig   = contrato.dtinicial.
                    vndseguro.dtfvig   = date(month(contrato.dtinicial),day(contrato.dtinicial),year(contrato.dtinicial) + 1).
                    vndseguro.datexp   = today .
                    vndseguro.exportado = no. 
                    vndseguro.numerosorte = pnumeroSorteio .
                    
                /*
                vmovseq = vmovseq + 1.
                create movim.
                assign
                    movim.movtdc = plani.movtdc
                    movim.etbcod = plani.etbcod
                    movim.placod = plani.placod
                    movim.emite  = plani.emite
                    movim.desti  = plani.desti
                    movim.movdat = plani.pladat
                    movim.movhr  = plani.horincl
                    movim.movseq = vmovseq
                    movim.procod = vndseguro.procod
                    movim.movqtm = 1
                    movim.movpc  = vndseguro.prseguro
                    movim.movalicms = 98 /* #3 */.
                 **/

 


end procedure.




