/* #1 helio.neto 18.02.19 - deixar limite e saldo aberto igual ao ws p2k */

{/admcom/progr/admcab-batch.i new}                        
               
{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-salaberto-principal as dec.


def var vdiasprocessamento as int  init 5.
def var varquivo           as char init "/admcom/lebesintel/hml/limites/processamento.csv".     

def var providev as dec.
def var limite-cred-scor as dec.
def var contacliente as int.
def var limitecalculado as dec.

def var basedecalculo as dec.
def var vendasaudavel as dec.
def var diaspagamento as int.
def var percsaudavel as dec.
/* def var letra as char. */


def var calendariobase as date.
def var parcelasspc as int.

calendariobase = 01/01/2010.
 
def buffer bclien for clien.
        

def new shared temp-table tt-cliente no-undo     
    field clientecod as int
    index c is unique primary clientecod asc.              
    
/* #1 helio.neto 18.02.19 - deixar limite e saldo aberto igual ao ws p2k */

def buffer xclien for clien.

procedure limite-cred-scor.
    def input param rec-clien as recid .
    def output param vcalclim as dec.
    def output param saldo-aberto as dec.
    def output param var-sallimite as dec.
    def output param parcelasspc  as int.
    
    def var vpardias as dec.  

    
    /* #1 */
    find xclien where recid(xclien) = rec-clien no-lock.
    find neuclien where neuclien.clicod = xclien.clicod no-lock no-error.
    if not avail neuclien
    then vcalclim = 0.
    else do:
       /* 27.11.2019 helio.neto */
        vcalclim = if avail neuclien 
                     then if neuclien.vctolimite >= today
                          then neuclien.vlrlimite
                          else 0
                     else 0.     
        run /admcom/progr/neuro/comportamento.p (clien.clicod, ?,  
                                       output var-propriedades). 
        var-salaberto-principal = dec(pega_prop("LIMITETOMPR")).
        if var-salaberto-principal = ? then var-salaberto-principal = 0.

        var-salaberto = dec(pega_prop("LIMITETOM")).
        if var-salaberto = ? then var-salaberto = 0.
        
        var-sallimite  = vcalclim - var-salaberto-principal.
        if var-sallimite = ? then var-sallimite = 0.
        /*27.11.2019 helio.neto */
    end.
    saldo-aberto = var-salaberto.
    
    for each fin.titulo where fin.titulo.empcod = 19
                      and fin.titulo.titnat = no
                      and fin.titulo.clifor = clien.clicod
                      and fin.titulo.titdtpag = ?
                      and fin.titulo.titsit = "LIB" 
                    no-lock
                    use-index por-clifor.
        if titulo.modcod <> "CRE" and
           titulo.modcod <> "CP0" and
           titulo.modcod <> "CP1" and
           titulo.modcod <> "CPN"
        then next.    
        if today - fin.titulo.titdtven > 30 
        then do:  
            parcelasspc = parcelasspc + 1. 
        end.

    end.
    
end procedure.



pause 0.                                                                

for each estab no-lock.  
    display estab.etbcod.   
    for each fin.titulo where  
        fin.titulo.etbcobra = estab.etbcod and 
        fin.titulo.titdtpag >= today - vdiasprocessamento 
        no-lock. 
        pause 0.  
        message fin.titulo.clifor.  
        find first tt-cliente where clientecod = titulo.clifor no-lock no-error.  
        if not avail tt-cliente then do:                                          
            create tt-cliente.                                                       
            assign tt-cliente.clientecod = titulo.clifor.                   
        end.  
    end.   
    message "Notas". 
    pause 0.  
    for each plani where plani.etbcod = estab.etbcod and plani.movtdc = 5 and plani.pladat >= today - vdiasprocessamento  no-lock.  
        pause 0. 
        message plani.Desti.  
        find first tt-cliente where clientecod = plani.Desti no-lock no-error.
        if not avail tt-cliente then do:                                        
            create tt-cliente.                                                       
            assign tt-cliente.clientecod = plani.Desti.                
        end.                                                         
    end.                                                                 
    message "propostas neuro". 
    pause 0.  
    for each neuproposta where neuproposta.etbcod = estab.etbcod and neuproposta.dtinclu >= today - vdiasprocessamento  no-lock.  
        pause 0. 
        find neuclien of neuproposta no-lock.
        message neuclien.clicod.  
        find first tt-cliente where clientecod = neuclien.clicod no-lock no-error.
        if not avail tt-cliente then do:                                        
            create tt-cliente.                                                       
            assign tt-cliente.clientecod = neuclien.clicod.
        end.                                                         
    end.                                                                 
    
end.


message "Clientes".
pause 0.    
for each bclien where bclien.datexp >= today - vdiasprocessamento and   bclien.datexp <= today no-lock.  
    pause 0. 
    message bclien.clicod.  
    find first tt-cliente where clientecod = bclien.clicod no-lock no-error. 
    if not avail tt-cliente then do:                                           
        create tt-cliente.                                                        
        assign tt-cliente.clientecod = bclien.clicod. 
    end. 
end.   

message "fim clientes". 
pause 0 .

                                               
output to value(varquivo). 
pause 0.                                                          

for each tt-cliente where tt-cliente.clientecod > 1 no-lock.                                              
    
    find clien where clien.clicod = tt-cliente.clientecod no-lock  no-error.
    if not avail clien
    then next.
    parcelasspc = 0.  
    limitecalculado = 0. 
    providev = 0.  
    basedecalculo = 0. 
    vendasaudavel = 0. 
    percsaudavel = 0.  
    
    run  limite-cred-scor (input recid(clien),
                           output limite-cred-scor,
                           output providev,
                           output limitecalculado,
                           output parcelasspc).
                              

    for each fin.titulo use-index iclicod where                         
                      fin.titulo.clifor = clien.clicod and                      
                      fin.titulo.titsit = "PAG" and
                      fin.titulo.empcod = 19 and     
                      fin.titulo.titnat = no and
                      fin.titulo.modcod = "CRE" and
                      fin.titulo.titdtpag <> ? and
                      fin.titulo.titdtven >= calendariobase
                                                                                                                     no-lock.              
                                              pause 0.         
                  if fin.titulo.titvlcob <= 0 then next.   
              if fin.titulo.titvlcob = ? then next.
              
              basedecalculo = basedecalculo + fin.titulo.titvlcob.
              diaspagamento = titdtpag - titdtven.
                 
            if diaspagamento <= 15 then do:
                 vendasaudavel = vendasaudavel + fin.titulo.titvlcob.
                    end.
                    
    end.                                            
                             
    if limitecalculado < 0 then limitecalculado = 0.                           
    if limitecalculado = ? then limitecalculado =  0.
                    
             percsaudavel = vendasaudavel / basedecalculo.
             percsaudavel = percsaudavel * 100.
                                              
            if percsaudavel = ? then percsaudavel = 0.
            if percsaudavel < 0 then percsaudavel = 0.                                     
    
    put clien.clicod ";" 
        clien.clinom ";" 
        limite-cred-scor format ">>>>>>>>>.99" ";" 
        providev format ">>>>>>>>>>.99" ";" 
        limitecalculado format ">>>>>>>>>>.99" ";" 
        YEAR(today) format "9999" "-" MONTH(today) format "99" "-" DAY(today) format "99" ";" 
        basedecalculo format ">>>>>>>>>>.99" ";" 
        vendasaudavel format ">>>>>>>>>>.99" ";" 
        percsaudavel ";" 
        parcelasspc ";" time ";" skip.

    
end.

output close.

