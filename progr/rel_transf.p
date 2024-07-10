{admcab.i}   

def temp-table tt-uf
    field ufecod  like forne.ufecod
    field uftotal like plani.platot format ">>,>>>,>>9.99".
    
    
def var varquivo as char.
def var vali like fiscal.alicms.
def var vemi like fiscal.plaemi.
def var vrec like fiscal.plarec.
def var vopf like fiscal.opfcod.

 def var tot-pla like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-bic like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-icm like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-ipi like fiscal.platot format "->>,>>>,>>9.99". 
 def var tot-out like fiscal.platot format "->>,>>>,>>9.99".
 

def temp-table tt-op
    field desti  like estab.etbcod
    field ali    like fiscal.alicms 
    field opfcod like fiscal.opfcod 
    field totpla like fiscal.platot format ">>>,>>>,>>9.99"
    field totbic like fiscal.bicms  format ">>>,>>>,>>9.99"
    field toticm like fiscal.icms   format ">>>,>>>,>>9.99"
    field totipi like fiscal.ipi    format ">>>,>>>,>>9.99"
    field totout like fiscal.out    format ">>>,>>>,>>9.99".


def var vnumero like fiscal.numero.
def var vforcod like forne.forcod.
def var totpla like plani.platot. 
def var totbic like plani.platot.
def var toticm like plani.platot.
def var totipi like plani.platot.
def var totout like plani.platot.
    

def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc.

repeat:

    for each tt-op:
        delete tt-op.
    end.    
    /*
    update vmovtdc colon 16 label "Tipo Movimento"
                        with frame f1.
    find tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    if not avail tipmov
    then display "GERAL" @ tipmov.movtnom no-label with frame f1.
    else display movtnom no-label with frame f1.
    */
    update vetbcod label "Filial" colon 15
            with frame f1 side-label width 80.
    if vetbcod = 0
    then undo. /*display "GERAL" @ estab.etbnom no-label with frame f1. */
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
                
                
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final" 
                with frame f1 side-label width 80.
                
                
                         
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rel_transf" + string(time) + ".txt".
    else varquivo = "l:~\relat~\rel_transf.txt".
    
    {mdad.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "100" 
        &Page-Line = "66" 
        &Nom-Rel   = ""conctb""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """LISTAGEM DE NOTAS DE TRANFERENCIA  "" + 
                     ""ESTABELECIMENTO:  "" + string(vetbcod) + 
                     "" "" +
                     string(vdti,""99/99/9999"") + "" ate "" +
                     string(vdtf,""99/99/9999"")"
        &Width     = "100"
        &Form      = "frame f-cabcab3"}

    disp with frame f1.
        
    put SKIP(1) "T R A N S F E R E N C I A S    E M I T I D A S"
            SKIP.
        
    for each plani where plani.movtdc = 6 and
                         plani.etbcod = estab.etbcod and
                         plani.emite = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf
                         no-lock:

            disp plani.emite plani.desti plani.numero format ">>>>>>>>9"
                 plani.pladat
                      plani.platot(total) format ">>>,>>>,>>9.99".
            
    end.
    
    Put SKIP(1) "T R A N S F E R E N C I A S    R E C E B I D A S"
                SKIP.
                
    for each plani where plani.movtdc = 6 and
                         plani.desti = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf
                         no-lock:
            disp plani.emite plani.desti plani.numero format ">>>>>>>>9"
                plani.pladat
                plani.platot(total) format ">>>,>>>,>>9.99".

    end.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p ( input varquivo, "" ).
    end.
    else do:
        {mrod.i}
    end.

end.    
                           
