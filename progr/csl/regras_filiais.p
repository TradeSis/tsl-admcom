def input parameter par-regra   as char.
def input parameter par-filial  as int.
def var vok as log.
{admcab.i}
def temp-table ttparam no-undo
    field REGRA         as char format "x(20)"
    field OPCAO         as char format "x(10)"
    field PARAMETRO     as char format "x(16)"
    field PROGRAMA      as char format "x(12)".

input from /admcom/progr/csl/parametro.ini.
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
def var vativa as log.
vativa = no.    
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
            create ttfilial.
            ttfilial.etbcod = estab.etbcod.
            ttfilial.REGRA  = ttparam.regra.
            ttfilial.OPCAO  = ttparam.opcao.
            ttfilial.PARAMETRO = ttparam.parametro.
            ttfilial.valor  = tab_INI.valor.
            if par-filial <> 0
            then do:
                if tab_INI.valor = "SIM"
                then vativa = yes.
            end.
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
    

for each ttfilial
    where 
        (if par-regra <> ""
         then ttfilial.regra = par-regra
         else true)  and
        (if par-filial <> 0
         then (ttfilial.etbcod = par-filial or
               ttfilial.etbcod = 0)
         else true) 
         
    break 
          by ttfilial.regra
          by ttfilial.etbcod.
    disp ttfilial 
        with centered.

end.    

if par-filial <> 0 and par-regra = ""
then do:
    if vativa = no
    then do:
        sresp = no.
        message "Ativar Filial" par-filial "em todos os parametros?" update sresp.
        if sresp 
        then do:
            for each ttparam where ttparam.opcao = "filiais" break by ttparam.parametro.
                create tab_ini.
                tab_ini.etbcod    = par-filial.
                tab_ini.cxacod    = 0.
                tab_ini.parametro = ttparam.parametro .
                tab_ini.valor     = "SIM".
                tab_ini.dtinclu   = today.
                tab_ini.dtexp     = today.
            end.
            leave.
        end.
    end.
end.    
