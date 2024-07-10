/*
*
*/
def var vmodcoddesc as char.
def var primeiro as log.
def var vbusca          like titulo.titnum.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Selecao "," ","  "," Altera "," Exclui "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" SELECAO DE tituloS ",
             " MODALIDADE/CONTA ",
             " Exclusao, no DocLiq, o titulo ",""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
form with frame frame-oper.
{cabec.i}
def input parameter par-pdvmov-Recid as recid.
def input parameter par-operacao      as char.

def var vcoluna        as int.


def var vnome as char format "x(10)".
def var vassnome as char.
/*
def buffer bCMon for CMon.
def buffer tCMon for CMon.
*/

def var vjurodesc   as dec format "(>>>>9.99)".
def var par-modcod      like pdvtmov.ctmcod.

def var vpdvmov-cmdvlr as dec.
def var vheader as char format "x(25)".

form header vheader
            with frame frame-oper.
def shared frame f-pdvmov.
/*def shared frame separa.*/
form
    pdvmov.sequencia
    vpdvmov-cmdvlr  label "Total" format "zzzz,zz9.99"
    pdvmov.dtincl    colon 10
    pdvmov.datamov
     with frame f-pdvmov
           row 5 side-labels width 80 no-box color messages
           centered 1 down.
/*form
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|"
    with frame separa   row 8 col 40 */
/*    1 down side-labels overlay no-box.*/

/*
def shared var shared-operacao as char format "x(80)".
def shared frame fs-operacao.
form shared-operacao
    with frame fs-operacao row 4 color input no-box side-labels no-labels
        width 80.
def var ini-operacao as char.
ini-operacao = shared-operacao.
*/
form
    esqcom1[1] format "x(12)" esqcom1[2] format "x(12)"
                              esqcom1[3] format "x(12)"
    skip
    esqcom1[4] format "x(15)" esqcom1[5] format "x(15)"
    with frame f-com1
                 row 21 no-box no-labels side-labels column vcoluna.
/*
form
    esqcom2
    with frame f-com2
                 row screen-lines - 2 no-box no-labels side-labels
                 column vcoluna.
*/
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


find pdvmov where recid(pdvmov) = par-pdvmov-Recid no-lock.
find pdvtmov  of pdvmov                               no-lock.
find cmon    of pdvmov                               no-lock.
find cmtipo  of cmon                                  no-lock.

    if pdvtmov.operacao
    then do:
        VHEADER = "CREDITOS".
        vcoluna = 42.
    end.
    else do:
        VHEADER = "DEBITOS".
        vcoluna = 1.
    end.

pause 0.
disp
    pdvmov.sequencia
    pdvmov.datamov
    pdvmov.dtincl
        with frame f-pdvmov.

pause 0.
bl-princ:
repeat:
/*    view frame separa.*/
    disp esqcom1 with frame f-com1.

    /*
    disp esqcom2 with frame f-com2.
    */
    if recatu1 = ?
    then
        if esqascend
        then
            find first pdvdoc of pdvmov 
                    no-lock no-error.
        else
            find last pdvdoc of pdvmov no-lock no-error.
    else
        find pdvdoc where recid(pdvdoc) = recatu1 no-lock.
    if not available pdvdoc
    then do:
        esqvazio = yes.
    end.
    else esqvazio = no.
    clear frame frame-oper all no-pause.
    if not esqvazio
    then do:
        find modal of pdvdoc no-lock.
        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                          titulo.titpar  = pdvdoc.titpar
                    no-lock no-error.
        vjurodesc = pdvdoc.valor_encargo - pdvdoc.desconto_tarifa.
        if avail titulo
        then do:
            
            assign
                vassnome =  "CON" + "-" +
                            titulo.titnum + if titulo.titpar <> 0
                                           then ("/" + string(titulo.titpar))
                                           else "".
            vassnome = "".
        end.
        
        vnome = substring(modal.modnom,1,10) + " " +
                substring(vassnome,1,17).
        
        display
            titulo.modcod
            vnome
            {titnum.i}
            titulo.clifor 
            pdvdoc.pago_parcial    column-label "P"
            pdvdoc.titvlcob  column-label "VlCobrado"
            vjurodesc column-label "Acres"
            pdvdoc.valor column-label "Operacao"
            with frame frame-oper
            row 7 6 down column vcoluna overlay
                                        no-box no-hide.
                                        
    end.
    else do:        /*   pause 3.
        view frame frame-oper.*/
    end.

    recatu1 = recid(pdvdoc).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*
    else color display message esqcom2[esqpos2] with frame f-com2.
    */
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next pdvdoc of pdvmov 
                                        no-lock no-error.
        else
            find prev pdvdoc of pdvmov 
                                        no-lock no-error.
        if not available pdvdoc
        then leave.
        if frame-line(frame-oper) = frame-down(frame-oper)
        then leave.
        down
            with frame frame-oper.

        find modal of pdvdoc no-lock.
        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                          titulo.titpar  = pdvdoc.titpar
                    no-lock no-error.
        vjurodesc = pdvdoc.valor_encargo - pdvdoc.desconto_tarifa.
        if avail titulo
        then do:
            
            assign
                vassnome =  "CON" + "-" +
                            titulo.titnum + if titulo.titpar <> 0
                                           then ("/" + string(titulo.titpar))
                                           else "".
            vassnome = "".
        end.
        
        vnome = substring(modal.modnom,1,10) + " " +
                substring(vassnome,1,17).
        
        display
            titulo.modcod
            vnome
            {titnum.i}
            titulo.clifor 
            pdvdoc.pago_parcial 
            pdvdoc.titvlcob 
            vjurodesc
            pdvdoc.valor

                with frame frame-oper.
    end.
    if par-operacao = "BAIXA"
    then leave bl-princ.
    if not esqvazio
    then up frame-line(frame-oper) - 1 with frame frame-oper.
    repeat with frame frame-oper:

        /*shared-operacao = ini-operacao .
        disp shared-operacao
                    with frame fs-operacao.
        */
        do:
            if not esqvazio
            then do:
                vpdvmov-cmdvlr = 0.
                for each pdvdoc of pdvmov 
                            no-lock.
                    vpdvmov-cmdvlr = vpdvmov-cmdvlr + pdvdoc.valor /*+
                                                        pdvdoc.valor_encargo
                                                         -
                                                        pdvdoc.desconto_tarifa*/ .
                end.
                disp vpdvmov-cmdvlr
                    with frame f-pdvmov.

                find pdvdoc where recid(pdvdoc) = recatu1 no-lock.
                find modal of pdvdoc no-lock.
                find titulo where titulo.contnum = int(pdvdoc.contnum) and
                          titulo.titpar  = pdvdoc.titpar
                    no-lock no-error.
                vjurodesc = pdvdoc.valor_encargo - pdvdoc.desconto_tarifa.
                        
                display
                    pdvdoc.hispaddesc no-label format "x(30)" colon 1
                        with frame frame-dados
                            row 16 side-labels  overlay 1 down
                            column vcoluna + 2
                                color messages no-box.
                if avail titulo
                then do:
                    display
                    titulo.titnum + "/" + string(titulo.titpar)
                            @ titulo.titnum label "titulo" colon 15
                    pdvdoc.titvlcob label "Principal" colon 15 skip
                    pdvdoc.pago_parcial label "Parcial?"
                    
                    vmodcoddesc no-label vjurodesc no-label colon 15
                        with frame frame-dados.
                end.
                
            status default
                if esqregua
                then "F4 Para Finalizar Lancamento, ENTER Para"
                     + if esqhel1[esqpos1] <> ""
                                        then esqhel1[esqpos1]
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then ""
                                        else "".
            color disp messages vnome
                                pdvdoc.valor
                                    with frame frame-oper.

                if pdvtmov.operacao
                     then esqcom1[1] = "Sel. A Pagar".
                     else esqcom1[1] = "Sel Contratos".
            display esqcom1 with frame f-com1 .
            choose field vnome        help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) color white/black.
            color disp normal   vnome
                                pdvdoc.valor
                                    with frame frame-oper.
            status default "".
            end.
            else do:
                status default
                    if esqregua
                    then "F4 Para Finalizar Lancamento, ENTER Para"
                     + if esqhel1[esqpos1] <> ""
                                        then esqhel1[esqpos1]
                                        else ""
                    else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                            then ""
                                            else "".
                if not cmtipo.cmtmonetario
                then if pdvtmov.operacao = yes
                     then esqcom1[1] = "Sel. A Pagar".
                     else esqcom1[1] = "Sel Contratos".
                disp esqcom1 with frame f-com1.
            end.
        end.
        {esquema.i &tabela = "pdvdoc"
                   &campo  = "vnome"
                   &where  = " of pdvmov
                               "
                   &frame  = "frame-oper"}
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
                /*
                shared-operacao = shared-operacao + "/" +
                                    caps(esqcom1[esqpos1]).
                disp shared-operacao
                    with frame fs-operacao.
                */
            hide frame frame-dados no-pause.
            if esqcom1[esqpos1] = " Consulta "
            then
                hide frame frame-oper no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Selecao " or
                   esqcom1[esqpos1] = "Sel. A Pagar" or
                   esqcom1[esqpos1] = "Sel Contratos"
                then do on error undo.
                    hide frame f-com1 no-pause.
                    hide frame frame-oper no-pause.
                    pause 0 .
                    run fin/cmdsel.p (input recid(pdvmov),
                                  input pdvtmov.operacao,
                                  input if not cmtipo.cmtmonetario
                                        then if pdvtmov.operacao = yes
                                                then YES /* CP */
                                                else NO
                                        else no).
                    find first pdvdoc of pdvmov no-error.
                    if not avail pdvdoc
                    then do:
                        display esqcom1[esqpos1]
                            with frame f-com1.
                        color disp normal esqcom1[esqpos1]
                                with frame f-com1.
                        assign
                            esqpos1 = if false /*not pdvtmov.cmtdselecao*/
                                      then 2
                                      else esqpos1.
                        display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                            with frame f-com1.
                        color displ message esqcom1[esqpos1]
                                with frame f-com1.
                        /*if not pdvtmov.cmtdtra
                        then leave.*/
                    end.
                    else do:
                        recatu1 = ?.
                        leave.
                    end.
                end.
                if (esqcom1[esqpos1] = " Modalidade ")
                then do on error undo.
                    run fin/cmdman.p (input recid(pdvmov),
                                  input ?,
                                  input ?,
                                  input pdvtmov.operacao,
                                  input esqcom1[esqpos1]).
                    recatu1 = ?.
                    leave.
                end.
                if (esqcom1[esqpos1] = " Dinheiro ")
                then do on error undo.
                    run fin/cmdman.p (input recid(pdvmov),
                                  input ?,
                                  input ?,
                                  input pdvtmov.operacao,
                                  input esqcom1[esqpos1]).
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Altera "
                then do with frame freceb.
                    if avail pdvdoc
                    then
                        run fin/cmdman.p (input recid(pdvmov),
                                      input recid(pdvdoc),
                                      input ?,
                                      input pdvtmov.operacao,
                                      input esqcom1[esqpos1]).
                end.
                if esqcom1[esqpos1] = " Exclui " and avail pdvdoc
                then do.
                    message "Confirma a Exclusao ?"
                            update sresp.
                    if sresp
                    then do:
                        find pdvdoc where recid(pdvdoc) = recatu1.
                        delete pdvdoc.
                        recatu1 = ?.
                        leave.
                    end.
                end.

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            find modal of pdvdoc no-lock.
            find titulo where titulo.contnum = int(pdvdoc.contnum) and
                              titulo.titpar  = pdvdoc.titpar
                        no-lock no-error.
            vjurodesc = pdvdoc.valor_encargo - pdvdoc.desconto_tarifa.
            
        vnome = "".
        vassnome = "".
        /**
        if modal.asscod = "C"
        then do:
            find bcmon where bcmon.cmocod = pdvdoc.codcod no-lock.
            find moeda of pdvdoc no-lock no-error.
            if pdvdoc.titcod = ?
            then do:
                vassnome = if pdvdoc.valor >= 0
                           then if avail moeda
                                then moeda.moenom
                                else ""
                           else "TROCO".
                if bcmon.cmocod <> cmon.cmocod
                then vassnome = bcmon.cxanom.
            end.
        end.
        if modal.asscod = "A"
        then do:
            find clifor where /*clifor.empcod = sempcod and*/
                             clifor.clfcod  = pdvdoc.codcod no-lock.
            vassnome = clifor.clfnom.
        end.
        if modal.asscod = "U"
        then do:
            find estab where /* estab.empcod = wempre.empcod and*/
                          estab.etbcod  = pdvdoc.codcod no-lock.
            vassnome = string(estab.etbcod) + " " + estab.etbnom.
        end.
        */
        if avail titulo
        then do:
            assign
                vassnome =  /*titulo.tdfcod + "-" +*/
                            titulo.titnum + if titulo.titpar <> 0
                                           then ("/" + string(titulo.titpar))
                                           else "".
        end.
        vnome = substring(modal.modnom,1,10) + " " +
                substring(vassnome,1,17).
        display
            vnome   column-label ""
                    pdvdoc.valor
                    with frame frame-oper.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        /*
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(pdvdoc).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.

    hide frame frame-oper no-pause.

hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-dados no-pause.
/*hide frame separa no-pause.*/
/*hide frame frame-dado-tit no-pause.*/
/*
shared-operacao = ini-operacao.
disp shared-operacao
    with frame fs-operacao.
*/
find first pdvdoc of pdvmov no-lock no-error.
if avail pdvdoc
then do:
    view frame frame-oper.
end.    
