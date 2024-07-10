/* helio 18/05/2022 https://trello.com/c/W3un7Tn8/347-thalis-exportador-titulos-unione */

def input param petbcod as int.

{/admcom/progr/api/acentos.i}

def var vcp as char init ";".
def var vnome as char.
def var vcpf  as char.
def var vvlr_principal as dec.
def var vvlr_seguro as dec.
def var vvlr_acrescimo as dec.
def var vvlr_saldo  as dec.
def var vvlr_nominal as dec.

def var vtpcontrato as char.

def var ccarteira as char.
def var cproduto  as char.
def var ccontrato_original as char.
def var ccliente_novo   as log format "novo/recorrente".

def var vt as int.

def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal 
    field saldoabe  like titulo.titvlcob  
    index idx is unique primary tipo desc contnum asc.

def temp-table ttcli no-undo
    field clicod    as int
    field dtcad     as date
    index cli is unique primary clicod asc.
    
def stream cliente.
output stream cliente to value("/admcom/tmp/unione/expunione_clientes_" + string(petbcod,"9999") + ".csv").
output to value("/admcom/tmp/unione/expunione_parcelas_" + string(petbcod,"9999") + ".csv").

put stream cliente unformatted
    "codigo_cliente" vcp
    "nome_cliente" vcp
    "cpf" vcp
    "dt_cadastro" vcp
    skip.

put unformatted
    "codigo_cliente" vcp
    "filial"  vcp    
    "modalidade" vcp
    "tp contrato" vcp
    "numero_contrato" vcp
    "numero_parcela" vcp
    "dt_emissao"         vcp
    "dt_vencimento" vcp
    "vlr_nominal" vcp
    "vlr_principal" vcp
    "vlr_acrescimo" vcp
    "vlr_seguro" vcp
    "vlr_saldo" vcp
    "dt_pagamento" vcp        
    "carteira" vcp
    "produto"  vcp 
    "contrato_original" vcp
    "cliente_novo" vcp    

    skip.

vt = 0.

for each contrato where contrato.etbcod = petbcod use-index mala no-lock.
    
    empty temp-table ttnovacao.
    
    vt = vt + 1.

    find ttcli where ttcli.clicod = contrato.clicod no-error.
    if not avail ttcli
    then do:
        vcpf  = "".
        vnome = "".
        
        create ttcli.
        ttcli.clicod = contrato.clicod.
        find clien where clien.clicod = contrato.clicod no-lock no-error.
        if avail clien
        then do:
            vnome = removeacento(clien.clinom) no-error.
            if vnome = ? then vnome = "-". 

            ttcli.dtcad  = clien.dtcad.
                   
            find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
            if avail neuclien 
            then do:
                if neuclien.cpf <> ?
                then do: 
                    if clien.tippes and length(string(neuclien.cpf)) <= 11
                    then vcpf = string(neuclien.cpf,"99999999999").
                    else vcpf = string(neuclien.cpf,"99999999999999").
                end.
                else do:
                    vcpf = clien.ciccgc.
                end.
            end.
            else do:
                vcpf = clien.ciccgc.
            end.
        end.
        put stream cliente
            unformatted
                contrato.clicod vcp
                caps(vnome)   vcp
                vcpf vcp
                string(ttcli.dtcad,"99/99/9999") vcp
                skip.
    
    end.    
    for each titulo where titulo.titnat = no and titulo.empcod = 19 and
            titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and
            titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum)
            no-lock .
        if titulo.titdtemi = ? 
        then next. 
        if titulo.titsit = "PAG" or titulo.titsit = "LIB"
           then.
           else next.
           
        ccliente_novo = no.

        if ttcli.dtcad = contrato.dtinicial
        then ccliente_novo = yes.

        if titulo.vlf_principal > 0 /* regra esta no comportamento */
        then do:
            if titulo.titdtemi < 04/20/2021
            then do:
                vvlr_principal = titulo.vlf_principal - titulo.titdes.
                vvlr_seguro    = titulo.titdes.
                vvlr_acrescimo = titulo.titvlcob - titulo.vlf_principal.
            end.
            else do:
                vvlr_principal = titulo.vlf_principal.
                vvlr_seguro    = titulo.titdes.
                vvlr_acrescimo = titulo.vlf_acrescimo.
            end.
        end.
        else do:
            
            vvlr_principal = titulo.titvlcob - titulo.titdes.
            vvlr_seguro    = titulo.titdes.
            vvlr_acrescimo = 0.
            
        end.
        find cobra where cobra.cobcod = titulo.cobcod no-lock no-error.
        ccarteira = (if titulo.cobcod <> ? 
                 then string(titulo.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "-").

            
        vtpcontrato = titulo.tpcontrato.
                    
        cproduto = "".
        run pegaproduto.

        ccontrato_original = "".
        if cproduto = "NOVACAO"    
        then do: 
            find first pdvmoeda where 
                    pdvmoeda.modcod = contrato.modcod and  
                    pdvmoeda.titnum = string(contrato.contnum) 
                    no-lock no-error.
            if avail pdvmoeda
            then do: 
                find first pdvmov of pdvmoe no-lock no-error.  
                if not avail pdvmov then next. 
                find pdvtmov of pdvmov no-lock. 
                if pdvtmov.novacao 
                then do:
                    run fin/montattnov.p (recid(pdvmov),no).
                    for each ttnovacao where ttnovacao.contnum <> contrato.contnum.             
                        ccontrato_original = ccontrato_original + 
                                    (if ccontrato_original = ""
                                     then ""
                                     else ",") +
                                     string(ttnovacao.contnum).
                    end.
                end.
            end.
        end.
                   
        vvlr_saldo = if titulo.titsit = "LIB"              
                 then titulo.titvlcob
                 else 0.
        vvlr_nominal = if titulo.titsit = "PAG"
                       then titulo.titvlcob
                       else if titulo.titvltot > 0
                            then titulo.titvltot
                            else titulo.titvlcob.
                             
        put unformatted
            titulo.clifor vcp
            titulo.etbcod vcp
            titulo.modcod vcp
            vtpcontrato vcp
            titulo.titnum vcp
            titulo.titpar vcp
            string(titulo.titdtemi,"99/99/9999") vcp
            string(titulo.titdtven,"99/99/9999") vcp
            trim(string(vvlr_nominal,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99")) vcp
            trim(string(vvlr_principal,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99")) vcp
            trim(string(vvlr_acrescimo,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99")) vcp
            trim(string(vvlr_seguro,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99"))    vcp
            trim(string(vvlr_saldo,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99")) vcp
            
            if titulo.titdtpag = ? then "" else string(titulo.titdtpag,"99/99/9999") vcp
            
            caps(ccarteira) vcp
            caps(cproduto) vcp
            string(ccliente_novo,"NOVO/RECORRENTE") vcp
            
            skip.
            
    end.            
end.





procedure pegaproduto.

    find ctbpostitprod where ctbpostitprod.contnum = int(titulo.titnum) no-lock no-error.
    if avail ctbpostitprod
    then do:
        cproduto = ctbpostitprod.produto.
        if cproduto = "DESCONHECIDO"
        then cproduto = "OUTROS".
        
        return.
    end.
    if vtpcontrato <> ""
    then do:
        cproduto =  if vtpcontrato = "F"
                    then "FEIRAO "
                    else if vtpcontrato = "N"
                         then "NOVACAO"
                         else if vtpcontrato = "L"
                              then "LP     "
                              else "".
        if cproduto <> ""
        then return.   
    end.    
    cproduto = "OUTROS".
    def var vcatcod as int.        
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail contrato
    then do:
        find contrsite where contrsite.contnum = int(titulo.titnum) no-lock no-error.
        if avail contrsite
        then do:
            cproduto = "Crediario Digital".
        end.
        else do:
            if contrato.modcod begins "CP"
            then do:
                cproduto = "Emprestimos".
            end.
            else do:    
                find first contnf where 
                    contnf.etbcod = contrato.etbcod and
                    contnf.contnum = contrato.contnum 
                    no-lock no-error.
                if avail contnf 
                then do:
                    find first plani where
                        plani.etbcod = contnf.etbcod and
                        plani.placod = contnf.placod 
                        no-lock no-error. 
                    if avail plani
                    then do:
                        vcatcod = 0.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod
                                             no-lock.
                            find produ of movim no-lock no-error.
                            if avail produ
                            then do:                    
                                if produ.catcod = 31 or produ.catcod = 41
                                then do:
                                    find categoria of produ no-lock.
                                    cproduto = caps(categoria.catnom).
                                    leave.
                                end.
                                else vcatcod = produ.catcod. 
                            end.
                        end.
                        if cproduto = "OUTROS"
                        then do:
                            find categoria where categoria.catcod = vcatcod no-lock no-error.
                            if avail categoria
                            then do:
                                cproduto = caps(categoria.catnom).
                            end.     
                        end.        
                    end.                                   
                end.          
            end.
        end.                     
    end.    
    if not avail ctbpostitprod
    then do on error undo:
        create ctbpostitprod.
        ctbpostitprod.contnum = int(titulo.titnum) .
        ctbpostitprod.produto = cproduto.
    end.    
    
end procedure.    

