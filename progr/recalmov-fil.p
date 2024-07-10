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
/*
find last coletor where coletor.etbcod = vetbcod no-lock no-error.
*/
def temp-table tt-produ like produ.
for each estoq where estoq.etbcod = 200 and
                     estoq.estatual < 0
                     no-lock.
    find first produ where
               produ.procod = estoq.procod
                         no-lock.
    create tt-produ.
    buffer-copy produ to tt-produ.                     
end.


if avail coletor
then vdata1 = coletor.coldat.
else vdata1 = /*date(01,01,year(today))*/ 01/01/2010.

def var vano as int format "9999".
def var vmes as int.
update vano with frame f-data 1 column.
do vmes = 1 to 5:

    vdata1 = date(vmes,1,vano).
    vdata2 = date(if vmes = 12 then 1 else vmes + 1,1,
                  if vmes = 12 then vano + 1 else vano) - 1.
    if vano = year(today) and
       vmes = month(today)
    then vdata2 = today.   
    disp
       vdata1  label "Inicio" format "99/99/9999"  with frame f-data.
       
    disp  vdata2   label "Fim" format "99/99/9999"
       with frame f-data.

vdtaux = vdata1 - 1.

for each tt-produ  no-lock:
    vprocod = tt-produ.procod.
    disp vprocod with 1 down frame f-disp.
    pause 0.
    /*
    for each movim where movim.procod = produ.proco and
                     movim.emite  = vetbcod and
                     movim.movdat >= vdata1  and
                     movim.movdat <= vdata2
                     no-lock.
      */
    
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
        .
        pause 0.
    end.
end.
end.
