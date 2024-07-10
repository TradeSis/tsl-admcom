{admcab.i}
{alcis/tpalcis.i}
def input parameter par-arq as char.

def var varquivo as char.
def var vqtde    as dec.

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

def var varq-dep as char.
def var varq-ant as char.
def var v as int.
def var vlinha as char.
def buffer xestab for estab.

varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.

input from ./consulta-crec.arq.
repeat.
    v = v + 1.
    import vlinha.
    if v = 1
    then do.
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


for each ttitem.
    find produ where produ.procod = int(ttitem.produto) no-lock no-error.
    if not avail produ
    then next.
    vqtde = dec(ttitem.Qtde_no_Pack) / 1000000000.
    if vqtde > 0
    then do on error undo.
        find first produaux where produaux.procod     = int(ttitem.produto)
                              and produaux.nome_campo = "Pack"
                       no-error.
        if not avail produaux
        then do.
            create produaux.
            assign
                produaux.procod      = int(ttitem.produto)
                produaux.nome_campo  = "Pack"
                produaux.valor_campo = string(vqtde).
        end.                
        produaux.valor_campo = string(vqtde).
    end.                                      
end.
for each ttitem where ttitem.bloq = "90".    
    find xestab where xestab.etbcod = int(ttitem.Fornecedor) no-lock no-error. 
    if not avail xestab
    then  /* notas de fornecedores */
        find last plani where plani.etbcod = int(ttitem.Proprietario) and
                         plani.numero = int(ttitem.NotaFiscal)   and
                         plani.desti  = int(ttitem.Proprietario) and
                         plani.emite  = int(ttitem.Fornecedor) 
                         no-lock no-error.
    else  /* notas de lojas */
        find last plani where plani.etbcod = int(ttitem.Fornecedor) and
                         plani.numero = int(ttitem.NotaFiscal)   and
                         plani.desti  = int(ttitem.Proprietario) and
                         plani.emite  = int(ttitem.Fornecedor) 
                         no-lock no-error.
    if not avail plani
    then next.

    find first movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.placod = plani.placod and
                     movim.procod = int(ttitem.produto) 
                     no-lock no-error.
    if not avail movim
    then next.

    find produ where produ.procod = int(ttitem.produto) no-lock no-error.
    if not avail produ
    then next.

    vqtde = dec(ttitem.Qtde_no_Pack) / 1000000000.
    if vqtde > 0
    then do on error undo.
        find first produaux where produaux.procod     = int(ttitem.produto)
                              and produaux.nome_campo = "Pack"
                       no-error.
        if not avail produaux
        then do.
            create produaux.
            assign
                produaux.procod      = int(ttitem.produto)
                produaux.nome_campo  = "Pack"
                produaux.valor_campo = string(vqtde).
        end.                
        produaux.valor_campo = string(vqtde).
    end.                                      

    if ttitem.bloq = "90"
    then do on error undo.
        /********  nao bloqueia mais a pedido do felipe
        create prodistr.
        ASSIGN prodistr.PlaCod   = ?                              
               prodistr.procod   = int(ttitem.produto)           
               prodistr.lipqtd   = dec(ttitem.quantidade) / 1000000000 
               prodistr.lipsit   = "A"                            
               prodistr.preqtent = 0                              
               prodistr.etbcod   = 995                            
               prodistr.numero   = next-value(prodistr)
               prodistr.etbabast = 995                            
               prodistr.predt    = today                          
               prodistr.lipseq   = prodistr.numero         
               prodistr.Tipo     = "BLOQ_ALCIS"                   
               prodistr.EtbOri   = 995                            
               prodistr.movpc    = 0                              
               prodistr.proposta = par-arq 
               prodistr.funcod   = sfuncod.                        

        create hprodistr.
        ASSIGN hprodistr.data     = today
               hprodistr.hora     = time
               hprodistr.procod   = prodistr.procod
               hprodistr.lipqtd   = prodistr.lipqtd
               hprodistr.lipsit   = prodistr.lipsit
               hprodistr.preqtent = prodistr.preqtent
               hprodistr.etbcod   = prodistr.etbcod
               hprodistr.numero   = prodistr.numero
               hprodistr.etbabast = prodistr.etbabast
               hprodistr.predt    = prodistr.predt
               hprodistr.lipseq   = prodistr.lipseq
               hprodistr.Tipo     = prodistr.Tipo
               hprodistr.EtbOri   = prodistr.EtbOri
               hprodistr.movpc    = prodistr.movpc
               hprodistr.proposta = "BLOQ_" + par-arq
               hprodistr.funcod   = prodistr.funcod.
        run alcis/sinc_prodistr.p (input prodistr.procod).
        *******************/
    end.
end.                        

unix silent value("mv " + varq-ant + " " + varq-dep).

