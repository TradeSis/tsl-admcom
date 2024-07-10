{admcab.i}

def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vprotot   like  plani.protot.
def var vplatot   like  plani.platot.
def var vserie    as char format "x(3)".
def var vforcod   like forne.forcod.

form
    estab.etbcod   label "Filial" colon 15
    estab.etbnom   no-label
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label
    vnumero   colon 15
    vserie
/*    plani.opccod   colon 15
    opcom.opcnom              */
    plani.pladat       colon 15
      with frame f1 side-label width 80 row 3.

form
    plani.bicms    colon 10
    plani.icms     colon 30
    plani.protot  colon 65
    plani.frete    colon 10
    plani.ipi      colon 30
    plani.descpro  colon 10
    plani.acfprod  colon 45
    plani.platot  with frame f2 side-label row 11 width 80 overlay.
/*
prompt-for func.funcod
           func.senha blank with frame f-func side-label centered.
find func where func.funcod = input func.funcod and
                func.senha  = input func.senha no-lock no-error.
if not avail func
then do:
    message "Funcionario Invalido".
    undo, retry.
end.
if func.senha <> "0701" and func.senha <> "100"
then do:
    message "Funcionario Invalido".
    undo, retry.
end.
*/
repeat:
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    hide  frame f2 no-pause.
    hide  frame f-produ2 no-pause.
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display
        estab.etbcod
        estab.etbnom with frame f1.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod NO-LOCK no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom when avail forne with frame f1.

    update vnumero 
           vserie  with frame f1.
    find first plani where plani.numero = vnumero and
                     plani.emite  = forne.forcod and
                     plani.movtdc = 15 and
                     plani.serie = vserie and
                     plani.etbcod = estab.etbcod NO-LOCK no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.

    find tipmov where tipmov.movtdc = 15 no-lock.
    display plani.pladat with frame f1.
    display plani.bicms
            plani.icms
            plani.protot
            plani.frete
            plani.ipi
            plani.descpro
            plani.acfprod
            plani.platot with frame f2.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod
                   NO-LOCK:
         find produ where produ.procod = movim.procod no-lock.
         disp produ.procod
              produ.pronom format "x(25)"
              movim.movqtm format ">,>>9.99" column-label "Qtd"
              movim.movalicms column-label "ICMS"
              movim.movalipi  column-label "IPI"
              movim.movpc  format ">,>>9.99" column-label "Custo"
              (movim.movpc * movim.movqtm) format ">>,>>9.99"
                                    column-label "TOTAL"
              with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
         down with frame f-produ2.
    end.
    sresp = no.
    message "Confirma Exclusao Da Nota Fiscal?" plani.numero
    update sresp.
    if sresp
    then do transaction:
        find current plani exclusive.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod :
            run atuest.p (input recid(movim),
                          input "E",
                          input 0).
            delete movim.
        end.
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = estab.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero).
            delete titulo.
        end.
        find etiqpla where etiqpla.etbplani = plani.etbcod
                       and etiqpla.plaplani = plani.placod
                     no-error.
        if avail etiqpla
        then etiqpla.notsit = "C".
        delete plani.
    end.
end.
