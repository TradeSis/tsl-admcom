/*  p2k_cpfcliente.p                                                        */
def input parameter par-clicod  like clien.clicod.
def output parameter Codigo_CPF_CNPJ as char format "x(18)" .
def output parameter Digito_CPF_CNPJ as char format "xx".

def var ccpf as char format "x(13)".
def var dcpf as dec.
def var ccnpj as char format "x(15)".
def var dcnpj as dec.
def var v as int.

    if par-clicod = 0
    then return.

find clien where clien.clicod = par-clicod no-lock.
    Codigo_CPF_CNPJ = "".
    Digito_CPF_CNPJ = "".
    ccpf = "".
    ccnpj = "".    
    if clien.tippes 
    then do.
        do v = 1 to 20.
            if substr(Clien.ciccgc,v,1) = "0" or
               substr(Clien.ciccgc,v,1) = "1" or
               substr(Clien.ciccgc,v,1) = "2" or 
               substr(Clien.ciccgc,v,1) = "3" or 
               substr(Clien.ciccgc,v,1) = "4" or 
               substr(Clien.ciccgc,v,1) = "5" or
               substr(Clien.ciccgc,v,1) = "6" or
               substr(Clien.ciccgc,v,1) = "7" or
               substr(Clien.ciccgc,v,1) = "8" or
               substr(Clien.ciccgc,v,1) = "9" 
            then ccpf = ccpf + substr(Clien.ciccgc,v,1). 
        end.
        dcpf = dec(ccpf) no-error.
/***
        Codigo_CPF_CNPJ = substr(string(dcpf,"99999999999"),1,9).
***/
        Codigo_CPF_CNPJ = substr(fill(" ", 11 - length(ccpf)) + ccpf, 1, 9).
        Digito_CPF_CNPJ = substr(string(dcpf,"99999999999"),10,2).
    end.    
    else do.
        do v = 1 to 20.
            if substr(Clien.ciccgc,v,1) = "0" or
               substr(Clien.ciccgc,v,1) = "1" or
               substr(Clien.ciccgc,v,1) = "2" or 
               substr(Clien.ciccgc,v,1) = "3" or 
               substr(Clien.ciccgc,v,1) = "4" or 
               substr(Clien.ciccgc,v,1) = "5" or
               substr(Clien.ciccgc,v,1) = "6" or
               substr(Clien.ciccgc,v,1) = "7" or
               substr(Clien.ciccgc,v,1) = "8" or
               substr(Clien.ciccgc,v,1) = "9" 
            then ccnpj = ccnpj + substr(Clien.ciccgc,v,1). 
        end.
        dcnpj = dec(ccnpj) no-error.
        Codigo_CPF_CNPJ = substr(string(dcnpj,"99999999999999"),1,12).
        Digito_CPF_CNPJ = substr(string(dcnpj,"99999999999999"),13,2).
    end.
    
    dcpf = 0.
    dcnpj = 0.

