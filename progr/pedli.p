/*                                                             pedli.p
*               Controle das Ordens de Compra por Fornecedor
*                   relatorio - compras
*/

{admcab.i }
def temp-table wfcla
    field clacod like produ.clacod
    field clanom like clase.clanom.
def var vdtini      as   date format "99/99/9999".
def var vdtfin      as   date format "99/99/9999".
def var wtot        like pedid.pedtot.
def var vlipqtd     like liped.lipqtd.
def var vlipqtdent  like liped.lipqtd.
def var vforcod     like forne.forcod.
def var vclacod     like clase.clacod.
def var vachei      as log.
def buffer bliped   for liped.
def var wtotent     like pedid.pedtot.
def var wtotentger  like pedid.pedtot.
def var vencontrei  as log.
vdtfin = today.
disp setbcod @ estab.etbcod with frame f1.
prompt-for estab.etbcod with frame f1.
find estab using estab.etbcod no-lock.
disp estab.etbnom no-label skip with frame f1.
update vforcod label "Fornecedor" with frame f1.
if vforcod <> 0
then do:
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        bell.
        message "Fornecedor nao Cadastrado".
        undo.
    end.
    else disp forne.fornom no-label format "x(30)" with frame f1.
end.
else disp "TODOS FORNECEDORES" with frame f1.

update vclacod skip with frame f1.

update
       "Periodo de"
       vdtini   no-label
        validate(vdtini <> ?,"Data Inicial Deve Ser Informada")
        help "Informe a Data Inicial do Periodo"
       "a"
       with frame f1.
update
       vdtfin  no-label
       validate(vdtfin >= vdtini,
                    "Data Final deve ser Igual ou Maior que a Inicial")
        help "Informe a Data Final do Periodo"
       with side-label centered frame f1
            row 5 color black/cyan.

if vclacod <> 0
then do:


{mdadmcab.i
    &Saida     = "printer"
    &Page-Size = "59"
    &Cond-Var  = "137"
    &Page-Line = "59"
    &Nom-Rel   = ""PEDLI""
    &Nom-Sis   = """SISTEMA COMERCIAL - COMPRAS"""
    &Tit-Rel   = """CONTROLE DE COMPRAS CLASSE/FORN - PERIODO DE ""
                            + string(vdtini,""99/99/9999"") +
                            "" A ""  + string(vdtfin,""99/99/9999"") "
    &Width     = "137"
    &Form      = "frame f-cabcab"}
form with frame flin down.


find estab where estab.etbcod = input estab.etbcod.

disp space "LOJA:" space(2)
   estab.etbnom no-label space(10)

   skip fill("-",137) format "x(137)" skip
   with no-label with frame floja width 160.

find clase where clase.clacod = vclacod no-lock.
disp clase.clacod
     clase.clanom no-label
           skip fill("-",137) format "x(137)" skip
             with frame f-cla side-label width 160.

for each pedid where pedid.pedtdc = 1 and
                     pedid.etbcod = estab.etbcod and
                     pedid.peddti >= vdtini and
                     pedid.peddtf <= vdtfin and
                     (if vforcod = 0
                        then true
                        else pedid.clfcod = vforcod)
                     no-lock,
               each forne where forne.forcod = pedid.clfcod no-lock
                     break by forne.fornom
                           by pedid.pednum:

    for each bliped of pedid:
        wtotent = wtotent + (bliped.lipent * bliped.lippreco).
        wtotentger = wtotentger + (bliped.lipent * bliped.lippreco).
    end.
    vachei = no.

    for each liped of pedid no-lock,
            each produ of liped no-lock.
            if produ.clacod = vclacod
            then vachei = yes.
    end.

    if vachei
    then do:
        wtot = wtot + pedid.pedtot.
        /*if first-of(forne.fornom)
        then do:*/
            disp forne.forcod
                 forne.fornom with frame f2 width 160 down.
        /*end.*/

        disp pedid.pednum   space(4)
             pedid.peddat   space(4)
             pedid.peddti space(4)
             pedid.peddtf space(4)
             pedid.pedtot(total)    column-label "Total Pedido"
             wtotent(total)         column-label "Total Entreg" skip(1)
                    with frame f2.

        vlipqtd = 0.
        for each liped of pedid no-lock,
            each produ where produ.procod = liped.procod and
                             produ.clacod = vclacod no-lock
            break BY liped.pednum
                  by produ.itecod:

            vlipqtd = vlipqtd + liped.lipqtd.
            vlipqtdent = vlipqtdent + liped.lipent.

            if last-of(produ.itecod)
            then do:
                put
                    "REF: " at 10
                    produ.prorefter format "x(13)" at 16 space(1)
                    produ.pronom space(1)
                    "PED: " vlipqtd format ">>>9" space(4)
                    "ENT: "vlipqtdent format ">>>9" space(2)
                    liped.lippreco space(3)
                    (vlipqtd * liped.lippreco) space(3)
                    (vlipqtdent * liped.lippreco).
                vlipqtd = 0.
                vlipqtdent = 0.
            end.
            if last-of (pedid.pednum)
            then put skip.
            if last-of (liped.pednum)
            then put skip(1).

        end.
        if last-of(forne.fornom)
        then do:
                put "------------" at 106
                    "------------" at 119 skip
                     wtot           at 106
                     wtotentger     at 119.
                wtot = 0.
                wtotentger = 0.
                put skip.

       put skip(1) fill("-",134) format "x(134)" skip.
       end.
    end.
end.
end.

else do:

{mdadmcab.i
    &Saida     = "printer"
    &Page-Size = "59"
    &Cond-Var  = "137"
    &Page-Line = "59"
    &Nom-Rel   = ""PEDLI""
    &Nom-Sis   = """SISTEMA COMERCIAL - COMPRAS"""
    &Tit-Rel   = """CONTROLE DE COMPRAS FORN/CLASSE - PERIODO DE ""
                            + string(vdtini,""99/99/9999"") +
                            "" A ""  + string(vdtfin,""99/99/9999"") "
    &Width     = "137"
    &Form      = "frame f-cabcabx"}
form with frame flinx down.


find estab where estab.etbcod = input estab.etbcod.

disp space "LOJA:" space(2)
   estab.etbnom no-label space(10)

   skip fill("-",137) format "x(137)" skip
   with no-label with frame flojax width 160.

for each pedid where pedid.pedtdc = 1 and
                     pedid.etbcod = estab.etbcod and
                     pedid.peddti >= vdtini and
                     pedid.peddtf <= vdtfin and
                     (if vforcod = 0
                        then true
                        else pedid.clfcod = vforcod)
                     no-lock.
    for each liped of pedid no-lock,
            each produ of liped no-lock.

        find first wfcla where wfcla.clacod = produ.clacod no-error.
        if not avail wfcla
        then do:
            find clase where clase.clacod = produ.clacod.
            create wfcla.
            assign wfcla.clacod = produ.clacod
                   wfcla.clanom = clase.clanom.
        end.
    end.
end.
for each wfcla by wfcla.clanom.

find clase where clase.clacod = wfcla.clacod.

vclacod = clase.clacod.
disp clase.clacod
     clase.clanom no-label
           skip fill("-",137) format "x(137)" skip
             with frame f-clax side-label width 160.

for each pedid where pedid.pedtdc = 1 and
                     pedid.etbcod = estab.etbcod and
                     pedid.peddti >= vdtini and
                     pedid.peddtf <= vdtfin and
                     (if vforcod = 0
                        then true
                        else pedid.clfcod = vforcod)
                     no-lock,
               each forne where forne.forcod = pedid.clfcod no-lock
                     break by forne.fornom
                           by pedid.pednum:

    for each bliped of pedid:
        wtotent = wtotent + (bliped.lipent * bliped.lippreco).
        wtotentger = wtotentger + (bliped.lipent * bliped.lippreco).
    end.
    vachei = no.

    for each liped of pedid no-lock,
            each produ of liped no-lock.
            if produ.clacod = vclacod
            then vachei = yes.
    end.

    if vachei
    then do:
        wtot = wtot + pedid.pedtot.
        /*if first-of(forne.fornom)
        then do:*/
            disp forne.forcod
                 forne.fornom with frame f2x width 160 down.
        /*end.*/

        disp pedid.pednum   space(4)
             pedid.peddat   space(4)
             pedid.peddti space(4)
             pedid.peddtf space(4)
             pedid.pedtot(total)    column-label "Total Pedido"
             wtotent(total)         column-label "Total Entreg" skip(1)
                    with frame f2x.

        vlipqtd = 0.
        for each liped of pedid no-lock,
            each produ where produ.procod = liped.procod and
                             produ.clacod = vclacod no-lock
            break BY liped.pednum
                  by produ.itecod:

            vlipqtd = vlipqtd + liped.lipqtd.
            vlipqtdent = vlipqtdent + liped.lipent.

            if last-of(produ.itecod)
            then do:
                put
                    "REF: " at 10
                    produ.prorefter  format "x(13)" at 16 space(1)
                    produ.pronom space(1)
                    "PED: " vlipqtd format ">>>9" space(4)
                    "ENT: "vlipqtdent format ">>>9" space(2)
                    liped.lippreco space(3)
                    (vlipqtd * liped.lippreco) space(3)
                    (vlipqtdent * liped.lippreco).
                vlipqtd = 0.
                vlipqtdent = 0.
            end.
            if last-of (pedid.pednum)
            then put skip.
            if last-of (liped.pednum)
            then put skip(1).

        end.
        if last-of(forne.fornom)
        then do:
                put "------------" at 106
                    "------------" at 119 skip
                     wtot           at 106
                     wtotentger     at 119.
                wtot = 0.
                wtotentger = 0.
                put skip.

       put skip(1) fill("-",137) format "x(137)" skip.
       end.
    end.
end.
end.
end.
