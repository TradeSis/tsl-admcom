{admcab.i new}
def buffer bhiest for hies.
def var vetbcod like estab.etbcod.
def var vdata1 as date.
def var vdata2 as date.
def var vdtaux as date.
def var vprocod like produ.procod.
def var vsal-ant as dec.
def var vsal-ent as dec.
def var vsal-sai as dec.
def var vsal-atu as dec.
def var vest-atu as dec.
vetbcod = 0.
vdata1 = today.
vdata2 = today.
update vetbcod label "Filial" with frame f-data.


def temp-table tt-promov
 field procod like produ.procod
 field datmov as date
 field vsal-atu as dec
 field vest-atu as dec
 index i1 procod.

 /*
for each movim where movim.etbcod = vetbcod and
                     movim.movdat >= 03/28/12 /*and
                     movim.procod = 1003 */   
                     no-lock.
    find first tt-promov where tt-promov.procod = movim.procod no-error.
    if not avail tt-promov
    then do:
        create tt-promov.
        tt-promov.procod = movim.procod.
    end.
    if tt-promov.datmov < movim.movdat
    then tt-promov.datmov = movim.movdat.

end.
   */
/*
find last coletor where coletor.etbcod = vetbcod no-lock no-error.
*/

if avail coletor
then vdata1 = coletor.coldat.
else vdata1 = /*date(01,01,year(today))*/ 01/01/2011.
vdata1 = 03/01/2012.

disp
       vdata1  label "Inicio" format "99/99/9999"  with frame f-data.
       
disp  vdata2   label "Fim" format "99/99/9999"
       with frame f-data.
def var vforcod like forne.forcod.
def var vnumero like plani.numero.

update vforcod vnumero .

for each plani where plani.etbcod = vforcod and
                     plani.movtdc = 6 and
                     plani.emite = vforcod and
                     plani.desti = vetbcod and
                     plani.numero = vnumero and
                     plani.pladat >= 03/01/12
                      no-lock.

disp plani.numero.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock.   
    find first tt-promov where tt-promov.procod = movim.procod no-error.
    if not avail tt-promov
    then do:
        create tt-promov.
        tt-promov.procod = movim.procod.
    end.
    if tt-promov.datmov < movim.movdat
    then tt-promov.datmov = movim.movdat.

end.
                      
end.                      

def var varq as char.
varq = "/admcom/work/auditoria/recalest-" + string(vetbcod,"999") + "-cl.txt".
update varq format "x(60)" label "Arquivo log".                                
                     
repeat:
/*
       update
       vprocod  format ">>>>>>>9" 
       with frame f-data 1 column.
*/
vdtaux = vdata1 - 1.

/*
for each movim where movim.etbcod = vetbcod and
                     movim.movtdc = 4 and
                     movim.movdat >= vdata1  and
                     movim.movdat <= vdata2 and
                     (if vprocod > 0
                     then movim.procod = vprocod else true)
                     no-lock.
    find produ where produ.procod = movim.procod no-lock.                     
*/

/*
for each produ where (if vprocod > 0
            then produ.procod = vprocod else true) no-lock:
    vprocod = produ.procod.
  */

for each tt-promov.
    find produ where produ.procod = tt-promov.procod no-lock no-error.
    if not avail produ then next.
    vprocod = produ.procod.
    disp vprocod with frame f-data.
    
    if produ.pronom matches "*recarga*"
    then next.
    if produ.pronom matches "*presente*"
    then next.
    if produ.pronom matches "*freteiro*"
    then next.
    
    assign
        vsal-ant = 0
        vsal-ent = 0
        vsal-sai = 0
        vsal-atu = 0
        vest-atu = 0
        .
        
    run extmovpr.p(input vetbcod,
                                      input vdata1,
                                      input vdata2,
                                      input vprocod,
                                      output vsal-ant,
                                      output vsal-ent,
                                      output vsal-sai,
                                      output vsal-atu,
                                      output vest-atu).
                  
    find last bhiest where bhiest.etbcod = vetbcod and
                    bhiest.procod = vprocod and
                    bhiest.hieano = year(vdtaux) and
                    bhiest.hiemes = month(vdtaux)
                     no-lock no-error
                     .
    find estoq where estoq.etbcod = vetbcod and
                         estoq.procod = vprocod.
 
    find last hiest where hiest.etbcod = vetbcod and
                    hiest.procod = vprocod and
                    hiest.hieano = year(vdata2) and
                    hiest.hiemes = month(vdata2) 
                    no-error .
    if not avail hiest
    then do:
        create hiest.
                assign hiest.etbcod = vetbcod
                    hiest.procod = vprocod
                    hiest.hiemes = month(vdata2)
                    hiest.hieano =  year(vdata2).

                hiest.hiestf = estoq.estatual.
                hiest.hiepcf = estoq.estcusto.
                hiest.hiepvf = estoq.estvenda.
 
    end.
    if (avail hiest and
        vsal-atu <> hiest.hiestf ) or
       (avail estoq  and   
        vsal-atu  <> estoq.estatual)
    then do:                               
        disp produ.procod(count)
            /*produ.pronom label "       Produto"
             */
            /*vsal-ent label "      Entradas"
            vsal-sai label "        Saidas"
            */
            vsal-atu label "   Saldo Atual"
            vest-atu label " Saldo Estoque"
            vsal-atu - vest-atu label "       Diferenca" format "->>>>>9.99"
            /*
            vdtaux label "Auxiliar"
            bhiest.hiestf when avail bhiest label "Ant-aux"
            hiest.hiestf label "Atu-REG"
            */
            with frame f-disp 1 down 1 column.
            .
               pause .
        /*sresp = no.
        message "Atualizar ? " update sresp.
        if sresp
        then*/ do:  
            assign
                tt-promov.vsal-atu = vsal-atu
                tt-promov.vest-atu = vest-atu
                .
            find estoq where estoq.etbcod = vetbcod and
                     estoq.procod = vprocod.
            if vdata2 = today
            then estoq.estatual = vsal-atu.
            if not avail hiest
           then do:
                create hiest.
                assign hiest.etbcod = estoq.etbcod
                    hiest.procod = estoq.procod
                    hiest.hiemes = month(today)
                    hiest.hieano =  year(today).

                hiest.hiestf = estoq.estatual.
                hiest.hiepcf = estoq.estcusto.
                hiest.hiepvf = estoq.estvenda.
           end.
            hiest.hiestf = vsal-atu.
        end.
        hide frame f-disp.
    end.
    end.

    output to value(varq) page-size 0.
    for each tt-promov where tt-promov.vsal-atu <> 0 or
                             tt-promov.vest-atu <> 0.
        disp tt-promov.procod    column-label "Produto"
             tt-promov.vsal-atu  column-label "Sal. Mov."
             tt-promov.vest-atu  column-label "Sal. Est."
             tt-promov.vsal-atu - tt-promov.vest-atu
             column-label "Dif"
             with frame ff down.
             
    end.
    output close.
    leave.
end.
