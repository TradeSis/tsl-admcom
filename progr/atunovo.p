def buffer bestpro for germatriz.estpro.
def buffer bhimov for commatriz.himov.
DEF BUFFER BESTOQ FOR commatriz.ESTOQ.
DEF BUFFER xESTOQ FOR commatriz.ESTOQ.
def input parameter vrecmov as recid.
def input parameter vtipo   as char.
def input parameter vqtd    as i.
def var vlog as char.
vlog = "/usr/admcom/work/atunovo.log".

find commatriz.movim where recid(commatriz.movim) = vrecmov no-lock no-error.
if not avail commatriz.movim
then do:
    next.
end.

if month(commatriz.movim.datexp) <> month(today)
then do:
    output to value(vlog) append.
        put commatriz.movim.placod format "9999999999" space(1)
            commatriz.movim.etbcod space(1)
            commatriz.movim.movdat space(1)
            commatriz.movim.datexp format "99/99/9999" space(1)
            today format "99/99/9999"        space(1)
            commatriz.movim.procod skip.
    output close.
end. 
                       
find commatriz.produ where 
     commatriz.produ.procod = commatriz.movim.procod no-lock no-error.
if not avail commatriz.produ
then do:
    output to value(vlog) append.
        put commatriz.movim.procod space(1)
            commatriz.movim.etbcod space(1)
            commatriz.movim.placod format "9999999999" space(1)
            commatriz.movim.movdat space(1)
            commatriz.movim.movtdc format "99" space(1) skip.
    output close.
end.

if commatriz.movim.movtdc = 6
then do:
    find first commatriz.plani where 
               commatriz.plani.etbcod = commatriz.movim.etbcod and
               commatriz.plani.placod = commatriz.movim.placod and
               commatriz.plani.movtdc = commatriz.movim.movtdc and
               commatriz.plani.pladat = commatriz.movim.movdat   no-lock
                                                                no-error.
    if not avail commatriz.plani
       then do:    
        next.
    end.
    /**************  TRANSFERENCIA - SAIDA ******************/
    find commatriz.estoq where 
         commatriz.estoq.etbcod = commatriz.plani.emite and
         commatriz.estoq.procod = commatriz.movim.procod no-error.
    if not avail commatriz.estoq
    then do:
        find first xestoq where 
                   xestoq.procod = commatriz.movim.procod no-lock.
        create commatriz.estoq.
        assign commatriz.estoq.etbcod = commatriz.plani.emite
               commatriz.estoq.procod = commatriz.movim.procod
               commatriz.estoq.estcusto = xestoq.estcusto
               commatriz.estoq.estvenda = xestoq.estvenda.
    end.

    if commatriz.plani.emite <> 22
    then do:
        if vtipo = "I"
        then commatriz.estoq.estatual = 
             commatriz.estoq.estatual - commatriz.movim.movqtm.
        if vtipo = "E"
        then commatriz.estoq.estatual = 
             commatriz.estoq.estatual + commatriz.movim.movqtm.
        if vtipo = "A"
        then commatriz.estoq.estatual = 
             commatriz.estoq.estatual + vqtd - movim.movqtm.
    
        find germatriz.estpro where 
             germatriz.estpro.procod = commatriz.estoq.procod no-error.
        if not avail germatriz.estpro
        then do:
            create germatriz.estpro.
            assign germatriz.estpro.procod = commatriz.estoq.procod.
        end.
        assign germatriz.estpro.estatual[plani.emite] = commatriz.estoq.estatual
               germatriz.estpro.estcusto[plani.emite] = commatriz.estoq.estcusto
               germatriz.estpro.estvenda[plani.emite] =                                                      commatriz.estoq.estvenda.
    end.

    find commatriz.hiest where 
                     commatriz.hiest.etbcod = commatriz.plani.emite         and
                     commatriz.hiest.procod = commatriz.movim.procod        and
                     commatriz.hiest.hiemes = month(today) and
                     commatriz.hiest.hieano =  year(today) no-error.
    if not avail commatriz.hiest
    then do:
        create commatriz.hiest.
        assign commatriz.hiest.etbcod = commatriz.plani.emite
               commatriz.hiest.procod = commatriz.movim.procod
               commatriz.hiest.hiemes = month(today)
               commatriz.hiest.hieano =  year(today).
    end.

    commatriz.hiest.hiestf = commatriz.estoq.estatual.
    commatriz.hiest.hiepcf = commatriz.estoq.estcusto.
    commatriz.hiest.hiepvf = commatriz.estoq.estvenda.

    /******************** FIM TRANSFERENCIA - SAIDA ***************/

    /******************** TRANSFERENCIA - ENTRADA *****************/

    find bestoq where bestoq.etbcod = commatriz.plani.desti and
                      bestoq.procod = commatriz.movim.procod no-error.
    if not avail bestoq
    then do:
        find first xestoq where xestoq.procod = commatriz.movim.procod no-lock.
        create bestoq.
        assign bestoq.etbcod = commatriz.plani.desti
               bestoq.procod = commatriz.movim.procod
               bestoq.estcusto = xestoq.estcusto
               bestoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then bestoq.estatual = bestoq.estatual + commatriz.movim.movqtm.
    if vtipo = "E"
    then bestoq.estatual = bestoq.estatual - commatriz.movim.movqtm.
    if vtipo = "A"
    then  bestoq.estatual = bestoq.estatual - vqtd + commatriz.movim.movqtm.

    find bestpro where bestpro.procod = bestoq.procod no-error.
    if not avail bestpro
    then do:
        create bestpro.
        assign bestpro.procod = bestoq.procod.
    end.
    assign bestpro.estatual[plani.desti] = bestoq.estatual
           bestpro.estcusto[plani.desti] = bestoq.estcusto
           bestpro.estvenda[plani.desti] = bestoq.estvenda.

    find commatriz.hiest where 
         commatriz.hiest.etbcod = commatriz.plani.desti         and
         commatriz.hiest.procod = commatriz.movim.procod        and
         commatriz.hiest.hiemes = month(today) and
         commatriz.hiest.hieano =  year(today) no-error.
    if not avail commatriz.hiest
    then do:
        create commatriz.hiest.
        assign commatriz.hiest.etbcod = commatriz.plani.desti
               commatriz.hiest.procod = commatriz.movim.procod
               commatriz.hiest.hiemes = month(today)
               commatriz.hiest.hieano =  year(today).
    end.

    commatriz.hiest.hiestf = bestoq.estatual.
    commatriz.hiest.hiepcf = bestoq.estcusto.
    commatriz.hiest.hiepvf = bestoq.estvenda.

    find bhimov where bhimov.etbcod = commatriz.plani.emite         and
                      bhimov.movtdc = 6                   and
                      bhimov.procod = commatriz.movim.procod        and
                      bhimov.himmes = month(today) and
                      bhimov.himano =  year(today) no-error.
    if not avail bhimov 
    then do:
        create bhimov.
        assign bhimov.etbcod = commatriz.plani.emite
               bhimov.movtdc = 6
               bhimov.procod = commatriz.movim.procod
               bhimov.himmes = month(today)
               bhimov.himano =  year(today).
    end.
    if vtipo = "I"
    then bhimov.himqtm = bhimov.himqtm + commatriz.movim.movqtm.
    if vtipo = "E"
    then bhimov.himqtm = bhimov.himqtm - commatriz.movim.movqtm.
    if vtipo = "A"
    then  bhimov.himqtm = bhimov.himqtm - vqtd + commatriz.movim.movqtm.

    /******************************************************/
    
    find commatriz.himov where 
                     commatriz.himov.etbcod = commatriz.plani.desti         and
                     commatriz.himov.movtdc = 7                             and
                     commatriz.himov.procod = commatriz.movim.procod        and
                     commatriz.himov.himmes = month(today) and
                     commatriz.himov.himano =  year(today) no-error.
    if not avail commatriz.himov
    then do:
        create commatriz.himov.
        assign commatriz.himov.etbcod = commatriz.plani.desti
               commatriz.himov.movtdc = 7
               commatriz.himov.procod = commatriz.movim.procod
               commatriz.himov.himmes = month(today)
               commatriz.himov.himano =  year(today).
    end.
    if vtipo = "I"
    then commatriz.himov.himqtm = 
         commatriz.himov.himqtm + commatriz.movim.movqtm.
    if vtipo = "E"
    then commatriz.himov.himqtm = 
         commatriz.himov.himqtm - commatriz.movim.movqtm.
    if vtipo = "A"
    then commatriz.himov.himqtm =
         commatriz.himov.himqtm - vqtd + commatriz.movim.movqtm.

    /****************** FIM TRANSFERENCIA - ENTRADA *****************/

end.
    
    /********************** INICIO ENTRADA **********************/

if commatriz.movim.movtdc = 4 or
   commatriz.movim.movtdc = 1 or
   commatriz.movim.movtdc = 7 or
   commatriz.movim.movtdc = 12 or
   commatriz.movim.movtdc = 15 or
   commatriz.movim.movtdc = 17
then do:
    find commatriz.estoq where 
         commatriz.estoq.etbcod = commatriz.movim.etbcod and
         commatriz.estoq.procod = commatriz.movim.procod no-error.
    if not avail commatriz.estoq
    then do:
        find first xestoq where xestoq.procod = commatriz.movim.procod no-lock.
        create commatriz.estoq.
        assign commatriz.estoq.etbcod = commatriz.movim.etbcod
               commatriz.estoq.procod = commatriz.movim.procod
               commatriz.estoq.estcusto = xestoq.estcusto
               commatriz.estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then commatriz.estoq.estatual = 
            commatriz.estoq.estatual + commatriz.movim.movqtm.
    if vtipo = "E"
    then commatriz.estoq.estatual = 
            commatriz.estoq.estatual - commatriz.movim.movqtm.
    if vtipo = "A"
    then  commatriz.estoq.estatual = 
            commatriz.estoq.estatual - vqtd + commatriz.movim.movqtm.
    
    find germatriz.estpro where 
         germatriz.estpro.procod = commatriz.estoq.procod no-error.
    if not avail germatriz.estpro
    then do:
        create germatriz.estpro.
        assign germatriz.estpro.procod = commatriz.estoq.procod.
    end.
    assign germatriz.estpro.estatual[movim.etbcod] = commatriz.estoq.estatual
           germatriz.estpro.estcusto[movim.etbcod] = commatriz.estoq.estcusto
           germatriz.estpro.estvenda[movim.etbcod] = commatriz.estoq.estvenda.


    find commatriz.hiest where 
                     commatriz.hiest.etbcod = commatriz.movim.etbcod        and
                     commatriz.hiest.procod = commatriz.movim.procod        and
                     commatriz.hiest.hiemes = month(today) and
                     commatriz.hiest.hieano =  year(today) no-error.
    if not avail commatriz.hiest
    then do:
        create commatriz.hiest.
        assign commatriz.hiest.etbcod = commatriz.movim.etbcod
               commatriz.hiest.procod = commatriz.movim.procod
               commatriz.hiest.hiemes = month(today)
               commatriz.hiest.hieano =  year(today).
    end.
    
    commatriz.hiest.hiestf = commatriz.estoq.estatual.
    commatriz.hiest.hiepcf = commatriz.estoq.estcusto.
    commatriz.hiest.hiepvf = commatriz.estoq.estvenda.
    
    if commatriz.movim.movtdc = 4 or
       commatriz.movim.movtdc = 1
    then do:
    
        find commatriz.himov where 
                    commatriz.himov.etbcod = commatriz.movim.etbcod        and
                    commatriz.himov.movtdc = 4                   and
                    commatriz.himov.procod = commatriz.movim.procod        and
                    commatriz.himov.himmes = month(today) and
                    commatriz.himov.himano = year(today) no-error.
        if not avail commatriz.himov
        then do:
            create commatriz.himov.
            assign commatriz.himov.etbcod = commatriz.movim.etbcod
                   commatriz.himov.movtdc = 4
                   commatriz.himov.procod = commatriz.movim.procod
                   commatriz.himov.himmes = month(today)
                   commatriz.himov.himano =  year(today).
        end.
        if vtipo = "I"
        then commatriz.himov.himqtm = 
                commatriz.himov.himqtm + commatriz.movim.movqtm.
        if vtipo = "E"
        then commatriz.himov.himqtm = 
                commatriz.himov.himqtm - commatriz.movim.movqtm.
        if vtipo = "A"
        then  commatriz.himov.himqtm = 
                commatriz.himov.himqtm - vqtd + commatriz.movim.movqtm.
    end.
end.
    /**************************  FIM ENTRADA ************************/


    /*********************** INICIO SAIDA ***********************/
if commatriz.movim.movtdc = 5 or
   commatriz.movim.movtdc = 13 or
   commatriz.movim.movtdc = 14 or
   commatriz.movim.movtdc = 16 or
   commatriz.movim.movtdc = 8  or
   commatriz.movim.movtdc = 18
then do:

    find commatriz.estoq where 
            commatriz.estoq.etbcod = commatriz.movim.etbcod and
            commatriz.estoq.procod = commatriz.movim.procod no-error.
    if not avail commatriz.estoq
    then do:
        find first xestoq where xestoq.procod = commatriz.movim.procod no-lock.
        create commatriz.estoq.
        assign commatriz.estoq.etbcod = commatriz.movim.etbcod
               commatriz.estoq.procod = commatriz.movim.procod
               commatriz.estoq.estcusto = xestoq.estcusto
               commatriz.estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then commatriz.estoq.estatual = 
                commatriz.estoq.estatual - commatriz.movim.movqtm.
    if vtipo = "E"
    then commatriz.estoq.estatual = 
                commatriz.estoq.estatual + commatriz.movim.movqtm.
    if vtipo = "A"
    then  commatriz.estoq.estatual = 
            commatriz.estoq.estatual + vqtd - commatriz.movim.movqtm.
                                       
    find germatriz.estpro where 
         germatriz.estpro.procod = commatriz.estoq.procod no-error.
    if not avail germatriz.estpro
    then do:
        create germatriz.estpro.
        assign germatriz.estpro.procod = commatriz.estoq.procod.
    end.
    assign germatriz.estpro.estatual[movim.etbcod] = commatriz.estoq.estatual
           germatriz.estpro.estcusto[movim.etbcod] = commatriz.estoq.estcusto
           germatriz.estpro.estvenda[movim.etbcod] = commatriz.estoq.estvenda.



    find commatriz.hiest where 
                     commatriz.hiest.etbcod = commatriz.movim.etbcod        and
                     commatriz.hiest.procod = commatriz.movim.procod        and
                     commatriz.hiest.hiemes = month(today) and
                     commatriz.hiest.hieano =  year(today) no-error.
    if not avail commatriz.hiest
    then do:
        create commatriz.hiest.
        assign commatriz.hiest.etbcod = commatriz.movim.etbcod
               commatriz.hiest.procod = commatriz.movim.procod
               commatriz.hiest.hiemes = month(today)
               commatriz.hiest.hieano =  year(today).
    end.

    commatriz.hiest.hiestf = commatriz.estoq.estatual.
    commatriz.hiest.hiepcf = commatriz.estoq.estcusto.
    commatriz.hiest.hiepvf = commatriz.estoq.estvenda.

    if commatriz.movim.movtdc = 5
    then do:
        find commatriz.himov where commatriz.himov.etbcod = commatriz.movim.etbcod        and
                         commatriz.himov.movtdc = commatriz.movim.movtdc        and
                         commatriz.himov.procod = commatriz.movim.procod        and
                         commatriz.himov.himmes = month(today) and
                         commatriz.himov.himano =  year(today) no-error.
        if not avail commatriz.himov
        then do:
            create commatriz.himov.
            assign commatriz.himov.etbcod = commatriz.movim.etbcod
                   commatriz.himov.movtdc = 5
                   commatriz.himov.procod = commatriz.movim.procod
                   commatriz.himov.himmes = month(today)
                   commatriz.himov.himano =  year(today).
        end.
        if vtipo = "I"
        then commatriz.himov.himqtm = commatriz.himov.himqtm + commatriz.movim.movqtm.
        if vtipo = "E"
        then commatriz.himov.himqtm = commatriz.himov.himqtm - commatriz.movim.movqtm.
        if vtipo = "A"
        then  commatriz.himov.himqtm = commatriz.himov.himqtm - vqtd + commatriz.movim.movqtm.
    end.
end.
    /**************************** FIM SAIDA *************************/



