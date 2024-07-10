/*
*
*    Esqueletao de Programacao
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Grade "," Inclusao "," Exclusao ","Programacao",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," "," ","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Grade do produ ",
             " Inclusao de produ ",
             " Preco do produ ",
             "  ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].
            
def var vcornom     like cor.cornom.
def input parameter rec2 as recid.

{cabec.i}

find pedid where recid(pedid) = rec2.

if pedid.sitped <> "A"
then sretorno = "CONSULTA".


if sretorno = "CONSULTA" 
then 
    assign esqcom1[2] = "" 
           esqcom1[3] = "" 
           esqcom1[5] = "". 


    form
        esqcom1
            with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

def new shared workfile wfite
    field itecod    like produ.itecod
    field tot       as   int format ">>>>" label "Quant"
    field lippreco  like liped.lippreco.

def new shared workfile wfcor
    field itecod    like produ.itecod
    field cornom    like cor.cornom
    field corcod    like cor.corcod
    field grade     as int format ">>>>" extent 17
    field lippreco  like liped.lippreco
    field alterado  as log.

def var vi as int.
def var vgrade      like taman.tamcod format "xxxx" extent 12.

for each liped of pedid:
    find produ of liped no-lock.
    find first wfite where
            wfite.itecod = produ.itecod
        no-error.
    if not available wfite
    then create wfite.
    assign
        wfite.itecod   = produ.itecod
        wfite.lippreco = liped.lippreco.
    find first wfcor where
                wfcor.itecod = produ.itecod and
                wfcor.corcod = produ.corcod
            no-error.
    if  not available wfcor then
        create wfcor.
    find clase of produ no-lock.
    find gratam where gratam.gracod = produ.gracod and
                      gratam.tamcod = produ.tamcod
                no-lock.
    find cor   of produ no-lock.
    assign
        wfcor.itecod = produ.itecod
        wfcor.corcod = produ.corcod
        wfcor.cornom = cor.cornom
        wfcor.lippreco = wfite.lippreco
        wfcor.grade[gratam.graord] = liped.lipqtd.
end.
for each wfite: 
    wfite.tot = 0. 
    for each wfcor where wfcor.itecod = wfite.itecod: 
        wfcor.grade[13] = 0. 
        do vi = 1 to 12: 
            wfcor.grade[13] = wfcor.grade[13] + wfcor.grade[vi]. 
        end. 
        wfite.tot = wfite.tot + wfcor.grade[13]. 
    end.
end.    




bl-princ:
repeat:
    form with frame f-dialogo side-labels centered row 7 overlay.
    form
        produpai.itecod column-label "Codigo"
        produpai.refer  
        produpai.pronom format "x(45)" 
        wfite.tot       format ">>,>>9"
/*        wfite.lippreco  format ">,>>9.99"*/
/*        vtotlinha like wfite.lippreco column-label "Total"*/
            with frame fprodu       width 80
                 centered 3 down row 7 color white/red
                 title " PEDIDO N. " + string(pedid.pednum) + " ".
    def new shared frame fcor.
    form 
         wfcor.cornom format "x(13)"
                        space(0) "|" space(0)
         wfcor.grade[1] space(0) "|" space(0)
         wfcor.grade[2] space(0) "|" space(0)
         wfcor.grade[3] space(0) "|" space(0)
         wfcor.grade[4] space(0) "|" space(0)
         wfcor.grade[5] space(0) "|" space(0)
         wfcor.grade[6] space(0) "|" space(0)
         wfcor.grade[7] space(0) "|" space(0)
         wfcor.grade[8] space(0) "|" space(0)
         wfcor.grade[9] space(0) "|" space(0)
         wfcor.grade[10] space(0) "|" space(0)
         wfcor.grade[11] space(0) "|" space(0)
         wfcor.grade[12] space(0) "|" space(0)
         wfcor.grade[13] format ">>>>" space(0)
         wfcor.grade[14] space(0) "|" space(0)
         wfcor.grade[15] space(0) "|" space(0)
         wfcor.grade[16] space(0) "|" space(0)
         wfcor.grade[17] space(0) "|" space(0)

         with frame fcor
            7 down row 16 centered width 160 no-labels no-box.

    pause 0.
    disp esqcom1 with frame f-com1.
    /*disp esqcom2 with frame f-com2.*/
    if  recatu1 = ? then
        find first wfite where true
                         no-lock no-error.
    else
        find wfite where recid(wfite) = recatu1 no-lock.
    if  not available wfite then do with frame f-dialogo:
        hide frame f-com1 no-pause.
        clear frame fprodu all.
        prompt-for produpai.itecod
                help "Digite Codigo do produ, F7 - ZOOM ou ENTER para Cadastrar"
                with frame fprodu.
        find produpai where produpai.itecod = 
                        input frame fprodu produpai.itecod.
        display produpai.pronom
                with frame fprodu.
        find grade of produpai no-lock.
        if grade.obser = "INA"
        then do:
            message "Produto com Grade Inativa".
            pause 2 no-message.
            undo.
        end.
        
        run co/lipedpai.p ( input recid(pedid) ,  
                            input ?,
                            input recid(produpai) ).          
        run co/lipgra.p (input produpai.itecod,
                         input recid(pedid),
                         input yes).
        recatu1 = ?.
        next.
    end.
    clear frame fprodu all no-pause.
    run frame-a.

    recatu1 = recid(wfite).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next wfite where true
                        no-lock no-error.
        if not available wfite
        then leave.
        if frame-line(fprodu) = frame-down(fprodu)
        then leave.
        down
            with frame fprodu.
        run frame-a.
    end.
    up frame-line(fprodu) - 1 with frame fprodu.

    repeat with frame fprodu:

        find wfite where recid(wfite) = recatu1 no-lock.
        find produpai  where produpai.itecod = wfite.itecod no-lock.

        status default
            if esqregua
            then esqhel1[esqpos1] + if esqhel1[esqpos1] <> ""
                                    then string(produpai.pronom)
                                    else ""
            else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                    then string(wfite.itecod)
                                    else "".

        vgrade = "".
        for each gratam where gratam.gracod = produpai.gracod.
            vgrade[gratam.graord] = gratam.tamcod.
        end.  
        form produpai.pronom format "x(12)" 
                   space(1) "|" space(0)
         vgrade[1] space(0) "|" space(0)
         vgrade[2] space(0) "|" space(0)
         vgrade[3] space(0) "|" space(0)
         vgrade[4] space(0) "|" space(0)
         vgrade[5] space(0) "|" space(0)
         vgrade[6] space(0) "|" space(0)
         vgrade[7] space(0) "|" space(0)
         vgrade[8] space(0) "|" space(0)
         vgrade[9] space(0) "|" space(0)
         vgrade[10] space(0) "|" space(0)
         vgrade[11] space(0) "|" space(0)
         vgrade[12] space(0) "|" space(0)
         " Tot"
            with frame fgratam no-box no-labels
                  color white/cyan row 14 width 81.
        disp produpai.pronom
             vgrade
           fill("-",80) format "x(80)"
            with frame fgratam.
        clear frame fcor all no-pause.
        for each wfcor where wfcor.itecod = wfite.itecod
            vi = 1 to 7:     
            disp wfcor.cornom
                 wfcor.grade
                with frame fcor.
            /*color disp black/cyan wfcor.grade
                with frame fcor.*/
            down with frame fcor. 
        end.
        choose field produpai.itecod help ""
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down   page-up
                  PF4 F4 ESC return
                  A B C D E F G H I J K L M N O P Q R S T U V W Y X Z
                  a b c d e f g h i j k l m n o p q r s t u v w y x z
                  1 2 3 4 5 6 7 8 9 0).

        if (asc(keyfunction(lastkey)) >= 48  and
            asc(keyfunction(lastkey)) <= 57)  or
           (asc(keyfunction(lastkey)) >= 65  and
            asc(keyfunction(lastkey)) <= 90)  or
           (asc(keyfunction(lastkey)) >= 97  and
            asc(keyfunction(lastkey)) <= 122)
        then do on error undo, retry on endkey undo, leave:
            /*
            vcornom = vcornom + keyfunction(lastkey).
            find first cor where
                             wfite.cornom begins vcornom no-lock no-error.
            if not avail wfite
            then do:
                vcornom = keyfunction(lastkey).
                find first wfite where
                                 wfite.cornom begins vcornom no-lock no-error.
            end.
            if available wfite
            then recatu1 = recid(wfite).
            leave.
            */
        end.

        status default "".

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
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(fprodu):
                find next wfite where true
                                 no-lock no-error.
                if not avail wfite
                then leave.
                recatu1 = recid(wfite).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(fprodu):
                find prev wfite where
                                no-lock  no-error.
                if not avail wfite
                then leave.
                recatu1 = recid(wfite).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next wfite where
                            no-lock no-error.
            if not avail wfite
            then next.
            color display white/red produpai.itecod.
            if frame-line(fprodu) = frame-down(fprodu)
            then scroll with frame fprodu.
            else down with frame fprodu.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev wfite where
                           no-lock  no-error.
            if not avail wfite
            then next.
            color display white/red produpai.itecod.
            if frame-line(fprodu) = 1
            then scroll down with frame fprodu.
            else up with frame fprodu.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave:
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            if esqcom1[esqpos1] = " Grade "
            then do with frame fprodu:
                color display message produpai.itecod 
                                      produpai.pronom
                                      produpai.refer  
/*                                      wfite.lippreco  */
                                      wfite.tot  
                                      /*vtotlinha  */
                                      with frame fprodu.
                run co/graite.p (input wfite.itecod,
                                 input recid(pedid) ).
                run co/lipgra.p (input wfite.itecod,
                              input recid(pedid),
                              input no).
                color display normal   wfcor.grade 
                                        with frame fcor.
                color display normal produpai.itecod 
                                      produpai.pronom
                                      produpai.refer  
/*                                      wfite.lippreco  */
                                      wfite.tot  
                                      /*vtotlinha  */
                                      with frame fprodu.
  
            end.
            if  esqcom1[esqpos1] = " Inclusao " then do with frame f-dialogo:
                hide frame f-com1 no-pause.
                clear frame fprodu all.
                
                prompt-for produpai.itecod
                    help "Digite Codigo do Item, F7 - ZOOM ou F6 para Cadastrar"
                    with frame fprodu.
                find produpai where
                        produpai.itecod = input frame fprodu produpai.itecod.
                display produpai.pronom
                        with frame fprodu.
                find grade of produpai no-lock.
                if grade.obser = "INA"
                then do:
                    message "Produto com Grade Inativa".
                    pause 2 no-message.
                    undo.
                end.
                run co/lipedpai.p ( input recid(pedid) ,  
                                    input ?,
                                    input recid(produpai) ).          
                
                run co/lipgra.p (input produpai.itecod,
                                 input recid(pedid),
                             input yes).               
                find first wfite where wfite.itecod = produpai.itecod
                        no-error.
                recatu1 = recid(wfite).
                leave.
            end.
            if esqcom1[esqpos1] = "Programacao"
            then do :
                hide frame fprodu  no-pause.
                hide frame fcor    no-pause.
                hide frame fgratam no-pause.
                hide frame f-com1  no-pause.
                run co/ocppro.p (input recid(pedid)).
                pause 0.
                view frame fprodu  . pause 0.
                view frame fcor    . pause 0.
                view frame fgratam . pause 0.
                view frame f-com1. pause 0.
            end.        
            if esqcom1[esqpos1] = " Exclusao "
            then do with frame fprodu:
                for each produ where produ.itecod = wfite.itecod.
                    find liped of pedid where liped.procod = produ.procod.
                    delete liped.
                end.
                for each wfcor where wfcor.itecod = wfite.itecod.
                    delete wfcor.
                end.
                delete wfite.
                recatu1 = ?.
                leave.                
            end.
            if esqcom1[esqpos1] = " Preco "
            then do with frame fprodu:
                find lipedpai of pedid where lipedpai.itecod = wfite.itecod
                                    no-lock no-error.
                find produpai of lipedpai no-lock.
                run co/lipedpai.p ( input recid(pedid) ,  
                                    input recid(lipedpai),
                                    input recid(produpai) ).
                find current lipedpai no-lock.
                wfite.lippreco = lipedpai.lippreco.
                find produ where produ.procod = wfite.itecod no-lock no-error.
                pause 0.
                recatu1 = recid(wfite).
                for each wfcor where wfcor.itecod = wfite.itecod:
                    wfcor.lippreco = wfite.lippreco.
                end.
/*                display wfite.lippreco.*/
                run co/lipgra.p (input wfite.itecod,
                              input recid(pedid),
                              input no).
                leave.
            end.
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                    with frame f-com2.
          end.
        end.
            run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(wfite).
    end.
end.
hide frame f-com1  no-pause.
hide frame fprodu   no-pause.
hide frame fcor    no-pause.
hide frame fgratam no-pause.



procedure frame-a.

    find produpai where produpai.itecod = wfite.itecod.
    display
        produpai.itecod
        produpai.pronom label "Descricao"
        produpai.refer
        /*wfite.lippreco*/
        wfite.tot
/*        wfite.lippreco * wfite.tot @ vtotlinha            */
        with frame fprodu.



end procedure.
