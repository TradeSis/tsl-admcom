def var vetbcod like estab.etbcod.
def var vcaminho as char format "x(45)" label "Diretorio/Caminho".
def var varqsai as char.

def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vdtpagini like plani.pladat.
def var vdtpagfin like plani.pladat.
def var vdtcontini like plani.pladat.
def var vdtcontfin like plani.pladat.

def var vflag      as log format "Sim/Nao".
def var vforne     as log format "Sim/Nao".

form vetbcod 
     vcaminho with frame f-dados
                centered 1 down side-labels title " DADOS INICIAIS ". 

repeat:

    update 
        vetbcod 
        vcaminho with frame f-dados.

    update vflag  label "Exporta Flag      " 
           vforne label "Exporta Fornecedor"
                with frame f-flag centered side-label 1 column.
                

    update vdti       label "Notas     " colon 15
           vdtf       no-label 
           vdtpagini  label "Pagamentos" colon 15
           vdtpagfin  no-label 
           vdtcontini label "Contratos " colon 15
           vdtcontfin no-label 
                with frame f-data side-label centered title "P E R I O D O".
   
    
    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell. bell. bell. bell.
        message  "Codigo da Filial invalido".
        pause. clear frame f-dados all.
        next.
    end.

    varqsai = vcaminho + "/" + "plani.d".
    
    disp " Aguarde, Gerando NOTAS FISCAIS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    for each tipmov where tipmov.movtdc <> 4 no-lock,
        each plani where plani.etbcod = vetbcod       and
                         plani.movtdc = tipmov.movtdc and
                         plani.pladat >= vdti         and
                         plani.pladat <= vdtf no-lock:
        export plani.
    end.
    for each plani where plani.movtdc = 6      and
                         plani.desti = vetbcod and 
                         plani.pladat >= vdti  and
                         plani.pladat <= vdtf no-lock:
        export plani.
    end.
    output close.
    
    varqsai = vcaminho + "/" + "movim.d".

    disp " Aguarde, Gerando MOVIMENTOS  ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.
                                       
    
    output to value(varqsai).
    for each tipmov where tipmov.movtdc <> 4 no-lock,
        each plani where plani.etbcod = vetbcod       and
                         plani.movtdc = tipmov.movtdc and
                         plani.pladat >= vdti         and
                         plani.pladat <= vdtf no-lock:
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock:
            export movim.
       
        end.
    end.
    for each plani where plani.movtdc = 6      and
                         plani.desti = vetbcod and 
                         plani.pladat >= vdti  and
                         plani.pladat <= vdtf no-lock:
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock:
            export movim.
            
        end.
    end.
    output close.
    

    /*
    varqsai = vcaminho + "/" + "pedid.d".
    
    output to value(varqsai).
    for each pedid where pedid.etbcod = vetbcod       and
                         pedid.pedtdc = 03            no-lock.
        
        export pedid.

    end.
    output close.
    
    
    varqsai = vcaminho + "/" + "liped.d".
    
    output to value(varqsai).
    for each liped where liped.etbcod = vetbcod       and
                         liped.pedtdc = 03            no-lock.
        
        export liped.

    end.
    output close.
    */
 
    
    
    
    varqsai = vcaminho + "/" + "titulo.d".

    disp " Aguarde, Gerando TITULOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    
    for each titulo where titulo.empcod = 19      and
                          titulo.titnat = no      and
                          titulo.modcod = "CRE"   and
                          titulo.etbcod = vetbcod and
                          titulo.titsit = "LIB"   no-lock:
        
        export titulo.
        
    
    end.
    
    for each titulo where titulo.etbcobra = vetbcod   and
                          titulo.titdtpag >= vdtpagini and
                          titulo.titdtpag <= vdtpagfin no-lock:
        
        if modcod <> "CRE"
        then next.
        if clifor = 1
        then next.
        
        export titulo.
        
    
    end.

 
    
    output close.


    varqsai = vcaminho + "/" + "contrato.d". 

    disp " Aguarde, Gerando CONTRATOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    for each contrato where contrato.etbcod    = vetbcod     and
                            contrato.dtinicial >= vdtcontini and
                            contrato.dtinicial <= vdtcontfin no-lock:
        
        export contrato.
        
    end.
    output close.
    
    varqsai = vcaminho + "/" + "contnf.d". 


    output to value(varqsai).
    for each contrato where contrato.etbcod    = vetbcod     and
                            contrato.dtinicial >= vdtcontini and
                            contrato.dtinicial <= vdtcontfin no-lock:
        
        for each contnf where contnf.etbcod  = contrato.etbcod and
                              contnf.contnum = contrato.contnum no-lock.
            export contnf.
        end.    
    end.
    output close.
    

    
    
    
    if vflag
    then do:
       
        varqsai = vcaminho + "/"+ "flag.d".
        output to value(varqsai).

        for each flag no-lock.
            export flag.
        end.
        output close.
    end.
    
    if vforne
    then do:
        varqsai = vcaminho + "/"+ "forne.d.".
  
        output to value(varqsai).
        for each forne no-lock.
            export forne.
        end.
        output close.
    end.
    
    

    
    
    varqsai = vcaminho + "/" + "estoq.d". 

    disp " Aguarde, Gerando ESTOQUES ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    for each estoq where estoq.etbcod = vetbcod no-lock :
        export estoq.
    end.
    output close.

    varqsai = vcaminho + "/" + "produ.d". 

    disp " Aguarde, Gerando PRODUTOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    for each produ no-lock : 
        export produ.
    end.
    output close.

    message "Arquivos Gerados com Sucesso" . pause.

end.
