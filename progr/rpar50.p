{admcab.i }

def var varquivo as char.

message "Gerando relatorio".

if opsys = "UNIX" 
then 
    varquivo = "/admcom/work/rpar50" + string(time). 
else 
    varquivo = "l:\work\rpar50" + string(time).

{mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""rpar50""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """TITULOS C/ PARCELA MAIOR QUE 50 S/ CONTRATO"""
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    for each titulo where titulo.empcod = 19    
                      and titulo.titnat = no 
                      and titulo.modcod = "CRE" no-lock:

        if titulo.titpar < 50 then next.

        find contrato where 
             contrato.contnum = int(titulo.titnum) no-lock no-error.
        if avail contrato
        then next.
        
        disp titulo.titnum 
             titulo.clifor 
             titulo.titpar 
             titulo.titvlcob format "->>>,>>9.99"
             titulo.titdtemi
             titulo.titdtven
             titulo.titvlpag format "->>>,>>9.99"
             titulo.titdtpag
             titulo.titsit
             with frame f-cont width 120 down.
        down with frame f-cont.             

    end.
    
output close.
    
