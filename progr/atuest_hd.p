def buffer bhimov for com.himov.
DEF BUFFER BESTOQ FOR com.ESTOQ.
DEF BUFFER xESTOQ FOR com.ESTOQ.
def input parameter vrecmov as recid.
def input parameter vtipo   as char.
def input parameter vqtd    as i.


find com.movim where recid(com.movim) = vrecmov no-lock no-error.
if not avail com.movim
then return.
 
if month(com.movim.datexp) <> month(today) 
then do: 
    find movdat where movdat.etbcod = com.movim.etbcod and 
                      movdat.placod = com.movim.placod and 
                      movdat.procod = com.movim.procod no-error.
    if not avail movdat 
    then do: 
        create movdat. 
        assign movdat.procod = com.movim.procod 
               movdat.etbcod = com.movim.etbcod 
               movdat.placod = com.movim.placod 
               movdat.datent = today.
    end.
    
end. 
                       


if com.movim.movtdc = 6 or com.movim.movtdc = 3
then do:

    
    find first com.plani where com.plani.etbcod = com.movim.etbcod and
                           com.plani.placod = com.movim.placod and
                           com.plani.movtdc = com.movim.movtdc and
                           com.plani.pladat = com.movim.movdat no-lock no-error.
    if not avail com.plani
    then return.



    /**************  TRANSFERENCIA - SAIDA ******************/
    find com.estoq where com.estoq.etbcod = com.plani.emite and
                     com.estoq.procod = com.movim.procod no-error.
    if not avail com.estoq
    then do:
        find first xestoq where xestoq.procod = com.movim.procod no-lock.
        create com.estoq.
        assign com.estoq.etbcod = com.plani.emite
               com.estoq.procod = com.movim.procod
               com.estoq.estcusto = xestoq.estcusto
               com.estoq.estvenda = xestoq.estvenda.
    end.

    if com.plani.emite <> 22
    then do:
        if vtipo = "I"
        then com.estoq.estatual = com.estoq.estatual - com.movim.movqtm.
        if vtipo = "E"
        then com.estoq.estatual = com.estoq.estatual + com.movim.movqtm.
        if vtipo = "A"
        then com.estoq.estatual = com.estoq.estatual + vqtd - com.movim.movqtm.
    
    end.

    find com.hiest where com.hiest.etbcod = com.plani.emite         and
                     com.hiest.procod = com.movim.procod        and
                     com.hiest.hiemes = month(today) and
                     com.hiest.hieano =  year(today) no-error.
    if not avail com.hiest
    then do:
        create com.hiest.
        assign com.hiest.etbcod = com.plani.emite
               com.hiest.procod = com.movim.procod
               com.hiest.hiemes = month(today)
               com.hiest.hieano =  year(today).
    end.

    com.hiest.hiestf = com.estoq.estatual.
    com.hiest.hiepcf = com.estoq.estcusto.
    com.hiest.hiepvf = com.estoq.estvenda.
    

    /******************** FIM TRANSFERENCIA - SAIDA ***************/


    /******************** TRANSFERENCIA - ENTRADA *****************/

    find bestoq where bestoq.etbcod = com.plani.desti and
                      bestoq.procod = com.movim.procod no-error.
    if not avail bestoq
    then do:
        find first xestoq where xestoq.procod = com.movim.procod no-lock.
        create bestoq.
        assign bestoq.etbcod = com.plani.desti
               bestoq.procod = com.movim.procod
               bestoq.estcusto = xestoq.estcusto
               bestoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then bestoq.estatual = bestoq.estatual + com.movim.movqtm.
    if vtipo = "E"
    then bestoq.estatual = bestoq.estatual - com.movim.movqtm.
    if vtipo = "A"
    then  bestoq.estatual = bestoq.estatual - vqtd + com.movim.movqtm.

    find com.hiest where com.hiest.etbcod = com.plani.desti         and
                     com.hiest.procod = com.movim.procod        and
                     com.hiest.hiemes = month(today) and
                     com.hiest.hieano =  year(today) no-error.
    if not avail com.hiest
    then do:
        create com.hiest.
        assign com.hiest.etbcod = com.plani.desti
               com.hiest.procod = com.movim.procod
               com.hiest.hiemes = month(today)
               com.hiest.hieano =  year(today).
    end.

    com.hiest.hiestf = bestoq.estatual.
    com.hiest.hiepcf = bestoq.estcusto.
    com.hiest.hiepvf = bestoq.estvenda.


    find bhimov where bhimov.etbcod = com.plani.emite         and
                      bhimov.movtdc = 6                   and
                      bhimov.procod = com.movim.procod        and
                      bhimov.himmes = month(today) and
                      bhimov.himano =  year(today) no-error.
    if not avail bhimov 
    then do:
        create bhimov.
        assign bhimov.etbcod = com.plani.emite
               bhimov.movtdc = 6
               bhimov.procod = com.movim.procod
               bhimov.himmes = month(today)
               bhimov.himano =  year(today).
    end.
    if vtipo = "I"
    then bhimov.himqtm = bhimov.himqtm + com.movim.movqtm.
    if vtipo = "E"
    then bhimov.himqtm = bhimov.himqtm - com.movim.movqtm.
    if vtipo = "A"
    then  bhimov.himqtm = bhimov.himqtm - vqtd + com.movim.movqtm.

    
    /******************************************************/
    
    find com.himov where com.himov.etbcod = com.plani.desti         and
                     com.himov.movtdc = 7                   and
                     com.himov.procod = com.movim.procod        and
                     com.himov.himmes = month(today) and
                     com.himov.himano =  year(today) no-error.
    if not avail com.himov
    then do:
        create com.himov.
        assign com.himov.etbcod = com.plani.desti
               com.himov.movtdc = 7
               com.himov.procod = com.movim.procod
               com.himov.himmes = month(today)
               com.himov.himano =  year(today).
    end.
    if vtipo = "I"
    then com.himov.himqtm = com.himov.himqtm + com.movim.movqtm.
    if vtipo = "E"
    then com.himov.himqtm = com.himov.himqtm - com.movim.movqtm.
    if vtipo = "A"
    then  com.himov.himqtm = com.himov.himqtm - vqtd + com.movim.movqtm.


    /****************** FIM TRANSFERENCIA - ENTRADA *****************/

end.

    
    /********************** INICIO ENTRADA **********************/
if com.movim.movtdc = 4 or
   com.movim.movtdc = 1 or
   com.movim.movtdc = 7 or
   com.movim.movtdc = 12 or
   com.movim.movtdc = 15 or
   com.movim.movtdc = 17
then do:
    find com.estoq where com.estoq.etbcod = com.movim.etbcod and
                     com.estoq.procod = com.movim.procod no-error.
    if not avail com.estoq
    then do:
        find first xestoq where xestoq.procod = com.movim.procod no-lock.
        create com.estoq.
        assign com.estoq.etbcod = com.movim.etbcod
               com.estoq.procod = com.movim.procod
               com.estoq.estcusto = xestoq.estcusto
               com.estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then com.estoq.estatual = com.estoq.estatual + com.movim.movqtm.
    if vtipo = "E"
    then com.estoq.estatual = com.estoq.estatual - com.movim.movqtm.
    if vtipo = "A"
    then  com.estoq.estatual = com.estoq.estatual - vqtd + com.movim.movqtm.
    
    
    find com.hiest where com.hiest.etbcod = com.movim.etbcod        and
                     com.hiest.procod = com.movim.procod        and
                     com.hiest.hiemes = month(today) and
                     com.hiest.hieano =  year(today) no-error.
    if not avail com.hiest
    then do:
        create com.hiest.
        assign com.hiest.etbcod = com.movim.etbcod
               com.hiest.procod = com.movim.procod
               com.hiest.hiemes = month(today)
               com.hiest.hieano =  year(today).
    end.
    
    com.hiest.hiestf = com.estoq.estatual.
    com.hiest.hiepcf = com.estoq.estcusto.
    com.hiest.hiepvf = com.estoq.estvenda.
   
    
    if com.movim.movtdc = 4 or
       com.movim.movtdc = 1
    then do:
    
        find com.himov where com.himov.etbcod = com.movim.etbcod        and
                         com.himov.movtdc = 4                   and
                         com.himov.procod = com.movim.procod        and
                         com.himov.himmes = month(today) and
                         com.himov.himano = year(today) no-error.
        if not avail com.himov
        then do:
            create com.himov.
            assign com.himov.etbcod = com.movim.etbcod
                   com.himov.movtdc = 4
                   com.himov.procod = com.movim.procod
                   com.himov.himmes = month(today)
                   com.himov.himano =  year(today).
        end.
        if vtipo = "I"
        then com.himov.himqtm = com.himov.himqtm + com.movim.movqtm.
        if vtipo = "E"
        then com.himov.himqtm = com.himov.himqtm - com.movim.movqtm.
        if vtipo = "A"
        then  com.himov.himqtm = com.himov.himqtm - vqtd + com.movim.movqtm.
    end.
end.
    /**************************  FIM ENTRADA ************************/


    /*********************** INICIO SAIDA ***********************/
if com.movim.movtdc = 5 or
   com.movim.movtdc = 13 or
   com.movim.movtdc = 14 or
   com.movim.movtdc = 16 or
   com.movim.movtdc = 8  or
   com.movim.movtdc = 18
then do:

    find com.estoq where com.estoq.etbcod = com.movim.etbcod and
                     com.estoq.procod = com.movim.procod no-error.
    if not avail com.estoq
    then do:
        find first xestoq where xestoq.procod = com.movim.procod no-lock.
        create com.estoq.
        assign com.estoq.etbcod = com.movim.etbcod
               com.estoq.procod = com.movim.procod
               com.estoq.estcusto = xestoq.estcusto
               com.estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then com.estoq.estatual = com.estoq.estatual - com.movim.movqtm.
    if vtipo = "E"
    then com.estoq.estatual = com.estoq.estatual + com.movim.movqtm.
    if vtipo = "A"
    then  com.estoq.estatual = com.estoq.estatual + vqtd - com.movim.movqtm.

                                       
    find com.hiest where com.hiest.etbcod = com.movim.etbcod        and
                     com.hiest.procod = com.movim.procod        and
                     com.hiest.hiemes = month(today) and
                     com.hiest.hieano =  year(today) no-error.
    if not avail com.hiest
    then do:
        create com.hiest.
        assign com.hiest.etbcod = com.movim.etbcod
               com.hiest.procod = com.movim.procod
               com.hiest.hiemes = month(today)
               com.hiest.hieano =  year(today).
    end.

    com.hiest.hiestf = com.estoq.estatual.
    com.hiest.hiepcf = com.estoq.estcusto.
    com.hiest.hiepvf = com.estoq.estvenda.
 


    if com.movim.movtdc = 5
    then do:
        find com.himov where com.himov.etbcod = com.movim.etbcod        and
                         com.himov.movtdc = com.movim.movtdc        and
                         com.himov.procod = com.movim.procod        and
                         com.himov.himmes = month(today) and
                         com.himov.himano =  year(today) no-error.
        if not avail com.himov
        then do:
            create com.himov.
            assign com.himov.etbcod = com.movim.etbcod
                   com.himov.movtdc = 5
                   com.himov.procod = com.movim.procod
                   com.himov.himmes = month(today)
                   com.himov.himano =  year(today).
        end.
        if vtipo = "I"
        then com.himov.himqtm = com.himov.himqtm + com.movim.movqtm.
        if vtipo = "E"
        then com.himov.himqtm = com.himov.himqtm - com.movim.movqtm.
        if vtipo = "A"
        then  com.himov.himqtm = com.himov.himqtm - vqtd + com.movim.movqtm.
    end.
end.

    /**************************** FIM SAIDA *************************/



