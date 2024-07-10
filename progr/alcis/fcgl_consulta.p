{admcab.i}
{alcis/tpalcis.i}

def input parameter par-arq as char.

def var varquivo as char.
def var vlinha   as char.
def var vpednum  like pedid.pednum.

def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Etbcod            as char format "x(12)"
    field N_Gaiola          as char format "x(11)"
    field Itens             as char format "xxx".

def temp-table ttitem
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Etbcod            as int  format ">>>>>9"
    field N_Gaiola          as char format "x(11)"
    field Seq               as char format "xxx"
    field Procod            as int
    field Qtd               as dec
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
               ttheader.Proprietario   = substr(vlinha,26,12)
               ttheader.Etbcod         = substr(vlinha,38,12)
               ttheader.N_Gaiola       = substr(vlinha,50,11)
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
               ttitem.Etbcod         = int( substr(vlinha,38,12))
               ttitem.N_Gaiola       = substr(vlinha,50,11)
               ttitem.seq            = substr(vlinha,61,3 )
               ttitem.procod         = int( substr(vlinha,64,40))
               ttitem.qtd            = dec( substr(vlinha,104,18)) / 1000000000
               ttitem.unidade        = substr(vlinha,122,6)
               ttitem.id_distrib     = substr(vlinha,128,32).
    end.
end.
input close.

varquivo = "../relat/fcgl-consulta." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "157"
            &Page-Line = "66"
            &Nom-Rel   = ""fcgl""
            &Nom-Sis   = """INTEGRACAO WMS ALCIS"""
            &Tit-Rel   = """FECHAMENTO DE GAIOLA - ARQUIVO : "" + par-arq"
            &Width     = "157"
            &Form      = "frame f-cabcab"}

for each ttheader.
    disp ttheader
            with frame flin width 250 down.
    down with frame flin.

    for each ttitem.
        find produ of ttitem no-lock.
        display ttitem except Remetente Nome_arquivo Nome_interface
                        Site Proprietario
                with frame fitem width 250 down.

        display produ.pronom format "x(33)" with frame fitem.

        if ttitem.id_distrib = "" or
           ttitem.id_distrib = "99999"
        then do.
            find first dispro where dispro.situacao  = "WMS" and
                                    dispro.etbcod    = int(ttitem.etbcod) and
                                    dispro.procod    = int(ttitem.procod) and
                                    dispro.dtenvwms <> ?                  and
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
                disp dispro.pednum
                     dispro.disdat format "99/99/99"
                     dispro.disqtd
                     dispro.romqtd
                     with frame fitem.
                down with frame fitem.          
            end.
        end.
    end.
end.                        

output close.    
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else do:
    {mrod.i}
end.
    
