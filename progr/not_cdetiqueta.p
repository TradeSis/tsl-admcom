/*       not_cdetiqueta.p
*
*/
{admcab.i}

def var vtotal as int.
def var vcusto as dec.

def var par-busca       as   char.
def buffer xestab for estab.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" OS ", " Marca ", " Movimenta ", "", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Filtros","Relatorio ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
    def var esqhel2         as char format "x(12)" extent 5.

def var vprimeiro as log.
def var vbusca as char.
/*D*
def var par-diaini as int.
def var par-diafim as int.
*D*/
def var par-dtini as date.
def var par-dtfim as date.
def var par-depdtini as date.
def var par-depdtfim as date.
def var par-envdtini as date.
def var par-envdtfim as date.
def var par-retdtini as date.
def var par-retdtfim as date.

def var vtime        as int.
def var vct          as int.

pause 0 before-hide.
form with frame f-proc.

form
    asstec.dtsaida
    vtotal label "Total"  to 80
    with frame ftotal row screen-lines - 1 no-box side-labels column 1
                 centered.

/*D*
find xestab where xestab.etbcod = setbcod no-lock.
vtime = time.
if xestab.etbcat = "LOJA"
then
    for each etiqest where etiqest.dtsaida = ?
                       and asstec.etbcod = setbcod no-lock.
        vct = vct + 1.
        if vct mod 57 = 0
        then
            disp  
                string(time - vtime, "hh:mm:ss") @ vbusca label "Processando"
                vct label "Abertas"
                with frame f-proc side-label centered row 10.
        run sincetiqest.p (recid(etiqest)).
    end.            
else
    for each etiqest where etiqest.dtsaida = ? no-lock.
        vct = vct + 1.
        if vct mod 77 = 0
        then
            disp
                string(time - vtime, "hh:mm:ss") @ vbusca label "Processando"
                vct label "Abertas"
                with frame f-proc side-label.
        run sincetiqest.p (recid(etiqest)).
    end.
hide frame f-proc no-pause.
*D*/

def buffer basstec    for asstec.
def buffer betiqope    for etiqope.

def new shared temp-table tt-asstec
    field marca     as log format "*/ "
    field rec       as recid.

/* Luciane - 21/03/2007 - 14546 */
/* Incluído campo sigla na tabela ttetiqueta para ordenar na tela e no relatório. */

def temp-table ttetiqueta
    field marca   as log format "*/ "
    field rec     as recid
    field etiqcod like asstec.oscod
    field sigla   like etiqope.sigla
    field antigo  as log

    index x etiqcod desc
    index y sigla etiqcod desc.

def buffer bttetiqueta for ttetiqueta.    
def buffer xasstec for asstec. 
def buffer xttetiqueta for ttetiqueta.
    
form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    
def var vchoose as char format "x(16)"  extent 4
            init [" Cons. Proprio   ",
                  " Cons. Terceiros ",
                  " ",
                  " GERAL "].
def var tchoose as char format "x(15)"  extent 4
            init ["EST", 
                  "CLI",
                  "",
                  "GERAL"].
def var vindex as int.
def var vframe as char.

/*D*
/* Luciane - 14556 - 21/03/2007 */
def var par-prazoent as date.
def var vprazoent    as date.
*D*/

def var par-etbcod like estab.etbcod.
def var par-etiqcod like asstec.oscod.
def var par-clicod like clien.clicod.
def var par-forcod like forne.forcod.
def var par-procod like produ.procod.
def var par-fabcod like produ.fabcod.
/*D* def var par-setcod like clase.clacod init 0. *D*/

/* Luciane - 14/02/2007 - 11888 */
def var par-numero like plani.numero.
def var par-pladat like plani.pladat.

def var par-emissao as log format "Sim/Nao".
def var par-fechamento as log format "Sim/Nao".
def var par-abertos as log format "Sim/Nao" init yes.
def var par-naoenviado as log format "Sim/Nao".
def var par-enviadosemretorno as log format "Sim/Nao".
def var par-envposto as log format "Sim/Nao".
def var par-retposto as log format "Sim/Nao".
def var par-envloja  as log format "Sim/Nao".
def var vdias   as int label "Dias" format ">>>9".
/*def var vdiastp as int label "T.P"  format ">>>9".*/

    form
        ttetiqueta.marca  format "*/ " column-label "*"
        asstec.etbcod   column-label "Etb"
        asstec.oscod
        asstec.procod
        produ.pronom  format "x(15)"
        asstec.serie  column-label "Conf" format "x(3)"
        etiqope.sigla format "x(3)"
        asstec.datexp
        asstec.forcod column-label "Posto" format ">>>>>>>9"
        vdias
      /*  asstec.osclifor column-label "OS Posto" */
        with frame frame-a .

form with frame flinha down no-box.
form with frame fcab.

repeat.    
    run pfiltros.
    if keyfunction(lastkey) = "end-error"
    then leave.

find first ttetiqueta no-lock no-error.
if not avail ttetiqueta
then do:
    message "Nao foram encontrados registros para esta selecao"
            view-as alert-box.
    leave.
end.

bl-princ:
repeat:    
    run ptotal.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttetiqueta where recid(ttetiqueta) = recatu1 no-lock.
    if not available ttetiqueta
    then return.
            
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttetiqueta).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttetiqueta
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
            find ttetiqueta where recid(ttetiqueta) = recatu1 no-lock.
            find asstec where recid(asstec) = ttetiqueta.rec no-lock.

            if asstec.etbcodatu = setbcod and
               asstec.dtsaida = ?
            then do.
                assign
                     esqcom1[2] = " Marca "
                     esqcom1[3] = " Movimenta ".
                if (setbcod = 988 or setbcod = 998) and
                   asstec.datexp = 01/01/2013
                then
                    assign
                     esqcom1[4] = " Marca Antigo"
                     esqcom1[5] = " Movim Antigo".
            end.
            else assign
                     esqcom1[2] = ""
                     esqcom1[3] = ""
                     esqcom1[4] = ""
                     esqcom1[5] = "".
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(asstec.oscod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(asstec.oscod)
                                        else "".

            disp asstec.dtsaida with frame ftotal.

            choose field asstec.oscod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 F8 PF8
                      tab PF4 F4 ESC return).
            
            if keyfunction(lastkey) = "CLEAR"
            then do: 
                recatu2 = ?.                
                hide frame frame-a no-pause.
                run not_etiqestin.p (input-output recatu2).  
                find asstec where recid(asstec) = recatu2 no-lock no-error.
                if avail asstec
                then do:
                    recatu1 = ?.
                    run montatt.
                    leave.
                end.
            end.
 
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca label "Busca"
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                find first basstec where basstec.oscod = int(vbusca)
                                    no-lock no-error.
                if avail basstec
                then do.
                    create ttetiqueta.
                    ttetiqueta.rec     = recid(basstec).
                    ttetiqueta.etiqcod = basstec.oscod.
                    recatu1 = recid(ttetiqueta).
                end.
                else do:
                    recatu1 = recatu2.
                    message "OS nao encontrada".
                    pause 1 no-message.
                end.    
                leave.
            end.

            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttetiqueta
                    then leave.
                    recatu1 = recid(ttetiqueta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttetiqueta
                    then leave.
                    recatu1 = recid(ttetiqueta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttetiqueta
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttetiqueta
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-etiqest color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " OS "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    recatu2 = recid(asstec).
                    run not_etiqestin.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.
                if esqcom1[esqpos1] = " Movimenta "
                then do:
                    find first ttetiqueta where ttetiqueta.marca
                                            and ttetiqueta.antigo
                               no-lock no-error.
                    if avail ttetiqueta
                    then do.
                        message "Usar a opcao de Movimenta antigo"
                                view-as alert-box.
                        leave.
                    end.

                    find first ttetiqueta where ttetiqueta.marca
                               no-lock no-error.
                    if not avail ttetiqueta
                    then do.
                        message "Sem itens marcados" view-as alert-box.
                        leave.
                    end.
                    hide frame f-com1  no-pause.
                    hide frame f-sub   no-pause.
                    for each tt-asstec.
                        delete tt-asstec.
                    end.
                    for each ttetiqueta where ttetiqueta.marca
                                          and ttetiqueta.antigo = no.
                        create tt-asstec.
                        tt-asstec.marca = yes.
                        tt-asstec.rec   = ttetiqueta.rec.
                        ttetiqueta.marca = no. /*17/02/2014*/
                    end.
                    hide frame ftotal.
                    run not_etiqseq.p.
                    view frame f-sub.
                    view frame f-com1.
                    pause 0.
                    recatu1 = ?.
                    run montatt.
                    find first ttetiqueta no-lock no-error.
                    if not avail ttetiqueta
                    then leave bl-princ.
                    else leave.
                end.
                if esqcom1[esqpos1] = " Movim Antigo"
                then do:
                    run versenha.p ("ManutSSC", "", 
                                    "Senha para Movimentar Antigo",
                                    output sresp). 
                    if not sresp
                    then next.
                    
                    find first ttetiqueta where ttetiqueta.marca
                                            and ttetiqueta.antigo
                               no-lock no-error.
                    if not avail ttetiqueta
                    then do.
                        message "Sem itens marcados" view-as alert-box.
                        leave.
                    end.
                    hide frame f-com1  no-pause.
                    hide frame f-sub   no-pause.
                    for each tt-asstec.
                        delete tt-asstec.
                    end.
                    for each ttetiqueta where ttetiqueta.marca
                                          and ttetiqueta.antigo
                                        no-lock.
                        create tt-asstec.
                        tt-asstec.marca = yes.
                        tt-asstec.rec   = ttetiqueta.rec.
                    end.
                    hide frame ftotal.
                    sretorno = "Antigo".
                    run not_etiqseq.p.
                    view frame f-sub.
                    view frame f-com1.
                    pause 0.
                    recatu1 = ?.
                    run montatt.
                    find first ttetiqueta no-lock no-error.
                    if not avail ttetiqueta
                    then leave bl-princ.
                    else leave.
                end.
                if esqcom1[esqpos1] = " Marca "
                then do:
                    find first bttetiqueta where bttetiqueta.marca
                               no-lock no-error.
                    if avail bttetiqueta
                    then do.
                        find basstec where recid(basstec) = bttetiqueta.rec
                            no-lock.
                        find betiqope of basstec no-lock.

                        find etiqope of asstec no-lock.
/***
def buffer betiqseq for etiqseq.

                        find etiqseq where etiqseq.etopecod = asstec.etopecod
                                       and etiqseq.etopeseq = asstec.etopeseq
                                    no-lock no-error.
                        
                        find betiqseq
                                where betiqseq.etopecod = basstec.etopecod
                                  and betiqseq.etopeseq = basstec.etopeseq
                                    no-lock no-error.
                        
                        if avail etiqseq and
                           avail betiqseq and
                           etiqseq.opccod <> betiqseq.opccod
                        then do.
                            message "Operacoes comerciais atuais incorretas"
                                    view-as alert-box.
                            leave.
                        end.
                        
                        if asstec.etopeseq = 0 and
                           basstec.etopeseq = 0 and
                           betiqope.sigla <> etiqope.sigla
                        then do.
                            message "Tipos diferentes de ordens de servico"
                                view-as alert-box.
                            leave.
                        end.

                        /*** 27/04/2010 ***/
                        if asstec.etopeseq <> basstec.etopeseq
                        then do.
                            message "Sequencias incorretas" view-as alert-box.
                            leave.
                        end.
***/
                        if asstec.etopeseq = 0 and
                           basstec.etopeseq = 0 and
                           betiqope.sigla <> etiqope.sigla
                        then do.
                            message "Tipos diferentes de ordens de servico"
                                view-as alert-box.
                            leave.
                        end.

                    end.        
                    find asstec where recid(asstec) = ttetiqueta.rec no-lock.
                    /*D* *D*/
                    find produ where produ.procod = asstec.procod
                               no-lock no-error.
                    if not avail produ
                    then do:
                        message "Produto" asstec.procod "da OS N." asstec.oscod
                                skip " nao encontrado"
                                view-as alert-box.
                        next.
                    end.
                    /*D* *D*/

                    if asstec.dtsaida = ?
                    then do.
                        ttetiqueta.marca = not ttetiqueta.marca.
                        ttetiqueta.antigo = no.
/*D*
                        if ttetiqueta.marca
                        then run not_etqauttroca.p (recid(asstec)).
*D*/
                    end.
                end.            
                if esqcom1[esqpos1] = " Marca Antigo"
                then do:
                    find first bttetiqueta where bttetiqueta.marca
                               no-lock no-error.
                    if avail bttetiqueta
                    then do.
                        find basstec where recid(basstec) = bttetiqueta.rec
                            no-lock.
                        find betiqope of basstec no-lock.

                        find etiqope of asstec no-lock.
/***
def buffer betiqseq for etiqseq.

                        find etiqseq where etiqseq.etopecod = asstec.etopecod
                                       and etiqseq.etopeseq = asstec.etopeseq
                                    no-lock no-error.
                        
                        find betiqseq
                                where betiqseq.etopecod = basstec.etopecod
                                  and betiqseq.etopeseq = basstec.etopeseq
                                    no-lock no-error.
                        
                        if avail etiqseq and
                           avail betiqseq and
                           etiqseq.opccod <> betiqseq.opccod
                        then do.
                            message "Operacoes comerciais atuais incorretas"
                                    view-as alert-box.
                            leave.
                        end.
                        
***/                        
                        if asstec.etopeseq = 0 and
                           basstec.etopeseq = 0 and
                           betiqope.sigla <> etiqope.sigla
                        then do.
                            message "Tipos diferentes de ordens de servico"
                                view-as alert-box.
                            leave.
                        end.

/*** antigo
                        /*** 27/04/2010 ***/
                        if asstec.etopeseq <> basstec.etopeseq
                        then do.
                            message "Sequencias incorretas" view-as alert-box.
                            leave.
                        end.
***/
                    end.        
                    find asstec where recid(asstec) = ttetiqueta.rec no-lock.

                    /*D* *D*/
                    find produ where produ.procod = asstec.procod
                               no-lock no-error.
                    if not avail produ
                    then do:
                        message "Produto" asstec.procod "da OS N." asstec.oscod
                                skip " nao encontrado"
                                view-as alert-box.
                        next.
                    end.
                    /*D* *D*/

                    if asstec.dtsaida = ?
                    then do.
                        ttetiqueta.marca = not ttetiqueta.marca.
                        ttetiqueta.antigo = yes.
                    end.
                end.            
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = "Filtros" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run pfiltros.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = "Relatorio" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run relatorio.
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttetiqueta).
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
end.

procedure frame-a.
    find asstec where recid(asstec) = ttetiqueta.rec no-lock.
    disp asstec.etbcod
        asstec.oscod
        asstec.datexp format "99/99/99"
        with frame frame-a 11 down centered color white/red row 5
                  title vchoose[vindex].

    find produ of asstec no-lock no-error.
    if asstec.etopeseq > 0
    then do.
        find etiqseq where etiqseq.etopecod = asstec.etopecod and
                           etiqseq.etopeseq = asstec.etopeseq
                     no-lock.
        find first etiqmov of etiqseq no-lock.
    end.
    vdias = today - asstec.datexp.
    /*run calcula-diastp (output vdiastp). */
    find etiqope of asstec no-lock.

def var vmarca as char format "x(1)".
if ttetiqueta.marca
then vmarca = "*".
if ttetiqueta.antigo
then vmarca = "A".

    disp
        /*ttetiqueta.marca format "* / "*/
        vmarca @ ttetiqueta.marca column-label "*"
        asstec.etbcod column-label "Etb"
        asstec.oscod
        asstec.procod
        produ.pronom  format "x(15)"
        etiqope.sigla column-label "Sig"
        if asstec.serie = "S" then "Sim" else "Nao" @ asstec.serie
        asstec.datexp column-label "Inclusao" format "99/99/99"
        asstec.forcod column-label "Posto"    format ">>>>>>9"
        vdias
        asstec.etbcodatu
        /*vdiastp when vdiastp <> 0
        asstec.osclifor column-label "OS"*/
        with frame frame-a.
    
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    find first ttetiqueta use-index y no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    find next ttetiqueta use-index y no-error.
if par-tipo = "up" 
then                  
    find prev ttetiqueta use-index y no-error.

end procedure.
         

procedure ptotal. 
    vtotal = 0.
    for each xttetiqueta no-lock.
        vtotal = vtotal + 1.
    end.
    pause 0 before-hide.
    disp vtotal label "Total"  to 80
         with frame ftotal.

end procedure.


procedure montatt.

    for each ttetiqueta.
        delete ttetiqueta.
    end.

    if par-etiqcod > 0
    then do:
        for each asstec where asstec.oscod = par-etiqcod no-lock.
            run criatt.
        end.
        leave.
    end.

    for each estab where
        (if par-etbcod = 0 then true else estab.etbcod = par-etbcod) no-lock.
        
        if par-abertos
        then do:
            for each asstec where asstec.etbcod = estab.etbcod
                              and asstec.dtsaida = ?
                    no-lock.
                if par-enviadosemretorno
                then
                    if asstec.dtenvass <> ? and
                       asstec.dtretass = ?
                    then.
                    else next.

                if par-naoenviado
                then
                    if asstec.dtenvass = ? 
                    then.
                    else next.

                if par-clicod > 0 and asstec.clicod <> par-clicod
                then next.

                if par-forcod > 0 and asstec.forcod <> par-forcod
                then next.

                if par-fabcod <> 0
                then do.
                    find produ of asstec no-lock no-error.
                    if avail produ
                    then
                        if produ.fabcod <> par-fabcod
                        then next.
                end.

/*D*
                if par-setcod <> 0
                then do:
                    find produ of asstec no-lock no-error.
                    if avail produ
                    then do.
                        find clase of produ no-lock.
                        if clase.setcod <> par-setcod
                        then next.
                    end.
                end.
*D*/
                if par-procod <> 0 and asstec.procod <> par-procod
                then next.

                if par-emissao
                then
                    if asstec.datexp >= par-dtini and
                       asstec.datexp <= par-dtfim
                    then.
                    else next.

                if par-fechamento
                then 
                    if asstec.dtsaida >= par-depdtini and
                       asstec.dtsaida <= par-depdtfim
                    then.
                    else next.

                if par-envposto
                then
                    if asstec.dtenvass >= par-envdtini and
                       asstec.dtenvass <= par-envdtfim
                    then.
                    else next.

                if par-retposto
                then
                    if asstec.dtretass >= par-retdtini and
                       asstec.dtretass <= par-retdtfim
                    then.
                    else next.

                run criatt.
            end.
        end.
        else do: /* fechados */
            
            for each asstec where asstec.etbcod = estab.etbcod and
                    asstec.dtsaida <> ?
                     no-lock. 

                if par-enviadosemretorno
                then
                    if asstec.dtenvass <> ? and
                       asstec.dtretass = ?
                    then.
                    else next.

                if par-naoenviado
                then
                    if asstec.dtenvass = ? 
                    then.
                    else next.
                 
                if par-clicod > 0 and asstec.clicod <> par-clicod
                then next.

                if par-forcod > 0 and asstec.forcod <> par-forcod
                then next.

                if par-fabcod <> 0
                then do:
                    find produ of asstec no-lock no-error.
                    if avail produ
                    then
                        if produ.fabcod <> par-fabcod
                        then next.
                end.

/*D*
                if par-setcod <> 0
                then do:
                    find produ of asstec no-lock no-error.
                    if avail produ
                    then do.
                        find clase of produ no-lock.
                        if clase.setcod <> par-fabcod
                        then next.
                    end.
                end.
*D*/
                if par-procod > 0 and asstec.procod <> par-procod
                then next.

                if par-emissao
                then
                    if asstec.datexp >= par-dtini and
                       asstec.datexp <= par-dtfim
                    then.
                    else next.

                if par-fechamento
                then
                    if asstec.dtsaida >= par-depdtini and
                       asstec.dtsaida <= par-depdtfim
                    then.
                    else next.

                if par-envposto
                then
                    if asstec.dtenvass >= par-envdtini and
                       asstec.dtenvass <= par-envdtfim
                    then.
                    else next.

                if par-retposto
                then
                    if asstec.dtretass >= par-retdtini and
                       asstec.dtretass <= par-retdtfim
                    then.
                    else next.

                run criatt.
            end.        
        end.
    end.        
    run ptotal.
                
end procedure.


procedure criatt.
    find etiqope of asstec no-lock.
    if vframe <> "GERAL" and etiqope.sigla <> vframe 
    then next.

    if par-etiqcod = 0 and par-envloja and asstec.dtenvfil <> ?
    then next.

    create ttetiqueta.
    ttetiqueta.rec   = recid(asstec).
    ttetiqueta.etiqcod = asstec.oscod.
    ttetiqueta.sigla = etiqope.sigla.
    
end procedure.


form with frame flinha no-box width 140.
    def var vtotpc  as dec.


procedure relatorio2.

    def buffer bplani for plani.
    def var vvenda as dec.

    if asstec.etopeseq > 0
    then do.
        find etiqseq where etiqseq.etopecod = asstec.etopecod and
                           etiqseq.etopeseq = asstec.etopeseq
                     no-lock no-error.
        if avail etiqseq 
        then find first etiqmov of etiqseq no-lock.
    end.
    vdias = today - asstec.datexp.

    /* Luciane - 21/03/2007 - 14548 */    
    find clien where clien.clicod = asstec.clicod no-lock no-error. 

/***
    /* solic.17137 */
    find last movim where movim.procod = asstec.procod
                      and movim.movtdc = 2
                    no-lock no-error.
    if avail movim
    then vtotpc = vtotpc + movim.movpc.
***/
    vcusto = 0.
    vvenda = 0.
        find estoq where estoq.procod = asstec.procod
                     and estoq.etbcod = setbcod
                   no-lock no-error.
        if avail estoq
        then assign
                vcusto = estoq.estcusto
                vvenda = estoq.estvenda.
    vtotpc = vtotpc + vcusto.

/*D*
    run calcula-diastp (output vdiastp). /*** 35258 ***/

    find last etiqpla of asstec where etiqpla.etmovcod = 2 no-lock no-error.
    if avail etiqpla
    then
        find bplani where bplani.etbcod = etiqpla.etbplani and
                          bplani.placod = etiqpla.plaplani
                    no-lock no-error.

    find etiqestdad of etiqest where etiqestdad.campo = "AUTTROCA"
                    no-lock no-error.
*D*/
    disp
        asstec.etbcod   column-label "Etb"
        asstec.oscod
        /*D* avail etiqestdad format "* / " column-label "A" *D*/
        asstec.procod
        /*D* etiqest.prodesc    *D*/
        etiqope.sigla 
        asstec.datexp
/*D*
        bplani.etbcod when avail bplani column-label "No."
        bplani.numero when avail bplani column-label "N.Fisc."
        bplani.pladat when avail bplani column-label "Remessa"
                      format "99/99/99"
*D*/
        vdias
        /* vdiastp when vdiastp <> 0 */
        clien.clinom format "x(20)" when avail clien
        vcusto column-label "Custo" format ">>>,>>9.99"
        vvenda column-label "Venda" format ">>>>9.99"
        with frame flinha.
    down with frame flinha.            

end procedure.


procedure relatorio.    

    def var mordem as char extent 4
                 init [" Geral ", " Fabricante ", " Produto ", " Filial "].
    def var vordem as int.
    def var vreg   as int.
    def var varquivo as char.

    disp mordem format "x(15)"
         with frame f-ordem no-label centered title " Ordenacao ".
    choose field mordem with frame f-ordem.
    vordem = frame-index.
    
    find estab where estab.etbcod = par-etbcod no-lock no-error.

    varquivo = "/admcom/relat/cdetiqueta" + string(time).
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "0"
        &Nom-Rel   = ""cdetiqueta""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """ORDENS DE SERVICO - "" +
                  string(par-etbcod) + "" "" +
                  (if avail estab then string(estab.etbnom) else "" GERAL"")"
       &Width     = "147"
       &Form      = "frame f-cabcab"}
 
    disp skip(1)
         par-etbcod         colon 30
         par-etiqcod        colon 30
         par-forcod       colon 30
         par-clicod         colon 30
         par-fabcod         colon 30
/***
         par-setcod         colon 30
***/
         par-procod         colon 30
/***
         par-prazoent       colon 30     
***/         par-abertos        colon 30
         par-emissao        colon 30
/*D*
         par-diaini         colon 50
         par-diafim
*D*/
         par-dtini          colon 50
         par-dtfim
         par-fechamento     colon 30
         par-depdtini       colon 50
         par-depdtfim
         par-naoenviado     colon 30
         par-envposto       colon 30
         par-envdtini       colon 50
         par-envdtfim
         par-enviadosemretorno colon 30
         par-retposto       colon 30
         par-retdtini       colon 50
         par-retdtfim
         with frame fcab side-labels 
              title "Filtros Controle Assistencia Tecnica".

if vordem = 1
then for each bttetiqueta no-lock,
    first asstec where recid(asstec) = bttetiqueta.rec no-lock,
    first etiqope of asstec no-lock
        break by asstec.etbcod
              by etiqope.etopecod
              by asstec.oscod 
              by asstec.datexp.
    if vframe = "GERAL" 
    then.
    else
       if etiqope.sigla <> vframe 
       then next.

    find produ of asstec no-lock no-error.

    run relatorio2.
end.

if vordem = 2
then for each bttetiqueta no-lock,
    first asstec where recid(asstec) = bttetiqueta.rec no-lock,
    produ of asstec no-lock
        break by produ.fabcod
              by asstec.etbcod
              by asstec.oscod.
    if vframe = "GERAL" 
    then.
    else
       if etiqope.sigla <> vframe 
       then next.

    if first-of (produ.fabcod)
    then do.
        find fabri of produ no-lock.
        disp skip(1)
             produ.fabcod
             fabri.fabnom no-label
             skip(1)
             with frame f-fabri side-label no-box.
    end.
    find etiqope of asstec no-lock.
    run relatorio2.
    vreg = vreg + 1.

    if last-of (produ.fabcod)
    then do.
        down with frame flinha.
        disp "Registros=" + string(vreg) @ clien.clinom with frame flinha.
        down 2 with frame flinha.
        vreg = 0.
    end.
end.

if vordem = 3
then for each bttetiqueta no-lock,
    first asstec where recid(asstec) = bttetiqueta.rec no-lock,
    produ of asstec no-lock
        break by produ.procod
              by asstec.etbcod
              by asstec.oscod.
    if vframe = "GERAL" 
    then.
    else
       if etiqope.sigla <> vframe 
       then next.
    find etiqope of asstec no-lock.
    run relatorio2.
    vreg = vreg + 1.

    if last-of (produ.procod)
    then do.
        down with frame flinha.
        disp "Registros=" + string(vreg) @ clien.clinom with frame flinha.
        down 2 with frame flinha.
        vreg = 0.
    end.
end.

if vordem = 4
then for each bttetiqueta no-lock,
    first asstec where recid(asstec) = bttetiqueta.rec no-lock,
    first etiqope of asstec no-lock
        break by asstec.etbcod
              by etiqope.etopecod
              by asstec.oscod 
              by asstec.datexp.
    if vframe = "GERAL" 
    then.
    else
       if etiqope.sigla <> vframe 
       then next.

    find produ of asstec no-lock no-error.
    run relatorio2.
    vreg = vreg + 1.

    if last-of (asstec.etbcod)
    then do.
        down with frame flinha.
        disp "Registros=" + string(vreg) @ clien.clinom with frame flinha.
        down 2 with frame flinha.
        vreg = 0.
    end.
end.

down 1 with frame flinha.
disp vtotpc  @ vcusto
     with frame flinha.
down with frame flinha.

output close.

if xestab.etbnom begins "DREBES-FIL"
then os-command silent /fiscal/lp
                     value("/usr/admcom/relat/cdetiqueta" + string(time)).
else run visurel.p (input varquivo, input "").



    
end procedure.

procedure pfiltros.

    disp
         par-etbcod         colon 30
         par-etiqcod        colon 30
         par-forcod       colon 30
         par-clicod         colon 30
         par-fabcod         colon 30
         /*D* par-setcod         colon 30     *D*/
         par-procod         colon 30
         /*D* par-prazoent       colon 30     *D*/
         par-abertos        colon 30
         par-emissao        colon 30
/*D*
         par-diaini         colon 50
         par-diafim
*D*/
         par-dtini          colon 50
         par-dtfim
         par-fechamento     colon 30
         par-depdtini       colon 50
         par-depdtfim
         par-naoenviado     colon 30
         par-envposto       colon 30
         par-envdtini       colon 50
         par-envdtfim
         par-enviadosemretorno colon 30
         par-retposto       colon 30
         par-retdtini       colon 50
         par-retdtfim
         par-envloja        colon 30
         with frame fcab
            title "Filtros Controle Assistencia Tecnica".
display vchoose
        with frame fff centered row 3 no-label overlay width 75.
choose field vchoose with frame fff.                         
vframe =  tchoose[frame-index].
vindex = frame-index.

find xestab where xestab.etbcod = setbcod no-lock.
if xestab.etbnom begins "DREBES-FIL"
then do:
    par-etbcod = setbcod.
    disp par-etbcod label "Estabelecimento"
    with frame fcab row 3 width 80 side-labels.
end.
else do:
    hide message no-pause.
    message color normal 
    "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
    message 
    "Pressione    F8 Para cadastrar nova Ordem de Servico".
    update par-etbcod go-on(F8 PF8)
        with frame fcab.
end.    
find estab where estab.etbcod = par-etbcod no-lock no-error.
if par-etbcod <> 0 and not avail estab
then do:
    message "Estabelecimento Errado".
    undo.
end.

if keyfunction(lastkey) = "GO" and not xestab.etbnom begins "DREBES-FIL"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

par-etiqcod = 0.
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
    message 
    "Pressione    F8 Para cadastrar nova Ordem de Servico".
 
update par-etiqcod
    go-on(F8 PF8)
    with frame fcab.
if keyfunction(lastkey) = "CLEAR"
then do: 
    recatu2 = ?. 
    run not_etiqestin.p (input-output recatu2).  
    find asstec where recid(asstec) = recatu2 no-lock no-error.
    if avail asstec
    then do:
        par-etbcod  = asstec.etbcod.
        par-etiqcod = asstec.oscod.
    end.
end.

if par-etbcod <> 0
then find asstec where asstec.oscod  = par-etiqcod
                   and asstec.etbcod = par-etbcod
                 no-lock no-error.
else find asstec where asstec.oscod = par-etiqcod no-lock no-error.
if par-etiqcod <> 0
then do:
    if not avail asstec
    then do:
        message "Ordem de Servico de Assitencia Inexistente".
        undo.
    end.
    else do.
        if avail asstec
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.        
    end.
end.

if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

update par-forcod label "Posto Assistencia"
    with frame fcab.
find forne where 
    forne.forcod = par-forcod no-lock no-error.
if par-forcod <> 0 and not avail forne then do:
    message "Posto Assistenca Inexistente".
    undo.
end.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

update par-clicod label "Cliente"
    with frame fcab.
find clien where clien.clicod = par-clicod no-lock no-error.
if par-clicod <> 0 and not avail clien
then do:
    message "Cliente Inexistente".
    undo.
end.

if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

update par-fabcod label "Fabricante"
    with frame fcab.
find fabri where fabri.fabcod = par-fabcod no-lock no-error.
if par-fabcod <> 0 and not avail fabri
then do:
    message "Fabricante Inexistente".
    undo.
end.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

/*D*
    update par-setcod with frame fcab.
    find setor where setor.setcod = par-setcod no-lock no-error.
    if par-setcod > 0 and not avail setor
    then do.
        message "Setor invalido".
        undo.
    end.
    if keyfunction(lastkey) = "GO"
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.
*D*/

par-procod = 0.
update par-procod label "Produto"
    when par-fabcod = 0 /*D* and par-setcod = 0 *D*/
    with frame fcab.
find produ where produ.procod = par-procod no-lock no-error.
if par-procod <> 0 and not avail produ
then do:
    message "Produto Inexistente".
    undo.
end.

/*D*
par-prazoent = ?.
update par-prazoent label "Prazo Entrega"
    with frame fcab.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
*D*/

update par-abertos label "Somente Abertos?" 
        with frame fcab.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

update par-emissao label "Filtra Inclusao"
    with frame fcab.

if keyfunction(lastkey) = "GO" and par-emissao = no
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

if par-emissao
then do:
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
 
    update par-dtini label "Inclusao de" colon 50
           par-dtfim label "Ate"
           with frame fcab.
    if par-dtini = ? or 
       par-dtfim = ? or
       par-dtfim < par-dtini
    then do:
        message "Datas Invalidas".
        undo.
    end.
end.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

par-fechamento = no.
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

update par-fechamento 
    when par-abertos = no label "Filtra Fechamento"
    with frame fcab.
if keyfunction(lastkey) = "GO" and par-fechamento = no
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

if par-fechamento
    then  do:
        hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

        update par-depdtini label "Fechamento de"
               par-depdtfim label "Ate"
            with frame fcab.
        if par-depdtini = ? or 
           par-depdtfim = ? or
           par-depdtfim < par-depdtini
        then do:
            message "Datas Invalidas".
            undo.
        end.
    end.                 
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~~mo campo".

update par-naoenviado label "Somente Nao Enviados?" 
    when par-abertos
        with frame fcab.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

par-envposto = no.
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

update par-envposto when par-naoenviado = no label "Filtra Envio Para Posto"
    with frame fcab.
if keyfunction(lastkey) = "GO" and par-envposto = no
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

if par-envposto
    then  do:
        hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

        update par-envdtini label "Envio de" par-envdtfim label "Ate"
            with frame fcab.
        if par-envdtini = ? or 
           par-envdtfim = ? or
           par-envdtfim < par-envdtini
        then do:
            message "Datas Invalidas".
            undo.
        end.
    end.                 
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

update par-enviadosemretorno label "Somente Nao Retornados?" 
    when par-abertos and par-naoenviado = no
        with frame fcab.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

par-retposto = no.
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

update par-retposto WHEN Par-enviadosemretorno = no and par-naoenviado = no
     label "Filtra Retorno Do Posto"
    with frame fcab.
if keyfunction(lastkey) = "GO" and par-retposto = no
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

if par-retposto
    then  do:
        hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

        update par-retdtini label "Retorno de" par-retdtfim label "Ate"
            with frame fcab.
        if par-retdtini = ? or 
           par-retdtfim = ? or
           par-retdtfim < par-retdtini
        then do:
            message "Datas Invalidas".
            undo.
        end.
    end.                 
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

update par-envloja label "Enviados para a loja" with frame fcab.
recatu1 = ?.

run montatt.

end procedure.

procedure calcula-diastp.

    def output parameter vdiastp as int init 0.

    def var vdtenvposto as date.
    vdiastp = 0.
/*D*
    for each etiqpla of asstec where etiqpla.etmovcod = 2 or
                                      etiqpla.etmovcod = 3 /*** 05/04/11 ***/
                     no-lock
                     break by etiqpla.data
                           by etiqpla.hora.
        if vdtenvposto = ?
        then vdtenvposto = etiqpla.data.
        else do.
            vdiastp = etiqpla.data - vdtenvposto.
            leave.
        end.
    end.
    if vdtenvposto <> ? and vdiastp = 0
    then vdiastp = today - vdtenvposto.
*D*/

end procedure.

