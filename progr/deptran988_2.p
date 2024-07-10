{admcab.i}

if setbcod <> 998
then do.
    message "Usar estab.998" view-as alert-box.
    return.
end.

/* NFE */
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.

def var varquivo  as char.
def var vcaminho  as char.
def var vetopeseq as int.
def var vtotnfe   as int.
def var vtotos    as int.
def var vtotqtde  as int.
def var vtotaudit as int.
def var vsetcod   like setor.setcod.
def var vcabrel   as char.
def var voscod    like asstec.oscod.
def buffer bclasse for clase.
def buffer bgrupo  for clase.

def temp-table tt-nfe
    field etopecod like asstec.etopecod
    field etopeseq like asstec.etopeseq
    field itens    as int  format ">>>>9" /* Qtde de itens */
    field qtde     as int  format ">>>>9" /* Qtde total */

    index nfe  is primary unique etopecod.

def temp-table tt-nfeitem
    field etopecod like asstec.etopecod
    field etopeseq like asstec.etopeseq
    field procod   like asstec.procod
    field qtde     as int
    
    index nfe  is primary unique etopecod procod.

def temp-table tt-nfeitem-os
    field etopecod like asstec.etopecod
    field etopeseq like asstec.etopeseq
    field procod   like asstec.procod
    field oscod    like asstec.oscod

    index nfe  is primary unique etopecod etopeseq procod oscod.

def temp-table tt-asstec
    field etopecod like asstec.etopecod
    field etopeseq like asstec.etopeseq
    field oscod    like asstec.oscod
    field procod   like asstec.procod
    field audit    as log
    field audcod   as char column-label "Audit" format "x(5)"
    
    index asstec is primary unique oscod
    index relat  etopecod etopeseq procod oscod.

def buffer btt-nfe for tt-nfe.

vcabrel = "ORDENS DE SERVICO - TRANSFERENCIA PARA 988".

repeat.
    update voscod with frame f-os down.

    find asstec where asstec.oscod = voscod no-lock no-error.
    if not avail asstec
    then do.
        message "OS nao encontrada" view-as alert-box.
        undo.
    end.
    run not_sincetiqest.p (recid(asstec)).

    find asstec where asstec.oscod = voscod no-lock.

    if asstec.etbcodatu <> 998
    then do.
        message "Estab.atual:" asstec.etbcodatu view-as alert-box.
        undo.
    end.

    if asstec.dtsaida <> ?
    then do.
        message "OS encerrada" view-as alert-box.
        undo.
    end.        

    vetopeseq = asstec.etopeseq.
    if vetopeseq > 0
    then do.
        find etiqseq where etiqseq.etopecod = asstec.etopecod
                       and etiqseq.etopeseq = vetopeseq
                     no-lock.
        find etiqmov of etiqseq no-lock.
        if etiqmov.sigla = "EnvAss"
        then do.
            message "OS esta no posto de assistencia" view-as alert-box.
            undo.
        end.
    end.

    find produ of asstec no-lock no-error.
    if not avail produ
    then do.
        message "Produto nao encontrado" view-as alert-box.
        undo.
    end.
        
    find clase of produ no-lock.
    find bclasse where bclasse.clacod = clase.clasup no-lock.
    find bgrupo  where bgrupo.clacod = bclasse.clasup no-lock.

    find first asstec_aux where asstec_aux.oscod      = asstec.oscod and
                                asstec_aux.nome_campo = "Auditoria"
                          no-lock no-error.

    create tt-asstec.
    assign
        tt-asstec.etopecod = asstec.etopecod
        tt-asstec.etopeseq = asstec.etopeseq
        tt-asstec.oscod    = asstec.oscod
        tt-asstec.procod   = asstec.procod
        tt-asstec.audit    = avail asstec_aux.

    if avail asstec_aux
    then tt-asstec.audcod = acha("Codigo", asstec_aux.valor_campo).

    /*
        Nota - Capa
    */
    find tt-nfe where tt-nfe.etopecod = tt-asstec.etopecod
                no-error.
    if not avail tt-nfe
    then do.
        create tt-nfe.
        assign
            tt-nfe.etopecod = tt-asstec.etopecod
            tt-nfe.etopeseq = tt-asstec.etopeseq.

        vtotnfe = vtotnfe + 1.
    end.

    /*
        Nota - Itens
    */
        assign
            tt-nfe.qtde = tt-nfe.qtde + 1.

        find tt-nfeitem where tt-nfeitem.etopecod = tt-asstec.etopecod
                          and tt-nfeitem.etopeseq = tt-asstec.etopeseq
                          and tt-nfeitem.procod   = asstec.procod
                        no-error.
        if not avail tt-nfeitem
        then do.
            create tt-nfeitem.
            assign
                tt-nfeitem.etopecod = tt-asstec.etopecod
                tt-nfeitem.etopeseq = tt-asstec.etopeseq
                tt-nfeitem.procod   = asstec.procod.

            assign
                tt-nfe.itens = tt-nfe.itens + 1.
        end.
        assign
            tt-nfeitem.qtde = tt-nfeitem.qtde + 1
            
            vtotaudit = vtotaudit + 1.

        create tt-nfeitem-os.
        assign
            tt-nfeitem-os.etopecod = tt-asstec.etopecod
            tt-nfeitem-os.etopeseq = tt-asstec.etopeseq
            tt-nfeitem-os.procod   = asstec.procod
            tt-nfeitem-os.oscod    = tt-asstec.oscod.

    assign
        vtotos   = vtotos + 1.

    vtotqtde = vtotqtde + 1.

    disp produ.procod produ.pronom with frame f-os.

    message "Ok".

end.
hide message no-pause.

find first tt-asstec no-lock no-error.
if not avail tt-asstec
then do.
    message "OS nao selecionadas" view-as alert-box.
    return.
end.
        
/*
*
*    tt-nfe.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "," Consulta ", " Gera NFE ", ""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-nfe where recid(tt-nfe) = recatu1 no-lock.
    if not available tt-nfe
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-nfe).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-nfe
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-nfe where recid(tt-nfe) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-nfe.etopecod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

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
                    if not avail tt-nfe
                    then leave.
                    recatu1 = recid(tt-nfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-nfe
                    then leave.
                    recatu1 = recid(tt-nfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-nfe
                then next.
                color display white/red tt-nfe.etopecod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-nfe
                then next.
                color display white/red tt-nfe.etopecod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form tt-nfe
                 with frame f-tt-nfe color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-tt-nfe.
                    disp tt-nfe.
                end.
                if esqcom1[esqpos1] = " Gera NFE "
                then do.
                    run geranfe (output sresp).
                    if sresp
                    then recatu1 = ?.
                    leave.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-nfe).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    display tt-nfe 
        with frame frame-a 11 down centered color white/red row 6.
end procedure.


procedure color-message.
    color display message
        tt-nfe.etopecod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        tt-nfe.etopecod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-nfe no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-nfe  no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-nfe  no-lock no-error.
        
end procedure.
         

procedure relatorionfe.

    varquivo = "/admcom/relat/rltran988" + string(time).
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "106"
        &Page-Line = "0"
        &Nom-Rel   = ""rltran988""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = "vcabrel"
        &Width     = "106"
        &Form      = "frame f-cabcab"}

disp
    tt-nfe.qtde
    tt-nfe.itens
    with frame f-cabrelnfe side-label width 106 no-box.

for each tt-nfeitem of tt-nfe no-lock.
    find produ of tt-nfeitem no-lock.
    for each tt-nfeitem-os of tt-nfeitem no-lock
            break by tt-nfeitem-os.procod.
        find tt-asstec where tt-asstec.oscod = tt-nfeitem-os.oscod no-lock.
        disp
            tt-nfeitem-os.procod
            produ.pronom
            tt-nfeitem-os.oscod (count by tt-nfeitem-os.procod)
            tt-asstec.audcod
            "|"
            tt-nfeitem.qtde
            with frame f-relnfe down no-box width 126.
    end.
end.

output close.
run visurel.p (input varquivo, input "").

end procedure.


procedure geranfe.

    def output parameter par-ok as log.

    def var vestatual like estoq.estatual.
    def var vmovseq   like movim.movseq.
    def var vobs-os   as char.

for each tt-plani.    delete tt-plani. end.
for each tt-movim.    delete tt-movim. end.
for each tt-movimaux. delete tt-movimaux. end.
for each tt-etiqpla.  delete tt-etiqpla. end.

find tipmov where tipmov.movtdc = 6 no-lock.

find first tt-nfeitem of tt-nfe no-lock no-error.
if not avail tt-nfeitem
then do.
    message "Sem itens auditados para gerar a NFE" view-as alert-box.
    return.
end.

run relatorionfe.

create tt-plani.
assign tt-plani.etbcod   = 998
       tt-plani.placod   = ?
       tt-plani.emite    = 998
       tt-plani.serie    = "1"
       tt-plani.numero   = ?
       tt-plani.movtdc   = tipmov.movtdc
       tt-plani.desti    = 988
       tt-plani.hiccod   = 5152
       tt-plani.opccod   = 5152
       tt-plani.pladat   = today
       tt-plani.datexp   = today
       tt-plani.modcod   = tipmov.modcod
       tt-plani.notfat   = 988
       tt-plani.dtinclu  = today
       tt-plani.horincl  = time
       tt-plani.notsit   = no
       tt-plani.vencod   = sfuncod
       tt-plani.NotPed   = ""
       tt-plani.notobs[1] = "".

vmovseq = 0.
vobs-os = "OS:".
for each tt-nfeitem of tt-nfe no-lock.

    for each tt-nfeitem-os of tt-nfeitem no-lock.
        create tt-etiqpla.
        assign
            tt-etiqpla.oscod    = tt-nfeitem-os.oscod
            tt-etiqpla.etopeseq = tt-nfeitem-os.etopeseq
            tt-etiqpla.etmovcod = 10 /* Tra988 */.

        find first tt-movimaux where tt-movimaux.etbcod = tt-plani.etbcod
                                 and tt-movimaux.procod = tt-nfeitem.procod
                                 and tt-movimaux.nome_campo = "OS"
                               no-error.
        if avail tt-movimaux
        then do.
            create tt-movimaux.
            assign
                tt-movimaux.movtdc = tt-plani.movtdc
                tt-movimaux.etbcod = tt-plani.etbcod
                tt-movimaux.placod = tt-plani.placod
                tt-movimaux.procod = produ.procod
                tt-movimaux.nome_campo  = "OS"
                tt-movimaux.valor_campo = "OS:".
        end.
        if length(tt-movimaux.valor_campo) < 65
        then tt-movimaux.valor_campo = tt-movimaux.valor_campo +
                       string(tt-nfeitem-os.oscod) + " ".
        else vobs-os = vobs-os + string(tt-nfeitem-os.oscod) + " ".
    end.
    vmovseq = vmovseq + 1.

    find estoq where estoq.etbcod = 998 /*** ??? ***/ and
                     estoq.procod = tt-nfeitem.procod
               no-lock no-error.

    create tt-movim.
    ASSIGN tt-movim.movtdc = tt-plani.movtdc
           tt-movim.PlaCod = tt-plani.placod
           tt-movim.etbcod = tt-plani.etbcod
           tt-movim.movseq = vmovseq
           tt-movim.procod = tt-nfeitem.procod
           tt-movim.movqtm = tt-nfeitem.qtde
           tt-movim.movdat = tt-plani.pladat
           tt-movim.MovHr  = tt-plani.horincl
           tt-movim.desti  = tt-plani.desti
           tt-movim.emite  = tt-plani.emite.

    if avail estoq
    then tt-movim.movpc  = estoq.estcusto.
        
    if tt-movim.movpc = 0
    then tt-movim.movpc = 1.

    tt-plani.platot = tt-plani.platot + (tt-movim.movpc * tt-movim.movqtm).
    tt-plani.protot = tt-plani.protot + (tt-movim.movpc * tt-movim.movqtm).
end.

tt-plani.notobs[1] = substr(vobs-os,   1, 200).
tt-plani.notobs[2] = substr(vobs-os, 201, 200).

find estab 998 no-lock.
run not_notgvlclf.p ("Estab", recid(estab), output sresp).
if not sresp
then return.

find estab 988 no-lock.
run not_notgvlclf.p ("Estab", recid(estab), output sresp).
if not sresp
then return.

sresp = no.
message "Confirma emissao NFE de transferencia para 988?" update sresp.
if sresp
then do.
    run manager_nfe.p (input "os_5152",
                       input ?,
                       output sresp).

    find current tt-nfe.
    delete tt-nfe.

    for each tt-etiqpla no-lock.
        find asstec where asstec.oscod = tt-etiqpla.oscod no-lock.
        run not_sincetiqest.p (recid(asstec)).
    end.

    recatu1 = ?.
end.

end procedure.

