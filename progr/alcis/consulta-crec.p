{admcab.i}
{alcis/tpalcis.i}

def input parameter par-arq as char.
def var varquivo as char.

varquivo = alcis-diretorio + "/" + par-arq.
unix silent value("quoter " + varquivo + " > ./consulta-crec.arq" ). 
def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)"
    field Fornecedor        as char format "x(12)".

def temp-table ttitem
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)" 
    field Fornecedor        as char format "x(12)"
    field bloq              as char format "xx"
    field Qtde_no_Pack      as char format "x(18)".

def var v as int.
def var vlinha as char.

input from ./consulta-crec.arq.
repeat.
    v = v + 1.
    import vlinha.
    if v = 1 then do.
        create ttheader.
        assign ttheader.Remetente      = substr(vlinha,1 ,10)
               ttheader.Nome_arquivo   = substr(vlinha,11,4 )
               ttheader.Nome_interface = substr(vlinha,15,8 )
               ttheader.Site           = substr(vlinha,23,3 )
               ttheader.NotaFiscal     = substr(vlinha,26,12)
               ttheader.Proprietario   = substr(vlinha,38,12)
               ttheader.Fornecedor     = substr(vlinha,50,12).
        next.
    end.
    create ttitem.
    assign ttitem.Remetente      = substr(vlinha,  1,10)
           ttitem.Nome_arquivo   = substr(vlinha, 11,04)
           ttitem.Nome_interface = substr(vlinha, 15,08)
           ttitem.Produto        = substr(vlinha, 23,40)
           ttitem.Quantidade     = substr(vlinha, 63,18)
           ttitem.NotaFiscal     = substr(vlinha, 81,12)
           ttitem.Proprietario   = substr(vlinha, 93,12)
           ttitem.Fornecedor     = substr(vlinha,105,12)
           ttitem.bloq           = substr(vlinha,117, 2)
           ttitem.Qtde_no_Pack   = substr(vlinha,119,18).
end.
input close.

varquivo = "../relat/consulta-crec." + string(time).
    
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""CREC""
        &Nom-Sis   = """INTEGRACAO WMS ALCIS"""
        &Tit-Rel   = """CONFIRMACAO DO RECEBIMENTO - ARQUIVO: "" + par-arq"
        &Width     = "120"
        &Form      = "frame f-cabcab"}

for each ttheader no-lock.
    disp ttheader
         with frame fheader width 250 down.
    down with frame fheader.
end.                        

for each ttitem no-lock.
    disp ttitem.produto  format "x(15)"
         ttitem.NotaFiscal 
         ttitem.Fornecedor 
         dec(ttitem.Quantidade) / 1000000000 format ">>>>>>>>9"
                                column-label "Qtd WMS"
         ttitem.bloq column-label "Status" 
         ttitem.bloq = "90" format "Bloq/"
         dec(ttitem.Qtde_no_Pack) / 1000000000 format ">>>>>>>>9"
                                column-label "Qtd.no Pack"
         with frame flin width 250 down.

    def buffer xestab for estab.
    find xestab where xestab.etbcod = int(ttitem.Fornecedor) no-lock no-error. 
    if not avail xestab
    then  /* notas de fornecedores */
        find last plani where plani.etbcod = int(ttitem.Proprietario) and
                              plani.numero = int(ttitem.NotaFiscal)   and
                              plani.desti  = int(ttitem.Proprietario) and
                              plani.emite  = int(ttitem.Fornecedor) 
                        no-lock no-error.
    else /* notas de lojas */
        find last plani where plani.etbcod = int(ttitem.Fornecedor)   and
                              plani.numero = int(ttitem.NotaFiscal)   and
                              plani.desti  = int(ttitem.Proprietario) and
                              plani.emite  = int(ttitem.Fornecedor) 
                        no-lock no-error.
    if avail plani
    then do.
        find movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.placod = plani.placod and
                     movim.procod = int(ttitem.produto) 
                     no-lock no-error.
        display movim.movqtm label "Qtd ERP" format ">>>>>>>>9"
                with frame flin.
        disp numero pladat dtinclu with frame flin.                      
    end.
    down with frame flin.
end.                        

output close.
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else do:
    {mrod.i}
end.
    
