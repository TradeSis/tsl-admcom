{admcab.i}   

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

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
    field totout like fiscal.out    format ">>>,>>>,>>9.99"
    field totfre like plani.frete   format ">>>,>>>,>>9.99"
    field totpis like plani.notpis  format ">>>,>>>,>>9.99"
    field totcof like plani.notcof  format ">>>,>>>,>>9.99"
    .
    
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
    
    update vmovtdc colon 16 label "Tipo Movimento"
                        with frame f1.
    find tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    if not avail tipmov
    then display "GERAL" @ tipmov.movtnom no-label with frame f1.
    else display movtnom no-label with frame f1.
    
    update vetbcod label "Filial" colon 15
            with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
                
                
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final" 
                with frame f1 side-label width 80.
                
                
                         
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:  
        for each tipmov where if vmovtdc = 0
                              then true
                              else tipmov.movtdc = vmovtdc no-lock.
            if tipmov.movtdc = 4 or
               tipmov.movtdc = 12
            then.
            else next.
            
        for each fiscal where fiscal.desti = estab.etbcod   and
                              fiscal.movtdc = tipmov.movtdc and  
                              fiscal.plarec >= vdti    and
                              fiscal.plarec <= vdtf no-lock:
            
            if fiscal.movtdc = 12 and
               fiscal.serie = "U"
            then next.
            for each tt-plani: delete tt-plani. end.
            for each tt-movim: delete tt-movim. end.
            
            find plani where plani.movtdc = fiscal.movtdc and
                             plani.etbcod = fiscal.desti and
                             plani.emite  = fiscal.emite and
                             plani.serie  = fiscal.serie and
                             plani.numero = fiscal.numero
                             no-lock no-error.
            if not avail plani then next.                 
            create tt-plani.
            buffer-copy plani to tt-plani.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                create tt-movim.
                buffer-copy movim to tt-movim.
            end.                     

            run piscofins.p .
            
            find first tt-op where tt-op.desti  = fiscal.desti  and
                                   tt-op.ali    = fiscal.alicms and
                                   tt-op.opfcod = fiscal.opfcod no-error.
            if not avail tt-op
            then do:
                create tt-op.
                assign tt-op.desti  = fiscal.desti
                       tt-op.ali    = fiscal.alicms
                       tt-op.opfcod = fiscal.opfcod.
            end.
            assign tt-op.totpla = tt-op.totpla + fiscal.platot. 
                   tt-op.totbic = tt-op.totbic + fiscal.bicms. 
                   tt-op.toticm = tt-op.toticm + fiscal.icms. 
                   tt-op.totipi = tt-op.totipi + fiscal.ipi. 
                   tt-op.totout = tt-op.totout + fiscal.out.

            for each tt-movim no-lock:
                assign
                    tt-op.totpis = tt-op.totpis +
                        (tt-movim.movpis / tt-movim.movqtm)
                    tt-op.totcof = tt-op.totcof +
                        (tt-movim.movcof / tt-movim.movqtm)
                    tt-op.totfre = tt-op.totfre +
                        (tt-movim.movdev / tt-movim.movqtm)  
                          .
            end.
        end.
        end.           
    end.        
             
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/conctbl.txt".               
    else varquivo = "l:~\relat~\conctb.txt".
    
    {mdad.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "130" 
        &Page-Line = "66" 
        &Nom-Rel   = ""conctb""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """LISTAGEM DE NOTAS DE ENTRADA  "" + 
                     ""ESTABELECIMENTO:  "" + string(vetbcod) + 
                     "" "" +
                     string(vdti,""99/99/9999"") + "" ate "" +
                     string(vdtf,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab3"}

        
    for each tt-op break by tt-op.desti:
        
        display tt-op.desti
                tt-op.opfcod format "9999"
                tt-op.ali 
                tt-op.totpla(total by tt-op.desti) column-label "Total"
                tt-op.totbic(total by tt-op.desti) column-label "Base ICMS"
                tt-op.toticm(total by tt-op.desti) column-label "ICMS"
                tt-op.totipi(total by tt-op.desti) column-label "IPI"
                tt-op.totout(total by tt-op.desti) column-label "Outras"
                tt-op.totfre(total by tt-op.desti) column-label "Frete"
                tt-op.totpis(total by tt-op.desti) column-label "PIS"
                tt-op.totcof(total by tt-op.desti) column-label "COFINS"
                                        with frame flista1 width 200 down.
     
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
                           
