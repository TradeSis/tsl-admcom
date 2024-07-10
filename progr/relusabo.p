/* ---------------------------------------------------------------------------
*  Nome.....: relclnao.p
*  Funcao...: Relatorio de bonus usados pelo cliente
*  Data.....: 04/01/2007
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */
{admcab.i new}

def var edatain     like   plani.pladat.
def var edatafi     like   plani.pladat.

def var varquivo    as     char.
def var vfiltro     as     char.

def var iconta      as     inte  init 0. 

    update edatain  label "Data inicial"
           edatafi  label "Data final"
           with frame f-upd side-label 2 col 1 down width 80
                title "RELATORIO DE BONUS USADOS PELO CLIENTE".
       
    assign vfiltro = string(edatain,"99/99/9999") + " ate " + 
                     string(edatafi,"99/99/9999").

    /*
    for each estab no-lock:
        for each plani where 
             plani.movtdc = 5 and
             plani.etbcod = estab.etbcod and
             plani.pladat >= edatain   and
             plani.pladat <= edatafi no-lock:
   
            assign iconta = iconta + 1.                          
    
            create tt-clinao.
            assign tt-clinao.clicod = plani.dest.
            
            disp iconta label "Processando..."
                 with frame f-proc side-label centered.
            pause 0 no-message.     
                        
        end.
    end.
    */
    
    hide frame f-proc.  

    /* DREBES */
    if opsys = "UNIX"
    then do:
            assign varquivo   = "/admcom/relat/relusabo." + string(time).
    end. 
    else do:
            assign varquivo   = "l:\relat\relusabo." + string(time).
    end.

    message "Montando Relatorio....".
        
    assign iconta   = 0.

    {mdadmcab.i
         &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "80"
         &Page-Line = "66"
         &Nom-Rel   = ""RELUSABO.P""
         &Nom-Sis   = """SISTEMA GERENCIAL"""
         &Tit-Rel   = """RELATORIO DE BONUS USADOS PELO CLIENTE  "" + 
                         vfiltro"
         &Width     = "80"
         &Form      = "frame f-rel01"}


if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else {mrod.i}.
