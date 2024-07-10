/* #3 */ /* Atualiza os percentuais pera os clientes atualizaveis
            porem apenas uma vez por cliente **/
/** #6 **/ /** 02.2019 Helio.Neto - Versao 4 - Inclui Elegiveis e acerta percentuais */
            
def input param p-today as date.
def var vl as int.
def var va as int.
def var pperc15 as dec decimals 4.
def var pperc45 as dec decimals 4.
def var pperc46 as dec decimals 4.

def var  vti as int.
def var vok as log.
def var ve_situacao as char extent 6 init
    ["ENVIAR","ATUALIZAR","PAGAR","BAIXAR","ARRASTAR","CADASATUALIZAR"].

/**def var ve_tipo     as char extent 7 init
    ["CADAS","CONTR","FINAN","PARCE","MERCA","PAGTO","BAIXA"].
**/
def var vi as int.

message "INI VER CLIEN" today  string(time,"HH:MM:SS").
vl = 0.
do vti = 1 to 6:
    message "Pesquisando "
        ve_situacao[vti].
    for each cslog_controle
        where  
                situacao = ve_situacao[vti]
        no-lock.
        vl = vl + 1.
        if vl mod 10 = 0 then disp  vl cslog_controle.situacao.
                 
        find contrato of cslog_controle no-lock no-error.

        find clien where clien.clicod = cslog_controle.cliente no-lock no-error.
        if not avail clien then next.
         

        /**do vi = 1 to 7.
            vok = no. 
            if ve_situacao[vti] = "ENVIAR" or
               ve_situacao[vti] = "ARRASTAR"
            then do:
                if ve_tipo[vi] = "CADAS" or
                   ve_tipo[vi] = "CONTR" or
                   ve_tipo[vi] = "PARCE" or
                   ve_tipo[vi] = "MERCA"
                then vok = yes.
            end.
            if ve_situacao[vti] = "ATUALIZAR" 
            then do:
                if ve_tipo[vi] = "CADAS" or
                   ve_tipo[vi] = "CONTR" or
                   ve_tipo[vi] = "PARCE" 
                then vok = yes.
            end.
            if ve_situacao[vti] = "PAGAR" 
            then do:
                if ve_tipo[vi] = "PAGTO" or
                   ve_tipo[vi] = "FINAN" or
                   /**ve_tipo[vi] = "CONTR" or**/
                   ve_tipo[vi] = "PARCE" 
                then vok = yes.
            end.
            if ve_situacao[vti] = "BAIXAR" 
            then do:
                if ve_tipo[vi] = "PAGTO" or
                   ve_tipo[vi] = "FINAN" or
                   ve_tipo[vi] = "BAIXA" or
                   /**ve_tipo[vi] = "CONTR" or**/
                   ve_tipo[vi] = "PARCE"
                then vok = yes.
            end.
            if ve_situacao[vti] = "CADASATUALIZAR" /*#1*/
            then do:
                if ve_tipo[vi] = "CADAS" 
                then vok = yes.
            end.
            
            if vok = no 
            then next.
            else do:
        **/    
                find cyber_clien where
                    cyber_clien.clicod = cslog_controle.cliente
                    no-lock no-error.
                if avail cyber_clien
                then do:    
                    if cyber_clien.dtultatuperc = ? or
                       cyber_clien.dtultatuperc < today
                    then do:
                        run csl/letitperc_v4.p 
                                (input  cyber_clien.clicod,
                                 output pperc15,
                                 output pperc45,
                                 output pperc46).
                        
                        do on error undo:
                            find current cyber_clien
                                exclusive no-wait no-error.
                            if avail cyber_clien
                            then do:
                                cyber_clien.perc15 = pperc15.
                                cyber_clien.perc45 = pperc45.
                                cyber_clien.perc46 = pperc46.
                                va = va + 1.
                            end.
                       end.
                    end.                       
        
                end.
            
            /*end.  
        end.*/
    end.        
    message "lidos " vl.
end.    
message "FIM VER CLIEN" today  string(time,"HH:MM:SS")
    "Lidos" vi "Contratos , Atualizados" va "Clientes".


