


{admcab.i}
{neuro/achahash.i}  
{neuro/varcomportamento.i}

def var vvlrlimite as dec.
def var vvctolimite as date.

def var vfpd as log.

def var vparcpag as int.
def var vparcabe as int.
def var vpercpag as dec.
def var vQTDECONT as int.

def var vstream as int.
def var cestcivil as char.
def var vinstrucao as char.
def var vcarro as char.
def var vcarteira as char.
def var vproduto as char.
def var vrendapresumida as dec. 

def var varqPAGAMENTO as char.
def var tiporeceita as char.
def var vjuros as dec.

def var vcp as char init ";".

def var vpassa as log.
def var vposicaoCPF as int.
def var vx as int.

def stream e1.
def stream e2.
def stream e3.
def stream e4.
def stream e5.
def stream e6.
def stream e7.
def stream e8.
def stream e9.
def stream e10.


def temp-table ttasses no-undo
    field assessoria as char
    field vstream     as int
    field envia     as log .

def temp-table ttstream no-undo
    field vstream     as int
    field aberta    as log
    field arquivo  as char.

do on error undo:
    find first asses_param where asses_param.dtfim = ?.
    asses_param.dtiniultproc = today.
    asses_param.hriniultproc = time.
    for each asses_envio.
        asses_envio.arquivoult = "".
    end.
    
end.

find current asses_param no-lock.    

message asses_param.dtiniultproc string(asses_param.hriniultproc,"HH:MM:SS") "processando pagamentos..."    .


pause 0 before-hide.
def var vcli as int.

/* processa pagamentos */

varqPAGAMENTO = "/admcom/import/cdlpoa/PAGAMENTOS" +  
            "-PAG-" + string(asses_param.dtiniultproc,"99999999") + replace(string(asses_param.hriniultproc,"HH:MM:SS"),":","") + ".csv".


output to value(varqPAGAMENTO).

put unformatted
    "cpf;codigocliente;contrato;datavencimento;datapagamento;valorparcela;valorpago;moeda;estab recebimento;modalidade;tpcontrato;parcela;" skip. 

for each titulo where titulo.titnat = no and
                      titdtpag >= today - asses_param.diasPGTO and
                      titdtpag <= today 
  no-lock.
  
    if titulo.titsit = "PAG" 
    then.
    else next.    
    if titulo.modcod = "CRE" or titulo.modcod begins "CP"
    then.
    else next.
    
    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien then next.
                                                         
    put unformatted
    clien.ciccgc ";"
    titulo.clifor ";"
    titulo.titnum ";"
    titulo.titdtven ";"
    titulo.titdtpag ";"
    trim(string(titulo.titvlcob,"->>>>>>>>>>9.99")) ";"
    trim(string(titulo.titvlpag,"->>>>>>>>>>9.99")) ";"
    titulo.moecod ";"
    titulo.etbcobra ";"
    titulo.modcod ";"  
    titulo.tpcontrato format "x(1)" ";"
    titulo.titpar ";" 
    skip.
  
end.  

output close.

message asses_param.dtiniultproc string(asses_param.hriniultproc,"HH:MM:SS") "processando contratos..."    .



for each clien no-lock.
    if clien.clicod < 10 then next.
    if clien.ciccgc = ?  then next.    

    find first neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    vcli = vcli + 1.
    if vcli mod 1000 = 0
    then do:
        hide message no-pause.
        message asses_param.dtiniultproc string(asses_param.hriniultproc,"HH:MM:SS") "processando..."    vcli.
    end.    
    
    vposicaoCPF = int(substring(clien.ciccgc,asses_param.posicaoCPF,1)).
    
    vpassa = no.
    for each asses_envio no-lock.
        do vx = 1 to 10.
            if asses_envio.digito5[vx] = vposicaoCPF
            then do:
                vpassa = yes.
                leave.
            end.    
        end.
        if vpassa
        then leave. 
    end. 
    if vpassa = no
    then next.

    /* Emissoes */
    
    for each ttasses.
        ttasses.envia = no.
    end.
        
    for each asses_envio no-lock.
        vpassa = no.
        do vx = 1 to 10.
            if asses_envio.digito5[vx] = vposicaoCPF
            then do:
                vpassa = yes.
                leave.
            end.    
        end.
        if not vpassa
        then next.
        
        find first ttasses where ttasses.assessoria = asses_envio.assessoria no-lock no-error.
        if not avail ttasses
        then do:
            create ttasses.
            ttasses.assessoria = asses_envio.assessoria.
            vstream  = vstream + 1.
            ttasses.vstream = vstream.
            ttasses.envia = no.
            
        end.  
             /*   
        /* Valida atraso maximo */
        if asses_envio.enviaCDC or asses_envio.enviaNOV
        then do:
            find first titulo use-index iclicod 
                where titulo.clifor = clien.clicod and 
                titulo.modcod = "CRE" and 
                titulo.titsit = "LIB" and 
                titulo.titdtpag = ? and 
                titulo.titdtven < today - asses_param.atrasoMax
                no-lock no-error.  
            if avail titulo  then  next.

        end.
        if asses_envio.enviaEP or asses_envio.enviaCPN
        then do:
            find first titulo use-index iclicod 
                where titulo.clifor = clien.clicod and 
                titulo.modcod begins "CP" and 
                titulo.titsit = "LIB" and 
                titulo.titdtpag = ? and 
                titulo.titdtven < today - asses_param.atrasoMax
                no-lock no-error.  
            if avail titulo then next.
        end.
        
        /* Valida se existe alguma parcela aberta */
        if asses_envio.enviaCDC or asses_envio.enviaNOV
        then do:
            find first titulo use-index iclicod where 
                    titulo.clifor = clien.clicod and 
                    titulo.modcod = "CRE" and 
                    titulo.titsit = "LIB" and 
                    titulo.titdtpag = ? and 
                    titulo.titdtven < today 
                    no-lock no-error.  
            if not avail titulo then next. 
        end.
        if asses_envio.enviaEP or asses_envio.enviaCPN
        then do:
            find first titulo use-index iclicod where 
                    titulo.clifor = clien.clicod and 
                    titulo.modcod = "CRE" and 
                    titulo.titsit = "LIB" and 
                    titulo.titdtpag = ? and  titulo.titdtven < today 
                    no-lock no-error.  
            if not avail titulo then next. 
        end.
               */
        ttasses.envia = yes.
        
    end.                
    
    /* Valida se foi elegivel em alguma assessoria */
    
    find first ttasses where ttasses.envia = yes no-error.
    if not avail ttasses
    then next.   
    
    for each ttasses where ttasses.envia = yes.
        find first ttstream where ttstream.vstream = ttasses.vstream no-error.
        if not avail ttstream
        then do:
            create ttstream.
            ttstream.vstream = ttasses.vstream.
            ttstream.aberta  = no. 
        end.
        if ttstream.aberta = no
        then do:    
            if ttasses.vstream = 1
            then do:
                {fin/assesexpautom_o.i " stream e1 " }
            end.    
            if ttasses.vstream = 2
            then do:
                {fin/assesexpautom_o.i " stream e2 "}
            end.    
            if ttasses.vstream = 3
            then do:
                {fin/assesexpautom_o.i " stream e3 "}
            end.    
            if ttasses.vstream = 4
            then do:
                {fin/assesexpautom_o.i " stream e4 "}
            end.    
            if ttasses.vstream = 5
            then do:
                {fin/assesexpautom_o.i " stream e5 "}
            end.    
            if ttasses.vstream = 6
            then do:
                {fin/assesexpautom_o.i " stream e6 "}
            end.    
            if ttasses.vstream = 7
            then do:
                {fin/assesexpautom_o.i " stream e7 "}
            end.    
            if ttasses.vstream = 8
            then do:
                {fin/assesexpautom_o.i " stream e8 "}
            end.    
        
        end.
        
    end.         
    

    tiporeceita = if clien.tippes then "PF" else "CNPJ".
    
    cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "". 
    
    find cpclien of clien no-lock no-error.
    if avail cpclien and cpclien.var-char8 <> ?
    then vinstrucao = acha("INSTRUCAO", cpclien.var-char8).
    else vinstrucao = "".

    vcarro = "NAO".
    find carro where carro.clicod = clien.clicod no-lock no-error.
    if avail carro
    then if carro.carsit 
         then vcarro = "SIM".

    if clien.prorenda[1] = ?
    then vrendapresumida = 0.
    else vrendapresumida = clien.prorenda[1].
         
        
    /* comportamento */
    
    var-propriedades  = "". 
    run neuro/comportamento.p (clien.clicod, ?,   /* hubseg */
                                   output var-propriedades). 
    vPARCPAG = int(pega_prop("PARCPAG")).
    if vPARCPAG = ? then vPARCPAG = 0.
    vPARCABE = int(pega_prop("PARCABE")).
    if vPARCABE = ? then vPARCABE = 0.
    vpercpag = vPARCPAG / (vPARCPAG + vPARCABE) * 100.
    vQTDECONT = int(pega_prop("QTDECONT")).
    if vQTDECONT = ? then vQTDECONT = 0.
    
    vfpd = no.

    vvctolimite = if avail neuclien then neuclien.vctolimite else ?.
    vvlrlimite  = if avail neuclien then neuclien.vlrlimite else 0.
    
    if vvctolimite < today or vvctolimite = ? 
    then do:
        vvlrlimite   = 0.
    end.     

    for each contrato where contrato.clicod = clien.clicod no-lock.  
        
    
        for each titulo where titulo.empcod = 19 and titulo.titnat = no and                        
                    titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                    titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
                    titulo.titdtpag = ? and titulo.titsit = "LIB"
                    no-lock.
            
            if titulo.titpar = 1 then vfpd = yes. /* nao pagou a primeira parcela */                 
            run exptitulo.
                    
        end.                   
    
    end.   
end. 


do on error undo:
    find first asses_param where asses_param.dtfim = ? .
    asses_param.dtfimultproc = today.
    asses_param.hrfimultproc = time.
    
    for each asses_envio.
        find ttasses  where  ttasses.assessoria = asses_envio.assessoria.
        find ttstream where ttstream.vstream = ttasses.vstream.
        asses_envio.arquivoult = ttstream.arquivo.    
    end.
    
end.


procedure exptitulo.
    
    for each ttasses where ttasses.envia = yes.
            
        find asses_envio where asses_envio.assessoria = ttasses.assessoria no-lock.
        if asses_envio.enviaCDC and titulo.modcod = "CRE" and titulo.tpcontrato = ""
        then.
        else do:
            if asses_envio.enviaNOV and titulo.modcod = "CRE" and titulo.tpcontrato = "N"
            then.
            else do:
                if asses_envio.enviaEP and (titulo.modcod = "CP0" or titulo.modcod = "CP1")
                then.
                else do:
                    if asses_envio.enviaCPN and titulo.modcod = "CPN"
                    then.
                    else next.
                end.
            end.
        end.
         
        
        if ttasses.vstream = 1
        then do:
            {fin/assesexpautom_e.i " stream e1 "}
        end.    
        if ttasses.vstream = 2
        then do:
            {fin/assesexpautom_e.i " stream e2 "}
        end.    
        if ttasses.vstream = 3
        then do:
            {fin/assesexpautom_e.i " stream e3 "}
        end.    
        if ttasses.vstream = 4
        then do:
            {fin/assesexpautom_e.i " stream e4 "}
        end.    
        if ttasses.vstream = 5
        then do:
            {fin/assesexpautom_e.i " stream e5 "}
        end.    
        if ttasses.vstream = 6
        then do:
            {fin/assesexpautom_e.i " stream e6 "}
        end.    
        if ttasses.vstream = 7
        then do:
            {fin/assesexpautom_e.i " stream e7 "}
        end.    
        if ttasses.vstream = 8
        then do:
            {fin/assesexpautom_e.i " stream e8 "}
        end.    
        
    end.


end procedure.





procedure pegaproduto.

    find ctbpostitprod where ctbpostitprod.contnum = int(titulo.titnum) no-lock no-error.
    if avail ctbpostitprod
    then do:
        vproduto = ctbpostitprod.produto.
        return.
    end.
    if titulo.tpcontrato <> ""
    then do:
        vproduto =  if titulo.tpcontrato = "F"
                    then "FEIRAO "
                    else if titulo.tpcontrato = "N"
                         then "NOVACAO"
                         else if titulo.tpcontrato = "L"
                              then "LP     "
                              else "".
        if vproduto <> ""
        then return.   
    end.    
    vproduto = "DESCONHECIDO".
    def var vcatcod as int.        
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail contrato
    then do:
        find contrsite where contrsite.contnum = int(titulo.titnum) no-lock no-error.
        if avail contrsite
        then do:
            vproduto = "Cre Digital".
        end.
        else do:
            if contrato.modcod begins "CP"
            then do:
                vproduto = "Emprestimos".
            end.
            else do:    
                find first contnf where 
                    contnf.etbcod = contrato.etbcod and
                    contnf.contnum = contrato.contnum 
                    no-lock no-error.
                if avail contnf 
                then do:
                    find first plani where
                        plani.etbcod = contnf.etbcod and
                        plani.placod = contnf.placod 
                        no-lock no-error. 
                    if avail plani
                    then do:
                        vcatcod = 0.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod
                                             no-lock.
                            find produ of movim no-lock no-error.
                            if avail produ
                            then do:                    
                                if produ.catcod = 31 or produ.catcod = 41
                                then do:
                                    find categoria of produ no-lock.
                                    vproduto = caps(categoria.catnom).
                                    leave.
                                end.
                                else vcatcod = produ.catcod. 
                            end.
                        end.
                        if vproduto = "DESCONHECIDO"
                        then do:
                            find categoria where categoria.catcod = vcatcod no-lock no-error.
                            if avail categoria
                            then do:
                                vproduto = caps(categoria.catnom).
                            end.     
                        end.        
                    end.                                   
                end.          
            end.
        end.                     
    end.    
    if not avail ctbpostitprod
    then do on error undo:
        create ctbpostitprod.
        ctbpostitprod.contnum = int(titulo.titnum).
        ctbpostitprod.produto = vproduto.
    end.    
    
end procedure.    

