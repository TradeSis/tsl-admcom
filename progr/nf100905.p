{admcab.i}
def var varquivo as char.


varquivo = "..\relat\nf100905".

 
{mdad.i 
    &Saida     = "value(varquivo)" 
    &Page-Size = "0" 
    &Cond-Var  = "130" 
    &Page-Line = "0" 
    &Nom-Rel   = ""."" 
    &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
    &Tit-Rel   = """RELATORIO NOTAS FISCAIS""" 
    &Width     = "130" 
    &Form      = "frame f-cabcab"}


find estab 995 no-lock.

display estab.etbnom   no-label at 30 skip(01)
        estab.endereco no-label at 20
        estab.munic    label "CIDADE" at 20
        estab.ufecod   label "UF"
        estab.etbcgc   label "CNPJ" at 20
        estab.etbinsc  label "INSC.ESTADUAL" at 20
            with frame f1 side-label.
         

for each plani where plani.etbcod = 995 and
                     plani.movtdc = 04 and
                     plani.emite  = 100905 and
                     plani.pladat <= 06/30/2004 by plani.pladat:


    
    disp plani.numero format ">>>>>>>9"
         plani.pladat
         plani.platot(total)
         plani.bicms(total)
         plani.icms(total)
                with frame f2 down.

end.

output close.
{mrod.i}

