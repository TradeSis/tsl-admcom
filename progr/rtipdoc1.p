{admcab.i}
def buffer titulo for banfin.titulo.
def buffer titluc for fin.titluc.
def var vdti as date.
def var vdtf as date.
vdti = today.
vdtf = today.
def var vetbcod like estab.etbcod.
def var vsel-sit1 as char format "x(15)" extent 5
           init["Nota Fiscal","Recibo Completo","RPA","Recibo Comum","Nenhum"].
           
update vetbcod label "Filial" skip
       vdti label "Periodo de" format "99/99/9999"
       vdtf label "Ate" format "99/99/9999"
       with frame f-dt side-label width 80.
    

def temp-table tt-tipdoc
       field etbcod like estab.etbcod
       field clifor like fin.titluc.clifor
       field tipdoc  as char
       field qtdtit as int
       field valor as dec
       index i1 etbcod clifor tipdoc. 
def var vtipdoc as char.
def var vdata as date.
for each estab where ( if vetbcod > 0
            then estab.etbcod = vetbcod else true)  no-lock:

do /*vdata = vdti to vdtf*/:
for each titulo where titulo.empcod = 19 and
                      titulo.titnat = yes and
                      titulo.modcod <> "CRE" and  
                      titulo.etbcod = estab.etbcod and   
                      titulo.titdtemi >= vdti and
                      titulo.titdtemi <= vdtf
                      no-lock.
    
    disp "Processando.....==>>   " titulo.titdtemi titulo.titnum
     with frame f-dis no-box 1 down centered color message no-label row 10.
    pause 0. 
    vtipdoc = "".
    if titulo.titagepag <> ""
    then vtipdoc = vsel-sit1[int(titulo.titagepag)].    
    else do:
        find first titluc where titluc.empcod = titulo.empcod and
                      titluc.titnat = titulo.titnat and
                      titluc.modcod = titulo.modcod and  
                      titluc.etbcod = titulo.etbcod and   
                      titluc.titdtven = titulo.titdtven and
                      titluc.titnum = titulo.titnum and
                      titluc.titpar = titulo.titpar
                      no-lock no-error.
        if avail titluc
        then do:
            if titluc.titagepag <> ""
            then vtipdoc = vsel-sit1[int(titluc.titagepag)].   
        end.
    end.
    find first tt-tipdoc where
               tt-tipdoc.etbcod = vetbcod and
               tt-tipdoc.clifor = titulo.clifor and
               tt-tipdoc.tipdoc = vtipdoc
               no-error.
    if not avail tt-tipdoc
    then do:
        create tt-tipdoc.
        tt-tipdoc.etbcod = vetbcod.
        tt-tipdoc.clifor = titulo.clifor.
        tt-tipdoc.tipdoc = vtipdoc.
    end.           
    tt-tipdoc.qtdtit = tt-tipdoc.qtdtit + 1.
    tt-tipdoc.valor  = tt-tipdoc.valor + titulo.titvlcob.
end.
end.
end.
def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/rtipdoc." + string(time).
    else varquivo = "..~\relat~\rtipdoc." + string(time).
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rtipdoc1""
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """TIPO DOCUMENTO DAS DESPESAS """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

disp with frame f-dt. 
for each tt-tipdoc:
    find first foraut where foraut.forcod = tt-tipdoc.clifor 
                no-lock no-error.
    if not avail foraut or
        foraut.autlp = no 
    then next.
    if vetbcod > 0
    then do:            
        find estab where estab.etbcod = tt-tipdoc.etbcod no-lock.
        disp tt-tipdoc.etbcod.
    end.
    disp tt-tipdoc.clifor    format ">>>>>>9"
         foraut.fornom format "x(35)"
         tt-tipdoc.tipdoc label "Documento" format "x(15)"
         tt-tipdoc.qtdtit label "QtdTit"   format "zzzzz"
         tt-tipdoc.valor(total)  label "Valor Total" format ">>>,>>9.99"
        with down width 100.
end.    
output close.
    
    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"") .
    end.
    else do:
        {mrod.i}
    end.

