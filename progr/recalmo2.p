{admcab.i}
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
/*
find last coletor where coletor.etbcod = vetbcod no-lock no-error.
*/

if avail coletor
then vdata1 = coletor.coldat.
else vdata1 = /*date(01,01,year(today))*/ 01/01/2010.

disp
       vdata1  label "Inicio" format "99/99/9999"  with frame f-data.
       
disp  vdata2   label "Fim" format "99/99/9999"
       with frame f-data.
repeat:
       update
       vprocod  format ">>>>>>>9" 
       with frame f-data 1 column.
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
    find produ where produ.procod = vprocod no-lock.
    disp vprocod with frame f-data.
    
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
    
    find last hiest where hiest.etbcod = vetbcod and
                    hiest.procod = vprocod and
                    hiest.hieano = year(vdata2) and
                    hiest.hiemes <= month(vdata2) 
                    no-error .
   /*
    message vsal-atu hiest.hiestf year(vdata2) month(vdata2). pause.
    */
    if avail hiest and
        vsal-atu <> hiest.hiestf
    then do:                               
        disp produ.pronom label "       Produto"
            /*vsal-ant label "Saldo Anterior"*/
            vsal-ent label "      Entradas"
            vsal-sai label "        Saidas"
            vsal-atu label "   Saldo Atual"
            vest-atu label " Saldo Estoque"
            vest-atu - vsal-atu label "       Diferenca" format "->>>>>9.99"
            vdtaux label "Auxiliar"
            bhiest.hiestf when avail bhiest label "Ant-aux"
            hiest.hiestf label "Atu-REG"
            with frame f-disp 1 down 1 column.
        sresp = no.
        message "Atualizar ? " update sresp.
        if sresp
        then do:  
            find estoq where estoq.etbcod = vetbcod and
                     estoq.procod = vprocod.
            if vdata2 = today
            then estoq.estatual = vsal-atu.
            hiest.hiestf = vsal-atu.
        end.
        hide frame f-disp.
    end.
    else do:
        message color red/with
        "Nenhuma divergencia encontrada."
        view-as alert-box.
    end.
end.
/*end. */
