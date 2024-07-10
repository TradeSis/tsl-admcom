/*                                                             pedlifo.p
*               Controle das Ordens de Compra por Fornecedor
*                   relatorio - compras
*/

{admcab.i}
def var vdtini      as   date format "99/99/9999".
def var vdtfin      as   date format "99/99/9999".
def var wtot        like pedid.pedtot.
def var wtotent     like pedid.pedtot.
def var wtotentger  like pedid.pedtot.
def var vlipqtd     like liped.lipqtd.
def var vlipqtdent  like liped.lipqtd.
def var vforcod     like forne.forcod.

def buffer bliped for liped.

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



{mdadmcab.i
    &Saida     = "printer"
    &Page-Size = "59"
    &Cond-Var  = "134"
    &Page-Line = "59"
    &Nom-Rel   = ""PEDLIFO""
    &Nom-Sis   = """SISTEMA COMERCIAL - COMPRAS"""
    &Tit-Rel   = """CONTROLE DAS ORDENS DE COMPRA - PERIODO DE ""
                            + string(vdtini,""99/99/9999"") +
                            "" A ""  + string(vdtfin,""99/99/9999"") "
    &Width     = "134"
    &Form      = "frame f-cabcab"}
form with frame flin down.


find estab where estab.etbcod = input estab.etbcod.

disp space "LOJA:" space(2)
   estab.etbnom no-label space(10)

   skip fill("-",134) format "x(134)" skip
   with no-label with frame floja width 160.

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

                     wtot = wtot + pedid.pedtot.

    for each bliped of pedid:
        wtotent = wtotent + (bliped.lipent * bliped.lippreco).
        wtotentger = wtotentger + (bliped.lipent * bliped.lippreco).
    end.

    if first-of(forne.fornom)
    then do:

        disp forne.forcod
             forne.fornom format "x(45)" with frame f2 width 160 down.
    end.

    disp pedid.pednum   space(3)
         pedid.peddat   format "99/99/9999" space(3) 
         pedid.peddti   format "99/99/9999" space(3) 
         pedid.peddtf   format "99/99/9999" space(3)  
         pedid.pedtot(total)    column-label "Total Pedido"
         wtotent(total)         column-label "Total Entreg" skip(1)
         with frame f2.
    wtotent = 0.

    vlipqtd = 0.
    vlipqtdent = 0.
    for each liped of pedid no-lock,
        each produ of liped no-lock
        break BY liped.pednum
              by produ.itecod:

        vlipqtd = vlipqtd + liped.lipqtd.
        vlipqtdent = vlipqtdent + liped.lipent.

        if last-of(produ.itecod)
        then do:
           put
               "REF: " at 10
               produ.prorefter  format "x(13)" at 16 space(1)
               produ.pronom format "x(40)" space(1)
               "PED: " vlipqtd format ">>>9" space(4)
               "ENT: "vlipqtdent format ">>>9" space(2)
               liped.lippreco format ">>>,>>9.99" space(3)
               (vlipqtd * liped.lippreco) format ">>>,>>9.99" space(3)
               (vlipqtdent * liped.lippreco) format ">>>,>>9.99".
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
