{admcab.i}
def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    like  plani.serie.
def var vopccod   like  plani.opccod.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.
def var vforcod     like forne.forcod.


form produ.procod
     produ.pronom format "x(30)"
     movim.movqtm format ">,>>9.99" column-label "Qtd"
     movim.movalicms column-label "ICMS"
     movim.movalipi  column-label "IPI"
     movim.movpc  format ">,>>9.99" column-label "Custo"
                    with frame f-produ1 row 5 7 down overlay
                                    centered color message width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.

form
    estab.etbcod   label "Filial" colon 15
    estab.etbnom   no-label
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label
    vnumero   colon 15
    plani.serie
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
    clear frame f-produ1 no-pause.
    hide  frame f2 no-pause.
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display
        estab.etbcod
        estab.etbnom with frame f1.
    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-error.
    if not avail forne
    then do:
        bell.
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom when avail forne with frame f1.

    update vnumero with frame f1.
    find first plani where plani.numero = vnumero and
                     plani.emite  = forne.forcod and
                     plani.movtdc = 1 and
                     plani.serie = "u" and
                     plani.etbcod = estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.
    display plani.serie with frame f1.
    do on error undo, retry:
        /*
        display plani.opccod with frame f1.
        find opcom where opcom.opccod = plani.opccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Comercial Nao Cadastrada".
            undo, retry.
        end.
        disp opcom.opcnom with frame f1. */
        find tipmov where tipmov.movtdc = 1 no-lock.
        display plani.pladat with frame f1.
    end.
    display plani.bicms
            plani.icms
            plani.protot
            plani.frete
            plani.ipi
            plani.descpro
            plani.acfprod
            plani.platot with frame f2.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod  no-lock:
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
     message "Confirma Exclusao Da Nota Fiscal" plani.numero
     update sresp.
     if sresp
     then do on error undo:
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock:
            run atuest.p (input recid(movim),
                        input "E",
                        input 0).
        end.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod:
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
        delete plani.
     end.
end.
