def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9017 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

vdg = "9017".
output to value(par-arquivo) append.  
/*def var vhora as int.
vhora = 3600 * 12 .*/
for each hispre where
         hispre.dtalt >= par-dtini and
         hispre.dtalt <= par-dtfim no-lock:
    
    
    /*
    if (hispre.dtalt = today - 1 and
       hispre.hora-inc < vhora) or
       (hispre.dtalt = today  and
       hispre.hora-inc > vhora)
    then next.    
    */
    if hispre.estvenda-ant = hispre.estvenda-nov and
       hispre.estpromo-ant = hispre.estpromo-nov 
    then next.
    
    find produ where produ.procod = hispre.procod no-lock no-error.
    if not avail produ then next.
    if produ.catcod <> 31 and       
       produ.catcod <> 41 
    then next.   
    put unformatted
        hispre.dtalt ";"
        vdg ";"
        produ.procod format ">>>>>>>9"  "|"
        produ.pronom                    "|"
        hispre.dtalt                    "|"
        string(hispre.hora-inc,"hh:mm:ss") "|"
        hispre.estvenda-nov format ">>,>>9.99"  "|" 
        hispre.estvenda-ant format ">>,>>9.99"  "|"
        hispre.estvenda-nov - hispre.estvenda-ant format "->>,>>9.99" "|"
        ""        
        skip.
    find first repexporta where repexporta.TABELA       = "HISPRE" 
                            and repexporta.Tabela-Recid = recid(hispre)
                            and repexporta.BASE         = "GESTAO_EXCECAO"
                            and repexporta.EVENTO       = "9017"
                                no-lock no-error.
    if not avail repexporta 
    then do on error undo. 
        create repexporta. 
        ASSIGN repexporta.TABELA       = "HISPRE" 
               repexporta.DATATRIG     = hispre.dtalt
               repexporta.HORATRIG     = time 
               repexporta.EVENTO       = "9017" 
               repexporta.DATAEXP      = today 
               repexporta.HORAEXP      = time 
               repexporta.BASE         = "GESTAO_EXCECAO"
               repexporta.Tabela-Recid = recid(hispre).
    end.
end.
output close.
 

