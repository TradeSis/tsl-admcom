def input param vdtini as date.
def input param vdtfin as date.
def input param varq   as char.

def buffer origem-cybacparcela for cybacparcela.
def var vparc    as int.
def var vetbcod  as int.

def buffer xpdvmov for pdvmov.
def var xtitvlpag as dec format "->>>>>>>9.99".

def var vtitvlpag as dec format "->>>>>>>9.99".
def var vtitvlcob as dec format "->>>>>>>9.99".
def var vtitvljur as dec format "->>>>>>>9.99".
def var vemitido_contrato as dec format "->>>>>>>9.99".

def var xvlpag    as dec.

def var vvalorOrigem as dec format "->>>>>>>9.99".

def var vidacordo as int.
def var vcontnum as int.
def var vtitpar as int.
def var vtabelaorigem as char format "x(40)".
def var vdadosorigem as char format "x(40)".



   def var vcp  as char init ";".
 
def temp-table ttparcelas no-undo
    field precpdvdoc    as recid
    field prectitulo    as recid
    field precbanbolorigem  as recid
    index contnum prectitulo asc .
def buffer bttparcelas for ttparcelas.

        pause 0 before-hide.
        for each banboleto 
            where banboleto.dtpagamento >= vdtini and
                  banboleto.dtpagamento <= vdtfin
                           no-lock:
                                                 
        
        
        
        vtitvlpag = 0.
        vvalorOrigem = 0. 
        vtitvlcob = 0.
        vtitvljur = 0.
        vtabelaorigem = "".        
        for each banbolorigem of banboleto no-lock.
            vvalorOrigem = vvalorOrigem + banbolorigem.valorOrigem.
                vtabelaorigem = banbolorigem.tabelaorigem.
                vdadosorigem  = banbolorigem.dadosorigem.
                
                    
                    if banbolorigem.tabelaorigem = "promessa" or (banbolorigem.tabelaOrigem = ? and  banbolorigem.ChaveOrigem = "idacordo,contnum,parcela")
                    then do:
                                        
                            find CSLPromessa where 
                                CSLPromessa.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
                                CSLPromessa.contnum  = int(entry(2,banbolorigem.dadosOrigem)) and
                                CSLPromessa.parcela  = int(entry(3,banbolorigem.dadosOrigem))
                            no-lock no-error.
                            if avail CSLPromessa
                            then  find cybacordo of CSLPromessa no-lock no-error.
                            vidacordo = int(entry(1,banbolorigem.dadosOrigem)) .
                            vcontnum = int(entry(2,banbolorigem.dadosOrigem)).
                            vtitpar  = int(entry(3,banbolorigem.dadosOrigem)).
                            find contrato where contrato.contnum = vcontnum no-lock.
                            find first titulo where
                                titulo.empcod = 19 and
                                titulo.titnat = no and
                                titulo.modcod = contrato.modcod and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(vcontnum) and
                                titulo.titpar = vtitpar
                            no-lock no-error.
                            if avail titulo
                            then do:
                                xtitvlpag = 0.
                                def var prec as recid.
                                
                                prec = ?.
                                for each pdvdoc where
                                    pdvdoc.ContNum           = string(titulo.titnum) and
                                    pdvdoc.titpar            = titulo.titpar and
                                    pdvdoc.hispaddesc        = "BAIXA DE BOLETO ACORDO CSL " + string(vidacordo) 
                                    and pdvdoc.pstatus = yes
                                    and pdvdoc.datamov = banboleto.dtpagamento
                                    no-lock. 
                                    if prec = ?
                                    then do:
                                        find pdvmov of pdvdoc no-lock.
                                        prec = recid(pdvmov).
                                    end.            

                                    xtitvlpag = xtitvlpag + pdvdoc.valor.

                                    vtitvlpag = vtitvlpag + pdvdoc.valor.
                                    vtitvlcob = vtitvlcob + pdvdoc.titvlcob.
                                    vtitvljur = vtitvljur + pdvdoc.valor_encargo.       

                                    create ttparcelas.
                                    ttparcelas.precpdvdoc = recid(pdvdoc).
                                    ttparcelas.prectitulo = recid(titulo).
                                    ttparcelas.precbanbolorigem = recid(banbolorigem).
                                    
                                    
                                end.
                                
                            end.
                    end.
                   
                    else
                    
                    if banbolorigem.tabelaOrigem = "cybacparcela"
                    then do:
                        find origem-cybacparcela where 
                             origem-cybacparcela.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
                             origem-cybacparcela.parcela  = int(entry(2,banbolorigem.dadosOrigem))
                            no-lock no-error.
                        if avail origem-cybacparcela
                        then do:
                            find cybacordo of origem-cybacparcela no-lock no-error.
                            if avail cybacordo
                            then do: 
                                        find contrato where contrato.contnum = origem-cybacparcela.contnum no-lock.
                                        find first titulo where
                                            titulo.empcod = 19 and
                                            titulo.titnat = no and
                                            titulo.modcod = contrato.modcod and
                                            titulo.etbcod = contrato.etbcod /* #2 cybacordo.etbcod */ and
                                            titulo.clifor = contrato.clicod and
                                            titulo.titnum = string(contrato.contnum) and
                                            titulo.titpar = origem-cybacparcela.parcela
                                            no-lock no-error.
                                        if avail titulo
                                        then do.                                                                
                                                
                                            xtitvlpag = 0.
                                            prec  = ?.
                                            for each pdvdoc where 
                                                pdvdoc.ContNum           = string(titulo.titnum) and
                                                pdvdoc.titpar            = titulo.titpar  and
                                                (pdvdoc.hispaddesc        =  "BAIXA ORIGEM ACORDO CYB " + string(cybacordo.idacordo) or
                                                 pdvdoc.hispaddesc =  "BAIXA ENTRADA ACORDO CYB " + string(cybacordo.idacordo))
                                                and pdvdoc.pstatus = yes
                                                and pdvdoc.datamov = banboleto.dtpagamento
                                                    no-lock.
                                                        if prec = ?
                                                        then do:
                                                            find pdvmov of pdvdoc no-lock.
                                                            prec = recid(pdvmov).
                                                            
                                                        end.            
                                                    
                                                    Xtitvlpag = xtitvlpag + pdvdoc.valor.

                                                    vtitvlpag = vtitvlpag + pdvdoc.valor.
                                                    vtitvlcob = vtitvlcob + pdvdoc.titvlcob.
                                                    vtitvljur = vtitvljur + pdvdoc.valor_encargo.       

                                                    create ttparcelas.
                                                    ttparcelas.precpdvdoc = recid(pdvdoc).
                                                    ttparcelas.prectitulo = recid(titulo).
                                                    ttparcelas.precbanbolorigem = recid(banbolorigem).
                                                    
                                            end.
                                        end.
                                end.                                                                                    
                        end.                            
                    end.    
                    else 
                    
                    if  (banbolorigem.tabelaOrigem = "titulo" or banbolorigem.tabelaOrigem = ?) and
                            num-entries(banBolOrigem.dadosOrigem)  = 2
                    then do:
                        find contrato where
                                contrato.contnum = int(entry(1,banbolorigem.dadosorigem)) 
                             no-lock no-error.    
                        if avail contrato
                        then do:  
                            find first   titulo where   
                                    titulo.empcod = 19 and 
                                    titulo.titnat = no and 
                                    titulo.modcod = contrato.modcod and 
                                    titulo.etbcod = contrato.etbcod and 
                                    titulo.clifor = contrato.clicod and 
                                    titulo.titnum = string(contrato.contnum) and 
                                    titulo.titpar = int(entry(2,banbolorigem.dadosorigem)) 
                                    no-lock no-error.
                                if not avail titulo then do:
                                                        message "nao achei" banbolorigem.tabelaOrigem banbolorigem.dadosorigem.
                                                        pause.
                                                     end.   
                            if avail titulo
                            then do:
                                prec = ?.
                                xtitvlpag = 0.
                                
                                for each pdvdoc where   
                                        pdvdoc.ContNum           = string(titulo.titnum) and
                                        pdvdoc.titpar            = titulo.titpar and
                                        pdvdoc.hispaddesc        = "BAIXA DE BOLETO " + string(banboleto.nossonumero) 
                                        and pdvdoc.pstatus = yes
                                        and pdvdoc.datamov = banboleto.dtpagamento
                                        
                                            no-lock. 

                                                if pdvdoc.ctmcod = "NCY" or
                                                   pdvdoc.ctmcod = "BOL"
                                                then.
                                                else next.
                                            
                                    if prec = ?
                                    then do:
                                        find pdvmov of pdvdoc no-lock.
                                        prec = recid(pdvmov).
                                    end.            
                                    xtitvlpag = xtitvlpag + pdvdoc.valor. 

                                    vtitvlpag = vtitvlpag + pdvdoc.valor. 
                                    vtitvlcob = vtitvlcob + pdvdoc.titvlcob. 
                                    vtitvljur = vtitvljur + pdvdoc.valor_encargo.        
                                    
                                    create ttparcelas.
                                    ttparcelas.precpdvdoc = recid(pdvdoc).
                                    ttparcelas.prectitulo = recid(titulo).
                                    ttparcelas.precbanbolorigem = recid(banbolorigem).
                                    
                                end.
                                
                            end.
                            else do:
                                message "nao achei titulo" banbolorigem.dadosorigem.
                                pause.
                            end.
                        end.
                        else do:
                            message " nao achei contrato " banbolorigem.dadosorigem.
                            pause.
                        end.
                    end.
             
        end.
        
        vemitido_contrato = banboleto.vlcobrado - banboleto.vlservico.
        
        disp banboleto.dtpagamento banboleto.bancod banboleto.nossonumero
                with centered 1 down.
                
                        /*disp banboleto.dtpagamento                         

                    banboleto.vlcobrado column-label "vlboleto" format "->>>>>>>9.99" (total) 
                    banboleto.vlservico column-label "vlServ" format "->>>>9.99" (total)  
                    vemitido_contrato column-label "emitido!contratos" format "->>>>>>>9.99" (total)
                    
                    banboleto.vlpagamento column-label "vlpago_boleto" format "->>>>>>>9.99" (total)
                    
                    banboleto.vlcobrado - banboleto.vlpagamento format "->>>>>>>9.99" column-label "DIF!vlboleto!-vlpago_boleto" (total).
                    

        disp
            vtitvlpag (total)
            vtitvlcob  format "->>>>>>>9.99" column-label "vtitvlcob" (total)
            vtitvljur format "->>>>>>>9.99" column-label "vtitvljur" (total)
                        
            vvalorOrigem - vtitvlpag  format "->>>>>>>9.99" column-label "DIF!vvalorOrigem! -vtitvlpag" (total)
            /*
            vtabelaorigem vdadosorigem */ 
            banboleto.bancod banboleto.nossonumero .
      
            if vvalorOrigem - vtitvlpag <> 0 then pause.                 
            */
            
           end.

message "Gerando arquivo" varq.

 output to value(varq).    

        put unformatted
        "Filial Pg"   vcp
        "DataMov"  vcp
        "TipoMov" vcp
        "NomeMov"  vcp 
        "CodigoCliente" vcp
        "Contrato" vcp
        "Parcela" vcp
        "codProp" vcp
        "propriedade" vcp
        "Vlr Nominal" vcp
        "Vlr Pago Nominal" vcp
        "Vlr Pago Juros" vcp
        "Vlr Pago Movimento" vcp                       
        "NossoNumero" vcp
        "Banco" vcp
        "Observacao" vcp
        "DUPLO?" vcp 
            skip.        

for each ttparcelas by ttparcelas.prectitulo.

    find pdvdoc where recid(pdvdoc) = ttparcelas.precpdvdoc no-lock.
    find pdvtmov of pdvdoc no-lock.
    find titulo where recid(titulo) = ttparcelas.prectitulo no-lock.
    find cobra of titulo no-lock.
    find banbolorigem where recid(banbolorigem) = ttparcelas.precbanbolorigem no-lock.
    find banboleto of banbolorigem no-lock.
    find banco of banboleto no-lock.
    
    find first bttparcelas where bttparcelas.prectitulo = ttparcelas.prectitulo and
                         recid(bttparcelas) <> recid(ttparcelas)
                         no-lock no-error.
                         

        put unformatted
        pdvdoc.etbcod vcp
        pdvdoc.datamov format "99/99/9999" vcp
        pdvdoc.ctmcod  vcp
        pdvtmov.ctmnom   vcp 
        titulo.clifor  vcp
        titulo.titnum vcp
        titulo.titpar vcp
        titulo.cobcod  vcp
        cobra.cobnom  vcp
        trim(string(titulo.titvlcob,"->>>>>>>>>>>>>9.99")) vcp
        trim(string(pdvdoc.titvlcob,"->>>>>>>>>>>>>9.99")) vcp
        trim(string(pdvdoc.valor_encargo,"->>>>>>>>>>>>>9.99")) vcp
        trim(string(pdvdoc.valor,"->>>>>>>>>>>>>9.99")) vcp
        banboleto.nossonumero vcp
        banco.numban vcp
        pdvdoc.hispaddesc vcp
        string(avail bttparcelas,"DUPLO/     ") vcp
            skip.        



end.
output close.


procedure cria-contrato. 
def input param vclicod  as int.
def input param vcontnum as int.
def input param vtitpar  as int.
def output param par-titvlpag as dec.

find contrato where contrato.contnum = vcontnum no-lock.
for each titulo where 
        titulo.empcod = 19 and titulo.titnat = no and
        titulo.etbcod = contrato.etbcod and
        titulo.modcod = contrato.modcod and
        titulo.clifor = contrato.clicod and
        titulo.titnum = string(contrato.contnum) and
        titulo.titpar = vtitpar
        no-lock.

        par-titvlpag = titulo.titvlpag.

        /*for each pdvdoc where pdvdoc.contnum = titulo.titnum and pdvdoc.titpar = titulo.titpar and
                    pdvdoc.datamov = banboleto.dtpagamento no-lock.
            disp pdvdoc.
        end.
        pause.
        */ 
end.

end procedure.


