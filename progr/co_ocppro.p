/*
*
*    liped.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec   as recid.
def input parameter par-pai   as recid.

def work-table tt-liped
    field rec as recid.
    
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" 1.Inclusao", " 2.Preco "," 3.Quantidade "," 4.Exclui ",""].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def var vpreco like liped.lippreco.
def buffer bliped       for liped.
def var vtotal      like liped.lippreco.
def var vi          as int.

form
    esqcom1
    with frame f-com1
        row screen-lines no-box no-labels column 1 centered overlay.

form
    pedid.pedtot
    with frame f-pedtot width 80 side-label row 6 col 52 overlay no-box.

assign
    esqregua = yes
    esqpos1  = 1.
pause 0.
find pedid  where recid(pedid) = par-rec no-lock.
find categoria of pedid no-lock no-error.

/***
/* Verificar quais tipo de pedidos pedem pedem descricao */ 
find tipped of pedid no-lock.
if tipped.tprocod = int(paramsis("TPROCODUSAGRADE")) and
   not program-name(2) matches "*co/lipedgra*"
then do:
    run ./co/lipedgra.p (input recid(pedid)). 
    run totaliza.
    return.
end.

vtipos = paramsis("TIPPEDDESCRICAO").
if vtipos <> "?" then  do:
   do vi = 1 to num-entries(vtipos).
      if tipped.pedtdc = int(entry(vi, vtipos)) then do:
         vpeddescricao = yes.
         leave.
      end.   
   end.
end.      
***/

display " " format "x(30)" "P R O D U T O S" 
    with frame fprod centered width 80 no-box color message row 9 overlay.

display pedid.pedtot
    with frame f-pedtot.

run monta-tt.

procedure monta-tt.

    for each tt-liped.
        delete tt-liped.
    end.
        
    if par-pai = ?
    then do:
        for each liped of pedid no-lock.
            create tt-liped.
            tt-liped.rec = recid(liped).
        end.    
    end.
    else do:
        find lipedpai where recid(lipedpai) = par-pai no-lock.
        for each liped where liped.etbcod = lipedpai.etbcod
                         and liped.pedtdc = lipedpai.pedtdc
                         and liped.pednum = lipedpai.pednum
                         and liped.lipcor = string(lipedpai.paccod)
                   no-lock.
            create tt-liped.
            tt-liped.rec = recid(liped).
        end.
/***
        for each produ where produ.itecod = lipedpai.itecod no-lock.
            for each liped of pedid where liped.procod = produ.procod
                    no-lock.
                create tt-liped.
                tt-liped.rec = recid(liped).
            end.                
        end.     
***/
    end.

end procedure.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else
        find tt-liped where recid(tt-liped) = recatu1 no-lock.
    if not available tt-liped
    then do:
        esqvazio = yes.
        if pedid.sitped = "F" or pedid.sitped = "C"
        then leave.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    recatu1 = recid(tt-liped).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-liped
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then do:
        up frame-line(frame-a) - 1 with frame frame-a.
    end.
    
    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-liped where recid(tt-liped) = recatu1 no-lock.
            find liped where recid(liped) = tt-liped.rec no-lock.
            if par-pai = ?
            then do.
                find produ of liped no-lock.
                find fabri of produ no-lock.
                find cor of produ no-lock.
                disp "Produto: " + string(produ.procod) + " " + produ.pronom 
                                + " " + cor.cornom
                                + " " + produ.protam
                            @ produ.pronom /*liped.descricao[1]*/
                   fabri.fabcod fabri.fabnom no-label
                   with frame fsub row 19 overlay no-labels no-box width 70.
            end.
            else do.
                find produpai of lipedpai no-lock.
                find fabri of produ no-lock.
                disp "Produto: " + string(produpai.itecod) + " " +
                                  produpai.pronom @ produ.pronom
                   fabri.fabcod fabri.fabnom no-label
                   with frame fsub row 19 overlay no-labels no-box width 70.
            end.

            run frame-a.
            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then string(liped.procod)
                                        else "".

            color display message  
                        liped.procod 
                        /*produ.refer  */
                        produ.pronom      
                        liped.lipqtd  
                        /*liped.PreQtEnt  
                        liped.lipqtdcanc  */
                        vpreco            
                        vtotal            
                        liped.lipsit      with frame frame-a .
            
            choose field liped.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5  
                      PF4 F4 ESC return).
            color display normal
                        liped.procod 
                        /*produ.refer  */
                        produ.pronom      
                        produ.protam
                        produ.corcod
                        liped.lipqtd  
                        /*liped.PreQtEnt  
                        liped.lipqtdcanc  */
                        vpreco            
                        vtotal            
                        liped.lipsit      with frame frame-a . 

            status default "".

        end.
            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5"   
            then do:
                esqregua = yes.
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = int(keyfunction(lastkey)).
                color display message esqcom1[esqpos1] with frame f-com1.
            end.    
        {esquema.i &tabela = "tt-liped"
                   &campo  = "liped.procod"
                   &where  = " true "
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio or
           keyfunction(lastkey) = "1" or 
           keyfunction(lastkey) = "2" or 
           keyfunction(lastkey) = "3" or 
           keyfunction(lastkey) = "4" or 
           keyfunction(lastkey) = "5" or 
           keyfunction(lastkey) = "6" or 
           keyfunction(lastkey) = "7" or 
           keyfunction(lastkey) = "8" or 
           keyfunction(lastkey) = "9"  
        then do on error undo, retry on endkey undo, leave:
            form 
                 with frame f-liped 
                      centered side-label row 5 .

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            if  (esqcom1[esqpos1] = " 1.Inclusao " or
                esqvazio) 
            then do:
                if not esqvazio
                then if pedid.sitped = "F"
                     then return.
                hide frame frame-a no-pause.
                hide frame f-com1  no-pause.
                hide frame fsub    no-pause.
                sretorno = "".
                find categoria of pedid no-lock no-error.
                if avail categoria and categoria.grade
                then run co_lipedp.p (input recid(pedid),
                                      input ?,
                                      "").
                else run co_liped.p (input recid(pedid),
                                     input ?,
                                     "").    
                view frame frame-a.
                view frame f-com1.
                view frame fsub.
                run monta-tt.
                run totaliza.
                if sretorno <> ""
                then do:
                    find liped where recid(liped) = int(sretorno) no-lock
                                    no-error.
                    if avail liped 
                    then do:
                        find first tt-liped where tt-liped.rec = recid(liped)
                                            no-lock.
                        recatu1 = recid(tt-liped).
                    end. 
                    else recatu1 = ?.
                end.
                else 
                    recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " 2.Preco "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame fsub    no-pause.
                    run co_liped.p (input recid(pedid) , 
                                    input recid(liped)),
                                    "Alt").
                    view frame frame-a.
                    view frame f-com1 .
                    view frame fsub.
                    run totaliza.
                end.

                if esqcom1[esqpos1] = " 1.Consulta "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    hide frame fsub no-pause.
                    run co_liped.p (input par-rec,
                                    recid(liped),
                                    "Con").   
                    pause 0.
                    view frame frame-a.
                    view frame f-com1.
                    view frame fsub.
                    pause 0.
                end.
/***
                if esqcom1[esqpos1] = " 3.Quantidade " or
                   esqcom1[esqpos1] = " 3.Entregas"         
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    hide frame fsub no-pause.
                    run co/ocproen2.p (recid(liped)).
                    view frame frame-a.
                    view frame fsub.
                    view frame f-com1 .
                    if liped.lipsit = "A" then
                       run totaliza.
                       
                    if esqcom1[esqpos1] = " 3.Quantidade "
                    then do:
                        run frame-a.
                        run leitura (input "seg").
                        if not avail tt-liped
                        then leave.
                        if frame-line(frame-a) = frame-down(frame-a)
                        then scroll with frame frame-a.
                        else down with frame frame-a.
                        recatu1 = recid(liped).
                    end.
                end.
***/
                if esqcom1[esqpos1] = " 4.Exclui " and
                    pedid.sitped <> "F"
                then do.
                    find produ of liped no-lock.
                    recatu1 = recid(tt-liped).
                    message "Excluir o produto " Produ.procod "-" 
                            Trim(Produ.ProNom) "?" update sresp.
                    hide message no-pause.
                    if sresp 
                    then do:
                        run leitura (input "seg").
                        if not available tt-liped 
                        then do: 
                            find tt-liped where recid(tt-liped) = recatu1. 
                            run leitura (input "up").
                        end. 
                        recatu2 = if available tt-liped 
                                  then recid(tt-liped) 
                                  else ?.
                    end.
                    find tt-liped where recid(tt-liped) = recatu1.
                    if sresp
                    then do transaction.
                        find current liped.
/***
                        for each proenoc where 
                                        proenoc.etbped = Pedid.etbped
                                    and proenoc.pednum = Pedid.pednum
                                    and proenoc.pedtdc = Pedid.pedtdc
                                    and proenoc.procod = Liped.procod
                                     exclusive-lock:
                            delete proenoc.            
                        end.
**/
                        find pedid of liped no-lock.
                        delete liped.
                        delete tt-liped.
                        run co/verifsitoc.p (recid(pedid)).
                        run totaliza.
                        recatu1 = recatu2.
                        leave.
                    end.
                end.
                if esqcom1[esqpos1] = " 4.Cancela "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    find pedid of liped no-lock.
                    run co/occancela.p (?, recid(Liped)).
                    run co/verifsitoc.p (recid(pedid)).
                    view frame frame-a.
                    view frame f-com1 .
                    recatu1 = ?.
                    leave.
                end.

                if esqcom1[esqpos1] = " 5.Nota Fiscal "
                then do.
                    find pedid of liped no-lock.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    run co/ocproenocnf.p ( recid(pedid), liped.procod).
                    view frame frame-a.
                    view frame f-com1 .
                end.
              end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-liped).
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
hide frame fprod   no-pause.
hide frame fsub    no-pause.
pause 0.

Procedure frame-a.
    find liped where recid(liped) = tt-liped.rec no-lock.

if avail categoria and categoria.grade
then assign
    esqcom1 = ""
    esqcom1[1] = " 1.Consulta ".
else assign
    esqcom1[1] = if pedid.pedsit /*pedid.sitped <> "A" */
                 then " 1.Consulta "
                 else " 1.Inclusao "
    esqcom1[2] = if liped.lipsit <> "A" 
                 then ""
                 else " 2.Preco "
    esqcom1[3] = if liped.lipsit = "A"
                 then " 3.Quantidade"
                 else " 3.Entregas"
                
    esqcom1[4] = if pedid.sitped = "F" or pedid.sitped = "C" or 
                    liped.lipsit = "C" /*or liped.preqtent <> 0*/
                 then ""
                 else 
                   if pedid.pedsit = no /*pedid.sitped = "A"*/
                   then " 4.Exclui " 
                   else " 4.Cancela ".

       disp esqcom1 with frame f-com1.

/*        vtotal = liped.lipqtd  * liped.lippreco - liped.lipdes.*/
        vtotal = (liped.lipqtd * liped.lippreco) - liped.lipdes + liped.lipipi.
        find produ of liped no-lock.
        vpreco = (liped.lippreco - (liped.lipdes / liped.lipqtd)).
    display
        liped.procod     column-label "Codigo"
        produ.pronom     column-label "Descricao" format "x(24)"
        produ.protam
        produ.corcod
        liped.lipqtd     column-label "Qtd"       format ">>>9.99"
        liped.lipEnt     column-label "Entreg"    format ">>>9.99"
/***
            liped.lipqtdcanc column-label "Canc"      format ">>9.99"
***/
        vpreco           column-label "Preco"     format ">>>9.99"
        vtotal           column-label "Total"     format ">>>,>>9.99"
        liped.lipsit     column-label "" format "X(1)"
        with frame frame-a screen-lines - 15 down centered row 10 no-box
                overlay.
End Procedure.

procedure totaliza.

do on error undo.

   find current pedid exclusive.
   pedid.pedtot = 0.
   for each bliped of pedid no-lock.
      pedid.pedtot = pedid.pedtot + (bliped.lippreco * bliped.lipqtd)
                                  - bliped.lipdes + bliped.lipipi.
   end.
   find current pedid no-lock.

   display 
         pedid.pedtot
        with frame f-pedtot.
   pause 0.
end.

end procedure.


procedure leitura . 

def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-liped  no-lock no-error. 
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-liped  no-lock no-error. 
             
if par-tipo = "up" 
then find prev tt-liped  no-lock no-error.                 

end procedure.
 