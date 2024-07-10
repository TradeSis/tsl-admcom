{admcab.i}

def var recimp as recid.
def var fila as char.
def var varquivo as char.

def temp-table wroma
    field pednum like liped.pednum
    field procod like produ.procod
    field pronom like produ.pronom
    field lipcor like liped.lipcor
    field west   like estoq.estatual format "->>>,>>9"
    field wdis   like estoq.estatual
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

if opsys = "unix"  
then do:  
    find first impress where impress.codimp = setbcod no-lock no-error.
    if avail impress  
    then do: 
        run acha_imp.p (input recid(impress), output recimp).
        
        find impress where recid(impress) = recimp no-lock no-error.
                            
        assign fila = string(impress.dfimp). 
    end.    
    varquivo = "/admcom/relat/os." + string(time).
end. 
else varquivo = "l:\relat\os." + string(time).

{mdadmcab.i
        &Saida     = "value(varquivo)"
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

    for each liped USE-INDEX LIPED where liped.pedtdc = 5 and
                         liped.etbcod = estab.etbcod and
                         liped.lipsit = "A" and
                         liped.protip = (if setbcod = 996
                                         then "C"
                                         else "M") no-lock.

/*        wped = liped.lipqtd - lipent. */
        find produ of liped no-lock no-error.
        wsep = 0.
        for each bliped where bliped.lipsit = "A" and
                              bliped.pedtdc = 5  and
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
               wroma.wsep   = wsep.

        find first dispro where dispro.etbcod = liped.etbcod and   
                                dispro.pednum = liped.pednum and   
                                dispro.procod = liped.procod no-lock no-error.

        if avail dispro
        then wroma.wdis = dispro.disqtd.
 
    
    
    end.
    for each wroma where wroma.wdis = 0 and
                         wroma.wsep = 0:
        delete wroma.
    end.
                             
    for each wroma break by wroma.pednum
                         by wroma.pronom:
        disp wroma.pednum space(3)
             wroma.procod space(3)
             wroma.pronom space(3)
             wroma.lipcor
             wroma.west column-label "Estoque" space(3)
             wroma.wdis column-label "Qtd.Distr." format ">>>,>>9" space(3)
             "........." column-label "Separada"
             wroma.wsep when wroma.wsep > 0 column-label "SEP" skip(1)
                        with frame f-rom width 160 down.
        if last-of(wroma.pednum)
        then page.
    end.
output close.

os-command silent lpr value(fila + " " + varquivo).
