{admcab.i}
def input parameter vetbcod like estab.etbcod.
def input parameter vdti as date format "99/99/9999".
def input parameter vdtf as date format "99/99/9999".

def shared temp-table tt-movim like com.movim. 
 
for each comloja.plani where comloja.plani.datexp >= vdti and
                             comloja.plani.datexp <= vdtf no-lock:
    
    
    display comloja.plani.pladat 
            comloja.plani.numero format "9999999" 
            comloja.plani.etbcod with 1 down. pause 0.
    find com.plani where com.plani.etbcod = comloja.plani.etbcod and
                         com.plani.placod = comloja.plani.placod and
                         com.plani.serie  = comloja.plani.serie no-error.
    if not avail com.plani 
    then do transaction:  

        create com.plani.
        {t-plani.i com.plani comloja.plani}.
    
    end.
    else do transaction:
                 /**** Alterado em 15/02/2012 para sobrepor
                       campo preenchido na filial e vazio na matriz *****/
        if substr(comloja.plani.notped,1,1) = "C"
            and com.plani.notped = ""
        then assign com.plani.notped = comloja.plani.notped.

        if com.plani.ufemi = ""
        then assign com.plani.ufemi = comloja.plani.ufemi.

    
    end.

end.


 
for each comloja.movim where comloja.movim.datexp >= vdti and
                             comloja.movim.datexp <= vdtf no-lock:
    
    
    display comloja.movim.procod 
            comloja.movim.etbcod
            comloja.movim.movdat with 1 down. pause 0.
    
    find com.movim where com.movim.etbcod = comloja.movim.etbcod and
                         com.movim.placod = comloja.movim.placod and
                         com.movim.procod = comloja.movim.procod no-error.
    if not avail com.movim
    then do transaction:  

        create com.movim.
        {t-movim.i com.movim comloja.movim}.
        /*
        run atuest_hd.p (input recid(com.movim),
                         input "i",
                         input 0).
        */

        create tt-movim.
        buffer-copy com.movim to tt-movim.

                          
    end.

end.

for each comloja.vndseguro where comloja.vndseguro.datexp >= vdti and
                             comloja.vndseguro.datexp <= vdtf no-lock:
    
    find com.vndseguro where 
         com.vndseguro.tpseguro = comloja.vndseguro.tpseguro and
         com.vndseguro.etbcod   = comloja.vndseguro.etbcod   and
         com.vndseguro.certifi  = comloja.vndseguro.certifi
         no-error.
    if not avail com.vndseguro
    then do transaction:  

        create com.vndseguro.
        buffer-copy comloja.vndseguro to com.vndseguro.
                          
    end.
    else if comloja.vndseguro.dtcanc <> ? and
            com.vndseguro.dtcanc = ?
        then do transaction:
            com.vndseguro.dtcanc = comloja.vndseguro.dtcanc.    
        end.
end.



for each com.cobranca where com.cobranca.etbcod = vetbcod:
 
    do transaction:
    
        delete com.cobranca.
        
    end.
    
end.


for each comloja.cobranca no-lock:
 
    find com.cobranca where com.cobranca.clicod = comloja.cobranca.clicod no-error.
    if not avail com.cobranca
    then do transaction:

        create com.cobranca.
        {t-cobranca.i com.cobranca comloja.cobranca}.
            
    
    end.
    
end.


