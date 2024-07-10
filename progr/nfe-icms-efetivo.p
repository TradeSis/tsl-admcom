/*
#1 04/19 - Projeto ICMS Efetivo
*/
def input  parameter p-recid   as recid.

def shared temp-table tt-plani like plani.
def shared temp-table tt-movimimp like movimimp.

find A01_infnfe where recid(A01_infnfe) = p-recid no-lock.
find first tt-plani.

for each tt-movimimp.

    find W01_total of A01_infnfe.

    assign
        tt-movimimp.placod = A01_infnfe.placod.

    find first N01_icms where N01_icms.chave = A01_infnfe.chave
                          and N01_icms.nitem = tt-movimimp.movseq.

    if tt-movimimp.impcodigo = 17
    then
        assign
            N01_icms.vBCFCP     = tt-movimimp.impBaseC
            N01_icms.pFCP       = tt-movimimp.impaliq
            N01_icms.vFCP       = tt-movimimp.impvalor
            W01_total.vfcp      = W01_total.vfcp + tt-movimimp.impvalor.

    else if tt-movimimp.impcodigo = 23
    then do.
        find first I01_Prod where I01_Prod.chave = A01_infnfe.chave
                              and I01_Prod.nitem = tt-movimimp.movseq.

/*
        message "Imposto 23 = " tt-movimimp.impvalor. pause.
*/
        assign
            N01_icms.vBCFCPST   = tt-movimimp.impBaseC
            N01_icms.pFCPST     = tt-movimimp.impaliq
            N01_icms.vFCPST     = tt-movimimp.impvalor

            tt-plani.platot  = tt-plani.platot + tt-movimimp.impvalor
            W01_total.vnf    = W01_total.vnf + tt-movimimp.impvalor
            W01_total.vfcpst = W01_total.vfcpst + tt-movimimp.impvalor.
    end.

    else if tt-movimimp.impcodigo = 25
    then assign
            N01_icms.vBCSTRet   = tt-movimimp.impBaseC
            N01_icms.pSt        = tt-movimimp.impaliq
            N01_icms.vICMSSTRet = tt-movimimp.impvalor
            N01_icms.vICMSSubstituto = tt-movimimp.impvlraux1.

    else if tt-movimimp.impcodigo = 27
    then assign
            N01_icms.vBCFCPSTRet = tt-movimimp.impBaseC
            N01_icms.pFCPSTRet   = tt-movimimp.impaliq
            N01_icms.vFCPSTRet   = tt-movimimp.impvalor
            W01_total.vFCPSTRet  = W01_total.vFCPSTRet + tt-movimimp.impvalor.

    else if tt-movimimp.impcodigo = 33
    then assign
            N01_icms.pRedBCEfet = tt-movimimp.impalRedBC
            N01_icms.vBCEfet    = tt-movimimp.impBaseC
            N01_icms.pICMSEfet  = tt-movimimp.impaliq
            N01_icms.vICMSEfet  = tt-movimimp.impvalor.

    create mimpcon.
    buffer-copy tt-movimimp to mimpcon.
end.

for each N01_icms where N01_icms.chave = A01_infnfe.chave:
    if N01_icms.cst = 60 and N01_icms.vBCSTRet = 0
    then N01_icms.cst = 90.
end.
    
