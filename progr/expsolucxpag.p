
def var par-dtultimoprocesso as date. /* Periodo de verificacao */
def var par-valortransacao as dec. /* valor da transacao para envio */
def var vconta as int.

def var vcp as char init ";".

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

find first tab_ini where tab_ini.parametro = "EXPSOLUCXPAG"
    no-lock no-error.
par-dtultimoprocesso =  if avail tab_ini  
                        then date(tab_ini.valor) 
                        else today - 1 no-error. 
if par-dtultimoprocesso = ?
then par-dtultimoprocesso = today - 1.


/* Funcoes */

/* descontinuado
*function buscavenda returns decimal
    (input p-recid as recid):
    def var ytotal as dec.
    def buffer xtitulo for titulo.         
    def buffer xcontrato for contrato.
    def buffer xcontnf for contnf.
    def buffer xplani for plani.
    
    find xtitulo where recid(xtitulo) = p-recid no-lock.    
    ytotal = 0.    
    find xcontrato where xcontrato.contnum = int(xtitulo.titnum) no-lock no-error.
    if avail xcontrato
    then do:
        find xcontnf where 
                xcontnf.etbcod  = xtitulo.etbcod and
                xcontnf.contnum = xcontrato.contnum no-lock no-error.
        if avail xcontnf
        then do:
            find first xplani where xplani.etbcod = xcontnf.etbcod and
                              xplani.placod = xcontnf.placod
                no-lock no-error.
            if avail xplani
            then do: 
                ytotal = if xplani.biss > 0   
                         then xplani.biss 
                         else (xplani.platot - xplani.vlserv).
            end.
        end.
    end.                
    
        
    return ytotal.
     
*end function.     
*/

function buscavendedor returns integer
    (input p-recid as recid):
    def var yvencod like plani.vencod.
    def buffer xtitulo for titulo.         
    def buffer xcontrato for contrato.
    def buffer xcontnf for contnf.
    def buffer xplani for plani.
    
    find xtitulo where recid(xtitulo) = p-recid no-lock.    
    yvencod = 0.
    find xcontrato where xcontrato.contnum = int(xtitulo.titnum) no-lock no-error.
    if avail xcontrato
    then do:
        find xcontnf where 
                xcontnf.etbcod  = xtitulo.etbcod and
                xcontnf.contnum = xcontrato.contnum no-lock no-error.
        if avail xcontnf
        then do:
            find first xplani where xplani.etbcod = xcontnf.etbcod and
                              xplani.placod = xcontnf.placod
                no-lock no-error.
            if avail xplani
            then do:
                yvencod = xplani.vencod.
            end.
        end.
    end.                
    return yvencod.
     
end function.     


message "processando pagamentos...". 
for each estab no-lock.
    /* regra 13.12.18, tirar a filial 65 da selecao */
    if estab.etbcod = 65
    then next.
     /* regra 26.12.18, tirar a filial 988 da selecao */
    if estab.etbcod = 988
    then next.
   
    hide message no-pause.
    message "processando pagamentos..." "loja" esta.etbcod "desde" par-dtultimoprocesso. 
    do vdata = par-dtultimoprocesso - 2 to today - 1:
        for each titulo where
            titulo.titnat = no and
            titulo.titdtpag = vdata and
            titulo.etbcod  = estab.etbcod and
            titulo.modcod = "CRE"
            no-lock.

            find clien where clien.clicod = titulo.clifor no-lock no-error.
            if not avail clien
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

            
            /* aguardando saber se eh necessario mesmo ou nao
            *vven_transacao  = buscavendedor(recid(titulo)).
            */
            
            
            /** regra valida pegando a venda somente
            /* valida valor da venda */
            *if vvalorvenda < par-valortransacao 
            *then next.
            */
            
            /**
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
                                tt-cli.data_transacao = titulo.titdtpag and 
                                tt-cli.etb_transacao  = titulo.etbcobra 
                no-error.         
            if not avail tt-cli
            then do:
                create tt-cli.
                tt-cli.clicod = clien.clicod. 
                tt-cli.data_transacao = titulo.titdtpag. 
                tt-cli.etb_transacao  = titulo.etbcobra.
                tt-cli.ven_transacao  = vven_transacao.
            end.    
            tt-cli.valor  = tt-cli.valor + titulo.titvlcob.
        end.       
    end.        
end.



vconta = 0. 
for each tt-cli. 
    vconta = vconta + 1.
end.
hide message no-pause.
message "processando..." vconta "transacoes".


output to /admcom/tmp/solucx/lebespagamentos.csv.
    put unformatted skip
        "id_transacao" vcp
        "id_loja" vcp
        "id_crediarista" vcp
        "data_pagamento" vcp
        "id_cliente" vcp
        "nome_do_cliente" vcp
        "sexo_do_cliente" vcp
        "telefone" vcp
        "email" vcp
        "cpf" vcp
        "valor"
        skip.

for each tt-cli
    break by tt-cli.clicod.
    find clien where clien.clicod = tt-cli.clicod no-lock.
    put unformatted skip
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
        trim(string(tt-cli.valor,">>>>>>>>>>>>9.99")).
end.
output close.


do on error undo
    transaction:
    
    find first tab_ini where tab_ini.parametro = "EXPSOLUCXPAG"
        exclusive-lock no-error.
    if avail tab_ini
    then do:
        tab_ini.valor = string(today - 2,"99/99/9999").
    end.

end.

