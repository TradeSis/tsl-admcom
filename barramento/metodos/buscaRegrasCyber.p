DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.

def var par-filial as int.
def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.
def var vi as int.
def var vok as log.

def temp-table ttparam no-undo
    field REGRA         as char format "x(20)"
    field OPCAO         as char format "x(10)"
    field PARAMETRO     as char format "x(16)"
    field PROGRAMA      as char format "x(12)".

{/admcom/barramento/metodos/buscaRegrasCyber.i}

/* LE ENTRADA */
lokJSON = hconteudoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

find first ttRegrasCyberEntrada no-error.
par-filial = int(ttregrasCyberEntrada.codigofilial).

create ttstatus.

input from /admcom/progr/cyb/parametro.ini.
repeat transaction on error undo , leave.
    create ttparam.
    import delimiter "," ttparam.
    if ttparam.regra = "" then delete ttparam.
end.    

for each ttparam.
    if ttparam.regra = "REGRA" or 
       ttparam.regra = "" or 
       ttparam.regra = ?
    then delete ttparam. 
end. 


def temp-table ttfilial no-undo
    field etbcod    like estab.etbcod
    field REGRA     like ttparam.regra     format "x(20)" 
    field OPCAO     like ttparam.OPCAO     format "x(12)"
    field PARAMETRO like ttparam.PARAMETRO format "x(20)"
    field VALOR     like tab_ini.VALOR format "x(6)".

    
for each ttparam break by ttparam.parametro.
    for each tab_ini where 
            tab_ini.etbcod      = 0 and
            tab_ini.parametro   = ttparam.parametro
            no-lock.
        create ttfilial.
        ttfilial.etbcod = 0.
        ttfilial.REGRA  = ttparam.regra.
        ttfilial.OPCAO  = ttparam.opcao.
        ttfilial.PARAMETRO = ttparam.parametro.
        ttfilial.valor  = tab_INI.valor.
    end.                            
    for each estab where
            (if par-filial <> 0
             then (estab.etbcod = par-filial)
             else true) no-lock.
        vok = no.
        for each tab_ini where 
            tab_ini.etbcod      = estab.etbcod and
            tab_ini.parametro   = ttparam.parametro
            no-lock.
            vok = yes.
            if ttparam.opcao = "Filiais" and tab_ini.valor = "NAO"
            then next.
            create ttfilial.
            ttfilial.etbcod = estab.etbcod.
            ttfilial.REGRA  = ttparam.regra.
            ttfilial.OPCAO  = ttparam.opcao.
            ttfilial.PARAMETRO = ttparam.parametro.
            ttfilial.valor  = tab_INI.valor.
        end.          
        
        if vOK = no and 
           ttparam.opcao = "Filiais"
        then do:
                create ttfilial.
                ttfilial.etbcod = estab.etbcod.
                ttfilial.REGRA  = ttparam.regra.
                ttfilial.OPCAO  = ttparam.opcao.
                ttfilial.PARAMETRO = ttparam.parametro.
                ttfilial.valor  = "NAO".
        end.
                          
    end.
end.
    
for each ttparam.
    find first ttregras where ttregras.regra = ttparam.regra no-error.
    if not avail ttregras
    then do:
        create ttregras.
        ttregras.regra = ttparam.regra.
    end.
    if ttparam.opcao = "Filiais" 
    then do:
        for each ttfilial where ttfilial.etbcod > 0 and
                            ttfilial.regra  = ttparam.regra and
                            ttfilial.opcao  = ttparam.opcao and
                            ttfilial.valor  <> "NAO" :
            create ttregrasfilial.
            ttregrasfilial.regra      = ttparam.regra.
            ttregrasfilial.filial     = string(ttfilial.etbcod).
        end.                   
        find first ttfilial where
            ttfilial.etbcod = 0 and
            ttfilial.regra  = ttparam.regra and
            ttfilial.opcao  = ttparam.opcao 
                        no-error.
        if avail ttfilial
        then do:
             create ttregrasfilial.
             ttregrasfilial.regra      = ttparam.regra.
             if ttfilial.valor = "NAO"
             then ttregrasfilial.filial     = "NENHUMA".
             else ttregrasfilial.filial     = "TODAS".
        end.
        next.    
    end.
    find first ttparametros where 
            ttparametros.regra      = ttparam.regra and
            ttparametros.atributo   = ttparam.opcao
        no-error.
    if not avail ttparametros
    then do:
        create ttparametros.
        ttparametros.regra      = ttparam.regra.
        ttparametros.atributo   = ttparam.opcao.
        ttparametros.parametroadmcom = ttparam.parametro.
    end.
    find first ttfilial where
        ttfilial.etbcod = 0 and
        ttfilial.regra  = ttparam.regra and
        ttfilial.opcao  = ttparam.opcao 
        no-error.
    ttparametros.valor = if avail ttfilial 
                    then ttfilial.valor
                    else "NAO".
    for each ttfilial where ttfilial.etbcod > 0 and
        ttfilial.regra  = ttparam.regra and
        ttfilial.opcao  = ttparam.opcao .
        create ttparametrosfilial.
        ttparametrosfilial.regra      = ttparam.regra.
        ttparametrosfilial.atributo   = ttparam.opcao.
        ttparametrosfilial.filial = string(ttfilial.etbcod).
        ttparametrosfilial.valor = ttfilial.valor.        
    end.                        
end.

for each ttregras.
    find first ttregrasfilial where 
        ttregrasfilial.chave = ttregras.chave and
        ttregras.regra = ttregrasfilial.regra
         no-error.
    if not avail ttregrasfilial
    then do:
        find first ttfilial where
            ttfilial.regra = ttregras.regra and
            ttfilial.opcao = "Filiais"
            no-error.    
        create ttregrasfilial.
        ttregrasfilial.regra = ttregras.regra.
        ttregrasfilial.filial = if avail ttfilial
                                then "NENHUMA"
                                else "TODAS".
    end.
end.



lokJson = hconteudoSaida:WRITE-JSON("LONGCHAR",  lcJsonSaida, TRUE).

