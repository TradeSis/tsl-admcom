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

form
    vetbcod 
    vcaminho
    with frame f-dados
        centered 1 down side-labels title " DADOS INICIAIS ". 

repeat :

    update 
        vetbcod 
        vcaminho 
        with frame f-dados.

    update  vdtpagini  label "Pagamentos" colon 15
           vdtpagfin  no-label 
                with frame f-data side-label centered title "P E R I O D O".
   
    
    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell. bell. bell. bell.
        message  "Codigo da Filial invalido".
        pause. clear frame f-dados all.
        next.
    end.

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
    
    for each titulo where titulo.empcod = 19        and
                          titulo.titnat = no        and
                          titulo.modcod = "CRE"     and
                          titulo.etbcod = vetbcod   and
                          titulo.titsit = "PAG"     and
                          titulo.titdtpag >= vdtpagini and
                          titulo.titdtpag <= vdtpagfin no-lock:
        
        export titulo.
        
    
    end.

 
    
    output close.



    message "Arquivos Gerados com Sucesso" . pause.

end.