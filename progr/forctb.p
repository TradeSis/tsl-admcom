/*
*
*    MANUTENCAO EM acrfilELECIMENTOS                         finan.p    02/05/95
*
*/

{admcab.i}

    
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
 



def var vnumero like fiscal.numero.
def var vforcod like forne.forcod.
def var totpla like plani.platot. 
def var totbic like plani.platot.
def var toticm like plani.platot.
def var totipi like plani.platot.
def var totout like plani.platot.
    

def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.

def var v-ven  as dec.
def var v-con  as dec.
def var v-acr  as dec.

    v-ven = 0.
    v-acr = 0.
    v-con = 0.

    totpla = 0.
    totbic = 0.
    toticm = 0.
    totipi = 0.
    totout = 0.
    
    
repeat:

    update vforcod label "Emite" with frame f1 side-label 
                width 80.
    find forne where forne.forcod = vforcod no-lock no-error. 
    if not avail forne  
    then do: 
        message "Fornecedor nao Cadastrado". 
        undo, retry. 
    end. 
    display forne.fornom no-label format "x(30)"
                with frame f1.
    
    update vdt1 label "Periodo"
           vdt2 no-label with frame f1.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/for_ctb" + string(time).
    else varquivo = "l:~\relat~\for_ctb" + string(time). 

    
    {mdad.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "130" 
        &Page-Line = "66" 
        &Nom-Rel   = ""forctb"" 
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE""" 
        &Tit-Rel   = """LISTAGEM DE NOTAS FISCAIS "" +  
                     ""FORNECEDOR:  "" + string(forne.forcod) +  "" "" + 
                     string(forne.fornom,""x(30)"") + "" "" +  
                     string(vdt1,""99/99/9999"") + "" ate "" + 
                     string(vdt2,""99/99/9999"")"
        &Width     = "130" 
        &Form      = "frame f-cabcab"}

    for each fiscal where fiscal.emite = forne.forcod and 
                          fiscal.plarec >= vdt1 and 
                          fiscal.plarec <= vdt2  
                            no-lock break by fiscal.opfcod 
                                          by fiscal.numero:
        /*            
        if fiscal.numero = 0
        then do:
            vnumero = int(string(day(plarec),"99") +
                          string(month(plarec),"99") +
                          string(substring(string(year(plarec)),3,2))).
            fiscal.numero = vnumero.
        end.
        */
                
        display fiscal.plarec 
                fiscal.numero format ">>>>>>9" 
                fiscal.opfcod column-label "OPF" format "9999" 
                fiscal.platot(total by fiscal.opfcod) format ">>,>>>,>>9.99"
                fiscal.bicms(total by fiscal.opfcod) format ">>,>>>,>>9.99"
                fiscal.icms(total by fiscal.opfcod)  format ">>,>>>,>>9.99"
                fiscal.ipi(total by fiscal.opfcod) format ">,>>>,>>9.99"
                fiscal.outras(total by fiscal.opfcod) format ">,>>>,>>9.99"
                                    with frame flista width 200 down.
    end. 
    output close.   
    
    /*
    {mrod.i} 
    */
    
    if opsys = "UNIX"
    then do:
        run visurel.p(input varquivo, input "").
    end.
    else do: 
        {mrod.i} 
    end. 
    
end.
     