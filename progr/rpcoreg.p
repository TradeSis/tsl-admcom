/*  rpcoreg.p                                                                 */
/* Lista Precos alterados no ADMCOM e no Profimetrics somente PRICE_TYPE 'R'  */
{admcab.i}
def var vdtini as date label "Data Inicial".
def var vdtfim as date label "Data Final".

update vdtini vdtfim
        with side-label width 80 row 3.

def buffer bprecohrg for precohrg.

def var varquivo as char format "x(30)".
if opsys = "UNIX" 
then varquivo = "/admcom/relat/rpcoreg." + string(time). 
else varquivo = "..\relat\rpcoreg" + string(time).


        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""rpcoreg""
            &Nom-Sis   = """SISTEMA DE PRECOS"""
            &Tit-Rel   = """ALTERACAO DE PRECOS REGULARES PERIODO DE "" +
                                  string(vdtini,""99/99/9999"") + "" A "" +
                                  string(vdtfim,""99/99/9999"")"
            &Width     = "100"
            &Form      = "frame f-cabcab"}

PUT UNFORMATTED
    skip
    "Lista Precos alterados no ADMCOM e no Profimetrics somente PRICE_TYPE 'R'"
        skip(1).
for each hispre where dtalt >= vdtini and
                      dtalt <= vdtfim no-lock 
                            by hispre.dtalt
                            by procod.
    find first precohrg where
               precoHrg.procod     = hispre.procod and
               precoHrg.PrVenda    = estvenda-nov  and
               precoHrg.data       = hispre.dtalt
               no-lock no-error.  
    if avail precohrg
    then 
        find first bprecohrg where
                   bprecoHrg.procod     = hispre.procod and
                   bprecoHrg.PrVenda    = estvenda-nov  and
                   bprecoHrg.data       = hispre.dtalt  and
                   bprecohrg.PRICE_TYPE  = "R"
                   no-lock no-error.  
    if avail precohrg and not avail bprecohrg
    then next.
    
    find produ of hispre no-lock.
          
    if not avail bprecohrg
    then do.
        disp hispre.dtalt column-label "Alteracao"
             hispre.procod    
             0 @ precohrg.etbcod label "Filial"
             produ.pronom     format "x(30)"
             estvenda-ant column-label "Preco!Antigo"
             estvenda-nov column-label "Preco!Novo"
             avail precohrg format "Itim/ADMCOM" column-label "Alt"
             bprecohrg.PRICE_TYPE when avail bprecohrg no-label   format "xxx"
             with width 200 down frame flin.
        down with frame flin.        
    end.
    else do.
        for each bprecohrg where
                   bprecoHrg.procod     = hispre.procod and
                   bprecoHrg.PrVenda    = estvenda-nov  and
                   bprecoHrg.data       = hispre.dtalt  and
                   bprecohrg.PRICE_TYPE  = "R"
                   no-lock .
    
            disp bprecoHrg.data     @ hispre.dtalt 
                 bprecoHrg.procod   @ hispre.procod    
                 bprecoHrg.etbcod   @ precohrg.etbcod label "Filial"
                 produ.pronom     format "x(30)"
                 estvenda-ant column-label "Preco!Antigo"
                 bprecoHrg.prvenda @ estvenda-nov column-label "Preco!Novo"
                 avail precohrg format "Itim/ADMCOM" column-label "Alt"
                 bprecohrg.PRICE_TYPE when avail bprecohrg no-label   
                                format "xxx"
                 with width 200 down frame flin.
            down with frame flin.        
        end.
    end.
end.           


    output close.
   
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.


