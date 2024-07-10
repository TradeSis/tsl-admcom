/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/
 
{admcab.i}
def var vdata   like plani.pladat.
def var vetbcod like estab.etbcod.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var totcus like plani.platot.
def var totven like plani.platot.
def var confec like plani.platot.
def var moveis like plani.platot.
def var outros like plani.platot.

repeat:
    totcus = 0.
    totven = 0.
    confec = 0.
    moveis = 0.
    outros = 0.
    update vetbcod label " Filial" with frame f-pro.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-pro.
    update vdata1 label "Periodo" colon 55
           vdata2 no-label with frame f-pro width 80 side-label.

    for each plani where plani.movtdc = 05           and
                         plani.etbcod = estab.etbcod and
                         plani.pladat >= vdata1      and
                         plani.pladat <= vdata2 no-lock:
      
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
            find produ where produ.procod = movim.procod no-lock.
            if produ.catcod = 41
            then confec = confec + movim.movqtm.
            if produ.catcod = 31
            then moveis = moveis + movim.movqtm.
            if produ.catcod <> 41 and
               produ.catcod <> 31
            then outros = outros + movim.movqtm.

            display movim.etbcod
                    movim.movdat
                    movim.movqtm
                    movim.movpc
                    (movim.movqtm * movim.movpc)
                        with frame f-total 1 down. 
            pause 0.
        end.
    end.
    hide frame f-total no-pause. 
    disp confec label "Confeccoes"
         moveis label "Moveis"
         outros label "Outros" 
        with frame f-total1 side-label centered row 10 overlay. 
end.

