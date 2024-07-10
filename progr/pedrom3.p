{admcab.i}
def temp-table wroma
    field pednum like liped.pednum
    field procod like produ.procod
    field pronom like produ.pronom
    field lipcor like liped.lipcor
    field west   like estoq.estatual format "->>>,>>9"
    field wped   like estoq.estatual
    field wsep   like estoq.estatual format "->>>,>>9".
for each wroma:
    delete wroma.
end.
def input parameter vetb like estab.etbcod.
def var wsep like liped.lipqtd.
def var wped like liped.lipqtd.
def var west like estoq.estatual format "->>>,>>9".
def buffer bliped   for liped.

find estab where estab.etbcod = vetb no-lock.


{mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "140"
        &Page-Line = "66"
        &Nom-Rel   = ""PEDROM""
        &Nom-Sis   = """SISTEMA DE PEDIDOS"""
        &Tit-Rel   = """PEDIDOS A SEPARAR POR ESTABELECIMENTO"" + "" - "" +
                        STRING(ESTAB.ETBCOD) + "" - "" + ESTAB.ETBNOM"
        &Width     = "140"
        &Form      = "frame f-cabcab"}


    disp estab.etbcod
         estab.etbnom no-label skip(1) with frame f-est side-label.

    disp "PLACA DO VEICULO : ..............." no-label skip(1)
                                              with frame fff centered width 130.

    for each liped USE-INDEX LIPED where liped.pedtdc = 3 and
                         liped.etbcod = estab.etbcod and
                         liped.lipsit = "A" and
                         liped.protip = (if setbcod = 996
                                         then "C"
                                         else "M") no-lock.
        wped = liped.lipqtd - lipent.
        find produ of liped no-lock.
        wsep = 0.
        for each bliped where bliped.lipsit = "A" and
                              bliped.pedtdc = 3  and
                              bliped.etbcod = estab.etbcod and
                              bliped.procod = liped.procod:
            wsep = wsep + bliped.lipsep.
        end.
        west = 0.
        for each estoq where estoq.etbcod = setbcod and
                             estoq.procod = produ.procod no-lock.
            west = west + estoq.estatual - wsep.
        end.
        create wroma.
        assign wroma.pednum = liped.pednum
               wroma.procod = produ.procod
               wroma.pronom = produ.pronom
               wroma.lipcor = liped.lipcor
               wroma.west   = west
               wroma.wped   = wped
               wroma.wsep   = wsep.

        /***************** COLOCADO PARA ATUALIZAR PEDIDO ************/
        
        find first pedid where pedid.pedtdc = liped.pedtdc
                           and pedid.pednum = liped.pednum
                           and pedid.etbcod = liped.etbcod
                         no-error.
        if avail pedid
        then do :
            
            pedid.pedobs[3] = pedid.pedobs[3]
                      + "|DATA_EXCLUSAO=" + string(today,"99/99/9999")
                      + "|HORA_EXCLUSAO=" + string(time,"HH:MM:SS")
                      + "|ETB_EXCLUSAO="  + string(setbcod)
                      + "|USUARIO_EXCLUSAO=" + string(sfuncod)
                      + "|PROG_EXCLUSAO=" + program-name(1)
                      + "|".
                    
 
 
            pedid.sitped = "R".
        end.
        /*************************************************************/
    end.
    for each wroma break by wroma.pednum
                         by wroma.pronom:
        disp wroma.pednum space(3)
             wroma.procod space(3)
             wroma.pronom space(3)
             wroma.lipcor
             wroma.west column-label "Estoque" space(3)
             wroma.wped column-label "Qtd.Pedida" format ">>>,>>9" space(3)
             "........." column-label "Separada"
             wroma.wsep when wroma.wsep > 0 column-label "SEP" skip(1)
                        with frame f-rom width 160 down.
        if last-of(wroma.pednum)
        then page.
    end.
output close.
