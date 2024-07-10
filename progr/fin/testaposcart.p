def input parameter pnew as log.
def parameter buffer otitulo for titulo.
def parameter buffer atitulo for titulo.

{/admcom/progr/acha.i}
def var vtpcontrato as char.

if   acha("FEIRAO-NOME-LIMPO",atitulo.titobs[1]) <> ? and           
     acha("FEIRAO-NOME-LIMPO",atitulo.titobs[1]) = "SIM" 
then vtpcontrato = "F". 
else vtpcontrato = atitulo.tpcontrato.


if not pnew
then do:
    
    /****if otitulo.titvlpag <> atitulo.titvlpag or 
       otitulo.titdtpag <> atitulo.titdtpag 
    then do: 
        if atitulo.dtultpgparcial = ?
        then do:
*            run /admcom/progr/fin/gerahisposcart.p   
                    (recid(atitulo),  
                     "pagamento",  
                     if atitulo.titdtpag = ? 
                     then today 
                     else atitulo.titdtpag,
                     vtpcontrato,
                     atitulo.tittotpag,
                     atitulo.cobcod,
                     atitulo.cobcod). 
        end.          
    end.
    else**/ do:
    
        if otitulo.cobcod <> atitulo.cobcod
        then do:
            run /admcom/progr/fin/gerahisposcart.p   
                (recid(atitulo),  
                 "ENTRADA",  
                 today,
                 vtpcontrato,
                 atitulo.titvlcob,
                 otitulo.cobcod,
                 atitulo.cobcod). 
        end.
    end.
end.            
/**else do:   
*    run /admcom/progr/fin/gerahisposcart.p   
            (recid(atitulo),  
             "emissao",  
             atitulo.titdtemi,
             vtpcontrato,
             atitulo.titvlcob,
             atitulo.cobcod,
             atitulo.cobcod). 
end.**/
