{admdisparo.i}


def var vcriapedidoautomatico as log.
def var par-valor as char.
vcriapedidoautomatico = no.
run lemestre.p (input  "CRIAPEDIDOAUTOMATICO",
                output par-valor).
if par-valor = "YES"
then vcriapedidoautomatico = yes.
else vcriapedidoautomatico = no.


def shared temp-table tt-movim      like com.movim.
def shared temp-table tt-plani      like com.plani.
def shared temp-table tt-pedid      like com.pedid.
def shared temp-table tt-liped      like com.liped.
def shared temp-table tt-globa      like com.globa.
def shared temp-table tt-nottra     like com.nottra.

def var vdata                       as date.
def var vweek                       as int.
def var lg-novo                     as log.
def var i                           as int.
def var vpednum                     like com.pedid.pednum.

def var vlog1                       as char.
def buffer bpedid                   for commatriz.pedid.

def temp-table tt-produ
    field procod like com.produ.procod 
    index procod procod.

def var vlog as char.
vlog  = "/usr/admcom/work/atucom" + string(time) + ".log".
vlog1 = "/usr/admcom/work/log." + string(day(today)) + string(month(today)).

vweek = int(weekday(today)).
if vweek = 2 
then vdata = today - 2.
else vdata = today - 1.

def temp-table ttservidor
    field etbcod like estab.etbcod
    field servidor like estab.etbcod.
    
input from /usr/admcom/progr/servidor.txt.
repeat :
    create ttservidor.
    import ttservidor.
end.
input close.
    
for each com.produ where com.produ.datexp >= vdata 
                     and com.produ.datexp <> ? no-lock:
    create tt-produ.
    assign               
        tt-produ.procod = com.produ.procod.
end.

/**************************************************************************** 
    ATUALIZA A TABELA DE PRODUTOS DA LOJA A PARTIR DA MATRIZ:
  - MODIFICACOES DE REGISTROS E/OU CRIACAO DE NOVOS REGISTROS 
*****************************************************************************/

def var cont as int.

output to value(vlog1) append.
    put "Atucom.p - Im Produtos"
        string(time,"hh:mm:ss") skip.
output close.

cont = 0.

for each commatriz.produ where 
         commatriz.produ.datexp <> ? and
         commatriz.produ.datexp >= vdata and
         not can-find (first tt-produ where 
                             tt-produ.procod = commatriz.produ.procod) 
         no-lock: 
    do transaction : 
        find first com.produ where
                   com.produ.procod = commatriz.produ.procod no-error.
        if not avail com.produ
        then create com.produ.
        
        output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Import Produ Matriz --> Loja ." 
            space(1)
            commatriz.produ.procod
            space(1)
            commatriz.produ.datexp
            space(1)
            skip.
        output close.
        
        cont = cont + 1.
        {tt-produ.i com.produ commatriz.produ}
        com.produ.exportado = yes.
        
        find first commatriz.estoq where 
                   commatriz.estoq.etbcod = setbcod
               and commatriz.estoq.procod = commatriz.produ.procod
                   no-error.
        find first com.estoq where com.estoq.etbcod = setbcod
                               and com.estoq.procod = commatriz.estoq.procod
                             no-error.
        if avail commatriz.estoq 
        then do :
            output to value(vlog) append.
            put today format "99/99/9999" space(1) 
                " Import Estoq Matriz --> Loja ." 
                space(1)
                commatriz.estoq.procod
                space(1)
                commatriz.estoq.datexp
              space(1)
                skip.
            output close.
            if not avail com.estoq 
            then do:
                create com.estoq.
                {tt-estoq.i com.estoq commatriz.estoq} 
            end.        
        end.
    end.
end.                                         

output to value(vlog1)  append.
    put "Atucom.p - Produtos " cont
        skip
        "Atucom.p - Im. Estoque" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        

/*********** Cria registro de Estoque que nao tem na Loja *************/
    
for each ttservidor where ttservidor.servidor = setbcod no-lock :
    for each com.produ no-lock :
        find first com.estoq where com.estoq.procod = com.produ.procod
                               and com.estoq.etbcod = ttservidor.etbcod
                             no-lock no-error.
        if avail com.estoq then next.
  
        find first commatriz.estoq where 
                            commatriz.estoq.etbcod = ttservidor.etbcod
                        and commatriz.estoq.procod = com.produ.procod 
                   no-lock no-error.

        if avail commatriz.estoq
        then do :
            output to value(vlog) append.
                put today format "99/99/9999" space(1) 
                    " Import Estoq Matriz --> Loja ." 
                    space(1)
                    commatriz.estoq.procod
                    space(1)
                    commatriz.estoq.datexp
                    space(1)
                    skip.
            output close.
        end.
        cont = cont + 1.
        if avail commatriz.estoq
        then do transaction: 
            create com.estoq.
            {tt-estoq.i com.estoq commatriz.estoq}.
        end.    
    end.        
end.

/************ Busca Alteracoes no Preco de Venda na Matriz *************/
    
output to value(vlog1)  append.
    put "Atucom.p - Estoque " cont
        skip
        "Atucom.p - Im. Preco" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        

for each ttservidor where ttservidor.servidor = setbcod no-lock:
    for each com.divpre where com.divpre.etbcod = ttservidor.etbcod and
                              com.divpre.datexp >= vdata no-lock:
        find commatriz.divpre where 
                    commatriz.divpre.etbcod = com.divpre.etbcod and
                    commatriz.divpre.placod = com.divpre.placod and
                    commatriz.divpre.procod = com.divpre.procod no-error.
        if not avail commatriz.divpre
        then do transaction:
            create commatriz.divpre.
            assign commatriz.divpre.etbcod = com.divpre.etbcod
                   commatriz.divpre.placod = com.divpre.placod
                   commatriz.divpre.procod = com.divpre.procod.
        end.
        do transaction:
            find commatriz.estoq where 
                    commatriz.estoq.etbcod = com.divpre.etbcod and
                    commatriz.estoq.procod = com.divpre.procod 
                                no-lock no-error.
            if avail commatriz.estoq
            then do:
                commatriz.divpre.premat = commatriz.estoq.estvenda.
            
                if commatriz.estoq.estprodat <> ?
                then if commatriz.estoq.estprodat >= com.divpre.divdat
                     then commatriz.divpre.premat = commatriz.estoq.estproper.
                     else commatriz.divpre.premat = commatriz.estoq.estvenda.

            end.
            
            assign commatriz.divpre.fincod = com.divpre.fincod 
                   commatriz.divpre.preven = com.divpre.preven  
                   commatriz.divpre.prefil = com.divpre.prefil 
                   commatriz.divpre.divdat = com.divpre.divdat 
                   commatriz.divpre.datexp = com.divpre.datexp 
                   commatriz.divpre.divjus = com.divpre.divjus.
        end.
    end.
end.
              
                    
                                           
        


for each ttservidor where ttservidor.servidor = setbcod no-lock : 
    for each commatriz.estoq where commatriz.estoq.datexp >= vdata   
                           and commatriz.estoq.datexp <> ? 
                           and commatriz.estoq.etbcod = ttservidor.etbcod
                         no-lock ,
        first com.estoq where com.estoq.procod = commatriz.estoq.procod
                          and com.estoq.etbcod = commatriz.estoq.etbcod : 
        cont = cont + 1.
        do transaction :
            assign
                com.estoq.estvenda  = commatriz.estoq.estvenda
                com.estoq.estcusto  = commatriz.estoq.estcusto
                com.estoq.estproper = commatriz.estoq.estproper
                com.estoq.estprodat = commatriz.estoq.estprodat
                com.estoq.estrep    = commatriz.estoq.estrep
                com.estoq.estinvdat = commatriz.estoq.estinvdat.
        
            output to value(vlog) append.
                put today format "99/99/9999" space(1) 
                    " Import Estoq Matriz --> Loja ." 
                    space(1)
                    commatriz.estoq.procod
                    space(1)
                    commatriz.estoq.datexp
                    space(1)
                    skip.
            output close.
        end.
    end.    
end.

output to value(vlog1)  append.
    put "Atucom.p - Preco " cont
        skip
        "Atucom.p - Im. PlaniMatriz" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        


/************ Buscando Notas Fiscais para a Loja *****************/

for each ttservidor where ttservidor.servidor = setbcod no-lock:
    for each commatriz.plani where commatriz.plani.datexp >= vdata - 3
                        and commatriz.plani.datexp <> ? 
                        and commatriz.plani.desti = ttservidor.etbcod no-lock : 
        find first com.plani where com.plani.etbcod = commatriz.plani.etbcod
                              and com.plani.placod = commatriz.plani.placod 
                             no-error.
        cont = cont + 1.
        if not avail com.plani
        then do transaction:
            create com.plani.
            {t-plani.i com.plani commatriz.plani}.

            output to value(vlog) append.
                put today format "99/99/9999" space(1) 
                    " Import Plani Matriz --> Loja ." 
                    space(1)
                    commatriz.plani.numero
                    space(1)
                    commatriz.plani.datexp
                    space(1)
                    skip.
            output close.
        end.
        for each commatriz.movim where 
                 commatriz.movim.etbcod = commatriz.plani.etbcod
                 and commatriz.movim.placod = commatriz.plani.placod no-lock :
            find first com.movim where 
                       com.movim.etbcod = commatriz.plani.etbcod
                   and com.movim.placod = commatriz.plani.placod
                   and com.movim.procod = commatriz.movim.procod no-error.
            if not avail com.movim
            then do transaction: 
                create com.movim.
                {t-movim.i com.movim commatriz.movim}.
                    
                output to value(vlog) append.
                    put today format "99/99/9999" space(1) 
                        " Import Movim Matriz --> Loja ." 
                        space(1)
                        commatriz.movim.procod
                        space(1)
                        commatriz.movim.movqtm
                        space(1)
                        skip.
                output close.
            end.
        end.
    end.
end.

output to value(vlog1)  append.
    put "Atucom.p - PlaniMatriz " cont
        skip
        "Atucom.p - Im. Plani" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        

for each tt-plani:
    cont = cont + 1.
    do transaction: 
        find commatriz.plani where 
             commatriz.plani.movtdc = tt-plani.movtdc and
             commatriz.plani.etbcod = tt-plani.etbcod and
             commatriz.plani.emite  = tt-plani.emite  and
             commatriz.plani.serie  = tt-plani.serie  and
             commatriz.plani.numero = tt-plani.numero no-error.
        if not avail commatriz.plani
        then create commatriz.plani.

        ASSIGN
            commatriz.plani.movtdc    = tt-plani.movtdc
            commatriz.plani.PlaCod    = tt-plani.PlaCod
            commatriz.plani.Numero    = tt-plani.Numero
            commatriz.plani.PlaDat    = tt-plani.PlaDat
            commatriz.plani.Serie     = tt-plani.Serie
            commatriz.plani.vencod    = tt-plani.vencod
            commatriz.plani.plades    = tt-plani.plades
            commatriz.plani.crecod    = tt-plani.crecod
            commatriz.plani.VlServ    = tt-plani.VlServ
            commatriz.plani.DescServ  = tt-plani.DescServ
            commatriz.plani.AcFServ   = tt-plani.AcFServ
            commatriz.plani.PedCod    = tt-plani.PedCod
            commatriz.plani.ICMS      = tt-plani.ICMS
            commatriz.plani.BSubst    = tt-plani.BSubst
            commatriz.plani.ICMSSubst = tt-plani.ICMSSubst
            commatriz.plani.BIPI      = tt-plani.BIPI
            commatriz.plani.AlIPI     = tt-plani.AlIPI
            commatriz.plani.IPI       = tt-plani.IPI
            commatriz.plani.Seguro    = tt-plani.Seguro
            commatriz.plani.Frete     = tt-plani.Frete.
            
        ASSIGN
            commatriz.plani.DesAcess  = tt-plani.DesAcess
            commatriz.plani.DescProd  = tt-plani.DescProd
            commatriz.plani.AcFProd   = tt-plani.AcFProd
            commatriz.plani.ModCod    = tt-plani.ModCod
            commatriz.plani.AlICMS    = tt-plani.AlICMS
            commatriz.plani.Outras    = tt-plani.Outras
            commatriz.plani.AlISS     = tt-plani.AlISS
            commatriz.plani.BICMS     = tt-plani.BICMS
            commatriz.plani.UFEmi     = tt-plani.UFEmi
            commatriz.plani.BISS      = tt-plani.BISS
            commatriz.plani.CusMed    = tt-plani.CusMed
            commatriz.plani.UserCod   = tt-plani.UserCod
            commatriz.plani.DtInclu   = tt-plani.DtInclu
            commatriz.plani.HorIncl   = tt-plani.HorIncl
            commatriz.plani.NotSit    = tt-plani.NotSit
            commatriz.plani.NotFat    = tt-plani.NotFat
            commatriz.plani.HiCCod    = tt-plani.HiCCod
            commatriz.plani.NotObs[1] = tt-plani.NotObs[1]
            commatriz.plani.NotObs[2] = tt-plani.NotObs[2]
            commatriz.plani.NotObs[3] = tt-plani.NotObs[3].
        
        ASSIGN
            commatriz.plani.RespFre   = tt-plani.RespFre
            commatriz.plani.NotTran   = tt-plani.NotTran
            commatriz.plani.Isenta    = tt-plani.Isenta
            commatriz.plani.ISS       = tt-plani.ISS
            commatriz.plani.NotPis    = tt-plani.NotPis
            commatriz.plani.NotAss    = tt-plani.NotAss
            commatriz.plani.NotCoFinS = tt-plani.NotCoFinS
            commatriz.plani.TMovDev   = tt-plani.TMovDev
            commatriz.plani.Desti     = tt-plani.Desti
            commatriz.plani.IndEmi    = tt-plani.IndEmi
            commatriz.plani.Emite     = tt-plani.Emite
            commatriz.plani.NotPed    = tt-plani.NotPed
            commatriz.plani.PLaTot    = tt-plani.PLaTot
            commatriz.plani.OpCCod    = tt-plani.OpCCod
            commatriz.plani.UFDes     = tt-plani.UFDes
            commatriz.plani.ProTot    = tt-plani.ProTot
            commatriz.plani.EtbCod    = tt-plani.EtbCod
            commatriz.plani.cxacod    = tt-plani.cxacod
            commatriz.plani.datexp    = tt-plani.datexp.

        find first com.plani where 
                   com.plani.movtdc = tt-plani.movtdc and
                   com.plani.etbcod = tt-plani.etbcod and
                   com.plani.emite  = tt-plani.emite  and
                   com.plani.serie  = tt-plani.serie  and
                   com.plani.numero = tt-plani.numero no-error.
        com.plani.exportado = yes.
        output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Atualiz Plani Loja --> Matriz ." 
            space(1)
            tt-plani.etbcod
            space(1)
            tt-plani.numero
            space(1)
            tt-plani.placod format "999999999999" 
            space(1)
            tt-plani.pladat
            skip.
        output close.      
        delete tt-plani.
    end.
end.


output to value(vlog1)  append.
    put "Atucom.p - Plani " cont
        skip
        "Atucom.p - Im. Movim" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        

connect ger -H erp.lebes.com.br -S sdrebger -N tcp -ld germatriz.

for each tt-movim:
   
    cont = cont + 1. 
    do transaction : 
        lg-novo = no.
        find first commatriz.movim where 
                   commatriz.movim.etbcod = tt-movim.etbcod and
                   commatriz.movim.placod = tt-movim.placod and
                   commatriz.movim.procod = tt-movim.procod no-error.
        if not avail commatriz.movim
        then do :
            lg-novo = yes.
            create commatriz.movim.
        end.
        
        ASSIGN
            commatriz.movim.movtdc    = tt-movim.movtdc
            commatriz.movim.PlaCod    = tt-movim.PlaCod
            commatriz.movim.etbcod    = tt-movim.etbcod
            commatriz.movim.movseq    = tt-movim.movseq
            commatriz.movim.procod    = tt-movim.procod
            commatriz.movim.movqtm    = tt-movim.movqtm
            commatriz.movim.movpc     = tt-movim.movpc
            commatriz.movim.MovDev    = tt-movim.MovDev
            commatriz.movim.MovAcFin  = tt-movim.MovAcFin
            commatriz.movim.movipi    = tt-movim.movipi
            commatriz.movim.MovPro    = tt-movim.MovPro
            commatriz.movim.MovICMS   = tt-movim.MovICMS
            commatriz.movim.MovAlICMS = tt-movim.MovAlICMS
            commatriz.movim.MovPDesc  = tt-movim.MovPDesc
            commatriz.movim.MovCtM    = tt-movim.MovCtM
            commatriz.movim.MovAlIPI  = tt-movim.MovAlIPI
            commatriz.movim.movdat    = tt-movim.movdat
            commatriz.movim.MovHr     = tt-movim.MovHr
            commatriz.movim.MovDes    = tt-movim.MovDes
            commatriz.movim.MovSubst  = tt-movim.MovSubst
            commatriz.movim.emite     = tt-movim.emite
            commatriz.movim.desti     = tt-movim.desti.

        ASSIGN
            commatriz.movim.OCNum[1]  = tt-movim.OCNum[1]
            commatriz.movim.OCNum[2]  = tt-movim.OCNum[2]
            commatriz.movim.OCNum[3]  = tt-movim.OCNum[3]
            commatriz.movim.OCNum[4]  = tt-movim.OCNum[4]
            commatriz.movim.OCNum[5]  = tt-movim.OCNum[5]
            commatriz.movim.OCNum[6]  = tt-movim.OCNum[6]
            commatriz.movim.OCNum[7]  = tt-movim.OCNum[7]
            commatriz.movim.OCNum[8]  = tt-movim.OCNum[8]
            commatriz.movim.OCNum[9]  = tt-movim.OCNum[9]
            commatriz.movim.datexp    = tt-movim.datexp.

        if lg-novo = yes
        then do :
            if today >= date(06,28,2001)
            then do : 
                output to /usr/admcom/work/movimatualiza.log append.
                    put commatriz.movim.etbcod space(1)
                        commatriz.movim.placod format ">>>>>>>>>>>>>9" 
                        space(1)
                        commatriz.movim.procod space(1)
                        commatriz.movim.movqtm space(1)
                        commatriz.movim.movpc space(1)
                        skip.
                output close.
                if connected("germatriz")
                then do :
                    run atunovo.p ( input recid(commatriz.movim) ,
                                    input "I" , input 0). 
                end.
            end.
            lg-novo = no.
        end.
        
        find first com.movim where 
                   com.movim.etbcod = tt-movim.etbcod and
                   com.movim.placod = tt-movim.placod and
                   com.movim.procod = tt-movim.procod no-error.
        com.movim.exportado = yes.
        
        output to value(vlog) append.
            put today format "99/99/9999" space(1) 
                " Atualiz Movim Loja --> Matriz ." 
                space(1)
                tt-movim.procod
                space(1)
                tt-movim.movpc
                space(1)
                tt-movim.movqtm
                space(1)
            tt-movim.etbcod 
            space(1)
            tt-movim.placod  format "99999999999" 
            skip.
        output close.        
        delete tt-movim.
    end.        
end.

output to value(vlog1)  append.
    put "Atucom.p - Movim " cont
        skip
        "Atucom.p - Im. Pedido" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.

if connected ("germatriz") 
then disconnect germatriz.

for each tt-pedid :
    cont = cont + 1.
    do transaction : 
        find first commatriz.pedid where
                   commatriz.pedid.pedtdc = tt-pedid.pedtdc and
                   commatriz.pedid.pednum = tt-pedid.pednum and
                   commatriz.pedid.etbcod = tt-pedid.etbcod 
                   no-error.
        if not avail commatriz.pedid
        then create commatriz.pedid.
        
        ASSIGN
            commatriz.pedid.pedtdc    = tt-pedid.pedtdc
            commatriz.pedid.pednum    = tt-pedid.pednum
            commatriz.pedid.regcod    = tt-pedid.regcod
            commatriz.pedid.peddat    = tt-pedid.peddat
            commatriz.pedid.comcod    = tt-pedid.comcod
            commatriz.pedid.pedsit    = tt-pedid.pedsit
            commatriz.pedid.fobcif    = tt-pedid.fobcif
            commatriz.pedid.nfdes     = tt-pedid.nfdes
            commatriz.pedid.ipides    = tt-pedid.ipides
            commatriz.pedid.dupdes    = tt-pedid.dupdes
            commatriz.pedid.cusefe    = tt-pedid.cusefe
            commatriz.pedid.condes    = tt-pedid.condes
            commatriz.pedid.condat    = tt-pedid.condat
            commatriz.pedid.crecod    = tt-pedid.crecod
            commatriz.pedid.peddti    = tt-pedid.peddti
            commatriz.pedid.peddtf    = tt-pedid.peddtf
            commatriz.pedid.acrfin    = tt-pedid.acrfin
            commatriz.pedid.sitped    = tt-pedid.sitped
            commatriz.pedid.vencod    = tt-pedid.vencod
            commatriz.pedid.frecod    = tt-pedid.frecod.

        ASSIGN
            commatriz.pedid.modcod    = tt-pedid.modcod
            commatriz.pedid.etbcod    = tt-pedid.etbcod
            commatriz.pedid.pedtot    = tt-pedid.pedtot
            commatriz.pedid.clfcod    = tt-pedid.clfcod
            commatriz.pedid.pedobs[1] = tt-pedid.pedobs[1]
            commatriz.pedid.pedobs[2] = tt-pedid.pedobs[2]
            commatriz.pedid.pedobs[3] = tt-pedid.pedobs[3]
            commatriz.pedid.pedobs[4] = tt-pedid.pedobs[4]
            commatriz.pedid.pedobs[5] = tt-pedid.pedobs[5].
        
        find first com.pedid where
                   com.pedid.pedtdc = tt-pedid.pedtdc and
                   com.pedid.pednum = tt-pedid.pednum and 
                   com.pedid.etbcod = tt-pedid.etbcod 
                   no-error.
        com.pedid.exportado = yes.
        
        output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Atualiz Pedid Loja --> Matriz ." 
            space(1)
            tt-pedid.etbcod
            space(1)
            tt-pedid.pednum
            space(1)
            tt-pedid.peddat
            skip.
        output close.      
        
        delete tt-pedid.
    end.
end.

output to value(vlog1)  append.
    put "Atucom.p - Pedido " cont
        skip
        "Atucom.p - Im. LinhaPedido " 
        "PedAuto " vcriapedidoautomatico  " setbcod "  setbcod "  "
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        

for each tt-liped:        
    cont = cont + 1. 
    do transaction : 

        if vcriapedidoautomatico 
        then do:
            if tt-liped.lipsit = "Z" 
            then do :
                find first commatriz.pedid where 
                           commatriz.pedid.pedtdc = tt-liped.pedtdc and
                           commatriz.pedid.sitped = "E" and
                           commatriz.pedid.etbcod = tt-liped.etbcod and
                           commatriz.pedid.pednum >= 100000
                         no-lock no-error.
                if not avail commatriz.pedid
                then do :
                    find last bpedid where 
                              bpedid.pedtdc = 3 and
                              bpedid.etbcod = tt-liped.etbcod  and
                              bpedid.pednum >= 100000
                              no-error.
                    if avail bpedid
                    then vpednum = bpedid.pednum + 1.
                    else vpednum = 100000.
    
                    create commatriz.pedid.
                    assign
                        commatriz.pedid.etbcod = tt-liped.etbcod
                        commatriz.pedid.pedtdc = tt-liped.pedtdc
                        commatriz.pedid.peddat = today
                        commatriz.pedid.pednum = vpednum
                        commatriz.pedid.sitped = "E" 
                        commatriz.pedid.pedsit = yes.
                end.
                else vpednum = commatriz.pedid.pednum.
            end.
        end.
        
        find first commatriz.liped where
                   commatriz.liped.etbcod = tt-liped.etbcod and
                   commatriz.liped.pedtdc = tt-liped.pedtdc and
                   commatriz.liped.pednum = tt-liped.pednum and
                   commatriz.liped.procod = tt-liped.procod and
                   commatriz.liped.predt  = tt-liped.predt no-error.
        if not avail commatriz.liped
        then create commatriz.liped.
  
        ASSIGN
            commatriz.liped.pedtdc    = tt-liped.pedtdc
            commatriz.liped.pednum    = tt-liped.pednum
            commatriz.liped.procod    = tt-liped.procod
            commatriz.liped.lippreco  = tt-liped.lippreco
            commatriz.liped.lipsit    = tt-liped.lipsit
            commatriz.liped.predtf    = tt-liped.predtf
            commatriz.liped.predt     = tt-liped.predt
            commatriz.liped.lipcor    = tt-liped.lipcor
            commatriz.liped.etbcod    = tt-liped.etbcod.

        if commatriz.liped.lipsit = "Z" 
        then do :
            commatriz.liped.lipqtd = commatriz.liped.lipqtd + 
                                      tt-liped.lipqtd.
            commatriz.liped.pednum = vpednum.
            commatriz.liped.lipsit = "A".
        end.
        else commatriz.liped.lipqtd = tt-liped.lipqtd.
        
        find first com.liped where
                   com.liped.etbcod = tt-liped.etbcod and
                   com.liped.pedtdc = tt-liped.pedtdc and
                   com.liped.pednum = tt-liped.pednum and
                   com.liped.procod = tt-liped.procod and
                   com.liped.predt  = tt-liped.predt no-error.
        com.liped.exportado = yes.
        
        output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Atualiz Liped Loja --> Matriz ." 
            space(1)
            tt-liped.etbcod
            space(1)
            tt-liped.pednum
            space(1)
            tt-liped.procod
            skip.
        output close. 
        
        delete tt-liped.
    end.
end.

output to value(vlog1)  append.
    put "Atucom.p - LinhaPedido " cont
        skip
        "Atucom.p - Im. NotTra" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        

for each tt-nottra:
    cont = cont + 1.
    do transaction : 
        find first commatriz.nottra where
                   commatriz.nottra.etbcod = tt-nottra.etbcod and
                   commatriz.nottra.desti  = tt-nottra.desti  and
                   commatriz.nottra.movtdc = tt-nottra.movtdc and
                   commatriz.nottra.serie  = tt-nottra.serie  and
                   commatriz.nottra.numero = tt-nottra.numero no-error.
        if not avail commatriz.nottra
        then create commatriz.nottra.

        ASSIGN
            commatriz.nottra.Etbcod    = tt-nottra.Etbcod
            commatriz.nottra.desti     = tt-nottra.desti
            commatriz.nottra.movtdc    = tt-nottra.movtdc
            commatriz.nottra.datexp    = tt-nottra.datexp
            commatriz.nottra.Serie     = tt-nottra.Serie
            commatriz.nottra.livre     = tt-nottra.livre
            commatriz.nottra.numero    = tt-nottra.numero.
            
        find first com.nottra where
                   com.nottra.etbcod = tt-nottra.etbcod and
                   com.nottra.desti  = tt-nottra.desti  and
                   com.nottra.movtdc = tt-nottra.movtdc and
                   com.nottra.serie  = tt-nottra.serie  and
                   com.nottra.numero = tt-nottra.numero no-error.
        com.nottra.exportado = yes.
        
        output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Atualiz Nottra Loja --> Matriz ." 
            space(1)
            tt-nottra.etbcod
            space(1)
            tt-nottra.numero
            space(1)
            tt-nottra.desti
            skip.
        output close. 
        
        delete tt-nottra.
    end.
end.

output to value(vlog1)  append.
    put "Atucom.p - NotTra " cont
        skip
        "Atucom.p - Im. Globa" 
        string(time,"hh:mm:ss") 
        skip.
output close.        
cont = 0.        

for each tt-globa:
    cont = cont + 1.
    do transaction : 
        find first commatriz.globa where
                   commatriz.globa.etbcod = tt-globa.etbcod and
                   commatriz.globa.glodat = tt-globa.glodat and
                   commatriz.globa.glopar = tt-globa.glopar and
                   commatriz.globa.glocot = tt-globa.glocot and
                   commatriz.globa.glogru = tt-globa.glogru no-error.
        if not avail commatriz.globa
        then create commatriz.globa.
  
        ASSIGN
            commatriz.globa.etbcod    = tt-globa.etbcod
            commatriz.globa.gloval    = tt-globa.gloval
            commatriz.globa.glopar    = tt-globa.glopar
            commatriz.globa.glogru    = tt-globa.glogru
            commatriz.globa.glocot    = tt-globa.glocot
            commatriz.globa.glodat    = tt-globa.glodat
            commatriz.globa.vencod    = tt-globa.vencod.
       
        find first com.globa where
                   com.globa.etbcod = tt-globa.etbcod and
                   com.globa.glodat = tt-globa.glodat and
                   com.globa.glopar = tt-globa.glopar and
                   com.globa.glocot = tt-globa.glocot and
                   com.globa.glogru = tt-globa.glogru no-error.
        com.globa.exportado = yes.
        
        output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Atualiz Globa Loja --> Matriz ." 
            space(1)
            tt-globa.etbcod
            space(1)
            tt-globa.glogru
            space(1)
            tt-globa.glodat
            skip.
        output close. 
        
        delete tt-globa.
    end.
end.

output to value(vlog1)  append.
    put "Atucom.p - Globa " cont
        skip
        "Atucom.p - Finalizando" 
        string(time,"hh:mm:ss") 
        skip.
output close.        

output to /usr/admcom/ultimo.ini.
    put time.
output close.
