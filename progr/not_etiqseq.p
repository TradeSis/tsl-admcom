{admcab.i}

/*
*
*    not_etiqseq.p    -    Esqueleto de Programacao
*
*/
def new shared temp-table wfasstec like asstec.

def shared temp-table tt-asstec
    field marca     as log format "*/ "
    field rec       as recid.

def temp-table tt-etiqseq
    field rec         as recid
    field etmovcod    like etiqmov.etmovcod
    field etmovnom    like etiqmov.etmovnom format "x(60)".

def temp-table tt-etiqmov
    field etmovcod like etiqmov.etmovcod    
    index etiqmov is primary unique etmovcod.

def temp-table tt-produ
    field procod    like estoq.procod
    field qtde      like estoq.estatual
    index produ is primary unique procod.

def var vfirst as log.

/*D*
def var copcoms as char.
def var vdados as char format "x(78)".
def buffer atu-clifor for clifor.
*D*/
def buffer atu-estab for estab.
def var vtabini    as char.
def var vetbassist as int.

run le_tabini.p (0, 0, "SSC-ESTABASSIST", OUTPUT vtabini).
vetbassist = int(vtabini).

find first tt-asstec where tt-asstec.marca no-lock.
find asstec where recid(asstec) = tt-asstec.rec no-lock.
 
    form
        tt-etiqseq.etmovnom no-label format "x(50)"
        etiqseq.etseqclf no-label
        space(10)
        etiqseq.etopecod no-label
        etiqseq.etopeseq no-label
        with frame frame-a .

find estab  where estab.etbcod = asstec.etbcod no-lock.
find atu-estab where atu-estab.etbcod = asstec.etbcodatu no-lock no-error.
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
   then find etiqmov of etiqseq no-lock.
   
   disp asstec.etbcod     colon 12 label "Loja"
        estab.etbnom      format "x(20)" no-label
        asstec.oscod      colon 60
        asstec.procod     colon 12
        produ.pronom      no-label  
        asstec.datexp     colon 60
        asstec.clicod label "Cliente" colon 12 format ">>>>>>>>>9"
        clien.clinom  no-label format "x(30)" when avail clien
        asstec.forcod label "Posto" colon 12
        forne.fornom  no-label format "x(20)" when avail forne
        asstec.dtenvass colon 60
/*D*
        asstec.atu-clfcod label "Atual" colon 12
        atu-clifor.clfnom  no-label format "x(20)" when avail atu-clifor
*D*/
        asstec.dtretass colon 60
        atu-estab.etbcod   colon 12 label "Loja Atual" when avail atu-estab
        atu-estab.etbnom   no-label when avail atu-estab
        asstec.dtsaida    colon 60
        with frame f-dados row 4 side-label width 80
                    title " Controle da OS " + string(asstec.etbcod)  + "/" 
                          + string(asstec.oscod) + " ".

procedure cria.

    def input parameter par-etopeseq like etiqseq.etopeseq.

    find etiqseq where etiqseq.etopecod = asstec.etopecod
                   and etiqseq.etopeseq = par-etopeseq
                 no-lock.
    find etiqmov of etiqseq no-lock.
    create tt-etiqseq.
    assign
        tt-etiqseq.rec      = recid(etiqseq)
        tt-etiqseq.etmovcod = etiqmov.etmovcod
        tt-etiqseq.etmovnom = etiqmov.etmovnom.

end procedure.


if sretorno = "Antigo"
then do.
    sretorno = "".
    /* Retorno de Conserto */
    run cria (if asstec.etopecod = 1 then 3 else 5).

    /* Transferencia origem */
    run cria (if asstec.etopecod = 1 then 4 else 7).

    /* Transferencia outra lj */
    run cria (if asstec.etopecod = 1 then 10 else 10).

    /* Transferencia outra lj */
    run cria (if asstec.etopecod = 1 then 31 else 31).

    if asstec.etopecod = 1 and
       asstec.etopeseq = 0
    then do.
        run cria (8).
        run cria (9).
    end.
end.
else do.

if asstec.etopeseq = 0
then do.
    /* Primeira movimentacao nao mistura proprio e terceiro */
    for each etiqseq where etiqseq.etopecod = asstec.etopecod and
                           etiqseq.etopesup = 0
                     no-lock.
        /* solic.15173 */
        if setbcod <> vetbassist and
           (etiqseq.etseqclf = "ETB" or etiqseq.etseqclf = "LOJ")
        then next.

        find etiqmov of etiqseq no-lock.
        create tt-etiqseq.
        assign
            tt-etiqseq.rec      = recid(etiqseq)
            tt-etiqseq.etmovcod = etiqmov.etmovcod
            tt-etiqseq.etmovnom = etiqmov.etmovnom.
    end.
end.
else do.
    /* Proximas movimentacoes - pode misturar */
    vfirst = yes.
    for each tt-asstec where tt-asstec.marca no-lock.
        find asstec where recid(asstec) = tt-asstec.rec no-lock.

        if vfirst
        then do.
            /* Primeira vez - sequencias possiveis do primeiro registro */
            vfirst = no.
            for each etiqseq where etiqseq.etopecod = asstec.etopecod and
                                   etiqseq.etopesup = asstec.etopeseq 
                             no-lock.
                /* solic.15173 */
                if setbcod <> vetbassist and
                   (etiqseq.etseqclf = "ETB" or etiqseq.etseqclf = "LOJ")
                then next.

                find etiqmov of etiqseq no-lock.
                create tt-etiqseq.
                assign
                    tt-etiqseq.rec      = recid(etiqseq)
                    tt-etiqseq.etmovcod = etiqmov.etmovcod
                    tt-etiqseq.etmovnom = etiqmov.etmovnom.
            end.
        end.
        else do.
            /* Implementando em 16/05/2013*/
            
            /* Segunda vez em diante - exclui sequencias nao possiveis */
            for each tt-etiqmov.
                delete tt-etiqmov.
            end.

            for each etiqseq where etiqseq.etopecod = asstec.etopecod and
                                   etiqseq.etopesup = asstec.etopeseq 
                             no-lock.
                /* solic.15173 */
                if setbcod <> vetbassist and
                   (etiqseq.etseqclf = "ETB" or etiqseq.etseqclf = "LOJ")
                then next.

                /* Sequencias possiveis */
                find etiqmov of etiqseq no-lock.
                find tt-etiqmov of etiqmov no-lock no-error.
                if not avail tt-etiqmov
                then do.
                    create tt-etiqmov.
                    tt-etiqmov.etmovcod = etiqmov.etmovcod.
                end.
            end.

            for each tt-etiqseq.
                /* Nao esta na lista das possiveis, exclui */
                find tt-etiqmov of tt-etiqseq no-lock no-error.
                if not avail tt-etiqmov
                then delete tt-etiqseq.
            end.
        end.
    end.
end.

end.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Realizar ",""].

form
    esqcom1
    with frame f-com1
               row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1
    recatu1  = ?.
clear frame frame-a all no-pause.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-etiqseq where recid(tt-etiqseq) = recatu1 no-lock.
    if not available tt-etiqseq
    then do:
        message "Movimentos nao Inexistentes" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-etiqseq).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-etiqseq
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-etiqseq where recid(tt-etiqseq) = recatu1 no-lock.

            status default "".

            choose field tt-etiqseq.etmovnom  help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up 
                      F4 PF4 ESC return).

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
                    if not avail tt-etiqseq
                    then leave.
                    recatu1 = recid(tt-etiqseq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-etiqseq
                    then leave.
                    recatu1 = recid(tt-etiqseq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-etiqseq
                then next.
                color display white/red tt-etiqseq.etmovnom with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-etiqseq
                then next.
                color display white/red tt-etiqseq.etmovnom with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause. 
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Realizar "
                then do:
                    hide frame f-com1  no-pause.

                    run vercusto (tt-etiqseq.rec, output sresp).
                    if not sresp
                    then next.

                    run verestoq (tt-etiqseq.rec, output sresp).
                    if not sresp
                    then next.

                    find first tt-asstec where tt-asstec.marca
                               no-lock no-error.
                    if not avail tt-asstec
                    then do.
                        message "Sem OS marcadas" view-as alert-box.
                        next.
                    end.

                    run valida (tt-etiqseq.rec, output sresp).
                    if not sresp
                    then next.

                    run realiza (tt-etiqseq.rec).
                    leave bl-princ.
                end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-etiqseq).                  
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.


procedure frame-a.

    find etiqseq where recid(etiqseq) = tt-etiqseq.rec no-lock.

/*D*
    find opcom where opcom.opccod = etiqseq.opccod no-lock.
*D*/
 
    disp
        etiqseq.etopecod no-label
        etiqseq.etopeseq no-label
        tt-etiqseq.etmovnom no-label format "x(40)"
        etiqseq.etseqclf no-label
/*D*
        opcom.opccod no-label
*D*/
        with frame frame-a 6 down centered row 14
                          title " Opcao de Proxima Movimentacao para OS " 
/*            + string(asstec.etbcod)  + "/" 
            + string(asstec.oscod) + " "*/
                          width 80.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-etiqseq no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-etiqseq no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-etiqseq no-lock no-error.
        
end procedure.


procedure vercusto.

    def input  parameter par-rec-seq as recid.
    def output parameter par-ok      as log init yes.

    def var vetiqueta as char.

    for each tt-asstec.
         tt-asstec.marca = yes.
    end.
    for each tt-asstec.
        find asstec where recid(asstec) = tt-asstec.rec no-lock.

        find estoq where estoq.procod = asstec.procod
                     and estoq.etbcod = setbcod
                   no-lock no-error.
        if not avail estoq or
           estoq.estcusto <= 0
        then do.
            tt-asstec.marca = no.
            vetiqueta = vetiqueta + string(asstec.etbcod) + "/" +
                            string(asstec.oscod) + " ".
        end.
    end.

    if vetiqueta <> ""
    then do.
        par-ok = no.
        message "Etiquetas sem custo:" vetiqueta view-as alert-box.
    end.

end procedure.
    
procedure verestoq.

    def input  parameter par-rec-seq as recid.
    def output parameter par-ok      as log init yes.

    def var vestatual like estoq.estatual.
    def var vtransito like estoq.estatual.
    def var vetiqueta as char.

    find etiqseq where recid(etiqseq) = par-rec-seq no-lock.
    find etiqmov of etiqseq no-lock.

    if etiqmov.sigla = "EnvAss" or
       etiqmov.sigla = "VendPJ" or
       etiqmov.sigla = "DevCom" or
       etiqmov.sigla = "SaiLoj" or
       etiqmov.sigla begins "Tra"
    then do.
        for each tt-produ.
            delete tt-produ.
        end.
        for each tt-asstec where tt-asstec.marca no-lock.
            find asstec where recid(asstec) = tt-asstec.rec no-lock.
            find tt-produ of asstec no-error.
            if not avail tt-produ
            then do.
                create tt-produ.
                tt-produ.procod = asstec.procod.
            end.
            tt-produ.qtde = tt-produ.qtde + 1.
        end.

        for each tt-produ no-lock.
            find estoq where estoq.procod = tt-produ.procod
                         and estoq.etbcod = setbcod
                       no-lock no-error.
            if avail estoq
            then vestatual = estoq.estatual.
            else vestatual = 0.
            if vestatual < tt-produ.qtde
            then vetiqueta = vetiqueta + string(tt-produ.procod) + " ".
        end.

/***
        for each tt-asstec where tt-asstec.marca no-lock.
            find asstec where recid(asstec) = tt-asstec.rec no-lock.

            find estoq where estoq.procod = asstec.procod
                         and estoq.etbcod = setbcod
                       no-lock no-error.
            if avail estoq
            then vestatual = estoq.estatual.
            else vestatual = 0.
            if vestatual < 1
            then vetiqueta = vetiqueta + string(asstec.etbcod) + "/" +
                             string(asstec.oscod) + " ".
        end.
***/

        if vetiqueta <> ""
        then do.
            par-ok = no.
            message "Produto sem estoque:" vetiqueta view-as alert-box.
        end.
    end.
/***
    find opcom where opcom.opccod = etiqseq.opccod no-lock.
    find tipmov of opcom no-lock.
    if tipmov.tipemite /* Saida */ and
       tipmov.movtesp = no
    then do.
        for each tt-asstec.
            tt-asstec.marca = yes.
        end.
        for each tt-asstec.
            find asstec where recid(asstec) = tt-asstec.rec no-lock.

            run estdispo.p (asstec.procod, setbcod, yes, output vestoque).
            if vestoque < 1
            then do.
                tt-asstec.marca = no.
                vetiqueta = vetiqueta + string(asstec.etbcod) + "/" +
                            string(asstec.oscod) + " ".
            end.
        end.
        if vetiqueta <> ""
        then do.
            par-ok = no.
            run message.p (input-output par-ok,
                           input "Etiquetas sem estoque: " + vetiqueta +
                                 ". Continuar?",
                       input " !! ALERTA !! ", 
                       input "Sim",
                       input "Nao").
        end.
    end.
***/
end procedure.


procedure valida.

    def input parameter par-rec-seq as recid.
    def output parameter par-ok as log init yes.

    def var vetbcod    like asstec.etbcod.
    def var vconfinado as char.
    def var vetopecod  like asstec.etopecod.

    find etiqseq where recid(etiqseq) = par-rec-seq no-lock.
    find etiqmov of etiqseq no-lock.

    assign
        vetbcod    = 0
        vconfinado = ""
        vetopecod  = 0.
    for each tt-asstec where tt-asstec.marca no-lock.
        find asstec where recid(asstec) = tt-asstec.rec no-lock.

        if etiqmov.sigla = "TraLoj"
        then do.
            if vetbcod = 0
            then vetbcod = asstec.etbcod.
            if vetbcod <> asstec.etbcod
            then do.
                par-ok = no.
                message "Estabelecimentos sao diferentes" view-as alert-box.
                leave.
            end.  
        end.

        if etiqmov.sigla = "TraOut" or
           etiqmov.sigla = "TraLoj" or
           etiqmov.sigla = "TraMat"
        then do.
            if vconfinado = ""
            then vconfinado = asstec.serie.
            if vconfinado <> asstec.serie
            then do.
                par-ok = no.
                message "Confinamento diferente" view-as alert-box.
                leave.
            end.
        end.

        if etiqmov.sigla <> "RetAss"
        then do.
            if vetopecod = 0
            then vetopecod = asstec.etopecod.
            if vetopecod <> asstec.etopecod
            then do.
                par-ok = no.
                message "Tipos diferentes de ordens de servico"
                                view-as alert-box.
                leave.
            end.
        end.
    end.

end procedure.


procedure realiza.

    def input parameter par-rec-seq as recid.

    def buffer betiqseq for etiqseq.
/*D*
    def var vrecplani as recid init ?.
    def var vmovseq   like movim.movseq.
    def var vmovtdc   like tipmov.movtdc.
    def var vtime     as int.
    def var vmotivo   as char format "x(60)".
    def buffer basstec for asstec.
    def buffer cplani for plani.

    /*** 30024 ***/
    def var vmovpc like movim.movpc.
    def buffer bplani   for plani.
    def buffer bmovim   for movim.
*D*/
    def var vetopeseq like etiqseq.etopeseq.

    find etiqseq where recid(etiqseq) = par-rec-seq no-lock.

/*D*
    copcoms = "OPCOM=" + string(etiqseq.opccod).
    
    find opcom where opcom.opccod = etiqseq.opccod no-lock.
    find tipmov of opcom no-lock.
    vmovtdc = opcom.movtdc.    
*D*/    
    find first tt-asstec where tt-asstec.marca no-lock.
    find asstec where recid(asstec) = tt-asstec.rec no-lock.

    /*D* *D*/
    find etiqmov of etiqseq no-lock.
    if etiqmov.executar = ""
    then do.
        message "Tipo de movimentacao nao configurada" view-as alert-box.
        return.
    end.
    if search(etiqmov.executar) = ?
    then do.
        message "Programa" etiqmov.executar " nao encontrado"
                view-as alert-box.
        return.
    end.
    for each tt-asstec where tt-asstec.marca.
        find asstec where recid(asstec) = tt-asstec.rec no-lock.
        create wfasstec.
        assign
            wfasstec.oscod    = asstec.oscod
            wfasstec.etbcod   = asstec.etbcod
            wfasstec.procod   = asstec.procod
            wfasstec.forcod   = asstec.forcod
            wfasstec.etopecod = asstec.etopecod
            wfasstec.etopeseq = 0.

        if etiqmov.sigla = "RetAss"
        then do.
            vetopeseq = asstec.etopeseq.
            if vetopeseq = 0
            then
                if asstec.etopecod = 1
                then vetopeseq = 2.
                else vetopeseq = 3.
            for each betiqseq where
                                betiqseq.etopecod = asstec.etopecod and
                                betiqseq.etopesup = vetopeseq and
                                betiqseq.etmovcod = etiqmov.etmovcod
                              no-lock.

                 /* solic.15173 */
                 if setbcod <> vetbassist and
                    (betiqseq.etseqclf = "ETB" or betiqseq.etseqclf = "LOJ")
                 then next.
                 wfasstec.etopeseq = betiqseq.etopeseq.
                 leave.
            end.
            find first wfasstec where wfasstec.etopeseq = 0 no-lock no-error.
            if avail wfasstec
            then do.
                message "Problema na sequencia das operacoes" view-as alert-box.
                return.
            end.
        end.
    
    end.
    run value(etiqmov.executar) (recid(etiqseq)).

    for each tt-asstec where tt-asstec.marca.
        run not_sincetiqest.p (tt-asstec.rec).
        tt-asstec.marca = no. /*** 440739 ***/
    end.
    
/*D*    
    message "Confirma Emissão da Nota?" update sresp.
    if not sresp
    then return.

    if etiqseq.etopedep <> 0
    then do.
        find first etiqpla where etiqpla.etbcod   = etiqest.etbcod  and
                                 etiqpla.oscod  = etiqest.oscod and
                                 etiqpla.etopeseq = etiqseq.etopedep
                           no-lock no-error.      
        if avail etiqpla
        then vclfcod = etiqpla.clfcod-desti.
    end.
    
    vclfcod = if etiqseq.etseqclf = "CLI"
              then etiqest.cli-clfcod
              else if etiqseq.etseqclf = "FOR"
                   then etiqest.for-clfcod
                   else if etiqseq.etseqclf = "ETB" 
                        then etiqest.etbcod 
                        else if etiqseq.etseqclf = "MAT"
                             then if etiqest.etbcodatu = 98 and 
                                     etiqest.dtentrada < 12/15/2011
                                     /*** 39600 ***/
                                  then 98
                                  else vetbassist
                             else 0.
                                                        
    if etiqseq.etseqclf = "ETB"
    then do with frame f-centro overlay centered side-label.
        /* Transferencia para outra filial */
        if etiqseq.etmovcod = 14
        then update vclfcod label "Filial".

        /*** 34370 ***/ /* etiqseq.etmovcod = 4 */
        update vmotivo label "Motivo" validate (length(vmotivo) > 10, "").
    end.    

    if tipmov.movttra /*** 20/04/2011 ***/
    then do.
        find first estab where estab.clfcod = vclfcod no-lock no-error.
        if avail estab
        then vclfcod = estab.etbcod.
    end.

    find tipmov where tipmov.movtdc = vmovtdc no-lock.

    if tipmov.movtnota = no
    then run not_nfentin.p (input vmovtdc,
                            input-output vrecplani).
    else run not_notg.p (input vmovtdc,
                        input vclfcod,
                        input "ASSISTENCIA",
                        output vrecplani).
    if vrecplani = ?
    then leave.

    find plani where recid(plani) = vrecplani no-lock.
    find tipmov of plani no-lock.

    vclfcod = if tipmov.tipemite = no /* entrada */
              then (if tipmov.movtnota = no /* digita */
                    then plani.emite
                    else plani.desti)
              else plani.desti.

    vmovseq = 0.
    vtime   = time.

    for each tt-etiqest where tt-etiqest.marca.
        find etiqest where recid(etiqest) = tt-etiqest.rec no-lock.

        if vmotivo <> ""
        then do.
            find etiqestdad of etiqest where etiqestdad.campo = "MotivTra"
                            no-error.
            if not avail etiqestdad
            then do:
                create etiqestdad.
                assign 
                    etiqestdad.etbcod  = etiqest.etbcod 
                    etiqestdad.oscod = etiqest.oscod 
                    etiqestdad.campo   = "MotivTra".
            end.
            etiqestdad.descricao = vmotivo.
        end.    
    
        find produ of etiqest no-lock.

        vmovpc  = produ.procmed.
        vmovseq = vmovseq + 1.

        /*** 30024 - Devolucao emitir pelo mesmo custo da nf de origem ***/
        for each betiqpla of etiqest
                          where betiqpla.notsit <> "C" use-index guiaseq
                          no-lock.
            find bplani where bplani.etbcod = betiqpla.etbplani and
                              bplani.placod = betiqpla.plaplani
                       no-lock no-error.
            if not avail bplani or
               bplani.notsit <> "F"
            then next.

            if tipmov.movtdev and
               tipmov.xx-pncod = bplani.movtdc
            then do.
                find first bmovim of bplani
                            where bmovim.procod = etiqest.procod
                            no-lock no-error.
                if avail bmovim
                then do.
                    vmovpc = bmovim.movpc.
                    leave.
                end.
            end.
        end.

        create movim.
        assign
            movim.etbcod   = plani.etbcod
            movim.placod   = plani.placod
            movim.movseq   = vmovseq
            movim.movhoremit = plani.etbcod
            movim.movhordest = etiqest.etiqcod
            movim.movtdc   = plani.movtdc
            movim.procod   = etiqest.procod
            movim.movsit   = "A"
            movim.movqtm   = 1
            movim.movpc    = vmovpc
            movim.desdesc  = string(produ.pronom,"x(30)") +
                             " OS: " + string(etiqest.etbcod) + "/" +
                             string(etiqest.etiqcod,">>>9").

        create etiqpla.
        assign
            etiqpla.etbcod   = etiqest.etbcod
            etiqpla.etiqcod  = etiqest.etiqcod
            etiqpla.etbplani = plani.etbcod
            etiqpla.plaplani = plani.placod
            etiqpla.movseq   = movim.movseq
            etiqpla.data     = today
            etiqpla.hora     = vtime
            etiqpla.etmovcod = etiqseq.etmovcod
            etiqpla.etopecod = etiqseq.etopecod
            etiqpla.etopeseq = etiqseq.etopeseq
            etiqpla.clfcod-desti = vclfcod.

        if vtime = time
        then pause 1 no-message. /* chave de etiqpla tem o campo hora */
        vtime = time.
    end.

    /* not_nfpagc.p */
    def var vok as log init no.
    if tipmov.movtnota = no
    then run not_fenota.p (input recid(plani), input no, input-output vok).
    else run not_notgdad.p (input tipmov.movtdc, 
                            "NOTA", 
                            input string(vrecplani),
                            copcoms).

    find plani where recid(plani) = vrecplani no-lock.
    if plani.notsit = "" or
       plani.notsit = "A"
    then do.
        run not_excnota.p (vrecplani).
        leave.
    end.
*D*/

end procedure.

