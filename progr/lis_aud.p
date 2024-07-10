{admcab.i}
def var vopccod like opcom.opccod format "x(04)".
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vtipo   as log format "Entrada/Saida".
def var varquivo as char.
def var arq_tot  as log format "Sim/Nao".


def new shared temp-table tt-fiscal
    field etbcod  like estab.etbcod
    field opfcod  as char
    field alicota as dec format ">>9.99"
    field totsai  like plani.platot 
    field base    like plani.platot 
    field icms    like plani.icms 
    field ipi     like plani.ipi 
    field valcon  like plani.platot
    field outras  like plani.outras
    field isentas like plani.isenta.
 

def new shared temp-table tt-plani
    field rec as recid
    field numero like plani.numero
    field serie  as char
    field vemi   like plani.emite
    field vdata  like plani.pladat 
    field totpla like plani.platot
    field valcon like plani.platot
    field basicm like plani.platot
    field valicm like plani.platot
    field tipo   as char
    field opf    like opcom.opccod.

repeat:

    for each tt-plani:
        delete tt-plani.
    end.    
    
    for each tt-fiscal:
        delete tt-fiscal.
    end.    
    

    
    vopccod = "".
    vetbcod = 0.
    vdti    = today.
    vdtf    = today.
    
    update arq_tot label "Gerar Arquivo de Totais" with frame f1.
    
    update vetbcod label "Filial   " at 1
                    with frame f1 side-label width 80.
                
    if vetbcod = 0
    then display "GERAl" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock. 
        display estab.etbnom no-label with frame f1.
    end.
    
    if arq_tot = no
    then do:
    

        update vopccod label "Op.Fiscal" at 1 with frame f1. 
        find opcom where opcom.opccod = vopccod no-lock no-error. 
        if not avail opcom 
        then do: 
            message "Operacao Fiscal Invalida". 
            pause.       
            undo, retry.
        end.                    

        display opcom.opcnom no-label with frame f1. 
        update vtipo label "Operacao" with frame f1.     
    
    end.
    
    update vdti label "Periodo  " at 1
           vdtf no-label with frame f1.

    
    if arq_tot
    then do:
        run aud_nfs.p (input vetbcod,
                       input vopccod,
                       input vdti,
                       input vdtf,
                       input arq_tot).

        run aud_nfe.p (input vetbcod,
                       input vopccod,
                       input vdti,
                       input vdtf,
                       input arq_tot).

    
    end.
    else do:
        if vtipo = no
        then
        run aud_nfs.p (input vetbcod,
                       input vopccod,
                       input vdti,
                       input vdtf,
                       input arq_tot).
        else               
        run aud_nfe.p (input vetbcod,
                       input vopccod,
                       input vdti,
                       input vdtf,
                       input arq_tot).
    end.
    
    if arq_tot
    then do:
                   
        varquivo = "l:\audit\tot" + string(vetbcod,">>9") + "_" +
                   string(day(vdti),"99") +  
                   string(month(vdti),"99") +  
                   string(year(vdti),"9999") + "_" +  
                   string(day(vdtf),"99") +  
                   string(month(vdtf),"99") +  
                   string(year(vdtf),"9999") + ".txt".

                   
                   
        output to value(varquivo).
        

        for each tt-fiscal break by tt-fiscal.etbcod.
        
            put tt-fiscal.etbcod format "999" 
                month(vdti) format "99"
                year(vdti) format "9999"
                tt-fiscal.opfcod   format "9999"
                tt-fiscal.alicota  format "99999"
                tt-fiscal.totsai   format "9999999999999.99"
                tt-fiscal.base     format "9999999999999.99"
                tt-fiscal.icms     format "9999999999999.99"
                tt-fiscal.isentas  format "9999999999999.99" 
                tt-fiscal.outras   format "9999999999999.99"
                tt-fiscal.ipi     format "9999999999999.99" skip.
                         

        end.            
        output close.
        
    end.
    else do:
    
    
        varquivo = "..\relat\lisaud" + STRING(day(today)) + 
                    string(vetbcod,">>9").

        {mdad.i &Saida     = "value(varquivo)" 
                &Page-Size = "64"
                &Cond-Var  = "137"
                &Page-Line = "66"
                &Nom-Rel   = ""lis_aud""
                &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
                &Tit-Rel   = """SALDO DREBES -  "" +
                                string(vetbcod,"">>9"") + "" - "" + 
                                string(vopccod,""9999"") + "" "" + 
                              "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
                &Width     = "137"
                &Form      = "frame f-cabcab"}
            
        for each tt-plani no-lock by tt-plani.numero:
    
            display tt-plani.numero column-label "Numero"
                    tt-plani.serie  column-label "Sr" format "x(02)"
                    tt-plani.vemi   column-label "Emite" format ">>>>>9"
                    tt-plani.vdata  column-label "Data"
                    tt-plani.totpla(total) column-label "Total Nota"
                    tt-plani.valcon(total) column-label "Valor!Contabil"
                    tt-plani.basicm(total) column-label "Base!Icms"
                    tt-plani.valicm(total) column-label "Valor!Icms"
                        with frame f2 down width 130.
        
        end.
        output close. 
        {mrod.i}

    end.
    
end.
        
