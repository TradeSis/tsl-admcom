/*
*
*    etiqpla.p    -    Esqueleto de Programacao    com esqvazio
*
#1 TP 24231493 
*/      
{admcab.i}

def buffer emiclifor for forne.
def buffer desclifor for forne.
def buffer emiestab  for estab.
def buffer desestab  for estab.
def buffer betiqpla  for etiqpla.

def var vnome as char.
def var vemitente as int format ">>>>>>9".
def var vdestinat as int format ">>>>>>9".

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Movimenta "," Nota Fiscal","",""].

def new shared temp-table tt-asstec
    field marca     as log format "*/ "
    field rec       as recid.

form
    esqcom1
    with frame f-com1 row 13 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

/*D*
def buffer atu-clifor for clifor.
*D*/
def buffer atu-estab for estab.

def input parameter par-rec-asstec as recid.
run not_sincetiqest.p (par-rec-asstec).

find asstec where recid(asstec) = par-rec-asstec no-lock.
find etiqope of asstec no-lock.
find estab  where estab.etbcod = asstec.etbcod no-lock.
find atu-estab  where atu-estab.etbcod = asstec.etbcodatu no-lock no-error.
find produ  of asstec no-lock. 
   
/*D*
find atu-clifor where atu-clifor.clfcod = asstec.atu-clfcod no-lock no-error. 
*D*/

find clien where clien.clicod = asstec.clicod no-lock no-error.
find forne where forne.forcod = asstec.forcod no-lock no-error. 

   find etiqseq where etiqseq.etopecod = asstec.etopecod and
                      etiqseq.etopeseq = asstec.etopeseq
                no-lock no-error.
   if avail etiqseq 
   then find etiqmov of etiqseq no-lock no-error.
   
   disp asstec.etbcod colon 11 label "Loja"
        estab.etbnom  format "x(30)" no-label
        asstec.oscod  colon 67

        asstec.procod colon 11
        produ.pronom  no-label format "x(30)"
        asstec.datexp colon 67

        asstec.clicod label "Cliente" colon 11 format ">>>>>>>>>9"
        clien.clinom  no-label format "x(25)" when avail clien
        asstec.dtenvass colon 67

        asstec.forcod label "Posto" colon 11
        forne.fornom  no-label format "x(25)" when avail forne
        asstec.dtretass  colon 67
/*D*
        asstec.atu-clfcod label "Atual" colon 12
        atu-clifor.clfnom no-label format "x(20)" when avail atu-clifor
*D*/
        atu-estab.etbcod colon 11 label "Loja Atual"   when avail atu-estab
        atu-estab.etbnom no-label when avail atu-estab
        asstec.dtenvfil  colon 67
        asstec.dtsaida   colon 67
        with frame f-dados row 4 side-label width 80
                    title  " Controle da OS de " + etiqope.etopenom + " - " +
              string(asstec.etbcod)  + "/" + string(asstec.oscod) + " ".

    find first etiqpla of asstec no-lock no-error.
    if not avail etiqpla
    then do:
        message "Sem Movimentacao".
        if asstec.etbcodatu = setbcod
        then do.
            for each tt-asstec.
                delete tt-asstec.
            end.
            create tt-asstec.
            tt-asstec.marca = yes.
            tt-asstec.rec = recid(asstec).
            run not_etiqseq.p.

            find first etiqpla of asstec where no-lock no-error.
            if not avail etiqpla
            then return.
            recatu1 = ?.
        end.
        else pause.
        next.
    end.

find func where func.etbcod = setbcod and func.funcod = sfuncod
          no-lock no-error.
if avail func and func.admin
then assign
        esqcom1[4] = " *Consulta* "
        esqcom1[5] = " *Altera* ".

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find etiqpla where recid(etiqpla) = recatu1 no-lock.
    if not available etiqpla
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else do.
        message "Movimentacoes nao realizadas".
        pause 2.
        leave bl-princ.
    end.

    recatu1 = recid(etiqpla).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available etiqpla
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find etiqpla where recid(etiqpla) = recatu1 no-lock.
            esqcom1[1] = if asstec.etbcodatu = setbcod and asstec.dtsaida = ?
                         then " Movimenta "
                         else "".
            esqcom1[3] = "".
            find last betiqpla of asstec no-lock no-error.
            repeat.
                if avail betiqpla
                then do.
                    find etiqmov of betiqpla no-lock no-error.
                    if avail etiqmov and etiqmov.sigla = "Tra988"
                    then do.
                        find prev betiqpla of asstec no-lock no-error.
                        next.
                    end.

                    if avail etiqmov and
                       etiqmov.EtMov-Est > 0
                    then esqcom1[3] = " Estorno ".
                end.
                leave.
            end.

            disp esqcom1 with frame f-com1.
            
            choose field etiqpla.data help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".

        end.
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
                    if not avail etiqpla
                    then leave.
                    recatu1 = recid(etiqpla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail etiqpla
                    then leave.
                    recatu1 = recid(etiqpla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail etiqpla
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail etiqpla
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form etiqpla
               with frame f-etiqpla color black/cyan centered side-label 
               2 col row 14.
                                                   
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Nota Fiscal "
                then do .
                    hide frame f-com1  no-pause.
                    find plani where plani.etbcod = etiqpla.etbplani and
                                     plani.placod = etiqpla.plaplani
                               no-lock.
                    run not_consnota.p (recid(plani)).
                    view frame f-com1.
                end. 
                if esqcom1[esqpos1] = " Movimenta "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-sub   no-pause.

                    /*D* *D*/
                    find produ where produ.procod = asstec.procod 
                               no-lock no-error.
                    if not avail produ
                    then do:
                        message "Produto" asstec.procod "da OS N." asstec.oscod
                                skip "nao localizado"
                                view-as alert-box.
                        next.
                    end.
                    /*D* *D*/

                    for each tt-asstec.
                        delete tt-asstec.
                    end.
                        create tt-asstec.
                        tt-asstec.marca = yes.
                        tt-asstec.rec = recid(asstec).
                    run not_etiqseq.p.
                    leave bl-princ.
                end.
                if esqcom1[esqpos1] = " Estorno "
                then do.
                    run estorno.
                    leave.
                end.
                if esqcom1[esqpos1] = " *Consulta* " or
                   esqcom1[esqpos1] = " *Altera* "
                then do with frame f-etiqpla.
                    disp etiqpla.
                    disp etiqpla.plaplani label "Placod" format ">>>>>>>>9"
                         etiqpla.etmovcod label "etmovcod".
                    if esqcom1[esqpos1] = " *Consulta* "
                    then pause.
                end.
                if esqcom1[esqpos1] = " *Altera* "
                then do on error undo with frame f-etiqpla side-label 2 col.
                    find current etiqpla exclusive.
                    update
                    /***#1
                        etiqpla.etopecod
                        etiqpla.etopeseq
                        etiqpla.etmovcod
                    ***/
                        etiqpla.notsit.
                    find current etiqpla no-lock.
                    run not_sincetiqest.p (recid(asstec)).
                end.

        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(etiqpla).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

    def var vfone   as char format "x(12)".
    def var vpladat as date.
    def var vhora   as char.
    def var vnotsit as char.

    find etiqmov of etiqpla no-lock no-error.
    find plani where plani.etbcod = etiqpla.etbplani and
                     plani.placod = etiqpla.plaplani
               no-lock no-error.
    if avail plani
    then do.
        if plani.modcod = "CAN"
        then vnotsit = "C".
        else if plani.notsit
        then vnotsit = "A".
        else vnotsit = "F".

        assign
            vemitente = plani.emite
            vdestinat = plani.desti
            vpladat   = plani.pladat
            vhora     = string(plani.horincl, "hh:mm:ss").
/*D*
    find clifor where clifor.clfcod = plani.emite no-lock.
   
    vfone = clifor.cxpos + clifor.fone.
    find emiclifor where emiclifor.forcod  = plani.emite no-lock no-error.
    IF AVAIL emiCLIFOR
    THEN FIND FIRST
            emiESTAB WHERE emiESTAB.CLFCOD = emiCLIFOR.CLFCOD NO-LOCK NO-ERROR.
    vemitente = /*D* IF AVAIL emiESTAB
                THEN emiESTAB.ETBCOD
                ELSE *D*/ if avail emiclifor
                     then emiclifor.clfcod
                     else 0.
    /***** destino */
    find desclifor where desclifor.clfcod = plani.desti no-lock no-error.
    IF AVAIL desCLIFOR
    THEN do.
        FIND FIRST
            desESTAB WHERE desESTAB.CLFCOD = desCLIFOR.CLFCOD NO-LOCK NO-ERROR.
        vfone = desclifor.cxpos + desclifor.fone.
    end.    
    vdestinat = IF AVAIL desESTAB
                THEN desESTAB.ETBCOD
                ELSE if avail desclifor
                     then desclifor.clfcod
                     else 0.
    if avail emiestab
    then
        if not avail desestab
        then vnome = desclifor.clfnom.
        else vnome = desestab.etbnom.
    else vnome = emiclifor.clfnom.
*D*/
    end.
    else
        assign
            vemitente = etiqpla.etbplani
            vdestinat = etiqpla.etbplani
            vpladat   = etiqpla.data
            vhora     = string(etiqpla.hora, "hh:mm:ss").

    display 
        etiqpla.data column-label "Data" format "99/99/99"
        vhora format "x(5)" column-label "Hora"
        etiqpla.notsit column-label "S"
        plani.opccod column-label "Op" format "9999"  when avail plani
        etiqmov.etmovnom format "x(26)" when avail etiqmov
        vemitente 
        vdestinat
        vemitente    column-label "Emite" format ">>>>>99"
        vdestinat    column-label "Desti" format ">>>>>99"
/*
        vnome format "x(13)" column-label ""
        vfone format "x(11)" column-label "Fone"
*/
        plani.serie  column-label "Ser"  when avail plani
        plani.numero column-label "Nota" when avail plani format ">>>>>>9"
        vnotsit format "x" column-label "S"
        with frame frame-a 4 down centered color white/red row 14
        title " Sequencia de Movimentacoes da OS "
            + string(asstec.etbcod)  + "/" 
            + string(asstec.oscod) + " ".
end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find last etiqpla of asstec no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find prev etiqpla of asstec  no-lock no-error.
             
if par-tipo = "up" 
then find next etiqpla of asstec no-lock no-error.

end procedure.


procedure estorno.

    def var vnumero   like plani.numero init 0.
    def var vdtincl   like plani.dtincl.
    def var vmovtdc   like plani.movtdc init 0.
    def var vetbcod   like plani.etbcod.
    def var vetmovcod like etiqpla.etmovcod.
    def var vrecid    as recid.

    run versenha.p ("ManutSSC", "",
                    "Senha para Registrar Estorno",
                    output sresp). 
    if not sresp
    then return.

    find last betiqpla of asstec no-lock no-error.
    repeat.
        if avail betiqpla
        then do.
            find etiqmov of betiqpla no-lock no-error.
            if not avail etiqmov
            then leave.

            if etiqmov.sigla = "Tra988"
            then do.
                find prev betiqpla of asstec no-lock no-error.
                next.
            end.

            assign
                vrecid    = recid(betiqpla)
                vetbcod   = betiqpla.etbplani
                vmovtdc   = etiqmov.Movtdc-Est
                vetmovcod = etiqmov.EtMov-Est.
        end.
        leave.
    end.

    if vrecid = ?
    then do.
        message "Problemas na OS para realizar o estorno" view-as alert-box.
        return.
    end.

    do on error undo with frame f-estorno side-label centered.
        update
            vnumero label "NF Estorno Nro" validate(vnumero > 0, "")
            vdtincl validate (vdtincl <= today, "").
        find plani where plani.movtdc = vmovtdc
                     and plani.etbcod = vetbcod
                     and plani.numero = vnumero
                     and plani.dtincl = vdtincl
                   no-lock no-error.
        if not avail plani
        then do.
            message "NFE de estorno nao encontrada" view-as alert-box.
            undo.
        end.
        disp plani.desti plani.platot.

        /*** 29/05/2013 ***/
        find first movim where movim.etbcod = plani.etbcod
                           and movim.placod = plani.placod
                           and movim.movtdc = plani.movtdc
                           and movim.procod = asstec.procod
                         no-lock no-error.
        if not avail movim
        then do.
            message "NFE de estorno nao contem o produto desta OS"
                view-as alert-box.
            undo.
        end.

        sresp = no.
        message "Confirma estorno?" update sresp.
        if sresp
        then do transaction.
            find betiqpla where recid(betiqpla) = vrecid exclusive.
            assign
                betiqpla.notsit = "C".

            create etiqpla.
            assign
                etiqpla.etbplani = plani.etbcod
                etiqpla.plaplani = plani.placod
                etiqpla.data     = plani.dtincl
                etiqpla.hora     = plani.horincl
                etiqpla.oscod    = betiqpla.oscod
                etiqpla.etopeseq = 0
                etiqpla.etmovcod = vetmovcod
                etiqpla.notsit   = "C".
        end.
        run not_sincetiqest.p (recid(asstec)).
    end.

end procedure.
