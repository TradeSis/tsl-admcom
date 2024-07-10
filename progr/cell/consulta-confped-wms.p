{admcab.i}
{tpalcis-wms.i}
def input parameter par-arq as char.

def var varquivo as char.
varquivo = alcis-diretorio + "/" + par-arq.
unix silent value("quoter " + varquivo + " > ./consulta-conf.arq" ). 
def temp-table ttheader
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"  
    field PROPRIETaRIO      as char format "x(12)"
    field NPedido           as char format "x(12)"     
    field Ncarga            as char format "x(12)"     
    field DataREAL          as char format "xxxxxxxx"  
    field HoraREAL          as char format "xxxxxxx"  
    field Peso              as char format "x(18)"
    field TipoPedido        as char format "x(4)"      
    field Transportadora    as char format "x(12)"     
    field Placa             as char format "x(10)".    
    

def temp-table ttitem       
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"
    field PROPRIETaRIO      as char format "x(12)"
    field NPedido           as char format "x(12)"
    field NItem             as char format "xxxx"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field Unidade           as char format "x(6)"
    field Peso              as char format "x(18)"
    field Lote              as char format "x(20)"
    .

def var v as int.
def var vlinha as char.
input from ./consulta-conf.arq.
repeat.
    v = v + 1.
    import vlinha.
    if v = 1 then do.
        create ttheader.
        assign
        ttheader.Remetente      =   substr(vlinha, 1   ,   10  )    .
        ttheader.NomeArquivo    =   substr(vlinha, 11  ,   4   )    .
        ttheader.NomeInterface  =   substr(vlinha, 15  ,   8   )    .
        ttheader.Site           =   substr(vlinha, 23  ,   3   )    .
        ttheader.PROPRIETaRIO   =   substr(vlinha, 26  ,   12  )    .
        ttheader.NPedido        =   substr(vlinha, 38  ,   12  )    .
        ttheader.Ncarga         =   substr(vlinha, 50  ,   12  )    .
        ttheader.Data           =   substr(vlinha, 62  ,   8   )    .
        ttheader.Hora           =   substr(vlinha, 70  ,   5   )    .
        ttheader.Peso           =   substr(vlinha, 75  ,   18  )    .
        ttheader.TipoPedido     =   substr(vlinha, 93  ,   4   )    .
        ttheader.Transportadora =   substr(vlinha, 97  ,   12  )    .
        ttheader.Placa          =   substr(vlinha, 109 ,   10  )
        .

        
        next.
    end.
    create ttitem.
    ttitem.Remetente        =   substr(vlinha,  1   ,   10  ).
    ttitem.NomeArquivo      =   substr(vlinha,  11  ,   4   ).
    ttitem.NomeInterface    =   substr(vlinha,  15  ,   8   ).
    ttitem.Site             =   substr(vlinha,  23  ,   3   ).
    ttitem.PROPRIETaRIO     =   substr(vlinha,  26  ,   12  ).
    ttitem.NPedido          =   substr(vlinha,  38  ,   12  ).
    ttitem.NItem            =   substr(vlinha,  50  ,   4   ).
    ttitem.Produto          =   substr(vlinha,  54  ,   40  ).
    ttitem.Quantidade       =   (substr(vlinha,  94  ,   18  )).
    ttitem.Unidade          =   substr(vlinha,  112 ,   6   ).
    ttitem.Peso             =   (substr(vlinha,  118 ,   18  )).
    ttitem.Lote             =   substr(vlinha,  136 ,   20  ).
    


end.
input close.

varquivo = "../relat/consulta-inve." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "157"
            &Page-Line = "66"
            &Nom-Rel   = ""CREC""
            &Nom-Sis   = """INTEGRACAO WMS ALCIS"""
            &Tit-Rel   = """Confirmacao da Ordem de Venda - arquivo "" +
                            par-arq                            "
            &Width     = "157"
            &Form      = "frame f-cabcab"}
do.
    find first ttheader.
    def var vpednum like pedid.pednum.
    def var vetbcod like pedid.etbcod.
    vetbcod = int(substr(npedido,1,3)).
    vpednum = int(substr(npedid,4)).
    disp ttheader
            with frame fheader width 250
                    down.
    find pedid where pedid.etbcod = vetbcod and
                     pedid.pednum = vpednum and
                     pedid.pedtdc = 95 no-lock no-error.
    if avail pedid
    then
    disp pedid.etbcod 
         pedid.pednum   
         pedid.modcod format "xxxxx"
         pedid.peddat
         pedid.sitped.
    down with frame fheader.
end.                        

for each ttitem.
    disp ttitem.produto  format "x(15)"
         ttitem.npedido

         dec(ttitem.Quantidade) / 1000000000 format ">>>>>>>>9"
                                column-label "Qtd WMS"
            with frame flin width 250
                    down.
    /*
    find liped of pedid where liped.procod = int(ttitem.produto) 
                            no-lock no-error.
    if avail liped
    then do.
        display liped.lipqtd column-label "Qtd Pedida!ERP"
                liped.lipent column-label "Qtd Separada!WMS"
                liped.lipsit
                liped.protip
                with frame flin .
    end.
    */
    down with frame flin.
end.                        
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
    
