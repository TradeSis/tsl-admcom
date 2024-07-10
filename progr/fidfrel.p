
{admcab.i}
def var vdti as date.
def var vdtf as date.
def var vforcod like forne.forcod.
def temp-table tt-titluc like fin.titluc.
def var vetbcod like estab.etbcod.

update vetbcod at 5 label "Filial" with frame f-data.
if vetbcod > 0
then do:
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f-data.
end.
update vforcod at 1 label "Fornecedor"
       with frame f-data 1 down width 80 side-label.
if vforcod > 0
then do:       
find first foraut where foraut.forcod = vforcod no-lock.
disp foraut.fornom no-label with frame f-data.
end.
update vdti label "Periodo de" format "99/99/9999"
       vdtf label "Ate"        format "99/99/9999"
       with frame f-data.

def temp-table tt-estab
    field etbcod like estab.etbcod
    field data   as date
    field valor  as dec
    index i1 etbcod data.
    
def var vcatcod like produ.catcod.
def var vvalor as dec.
def var vdata as date.
def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/desp" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
    else varquivo = "..\relat\desp" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).

        {mdadmcab.i &Saida = "value(varquivo)"
                &Page-Size = "64" 
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""respla"" 
                &Nom-Sis   = """SISTEMA CREDIARIO""" 
                &Tit-Rel   = """ DESPESAS FINANCEIRAS PAGAS """
                &Width     = "80"
                &Form      = "frame f-cabc2"}
        
        disp with frame f-data. 
        
        do vdata = vdti to vdtf:
        
        for each fin.titluc where titluc.etbcobra = estab.etbcod and
                              titluc.titdtpag = vdata no-lock
                              :
                    
            display titluc.etbcod column-label "Filial" 
                    titluc.titnum 
                    titluc.clifor column-label "Codigo" 
                    titluc.titdtpag
                    titluc.titvlpag(total)
                        with frame f-titluc down width 100.
                    

        end.
         
        /*****
        for each banfin.titulo where titulo.etbcobra = estab.etbcod and
                                     titulo.titdtpag = vdata and
                                     titulo.titnat = yes no-lock:
                       
                    
            display titulo.etbcod column-label "Filial" 
                    titulo.titnum 
                    titulo.clifor column-label "Codigo" 
                    titulo.titdtpag
                    titulo.titvlpag(total)
                        with frame f-titluc down width 140.
                    

        end.  
        ***/   
        end.
        output close. 
         IF opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"") .
        end.
        else do:
            {mrod.i}
        end.
 