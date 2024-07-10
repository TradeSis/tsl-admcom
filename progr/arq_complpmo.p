{admcab.i}

prompt-for complpmo.mescomp label "Competencia Mes/Ano" format "99"
        validate(input complpmo.mescomp > 0 ,"Informe o mes de competencia.")
           "/"
           complpmo.anocomp no-label  format "9999"
           validate(input complpmo.anocomp > 0,"Informe o ano de competencia.")
           with frame f-ma side-label width 80
           .

def var vpath as char format "x(22)".
vpath = "/admcom/folha/premios/".
disp vpath label "Arquivo" space(0) with frame f-arq. 
update varquivo as char no-label format "x(20)"
    help "Informe o caminho e o nome do arquivo."
            with frame f-arq 1 down side-label width 80
            overlay row 7.
        
varquivo = vpath + varquivo.

output to value(varquivo).
    
    put unformatted 
        "Filial;CodAdm;CodFol;Nome;MesComp;AnoComp;Valor"
        skip.
    for each tbpmofol where
             tbpmofol.anocomp = input complpmo.anocomp and
             tbpmofol.mescomp = input complpmo.mescomp 
             no-lock:
        put  unformatted 
             tbpmofol.etbcod  ";"
             tbpmofol.funcod  ";"
             tbpmofol.codfol  ";"
             tbpmofol.funnom  ";"
             tbpmofol.mescomp ";"
             tbpmofol.anocomp ";"
             tbpmofol.valliq
             skip .
             
    end.

output close.    
 

message color red/with
        "Arquivo gerado" skip
        varquivo
        view-as alert-box.
        
