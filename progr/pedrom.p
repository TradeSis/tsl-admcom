{admcab.i}
def temp-table wroma
    field pednum like liped.pednum
    field procod like produ.procod
    field pronom like produ.pronom
    field lipcor like liped.lipcor
    field west   like estoq.estatual format "->>>,>>9"
    field wped   like estoq.estatual
    field wsep   like estoq.estatual format "->>>,>>9"
    field setcod like setdep.setcod
    field setnom like setdep.setnom
    field ordimp like setdep.ordimp.

for each wroma:
    delete wroma.
end.
def input parameter vetb like estab.etbcod.
def var wsep like liped.lipqtd.
def var wped like liped.lipqtd.
def var west like estoq.estatual format "->>>,>>9".
def buffer bliped   for liped.
def var vpednum like pedid.pednum.

find estab where estab.etbcod = vetb no-lock.


find first liped use-index liped 
                    where (liped.pedtdc = 2 or
                           liped.pedtdc = 3) and
                           liped.etbcod = estab.etbcod and
                           liped.lipsit = "A" and
                           liped.protip = (if setbcod = 996
                                          then "C"
                                          else "M") no-lock no-error.
if avail liped
then vpednum = liped.pednum.
                                          



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

    disp "PLACA DO VEICULO : ..............." 
            no-label skip(1) with frame fff centered width 130.

    for each liped USE-INDEX LIPED where (liped.pedtdc = 2 or
                                          liped.pedtdc = 3) and
                         liped.etbcod = estab.etbcod and
                         liped.lipsit = "A" and
                         liped.protip = (if setbcod = 996
                                         then "C"
                                         else "M") no-lock.
        wped = liped.lipqtd - lipent.
        find produ of liped no-lock.
        wsep = 0.

        for each bliped where bliped.lipsit = "A" and
                              bliped.pedtdc = 2  and
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
               
        find first setdep use-index ind-2
                    where setdep.etbcod = setbcod and
                          setdep.clacod = produ.clacod no-lock no-error.
        if avail setdep
        then assign wroma.setcod = setdep.setcod
                    wroma.setnom = setdep.setnom
                    wroma.ordimp = setdep.ordimp.
                          
    end.
    
    for each wroma break by wroma.pednum
                         by wroma.setcod
                         by wroma.ordimp
                         by wroma.pronom:
       
        if first-of(wroma.pednum)
        then put "Pedido n§ "  wroma.pednum skip(1).  
        disp wroma.setnom column-label "PAV" format "x(15)"
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
