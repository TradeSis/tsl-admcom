{admcab.i}

def var vtot like plani.platot format ">>,>>>,>>9.99".
def var vano as int format "9999".
def var vmes as int format "99".
def var vv as char format "x".
def var vtipo as l format "Entrada/Saida" initial no.
def var vtitnum like titulo.titnum.
def var vetbcod like estab.etbcod.
def var vnumlan as int.
def var vdata like plani.pladat.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Transfere ","","","",""].


/*if setbcod = 999 and sfuncod = 101
then*/ /*esqcom2[1] = " Ajusta".*/

def buffer bctbhie       for ctbhie.


    form
        esqcom1
            with frame f-com1
                  no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
repeat:
    hide frame frame-a no-pause.
    recatu1 = ?.

    update vetbcod label "Filial...... "
           with frame f-etb centered color blue/cyan side-labels
                    width 80.
        
    if vetbcod = 0  then undo.

    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-etb. 

    update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f-etb.
 
     
def var tot-qtd as dec.
def var tot-ctm as dec.

def buffer dctbhie for ctbhie.

bl-princ:
repeat:
    tot-qtd = 0. tot-ctm = 0.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first ctbhie where ctbhie.etbcod = vetbcod and
                                ctbhie.ctbmes = vmes    and
                                ctbhie.ctbano = vano 
                                no-lock no-error.
    else
        find ctbhie where recid(ctbhie) = recatu1 no-lock.
    vinicio = yes.
    if not available ctbhie
    then do:
        message "Tabela de ctbhie Vazia".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create ctbhie.
                update ctbhie.

                vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find produ where produ.procod = ctbhie.procod no-lock.
    
    display ctbhie.procod
            produ.pronom format "x(33)"
            produ.catcod column-label "Dep"
            ctbhie.ctbest column-label "Qtd" format ">>,>>9.99"
            ctbhie.ctbcus column-label "Custo" format ">>,>>9.99"
            (ctbhie.ctbest * ctbhie.ctbcus) @ vtot
                 with frame frame-a 8 down width 80 overlay
                 .

    recatu1 = recid(ctbhie).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    pause 0.
    repeat:
        find next ctbhie where ctbhie.etbcod = vetbcod and
                               ctbhie.ctbmes = vmes    and
                               ctbhie.ctbano = vano no-lock no-error.
        if not available ctbhie
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.

        find produ where produ.procod = ctbhie.procod no-lock.
        display ctbhie.procod
                produ.pronom
                produ.catcod
                ctbhie.ctbest
                ctbhie.ctbcus
                (ctbhie.ctbest * ctbhie.ctbcus) @ vtot
                     with frame frame-a.
      

    end.
    up frame-line(frame-a) - 1 with frame frame-a.


    tot-qtd = 0. tot-ctm = 0.
    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano 
                      no-lock:
            tot-qtd = tot-qtd + dctbhie.ctbest.
            tot-ctm = tot-ctm + (dctbhie.ctbcus * dctbhie.ctbest).
    end.
    
    disp tot-qtd to 55   format ">>>,>>9.99"
         tot-ctm to 79   format ">>,>>>,>>9.99"
         with frame ftot row 20 overlay no-box no-label
    color message.
    pause 0.

    repeat with frame frame-a:
        find ctbhie where recid(ctbhie) = recatu1 no-lock.

        choose field ctbhie.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
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
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next ctbhie where ctbhie.etbcod = vetbcod and
                                       ctbhie.ctbmes = vmes    and
                                       ctbhie.ctbano = vano no-error.

                if not avail ctbhie
                then leave.
                recatu1 = recid(ctbhie).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev ctbhie where ctbhie.etbcod = vetbcod and
                                       ctbhie.ctbmes = vmes    and
                                       ctbhie.ctbano = vano no-error.
                if not avail ctbhie
                then leave.
                recatu1 = recid(ctbhie).
            end.
            leave.
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
            find next ctbhie where ctbhie.etbcod = vetbcod and
                                   ctbhie.ctbmes = vmes    and
                                   ctbhie.ctbano = vano no-error.

            if not avail ctbhie
            then next.
            color display normal
                ctbhie.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev ctbhie where ctbhie.etbcod = vetbcod and
                                   ctbhie.ctbmes = vmes    and
                                   ctbhie.ctbano = vano no-error.
            if not avail ctbhie
            then next.
            color display normal
                ctbhie.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame frame-a no-pause.
            leave bl-princ.
        end.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.

                create ctbhie.
                update ctbhie.
            end.
            
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.

                do on error undo:
                    find current ctbhie.
                    update ctbhie.
                    find current ctbhie no-lock.
                end.
                tot-qtd = 0. tot-ctm = 0.
    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano 
                      no-lock:
            tot-qtd = tot-qtd + dctbhie.ctbest.
            tot-ctm = tot-ctm + (dctbhie.ctbcus * dctbhie.ctbest).
    end.
    
    disp tot-qtd to 55   format ">>>,>>9.99"
         tot-ctm to 79   format ">>,>>>,>>9.99"
         with frame ftot row 20 overlay no-box no-label
    color message.
    pause 0.

            end.

            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                
            
                display ctbhie with frame f-consulta no-validate.
            end.
            

            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" ctbhie.procod update sresp.
                if not sresp
                then leave.
                find next ctbhie where ctbhie.etbcod = vetbcod and
                                       ctbhie.ctbmes = vmes    and
                                       ctbhie.ctbano = vano no-error.
                if not available ctbhie
                then do:
                    find ctbhie where recid(ctbhie) = recatu1.
                    find prev ctbhie where ctbhie.etbcod = vetbcod and
                                            ctbhie.ctbmes = vmes    and
                                            ctbhie.ctbano = vano no-error.
                end.
                recatu2 = if available ctbhie
                          then recid(ctbhie)
                          else ?.
                find ctbhie where recid(ctbhie) = recatu1.
                delete ctbhie.
                recatu1 = recatu2.
                leave.
            end.
            
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                /**
                message "Confirma Impressao de ctbhieidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each ctbhie where ctbhie.etbcod = vetbcod:
                    display ctbhie.
                end.
                output close.
                recatu1 = recatu2.
                leave.
                **/
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2 overlay.
                /*
            message esqregua esqpos2 esqcom2[esqpos2].
                */
            pause 0.
            if esqcom2[esqpos1] = " Ajusta"
            then do:
                run ajusta-quantidade.
            end.
            if esqcom2[esqpos1] = " Transfere "
            then do:
                view frame frame-a .
                pause 0.
                run transfere-filial.
                leave bl-princ.
            end.

          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        

        find produ where produ.procod = ctbhie.procod no-lock.
        display ctbhie.procod
                produ.pronom
                produ.catcod
                ctbhie.ctbest
                ctbhie.ctbcus
               (ctbhie.ctbest * ctbhie.ctbcus) @ vtot
                   with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ctbhie).
   end.
end.
leave.
end.

def var val-atual as dec format ">>,>>>,>>9.99".
def var val-dvser as dec format ">>,>>>,>>9.99".
def var val-ajust as dec format "->>,>>>,>>9.99".
def var val-ajuse as dec format "->>,>>>,>>9.99".
def var qtd-acimad as dec.
def var qtd-ajuste as dec.
def var val-difer as dec format "->>,>>>,>>9.99".

procedure transfere-filial:
    def var vfildest like estab.etbcod.
    message "Filial destino:" update vfildest.
    find estab where estab.etbcod = vfildest no-lock no-error.
    if avail estab
    then do:
        sresp = no.
        message "Confirma transferir saldo para filial " vfildest "?"
        update sresp.
        if sresp
        then do:
            for each ctbhie where ctbhie.etbcod = vetbcod and
                                ctbhie.ctbmes = vmes    and
                                ctbhie.ctbano = vano 
                                 .
                find first bctbhie where
                           bctbhie.etbcod = vfildest and
                           bctbhie.ctbmes = vmes and
                           bctbhie.ctbano = vano and
                           bctbhie.procod = ctbhie.procod
                           no-error.
                if avail bctbhie
                then do on error undo:
                    bctbhie.ctbest = bctbhie.ctbest + ctbhie.ctbest.
                    delete ctbhie.
                end.
                else do on error undo:
                    ctbhie.etbcod = vfildest.
                end.           
            end.                    
        end.
    end.
    
    message color red/with
    "Saldo de estoque transferido para" vfildest
    view-as alert-box.
    
end procedure.    
procedure ajusta-quantidade:
    
    val-atual = 0.
    val-dvser = 0.
    val-ajust = 0.
    val-ajuse = 0.
    val-difer = 0.
    qtd-acimad = 0.
    qtd-ajuste = 0.
    
    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano 
                      no-lock:
        val-atual = val-atual + (dctbhie.ctbcus * dctbhie.ctbest).
    end.
  
    disp val-atual label "Valor Atual" with frame f-ajus.
    update val-dvser label "Valor Dvser" 
        with frame f-ajus 1 down centered row 10 side-label
        1 column overlay color message.
    val-difer = val-dvser - val-atual.
    disp val-difer label "Ajustar" with frame f-ajus.
    pause. 

    if val-difer < 0
    then do:
        val-ajust = val-difer * (-1).
        message val-ajust. pause.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 1000.
            qtd-ajuste = 600.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 900.
            qtd-ajuste = 500.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 800.
            qtd-ajuste = 400.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 700.
            qtd-ajuste = 300.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 600.
            qtd-ajuste = 200.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 500.
            qtd-ajuste = 100.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 400.
            qtd-ajuste = 80.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 300.
            qtd-ajuste = 70.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 200.
            qtd-ajuste = 60.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 100.
            qtd-ajuste = 50.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 50.
            qtd-ajuste = 10.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 40.
            qtd-ajuste = 7.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 30.
            qtd-ajuste = 6.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 20.
            qtd-ajuste = 5.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 10.
            qtd-ajuste = 4.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 7.
            qtd-ajuste = 3.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 5.
            qtd-ajuste = 2.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 4.
            qtd-ajuste = 1.
            run ajusta-menos.
        end.
        val-ajuse = val-ajuse * (-1).
    end.
    else if val-difer > 0
    then do:
        val-ajust = val-difer .
        message val-ajust. pause.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 1000.
            qtd-ajuste = 600.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 900.
            qtd-ajuste = 500.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 800.
            qtd-ajuste = 400.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 700.
            qtd-ajuste = 300.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 600.
            qtd-ajuste = 200.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 500.
            qtd-ajuste = 100.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 400.
            qtd-ajuste = 80.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 300.
            qtd-ajuste = 70.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 200.
            qtd-ajuste = 60.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 100.
            qtd-ajuste = 50.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 50.
            qtd-ajuste = 10.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 40.
            qtd-ajuste = 7.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 30.
            qtd-ajuste = 6.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 20.
            qtd-ajuste = 5.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 10.
            qtd-ajuste = 4.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 7.
            qtd-ajuste = 3.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 5.
            qtd-ajuste = 2.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 4.
            qtd-ajuste = 1.
            run ajusta-mais.
        end.
    end.

    disp val-ajuse label "Ajuste" with frame f-ajus.
end procedure. 

procedure ajusta-menos:

    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano and
                      dctbhie.ctbest > qtd-acimad  
                      by dctbhie.ctbest descending
                      :
        if val-ajuse < val-ajust
        then do:
            if val-ajuse + (dctbhie.ctbcus * qtd-ajuste) <= val-ajust
            then do:
                    /*
                dctbhie.ctbest = dctbhie.ctbest - qtd-ajuste.
                    */
                val-ajuse = val-ajuse + (dctbhie.ctbcus * qtd-ajuste).
            end.
        end.
    end.        
end procedure.
procedure ajusta-mais:

    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano and
                      dctbhie.ctbest > qtd-acimad  
                      by dctbhie.ctbest descending
                      :
        if val-ajuse < val-ajust
        then do:
            if val-ajuse + (dctbhie.ctbcus * qtd-ajuste) <= val-ajust
            then do:
                    /*
                dctbhie.ctbest = dctbhie.ctbest + qtd-ajuste.
                    */
                val-ajuse = val-ajuse + (dctbhie.ctbcus * qtd-ajuste).
            end.
        end.
    end.        
end procedure.

/****************************

/*********** baca para ajuste geral com arquivo ************/

def temp-table tt-arquivo
    field campo1 as int
    field campo2 as dec
    field campo3 as char
    field campo4 as char
    field campo5 as char
    field campo6 as int
    field campo7 as dec
    .

def var valor1 as char.
def var valor2 as char.
def var vlinha as char.
input from /admcom/work/dif-estoque.csv.csv.
repeat:
    import unformatted vlinha.
    message vlinha. pause 0.
    create tt-arquivo.
    assign
    campo1 = int(entry(1,vlinha,";"))
    valor1 = trim(entry(2,vlinha,";"))
    valor1 = replace(valor1,".","")
    valor1 = replace(valor1,",",".") 
    campo2 = dec(valor1)
    campo6 = int(entry(6,vlinha,";"))
    valor2 = trim(entry(7,vlinha,";"))
    valor2 = replace(valor2,".","")
    valor2 = replace(valor2,",",".") 
    campo7 = dec(valor2)
          .
end.
input close.

def var val-atual as dec format ">>,>>>,>>9.99".
def var val-dvser as dec format ">>,>>>,>>9.99".
def var val-ajust as dec format "->>,>>>,>>9.99".
def var val-ajuse as dec format "->>,>>>,>>9.99".
def var qtd-acimad as dec.
def var qtd-ajuste as dec.
def var val-difer as dec format "->>,>>>,>>9.99".

def buffer dctbhie for ctbhie.
def var vetbcod like estab.etbcod.
def var vano as int.
def var vmes as int.
vano = 2013.
vmes = 12.

for each tt-arquivo.
    disp tt-arquivo.campo1 
     tt-arquivo.campo2(total) format ">>>,>>>,>>9.99"
     tt-arquivo.campo7(total) format ">>>,>>>,>>9.99"
     tt-arquivo.campo7 - tt-arquivo.campo2(total) format "->>>,>>>,>>9.99"
     .
    pause 0.
    vetbcod = tt-arquivo.campo1.

    run ajusta-quantidade.

end.

procedure ajusta-quantidade:
    
    val-atual = 0.
    val-dvser = 0.
    val-ajust = 0.
    val-ajuse = 0.
    val-difer = 0.
    qtd-acimad = 0.
    qtd-ajuste = 0.
    
    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano 
                      no-lock:
        val-atual = val-atual + (dctbhie.ctbcus * dctbhie.ctbest).
    end.
  
    disp val-atual label "Valor Atual" with frame f-ajus.
    val-dvser = tt-arquivo.campo7.
    disp val-dvser label "Valor Dvser" 
        with frame f-ajus 1 down centered row 10 side-label
        1 column overlay color message.
    val-difer = val-dvser - val-atual.
    disp val-difer label "Ajustar" with frame f-ajus.
    
    pause 0. 

    if val-difer < 0
    then do:
        val-ajust = val-difer * (-1).
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 1000.
            qtd-ajuste = 600.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 900.
            qtd-ajuste = 500.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 800.
            qtd-ajuste = 400.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 700.
            qtd-ajuste = 300.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 600.
            qtd-ajuste = 200.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 500.
            qtd-ajuste = 100.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 400.
            qtd-ajuste = 80.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 300.
            qtd-ajuste = 70.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 200.
            qtd-ajuste = 60.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 100.
            qtd-ajuste = 50.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 50.
            qtd-ajuste = 10.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 40.
            qtd-ajuste = 7.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 30.
            qtd-ajuste = 6.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 20.
            qtd-ajuste = 5.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 10.
            qtd-ajuste = 4.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 7.
            qtd-ajuste = 3.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 5.
            qtd-ajuste = 2.
            run ajusta-menos.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 4.
            qtd-ajuste = 1.
            run ajusta-menos.
        end.
        val-ajuse = val-ajuse * (-1).
    end.
    else if val-difer > 0
    then do:
        val-ajust = val-difer .
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 1000.
            qtd-ajuste = 600.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 900.
            qtd-ajuste = 500.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 800.
            qtd-ajuste = 400.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 700.
            qtd-ajuste = 300.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 600.
            qtd-ajuste = 200.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 500.
            qtd-ajuste = 100.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 400.
            qtd-ajuste = 80.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 300.
            qtd-ajuste = 70.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 200.
            qtd-ajuste = 60.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 100.
            qtd-ajuste = 50.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 50.
            qtd-ajuste = 10.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 40.
            qtd-ajuste = 7.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 30.
            qtd-ajuste = 6.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 20.
            qtd-ajuste = 5.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 10.
            qtd-ajuste = 4.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 7.
            qtd-ajuste = 3.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 5.
            qtd-ajuste = 2.
            run ajusta-mais.
        end.
        if val-ajuse < val-ajust
        then do:
            qtd-acimad = 4.
            qtd-ajuste = 1.
            run ajusta-mais.
        end.
    end.
    disp val-ajuse label "Ajuste" with frame f-ajus.
    pause 1.
end procedure. 

procedure ajusta-menos:

    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano and
                      dctbhie.ctbest > qtd-acimad  
                      by dctbhie.ctbest descending
                      :
        if val-ajuse < val-ajust
        then do:
            if val-ajuse + (dctbhie.ctbcus * qtd-ajuste) <= val-ajust
            then do:
                    
                dctbhie.ctbest = dctbhie.ctbest - qtd-ajuste.
                    
                val-ajuse = val-ajuse + (dctbhie.ctbcus * qtd-ajuste).
            end.
        end.
    end.        
end procedure.
procedure ajusta-mais:

    for each dctbhie where dctbhie.etbcod = vetbcod and
                      dctbhie.ctbmes = vmes    and
                      dctbhie.ctbano = vano and
                      dctbhie.ctbest > qtd-acimad  
                      by dctbhie.ctbest descending
                      :
        if val-ajuse < val-ajust
        then do:
            if val-ajuse + (dctbhie.ctbcus * qtd-ajuste) <= val-ajust
            then do:
                    
                dctbhie.ctbest = dctbhie.ctbest + qtd-ajuste.
                    
                val-ajuse = val-ajuse + (dctbhie.ctbcus * qtd-ajuste).
            end.
        end.
    end.        
end procedure.

/********* fim baca ajuste geral com arquivo *****************/

************************/
