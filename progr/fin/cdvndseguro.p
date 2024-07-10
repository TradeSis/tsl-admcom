/*
Projeto: Seguro Prestamista
11/2015
*    cdvndseguro.p    -    Esqueleto de Programacao
#1 Entrega em outra loja
*/
{admcab.i}

def input param par-param as char.

def var vetbcod   as int.
def var vplacod   like plani.placod.
def var vclicod   like clien.clicod.
def var vnumerosorte as char.
def var vfil-tpseguro as char init "".

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
    initial ["Consulta","Nota Fiscal","Certificado","Congela","Descongela",
             "Cancela"].
def var esqcom2         as char format "x(12)" extent 5
    initial [" Pesquisa ",""].
def buffer bvndseguro for vndseguro.
    
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

if par-param begins "EtbCod"
then assign
        vetbcod = int(acha("EtbCod", par-param))
        vplacod = int(acha("PlaCod", par-param))
        esqcom1[2] = ""
        esqcom2[1] = "".
else do.
    {filtro-segtipo.i vfil-tpseguro}

    if sremoto
    then vetbcod = setbcod.
    else do:
        vetbcod = 0.
        message "Filtrar Filial?" update vetbcod.
    end.
end.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find vndseguro where recid(vndseguro) = recatu1 no-lock.
    if not available vndseguro
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(vndseguro).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    repeat:
        run leitura (input "seg").
        if not available vndseguro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find vndseguro where recid(vndseguro) = recatu1 no-lock.
        find segtipo of vndseguro no-lock.
        if sremoto or
           vndseguro.dtcanc <> ? or
           vndseguro.dtfvig < today or
           segtipo.manutencao = no
        then assign
                esqcom1[4] = ""
                esqcom1[5] = ""
                esqcom1[6] = "".
        else assign
                esqcom1[4] = "Congela"
                esqcom1[5] = "Descongela"
                esqcom1[6] = "Cancela".

        /* helio 23012024
        if segtipo.progcertificado = ""
        then esqcom1[3] = "".
        else esqcom1[3] = "Certificado".
        */
        disp esqcom1 with frame f-com1.

        status default "".
        run color-message.
        choose field vndseguro.certifi help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return p P).
        run color-normal.
        status default "".

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
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail vndseguro
                    then leave.
                    recatu1 = recid(vndseguro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail vndseguro
                    then leave.
                    recatu1 = recid(vndseguro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail vndseguro
                then next.
                color display white/red vndseguro.certifi with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail vndseguro
                then next.
                color display white/red vndseguro.certifi with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
            if lastkey = keycode("p") or lastkey = keycode("P")
            then do:
                pause 0.
                update vclicod with frame f-procura 1 down
                 centered row 9 color message overlay
                 side-label. 
                 recatu1 = ?.
                 next bl-princ.
            end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form vndseguro except placod datexp
                 with frame f-vndseguro color black/cyan 2 col
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = "Consulta" or
                   esqcom1[esqpos1] = "Cancela"
                then do with frame f-vndseguro.
                    find clien of vndseguro no-lock.
                    disp vndseguro except placod datexp.
                    vnumerosorte = vndseguro.numerosorte.
                    if length(vnumerosorte) < 8
                    then vnumerosorte = fill("0",8 - length(vnumerosorte)) +
                         vnumerosorte.
                    disp vnumerosorte @ vndseguro.numerosorte.
                    disp vndseguro.certifi 
                         clien.clinom.
                end.
                if esqcom1[esqpos1] = "Nota Fiscal"
                then do:
                    find plani where plani.etbcod = vndseguro.etbcod
                                 and plani.placod = vndseguro.placod
                               no-lock no-error.
                    if avail plani
                    then do.
                        hide frame f-com1 no-pause.
                        hide frame f-com1 no-pause.
                        run not_consnota.p (recid(plani)).
                        view frame f-com1.
                        view frame f-com2.
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = "Congela" or
                   esqcom1[esqpos1] = "DesCongela"
                then do on error undo with frame f-congela.
                    disp
                        vndseguro.DtAnaliseEnt
                        vndseguro.DtAnaliseSai.
                    find current vndseguro exclusive.
                    if esqcom1[esqpos1] = "Congela"
                    then update vndseguro.DtAnaliseEnt.
                    else update vndseguro.DtAnaliseSai.

                    if esqcom1[esqpos1] = "Congela"
                    then vndseguro.situacao = no.
                    else vndseguro.situacao = yes.
                end.
                if esqcom1[esqpos1] = "Cancela"
                then run cancela.
                if esqcom1[esqpos1] = "Certificado"
                then do.
                    
                    if sremoto and
                       segtipo.geranumsorte and
                       vndseguro.etbcod <> 188 /* Hml */ and
                       vndseguro.etbcod <> 189 /* Hml */ and
                       vndseguro.procod <> 559910 and
                       (vndseguro.numerosorte = "" or
                        vndseguro.numerosorte = ?)
                    then run busca-numero-seguro.
                    /* helio 16012023 - retirado para deixar fixo no programa e mais visivel
                    * run value(segtipo.progcertificado) (recid(vndseguro), 1).
                    */
                    /* helio 16012023 */
                    if segtipo.tpseguro = 1 or /* seguro prestamista moda ou moveis */
                       segtipo.tpseguro = 3    /* seguro prestamista emprestimo */
                    then run termo/imptermoseguro.p (recid(vndseguro), 1, "/admcom/relat/").
                    if segtipo.tpseguro = 5 or /* garantia estendida */
                       segtipo.tpseguro = 6    /* rfq */ 
                    then 
                        /* helio 23012024 */
                        /*run loj/qbesegprest.p    (recid(vndseguro), 1). */
                        run termo/bilhete_txt.p (recid(vndseguro)).
                    
                    
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Pesquisa "
                then do:
                    prompt-for
                        vndseguro.etbcod
                        vndseguro.certifi
                        with frame fpesq side-label.
                    find bvndseguro
                            where bvndseguro.tpseguro = vndseguro.tpseguro
                              and bvndseguro.etbcod   = input vndseguro.etbcod
                              and bvndseguro.certifi  = input vndseguro.certifi
                                    no-lock no-error.
                    if avail bvndseguro
                    then recatu1 = recid(bvndseguro).
                end.
                leave.
            end.
        end.
        run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(vndseguro).
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


procedure frame-a.

    find plani where plani.etbcod = vndseguro.etbcod
                 and plani.placod = vndseguro.placod
               no-lock no-error.
    display
        vndseguro.tpseguro column-label "Tp"
        vndseguro.etbcod
        vndseguro.certifi 
        vndseguro.clicod
        vndseguro.prseguro
        vndseguro.dtincl
        vndseguro.dtcanc
        vndseguro.procod
/*        plani.serie  column-label "Ser"  when avail plani*/
        plani.numero format ">>>>>>9" column-label "Nota" when avail plani
        with frame frame-a 11 down centered color white/red row 5
                title vtpnome.
end procedure.


procedure color-message.
    color display message
        vndseguro.etbcod
        vndseguro.certifi
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        vndseguro.etbcod
        vndseguro.certifi
        with frame frame-a.
end procedure.


procedure leitura.
    def input parameter par-tipo as char.

if vplacod = ?
then do.
    if par-tipo = "pri" 
    then find last vndseguro use-index inclusao where vndseguro.tpseguro = vtpseguro
                and (if vetbcod > 0 then vndseguro.etbcod = vetbcod else true)
                and (if vclicod > 0 then vndseguro.clicod = vclicod else true) 
            no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then find prev vndseguro use-index inclusao where vndseguro.tpseguro = vtpseguro
                and (if vetbcod > 0 then vndseguro.etbcod = vetbcod else true)
                and (if vclicod > 0 then vndseguro.clicod = vclicod else true) 
            no-lock no-error.
             
    if par-tipo = "up" 
    then find next vndseguro use-index inclusao where vndseguro.tpseguro = vtpseguro
                and (if vetbcod > 0 then vndseguro.etbcod = vetbcod else true)
                and (if vclicod > 0 then vndseguro.clicod = vclicod else true) 
            no-lock no-error.
end.
else do.
    if par-tipo = "pri" 
    then find last vndseguro where vndseguro.etbcod = vetbcod
                                and vndseguro.placod = vplacod
            no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then find prev vndseguro  where vndseguro.etbcod = vetbcod
                                and vndseguro.placod = vplacod
            no-lock no-error.
             
    if par-tipo = "up" 
    then find next vndseguro where vndseguro.etbcod = vetbcod
                               and vndseguro.placod = vplacod
            no-lock no-error.
end.

end procedure.


procedure cancela.

    def var vmotivo as int.
    def var mmotivo as char extent 10 format "x(65)" init [
        "11   CANCELADO POR SOLICITAÇÃO",
        "12   CANCELAMENTO SOLICITADO PELO CLIENTE NO REPRESENTANTE",
        "13   CANCELADO POR SOLICITAÇÃO - DIFICULDADES FINANCEIRAS",
        "21   CANCELADO POR EXPIRAÇÃO DO CONTRATO",
        "31   CANCELADO POR INADIMPLÊNCIA",
        "32   CANCELADO POR INADIMPLÊNCIA PELA ROTINA DE FATURAMENTO",
        "41   CANCELADO POR OCORRENCIA DE SINISTRO",
        "51   CANCELADO POR PRODUTO NÃO ACEITO",
        "52   CANCELADO POR VALOR DO PREMIO NÃO CORRESPONDENTE AO PRODUTO",
        "91   OUTROS"].

    pause 0.
    disp mmotivo
        with frame f-motivo no-label centered title " Tipo de Cancelamento "
        overlay.
    choose field mmotivo with frame f-motivo.
    vmotivo = frame-index.

    sresp = no.
    message "Confirma cancelamento?" update sresp.
    hide frame f-motivo no-pause.
    if not sresp
    then return.

    do on error undo.
        find current vndseguro.
        assign
            vndseguro.dtcanc  = today
            vndseguro.motcanc = int(substr(mmotivo[vmotivo],1,2)).
            
        run fin/cancelacontratoseguro.p (recid(vndseguro)).

    end.
end procedure.


procedure busca-numero-seguro:
    /* acesso remoto */

    do on error undo.
        find current vndseguro exclusive.
        find first segnumsorte use-index venda where
                segnumsorte.dtivig = date(month(vndseguro.dtincl),
                                          01,
                                          year(vndseguro.dtincl))
            and segnumsorte.dtfvig = date(if month(vndseguro.dtincl) = 12
                                          then 01
                                          else month(vndseguro.dtincl) + 1,
                                          01,
                                          if month(vndseguro.dtincl) = 12
                                          then year(vndseguro.dtincl) + 1
                                          else year(vndseguro.dtincl)) - 1
            and segnumsorte.dtuso  = ?
                 exclusive no-wait no-error.
        if avail segnumsorte
        then do.
            assign
                segnumsorte.dtuso   = today
                segnumsorte.hruso   = time
                segnumsorte.etbcod  = vndseguro.etbcod
                segnumsorte.placod  = vndseguro.placod
                segnumsorte.contnum = vndseguro.contnum
                segnumsorte.certifi = vndseguro.certifi

                vndseguro.numerosorte = string(segnumsorte.serie,"999") +
                                        string(segnumsorte.nsorteio,"99999").
        end.
        find current vndseguro no-lock.
    end.

end procedure.

