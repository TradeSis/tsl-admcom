def var vcont as integer.

def shared temp-table reg-c
    field CNPJ-emitente   as        CHAR 
    field CNPJ-destino   as         CHAR 
    field total-produtos          as DEC 
    field base-icms               as DEC 
    field valor-icms              as DEC 
    field base-substitucao        as DEC 
    field valor-icms-substiuicao  as DEC 
    field valor-acrescimo         as DEC  
    field valor-desconto          as DEC  
    field valor-frete             as DEC  
    field valor-seguro            as DEC  
    field valor-despesas          as DEC  
    field valor-ipi               as DEC  
    field valor-outras            as DEC  
    field valor-isento            as DEC  
    field total-da-nota           as DEC  
    field obs as char extent 6
    field CNPJ-transportador   as char
    field NOME-transportador   as char
    field QTD-Volumes          as INT
    field Especie              as CHAR 
    field Tipo-frete           as char
    field Placa                as CHAR
    field UF-transp            as CHAR
    .

def shared temp-table reg-i
    field cfop                      as INT 
    field sequencia                 as INT 
    field codigo-produto            as INT 
    field descricao-produto         as CHAR 
    field quantidade                as DEC 
    field valor-unitario            as DEC 
    field Aliquota-icms             as DEC 
    field valor-icms                as DEC 
    field aliquota-ipi              as DEC 
    field valor-ipi                 as DEC 
    .

def var varq1 as char.
varq1 = "/admcom/nfe/logosystem/PreNota.arq".
output to ./lixo-nfe.txt.
unix silent value(" ls /admcom/nfe/logosystem/prenota*.txt > " + varq1).
output close.

def temp-table tt-arq
    field arq as char.
input from value(varq1).
repeat:
    create tt-arq.
    import tt-arq.arq.
end.
input close.

unix silent value(" rm " + varq1).

find first tt-arq where tt-arq.arq <> "" no-error.
if not avail tt-arq
then return.
    
def var vregistro as char.
if search(tt-arq.arq) = ?
then return.
      
input from value(tt-arq.arq).
repeat:
    import unformatted vregistro.
    if vregistro <> ""
    then do:
        if substr(vregistro,1,1) = "C"    /*** REGISTRO TIPO "C" ***/
        then do: 
            create reg-c.
            assign
                reg-c.CNPJ-emitente           = (substr(vregistro,2,20))
                reg-c.CNPJ-destino            = (substr(vregistro,22,20))
                reg-c.total-produtos          = 
                                DEC(substr(vregistro,42,14)) / 100   
                reg-c.base-icms               = 
                                DEC(substr(vregistro,56,14)) / 100
                reg-c.valor-icms              = 
                                DEC(substr(vregistro,70,14)) / 100
                reg-c.base-substitucao        = 
                                DEC(substr(vregistro,84,14)) / 100
                reg-c.valor-icms-substiuicao  = 
                                DEC(substr(vregistro,98,14)) / 100
                reg-c.valor-acrescimo         = 
                                DEC(substr(vregistro,112,14)) / 100
                reg-c.valor-desconto          = 
                                DEC(substr(vregistro,126,14)) / 100
                reg-c.valor-frete             = 
                                DEC(substr(vregistro,140,14)) / 100
                reg-c.valor-seguro            = 
                                DEC(substr(vregistro,154,14)) / 100
                reg-c.valor-despesas          = 
                                DEC(substr(vregistro,168,14)) / 100
                reg-c.valor-ipi               = 
                                DEC(substr(vregistro,182,14)) / 100
                reg-c.valor-outras            = 
                                DEC(substr(vregistro,196,14)) / 100
                reg-c.valor-isento            = 
                                DEC(substr(vregistro,210,14)) / 100
                reg-c.total-da-nota           = 
                                DEC(substr(vregistro,224,14)) / 100
                .
        END.
        else if substr(vregistro,1,1) = "I"   /*** REGISTRO TIPO "I"  ***/
        then do:
            
            create reg-i.
            assign
                reg-i.cfop                = int(substr(vregistro,2,4))
                reg-i.sequencia           = int(substr(vregistro,6,3))
                reg-i.codigo-produto      = int("6" + substr(vregistro,10,8))
                reg-i.descricao-produto   = substr(vregistro,18,60)
                reg-i.quantidade          = 
                            dec(substr(vregistro,78,14)) / 10000
                reg-i.valor-unitario      = 
                            dec(substr(vregistro,92,14)) / 10000
                reg-i.Aliquota-icms       =
                            dec(substr(vregistro,106,14)) / 100
                reg-i.valor-icms          = 
                            dec(substr(vregistro,120,14)) / 100
                reg-i.aliquota-ipi        = 
                            dec(substr(vregistro,134,14)) / 100
                reg-i.valor-ipi           = 
                            dec(substr(vregistro,148,14)) / 100
                .
            find first prodnewfree where
                       prodnewfree.procod = reg-i.codigo-produto
                       no-lock no-error.
            if not avail prodnewfree 
            then do:
                create prodnewfree .
                assign
                    prodnewfree.procod = reg-i.codigo-produto
                    prodnewfree.pronom = reg-i.descricao-produto
                    prodnewfree.proindice = ?
                    prodnewfree.itecod = reg-i.codigo-produto. 
            end.
            else reg-i.descricao-produto   = prodnewfree.pronom.
        end.
        else if substr(vregistro,1,1) = "O" /*** REGISTRO TIPO "0"  ***/
        THEN do:
            find first reg-c no-error.
            if avail reg-c
            then do:
                assign
                    reg-c.obs[1] = substr(vregistro,2,60)
                    reg-c.obs[2] = substr(vregistro,62,60)
                    reg-c.obs[3] = substr(vregistro,122,60)
                    reg-c.obs[4] = substr(vregistro,182,60)
                    reg-c.obs[5] = substr(vregistro,242,60)
                    reg-c.obs[6] = substr(vregistro,302,60)
                    .
                    
                do vcont = 1 to 25:
                    
                    assign
                      reg-c.obs[1] = replace(reg-c.obs[1],"  "," ")
                      reg-c.obs[2] = replace(reg-c.obs[2],"  "," ")
                      reg-c.obs[3] = replace(reg-c.obs[3],"  "," ")
                      reg-c.obs[4] = replace(reg-c.obs[4],"  "," ")
                      reg-c.obs[5] = replace(reg-c.obs[5],"  "," ")
                      reg-c.obs[6] = replace(reg-c.obs[6],"  "," ")
                      .
                      
                end.    
                    
            end.
        end.            
        else if substr(vregistro,1,1) = "T" /*** REGISTRO TIPO "T"   ***/
        then do:
            find first reg-c no-error.
            if avail reg-c
            then do:
                assign 
                    reg-c.CNPJ-transportador = substr(vregistro,2,20)   
                    reg-c.NOME-transportador = substr(vregistro,22,50)
                    reg-c.QTD-Volumes        = int(substr(vregistro,72,7))
                    reg-c.Especie            = substr(vregistro,79,5)
                    reg-c.Tipo-frete         = substr(vregistro,84,1)
                    reg-c.Placa              = substr(vregistro,85,8)
                    reg-c.UF-transp          = substr(vregistro,93,2)
                    .
            end.
        end.                    
    end.
end. 
 
unix silent value(" mv " + tt-arq.arq + " " + tt-arq.arq + ".uso").
