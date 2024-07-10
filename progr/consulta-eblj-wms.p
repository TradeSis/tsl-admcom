{admcab.i}
{tpalcis-wms.i}
def input parameter par-arq as char.

def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/INS/".
def var vdiretorio-apos as char.
vdiretorio-apos = "/usr/ITF/dat/in/".


def var varquivo as char.
varquivo = alcis-diretorio + "/" + par-arq.
def var varq-dep as char.
def var varq-ant as char.
varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.

unix silent value("quoter " + varquivo + " > ./consulta-conf.arq" ). 
def temp-table ttheader
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"  
    field PROPRIETaRIO      as char format "x(12)"
    field NCarregamento     as char format "x(11)"     
    field NLoja             as char format "x(12)"     
    field DataREAL          as char format "xxxxxxxx"  
    field HoraREAL          as char format "xxxxxxx"  
    field Transportadora    as char format "x(12)"     
    field Placa             as char format "x(10)".    
    

def temp-table ttitem       
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"
    field PROPRIETaRIO      as char format "x(12)"
    field NCarregamento     as char format "x(11)"
    field NPedido           as char format "x(12)"
    field NLoja             as char format "x(12)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field Unidade           as char format "x(6)"
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
        ttheader.NCarregamento  =   substr(vlinha, 38  ,   11  )    .
        ttheader.NLoja          =   substr(vlinha, 49  ,   12  )    .
        ttheader.Data           =   substr(vlinha, 61  ,   8   )    .
        ttheader.Hora           =   substr(vlinha, 69  ,   5   )    .
        ttheader.Transportadora =   substr(vlinha, 74  ,   12  )    .
        ttheader.Placa          =   substr(vlinha, 86  ,   10  )
        .

    end.
    else do:
    create ttitem.
    ttitem.Remetente        =   substr(vlinha,  1   ,   10  ).
    ttitem.NomeArquivo      =   substr(vlinha,  11  ,   4   ).
    ttitem.NomeInterface    =   substr(vlinha,  15  ,   8   ).
    ttitem.Site             =   substr(vlinha,  23  ,   3   ).
    ttitem.PROPRIETaRIO     =   substr(vlinha,  26  ,   12  ).
    ttitem.NCarregamento    =   substr(vlinha,  38  ,   11  ).
    ttitem.NPedido          =   substr(vlinha,  49  ,   12  ).
    ttitem.NLoja            =   substr(vlinha,  61  ,   12  ).
    ttitem.Produto          =   substr(vlinha,  73  ,   40  ).
    ttitem.Quantidade       =   substr(vlinha, 113  ,   9  ).
    ttitem.Unidade          =   substr(vlinha, 131  ,   6   ).
    
    end.

end.
input close.

varquivo = "../relat/consulta-inve." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""CREC""
            &Nom-Sis   = """INTEGRACAO WMS ALCIS"""
            &Tit-Rel   = """Confirmacao de Embarque - arquivo "" +
                            par-arq                            "
            &Width     = "100"
            &Form      = "frame f-cabcab"}

do:
    find first ttheader.
    def var vpednum like pedid.pednum.
    def var vetbcod like pedid.etbcod.

    disp 
        ttheader.PROPRIETaRIO
        ttheader.NCarregamento
        ttheader.NLoja
        ttheader.Data
        ttheader.Hora
        ttheader.Transportadora
        ttheader.Placa
            with frame fheader width 200
                    down.
    /***
    create ebljh.
    assign
        ebljh.codigo_proprietario = dec(ttheader.PROPRIETaRIO)
        ebljh.numero_carregamento = dec(ttheader.NCarregamento)
        ebljh.numero_filial       = int(ttheader.NLoja)
        ebljh.data                = date(ttheader.Data)
        ebljh.hora                = ttheader.Hora
        ebljh.codigo_transp       = ttheader.Transportadora
        ebljh.placa_veiculo       = ttheader.Placa 
        ebljh.situacao = "F"
        .
        ***/
end.
 
for each ttitem.

    disp  
    ttitem.PROPRIETaRIO
    ttitem.NCarregamento
    ttitem.NPedido
    ttitem.NLoja
    ttitem.Produto   format "x(10)"
    ttitem.Quantidade format "x(10)"
    ttitem.Unidade
    with frame fttitem width 200
            down.
    
    /*
    create eblji.
    assign
        eblji.codigo_proprietario = dec(ttitem.PROPRIETaRIO)     
        eblji.numero_carregamento = dec(ttitem.NCarregamento)
        eblji.numero_pedido       = int(ttitem.NPedido)
        eblji.numero_filial       = int(ttitem.NLoja) 
        eblji.procod              = int(ttitem.Produto) 
        eblji.quantidade          = dec(ttitem.Quantidade)
        eblji.unidade             = ttitem.Unidade  
        eblji.situacao = "F"
        .
      */
end.                        

output close.
run visurel.p (input varquivo, input "").



