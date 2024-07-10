{admcab.i}

def var varq as char format "x(60)".
update varq label "Arquivo CSV"
    help "Possuir duas colunas com codigo produto;codigo fornecedor"
    with side-label.
def var vprocod as char.
def var vforcod as char.

def temp-table tt-pro
    field procod as int format ">>>>>>>>9"
    field pronom like produ.pronom
    field forcod as int format ">>>>>>>>>9"
    field ufecod as char format "!!"
    field ncm as char format "x(15)"
    field alicms as dec
    field icmsst as dec
    field mva as dec
    field pis as dec
    field cofins as dec
    index i1 procod
    .
    

input from value(varq).
repeat:
    import delimiter ";" vprocod vforcod.

    create tt-pro.
    assign
        tt-pro.procod = int(vprocod)
        tt-pro.forcod = int(vforcod)
        .
end.
input close.    

for each tt-pro ,
    first produ where produ.procod = tt-pro.procod no-lock.
    tt-pro.pronom = produ.pronom.
    tt-pro.ncm = string(produ.codfis).
    find last movim where movim.procod = tt-pro.procod and
                          movim.movtdc = 4 and
                          movim.emite  = tt-pro.forcod
                          no-lock no-error.
    if avail movim 
    then do:
        tt-pro.pis = movim.movpis.
        tt-pro.cofins = movim.movcofins.
        tt-pro.alicms = movim.movalicms.
                    
        find first plani where plani.placod = movim.placod and
                        plani.etbcod = movim.etbcod and
                        plani.movtdc = movim.movtdc
                        no-lock.
        find first forne where forne.forcod = plani.emite no-lock no-error.
        if avail forne then tt-pro.ufecod = forne.ufecod.
        
        find a01_infnfe where a01_infnfe.chave = plani.ufdes no-lock
                 no-error.
        if avail a01_infnfe
        then do:         
            find i01_prod where 
             i01_prod.chave = plani.ufdes and
             i01_prod.procod = movim.procod
             no-lock no-error.
            if avail i01_prod
            then do:
                find n01_icms of i01_prod no-lock no-error. 
                if avail n01_icms
                then do:   
                    tt-pro.ncm = i01_prod.ncm.
                    tt-pro.mva = n01_icms.pMVAST.
                    tt-pro.icmsst = n01_icms.vicmsst.
                    tt-pro.alicms = n01_icms.picms.
                end.
            end.
        end.
        else do:
            find first mvcusto where mvcusto.etbcod = plani.etbcod and
                               mvcusto.placod = plani.placod and
                               mvcusto.serie  = plani.serie  and
                               mvcusto.procod = produ.procod
                               no-lock no-error.
            if avail mvcusto
            then do:
                tt-pro.pis    = dec(acha("valpis",mvcusto.char2)). 
                tt-pro.cofins = dec(acha("valcofins",mvcusto.char2)).
            end.            
        end.
    end.
end.
     
for each tt-pro.
    if tt-pro.procod = 0
    then delete tt-pro.
end.
/*
for each tt-pro.    
disp tt-pro.
end.
pause.
*/


def var varq-pro as char.
varq-pro = entry(1,varq,".") + "-gerado.csv".
output to value(varq-pro).
put "Codigo;Descricao;Fornecedor;UF origem;NCM;Aliq ICMS;ICMS ST;MVA;Pis;Cofins"
    skip.
for each tt-pro.
    put unformatted
    tt-pro.procod ";"
    tt-pro.pronom ";"
    tt-pro.forcod ";"
    tt-pro.ufecod ";"
    tt-pro.ncm ";"
    tt-pro.alicms ";"
    tt-pro.icmsst ";"
    tt-pro.mva ";"
    tt-pro.pis ";"
    tt-pro.cofins
    skip.
end.    
output close.

message color red/whit
    "Arquivo gerado" varq-pro
    view-as alert-box.

