
def var par-dtultimoprocesso as date. /* Periodo de verificacao */
def var par-valortransacao as dec. /* valor da transacao para envio */
def var vconta as int.

def var vcp as char init ";".

def var vvalorvenda as dec.
def var vven_transacao as int.
def var verro       as log.
def var vdata       as date.

def temp-table tt-cli no-undo
    field clicod            like clien.clicod
    field data_transacao    as date
    field etb_transacao     like plani.etbcod
    field valor             as dec
    field ven_transacao as int
    index clitrans is unique primary
                etb_transacao  asc
                clicod asc
                data_transacao asc.


find first tab_ini where tab_ini.parametro = "EXPSOLUCXVEN"
    no-lock no-error.
par-dtultimoprocesso =  if avail tab_ini  
                        then date(tab_ini.valor) 
                        else today - 1 no-error. 
if par-dtultimoprocesso = ?
then par-dtultimoprocesso = today - 1.

find first tab_ini where tab_ini.parametro = "EXPSOLUCXVLR"
    no-lock no-error.
par-valortransacao   = if avail tab_ini
                       then dec(tab_ini.valor)
                       else 0 no-error.
if par-valortransacao = ?
then par-valortransacao = 0.
                       

message "processando vendas... desde" par-dtultimoprocesso - 1 "valor " par-valortransacao. 
for each estab no-lock.
 
    /* regra 13.12.18, tirar a filial 65 da selecao */
    if estab.etbcod = 65
    then next.

    /* regra 26.12.18, tirar a filial 988 da selecao */
    if estab.etbcod = 988
    then next.
    
 
    hide message no-pause.
    message "processando vendas..." "loja" esta.etbcod "desde" par-dtultimoprocesso. 
    
    for each plani where
        plani.movtdc = 5 and
        plani.etbcod = estab.etbcod and
        plani.pladat >= par-dtultimoprocesso - 1 and
        plani.pladat <= today - 1  no-lock.

        if plani.desti = 1 
        then next.   
        find clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien
        then next.

        vvalorvenda = if plani.biss > 0  
                      then plani.biss
                      else (plani.platot - plani.vlserv).
 
        /* valida valor da venda */
        if vvalorvenda < par-valortransacao 
        then next.
     
        /* valida dados cadastrais */
        verro = yes.
        if clien.zona <> "" and /* email */   
           clien.zona <> ?
        then verro = no.
        if clien.fone <> "" and
           clien.fone <> ? 
        then verro = no.
        if clien.fax <> "" and /* celular */
           clien.fax <> ? 
        then verro = no.
        if verro 
        then next.

        
        /*
        /* verifica se clien ja foi enviado ultimox x dias*/
        *
        *find flag where flag.clicod = clien.clicod no-lock no-error.
        *if avail flag
        *then do:
        *    if flag.datexp2 <> ?
        *    then do:
        *        if flag.datexp2 < today - par-periodoenvio
        *        then next.
        *    end.
        *end.
        */
        
        find first tt-cli where tt-cli.clicod = clien.clicod and 
                                tt-cli.data_transacao = plani.pladat and 
                                tt-cli.etb_transacao  = plani.etbcod 
            no-error.         
        if not avail tt-cli
        then do:
            create tt-cli.
            tt-cli.clicod = clien.clicod. 
            tt-cli.data_transacao = plani.pladat. 
            tt-cli.etb_transacao  = plani.etbcod.
            tt-cli.ven_transacao = plani.vencod.
        end.    
        tt-cli.valor  = tt-cli.valor + vvalorvenda.
    end.       
end.


vconta = 0. 
for each tt-cli. 
    vconta = vconta + 1.
end.
hide message no-pause.
message "processando..." vconta "transacoes".



output to value("/admcom/tmp/solucx/lebesvendas000" + "_" + string(today,"999999") + ".csv").
    put unformatted skip
        "id_transacao" vcp
        "id_loja" vcp
        "id_consultor" vcp
        "data_compra" vcp
        "id_cliente" vcp
        "nome_do_cliente" vcp
        "sexo_do_cliente" vcp
        "telefone" vcp
        "email" vcp
        "cpf" vcp
        "valor"
        skip.

for each tt-cli where tt-cli.etb_transacao <> 200
    break by tt-cli.clicod.
    find clien where clien.clicod = tt-cli.clicod no-lock.
    put unformatted 
        string(tt-cli.etb_transacao,"999") +
        string(tt-cli.data_transacao,"99999999") +
        string(tt-cli.clicod)  vcp
        string(tt-cli.etb_transacao,"999") vcp
        tt-cli.ven_transacao vcp
        tt-cli.data_transacao vcp
        tt-cli.clicod vcp
        clien.clinom vcp
        trim(string(clien.sexo,"Masculino/Feminino")) vcp
        (if clien.fone = "" or clien.fone = ?
         then clien.fax
         else clien.fone) vcp
        clien.zona vcp
        clien.ciccgc vcp
        trim(string(tt-cli.valor,">>>>>>>>>>>>9.99"))
        skip.
        
end.
output close.


message "Exportando Filial 200".

output to value("/admcom/tmp/solucx/lebesvendas200" + "_" + string(today,"999999") + ".csv").
    put unformatted skip
        "id_transacao" vcp
        "id_loja" vcp
        "id_consultor" vcp
        "data_compra" vcp
        "id_cliente" vcp
        "nome_do_cliente" vcp
        "sexo_do_cliente" vcp
        "telefone" vcp
        "email" vcp
        "cpf" vcp
        "valor"
        skip.

for each tt-cli where tt-cli.etb_transacao = 200
    break by tt-cli.clicod.
    find clien where clien.clicod = tt-cli.clicod no-lock.
    put unformatted 
        string(tt-cli.etb_transacao,"999") +
        string(tt-cli.data_transacao,"99999999") +
        string(tt-cli.clicod)  vcp
        string(tt-cli.etb_transacao,"999") vcp
        tt-cli.ven_transacao vcp
        tt-cli.data_transacao vcp
        tt-cli.clicod vcp
        clien.clinom vcp
        trim(string(clien.sexo,"Masculino/Feminino")) vcp
        (if clien.fone = "" or clien.fone = ?
         then clien.fax
         else clien.fone) vcp
        clien.zona vcp
        clien.ciccgc vcp
        trim(string(tt-cli.valor,">>>>>>>>>>>>9.99"))
        skip.
        
end.
output close.



do on error undo
    transaction:
    
    find first tab_ini where tab_ini.parametro = "EXPSOLUCXVEN"
        exclusive-lock no-error.
    if avail tab_ini
    then do:
        
        tab_ini.valor = string(today,"99/99/9999").
        
    end.

end.
    
