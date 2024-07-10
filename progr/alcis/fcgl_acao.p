{admcab.i}
{alcis/tpalcis.i}

def input parameter par-arq as char.

def buffer cliped for liped.
def buffer xliped for liped.
def buffer bpedid for liped.
def buffer xpedid for pedid.

def var vpedrec  as recid.
def var vpednum  like pedid.pednum.
def var vlinha   as char.
def var varq-dep as char.
def var varq-ant as char.

varq-ant = alcis-diretorio + "/" + par-arq.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.

def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as int
    field Etbcod            as int
    field N_Gaiola          as int
    field Itens             as char format "xxx".

def temp-table ttitem
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Etbcod            as char format "x(12)"
    field N_Gaiola          as char format "x(11)"
    field Seq               as char format "xxx"
    field Procod            as char format "x(40)"
    field Qtd               as char format "x(18)"
    field Unidade           as char format "x(6)"
    field ID_Distrib        as char format "x(32)".

input from value(alcis-diretorio + "/" + par-arq).
repeat.
    import unformatted vlinha.
    if substr(vlinha,15,8 ) = "FCGLH"
    then do.
        create ttheader.
        assign ttheader.Remetente      = substr(vlinha,1 ,10)
               ttheader.Nome_arquivo   = substr(vlinha,11,4 )
               ttheader.Nome_interface = substr(vlinha,15,8 )
               ttheader.Site           = substr(vlinha,23,3 )
               ttheader.Proprietario   = int( substr(vlinha,26,12) )
               ttheader.Etbcod         = int( substr(vlinha,38,12) )
               ttheader.N_Gaiola       = int( substr(vlinha,50,11) )
               ttheader.Itens          = substr(vlinha,61,3 ).
    end.
    if substr(vlinha,15,8 ) = "FCGLI"    
    then do.
        create ttitem.
        assign ttitem.Remetente      = substr(vlinha,1 ,10)
               ttitem.Nome_arquivo   = substr(vlinha,11,4 )
               ttitem.Nome_interface = substr(vlinha,15,8 )
               ttitem.Site           = substr(vlinha,23,3 )
               ttitem.Proprietario   = substr(vlinha,26,12)
               ttitem.Etbcod         = substr(vlinha,38,12)
               ttitem.N_Gaiola       = substr(vlinha,50,11)
               ttitem.seq            = substr(vlinha,61,3 )
               ttitem.procod         = substr(vlinha,64,40)
               ttitem.qtd            = substr(vlinha,104,18)
               ttitem.unidade        = substr(vlinha,122,6)
               ttitem.id_distrib     = substr(vlinha,128,32).   
    end.
end.
input close.

/***
    Validacoes / Verificar estoque
***/
def buffer etb-orig for estab.
def buffer etb-dest for estab.
    
find first ttheader no-lock.

find etb-orig where etb-orig.etbcod = ttheader.Proprietario no-lock no-error.
if not avail etb-orig
then do.
    message "Estab.Destino invalido" ttheader.Proprietario view-as alert-box.
    return.
end.

find etb-dest where etb-dest.etbcod = ttheader.Etbcod no-lock no-error.
if not avail estab
then do.
    message "Estab.Destino invalido" ttheader.Etbcod view-as alert-box.
    return.
end.

if ttheader.N_Gaiola = 0
then do.
    message "Gaiola invalida" ttheader.N_Gaiola view-as alert-box.
    return.
end.

find first ttitem where ttitem.ID_Distrib <> ""
                    and ttitem.ID_Distrib <> "99999"
                    and ttitem.ID_Distrib <> fill("0", 20)
                  no-lock no-error.
if avail ttitem
then do.
    message "Arquivo possui codigo de distribuicao" ttitem.ID_Distrib
        view-as alert-box.
    return.
end.

/***
    PROCESSAMENTO
***/

for each ttitem.
    find first dispro where dispro.situacao   = "WMS" and
                            dispro.etbcod     = int(ttitem.etbcod) and
                            dispro.procod     = int(ttitem.procod) and
                            dispro.dtenvwms  <> ?                  and
                            dispro.dtretwms  = ?
                      no-error.
    if not avail dispro
    then do on error undo.
        vpednum = 0. 
        find last pedid use-index ped  
                           where pedid.etbcod = int(ttitem.etbcod) and
                                 pedid.pedtdc = 5  no-lock no-error.
        if not avail pedid 
        then vpednum = 1. 
        else vpednum = pedid.pednum + 1.
        create dispro.
        assign dispro.situacao   = "WMS"
               dispro.etbcod     = int(ttitem.etbcod)
               dispro.procod     = int(ttitem.procod)
               dispro.dtenvwms   = today
               dispro.dtretwms   = ? 
               dispro.pednum     = vpednum 
               dispro.disdat     = today 
               dispro.disqtd     = 0 
               dispro.datexp     = today.
    end.

    if avail dispro
    then do.
        dispro.dtretwms  = today.
        dispro.qtdretwms = dec(ttitem.qtd) / 1000000000.
        dispro.romqtd    = dispro.qtdretwms.
        find estab where estab.etbcod = dispro.etbcod no-lock.
        find produ where produ.procod = dispro.procod no-lock no-error. 
        find first cliped where cliped.pedtdc = 5             and
                                cliped.etbcod = estab.etbcod  and
                                cliped.lipsit = "A"           and
                                cliped.procod = produ.procod
                                            no-error.
        if not avail cliped 
        then do : 
            find bpedid where recid(bpedid) = vpedrec no-error. 
            if not avail bpedid 
            then do: 
                find last bpedid where bpedid.etbcod = estab.etbcod 
                                   and bpedid.pedtdc = 5 no-error. 
                if avail bpedid 
                then vpednum = bpedid.pednum + 1. 
                else vpednum = 1. 
                create xpedid. 
                assign xpedid.pedtdc    = 5 
                       xpedid.pednum    = vpednum 
                       xpedid.regcod    = estab.regcod 
                       xpedid.peddat    = today  
                       xpedid.pedsit    = yes 
                       xpedid.sitped    = "A" 
                       xpedid.modcod    = "PED" 
                       xpedid.etbcod    = estab.etbcod. 
                vpedrec = recid(xpedid). 
            end. 
            find clase where clase.clacod = produ.clacod no-lock. 
            create xliped. 
            assign xliped.pednum = xpedid.pednum  
                   xliped.pedtdc = xpedid.pedtdc 
                   xliped.predt  = xpedid.peddat 
                   xliped.etbcod = xpedid.etbcod 
                   xliped.procod = produ.procod 
                   xliped.lipcor = "" 
                   xliped.wmsgaiola = ttitem.N_Gaiola
                   xliped.lipqtd = dispro.romqtd 
                   xliped.lipsep = xliped.lipqtd 
                   xliped.lipsit = "A" 
                   xliped.protip = if clase.claordem = yes
                                   then "M" else "C".
            if produ.catcod = 45 or  
               produ.catcod = 41 or 
               produ.catcod = 51 
            then xliped.protip = "C". 
            find estoq where estoq.etbcod = xliped.etbcod and
                             estoq.procod = xliped.procod no-lock no-error.
            if avail estoq 
            then xliped.lippreco = estoq.estcusto. 
            else do: 
                find first estoq where estoq.procod = xliped.procod
                                                        no-lock no-error.
                        xliped.lippreco = estoq.estcusto.
            end. 
            disp xliped.procod label "Aguarde... Lendo Produto"
                                with frame f-len3 centered color yellow/red
                                                side-label overlay row 10.
            pause 0.
        end. 
        else do: 
            cliped.lipsep = cliped.lipsep + dispro.romqtd. 
            cliped.wmsgaiola = ttitem.N_Gaiola.
            find estoq where estoq.etbcod = cliped.etbcod and
                             estoq.procod = cliped.procod no-lock no-error.
            if avail estoq
            then cliped.lippreco = estoq.estcusto.
            else do: 
                find first estoq where estoq.procod = xliped.procod
                                                       no-lock no-error.
                cliped.lippreco = estoq.estcusto.
            end. 
            disp cliped.procod label "Aguarde... Lendo Produto"
                                with frame f-len4 centered color yellow/red
                                                side-label overlay row 10.
        end.
    end.
end.                      
 
unix silent value("mv " + varq-ant + " " + varq-dep).
    
