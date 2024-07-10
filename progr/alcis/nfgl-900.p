/* Fechamento de Gaiola          WMS Alcis                              */

FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.


def input parameter par-rec as recid.

def var varq_aux        as char.
def var varquivo        as char.
def var vgaiola         as char format "x(11)".
def var p-valor         as int.

find plani where recid(plani) = par-rec no-lock no-error.
if not avail plani
then leave.

do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-NFGL".
    p-valor = int(tab_ini.valor) + 1.
    tab_ini.valor = string(p-valor).
end. 

varquivo = "/admcom/tmp/alcis/INS/NFGL" + string(p-valor,"99999999") + ".DAT". 
vgaiola  = acha("Gaiola", plani.NotPed).
output to value(varquivo).
put unformatted
    "LEBES"                 format "x(10)"
    "NFGL"                  format "x(4)"
    "NFGLH"                 format "x(8)"
    "CD3"                   format "x(3)"
    "900"                   format "x(12)"
    string(plani.desti)     format "x(12)"
    string(int(vgaiola))    format "x(11)"
    string(plani.numero)    format "x(12)"
    skip.
output close.
unix silent value("mv " + varquivo + " /usr/ITF/dat/in/").

do on error undo.
    create planiaux. 
    assign planiaux.etbcod      = plani.etbcod  
           planiaux.placod      = plani.placod 
           planiaux.emite       = plani.emite  
           planiaux.serie       = plani.serie  
           planiaux.numero      = plani.numero  
           planiaux.nome_campo  = "ALCIS_NFGL"  
           planiaux.valor_campo = "DATA="  + string(today) +
                                  "|HORA=" + string(time) +
                                  "|ARQ="  + varquivo.
end.

/***
    Integracao com a ITIM
***/
def var vlinha    as char.
def var vnarquivo as int.

def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as int
    field Etbcod            as int
    field N_Gaiola          as int
    field Itens             as int.

def temp-table ttitem
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Etbcod            as char format "x(12)"
    field N_Gaiola          as char format "x(11)"
    field Seq               as int
    field Procod            as int
    field Qtd               as dec
    field Unidade           as char format "x(6)"
    field ID_Distrib        as char format "x(32)".

varq_aux  = acha("Arquivo", plani.NotPed).

if length(varq_aux) = 13
then vnarquivo = int(substr(varq_aux, 5, 5)).
else if length(varq_aux) = 14
then vnarquivo = int(substr(varq_aux, 5, 6)).

varquivo  = "/admcom/tmp/alcis/itim/" + varq_aux.

if search(varquivo) <> ?
then do.
    input from value(varquivo).
    repeat.
        import unformatted vlinha.
        if substr(vlinha,15,8 ) = "FCGLH"
        then do.
            create ttheader.
            assign
                ttheader.Remetente      = substr(vlinha,1 ,10)
                ttheader.Nome_arquivo   = substr(vlinha,11,4 )
                ttheader.Nome_interface = substr(vlinha,15,8 )
                ttheader.Site           = substr(vlinha,23,3 )
                ttheader.Proprietario   = int( substr(vlinha,26,12) )
                ttheader.Etbcod         = int( substr(vlinha,38,12) )
                ttheader.N_Gaiola       = int( substr(vlinha,50,11) )
                ttheader.Itens          = int( substr(vlinha,61,3 ) ).
        end.
        if substr(vlinha,15,8 ) = "FCGLI"    
        then do.
            create ttitem.
            assign
                ttitem.Remetente      = substr(vlinha,1 ,10)
                ttitem.Nome_arquivo   = substr(vlinha,11,4 )
                ttitem.Nome_interface = substr(vlinha,15,8 )
                ttitem.Site           = substr(vlinha,23,3 )
                ttitem.Proprietario   = substr(vlinha,26,12)
                ttitem.Etbcod         = substr(vlinha,38,12)
                ttitem.N_Gaiola       = substr(vlinha,50,11)
                ttitem.seq            = int(substr(vlinha,61,3) )
                ttitem.procod         = int(substr(vlinha,64,40) )
                ttitem.qtd            = dec(substr(vlinha,104,18)) / 1000000000
                ttitem.unidade        = substr(vlinha,122,6)
                ttitem.id_distrib     = substr(vlinha,128,32).   
        end.
    end.
    input close.

    /* Deletar origem Admcom */
    for each ttitem.
        if ttitem.id_distrib = "" or
           ttitem.id_distrib = "99999" or
           ttitem.id_distrib = fill("0", 20)
        then delete ttitem.
    end.

    find first ttitem no-lock no-error.
    if avail ttitem
    then do.
        find wmsarq where wmsarq.etbori   = ttheader.Proprietario
                      and wmsarq.narquivo = vnarquivo
                    no-lock no-error.
        if not avail wmsarq
        then do on error undo.
            find first ttheader no-lock.
            create wmsarq.
            assign
                wmsarq.etbori = ttheader.Proprietario
                wmsarq.etbdes = ttheader.etbcod
                wmsarq.gaiola = ttheader.n_gaiola
                wmsarq.itens  = ttheader.Itens
                wmsarq.narquivo  = vnarquivo
                wmsarq.nfefuncod = plani.vencod
                wmsarq.nfedata = plani.dtincl
                wmsarq.nfehora = plani.horincl
                wmsarq.arquivo = varq_aux.

            for each ttitem no-lock.
                create wmsarqit.
                assign
                    wmsarqit.etbori = ttheader.Proprietario
                    wmsarqit.narquivo = vnarquivo
                    wmsarqit.procod = ttitem.procod
                    wmsarqit.seq    = ttitem.seq
                    wmsarqit.qtde   = ttitem.qtd
                    wmsarqit.STOCK_MOVEMENT_ID = ttitem.id_distrib.
            end.
        end.
    end.
    unix silent value("mv " + varquivo + " /admcom/tmp/alcis/bkp/").
end.
