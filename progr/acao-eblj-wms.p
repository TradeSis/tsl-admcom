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

        
        next.
    end.
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
    ttitem.Quantidade       =   substr(vlinha, 113  ,   9   ).
    ttitem.Unidade          =   substr(vlinha, 131  ,   6   ).
    


end.
input close.

do:
    find first ttheader.
    
    disp dec(ttheader.PROPRIETaRIO). pause.
    create ebljh.
    assign
        ebljh.codigo_proprietario = dec(ttheader.PROPRIETaRIO)
                        /*
                        dec(substr(trim(ttheader.PROPRIETaRIO),4,3))
                        */
        ebljh.numero_carregamento = dec(ttheader.NCarregamento)
        ebljh.numero_filial       = int(ttheader.NLoja)
        ebljh.data                = if trim(ttheader.Data) <> "0"
                                    then date(ttheader.Data)
                                    else ?
        ebljh.hora                = ttheader.Hora
        ebljh.codigo_transp       = ttheader.Transportadora
        ebljh.placa_veiculo       = ttheader.Placa 
        ebljh.situacao = "F"
        .
end.
 
for each ttitem.
                                              
    create eblji.
    assign
        eblji.codigo_proprietario = dec(ttitem.PROPRIETaRIO)     
        eblji.numero_carregamento = dec(ttitem.NCarregamento)
        eblji.numero_pedido       = int(substr(ttitem.NPedido,4,9))
        eblji.numero_filial       = int(ttitem.NLoja) 
        eblji.procod              = int(ttitem.Produto) 
        eblji.quantidade          = dec(ttitem.Quantidade)
        eblji.unidade             = ttitem.Unidade  
        eblji.situacao = "F"
        .
end.                        

output to erro.rr.
unix silent value("cp " + varq-ant + " " + varq-dep).
unix silent value("rm -rf " + varq-ant).
output close.

{mens-interface-wms-alcis.i "REC"}
