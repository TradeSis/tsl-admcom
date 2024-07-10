/* ---------------------------------------------------------------------------
*  Nome.....: relclnao.p
*  Funcao...: Relatorio de clientes (Sem compras nas filiais)
*  Data.....: 19/12/2006
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */
{admcab.i new}

def var edatain     like   plani.pladat.
def var edatafi     like   plani.pladat.

def var varquivo    as     char.
def var vfiltro     as     char.

def var iconta      as     inte  init 0. 

def temp-table tt-clinao       no-undo
    field clicod      like clien.clicod
    index ch_clicod   clicod.

    for each tt-clinao:
        delete tt-clinao.
    end.   

    assign edatain = today - 30
           edatafi = today.

    update edatain  label "Data inicial"
           edatafi  label "Data final"
           with frame f-upd side-label 2 col 1 down width 80
                title "RELATORIO DE CLIENTES SEM COMPRAS".
       
    assign vfiltro = string(edatain,"99/99/9999") + " ate " + 
                     string(edatafi,"99/99/9999").


    for each estab no-lock:
        for each plani where 
             plani.movtdc = 5 and
             plani.etbcod = estab.etbcod and
             plani.pladat >= edatain   and
             plani.pladat <= edatafi no-lock:
   
            assign iconta = iconta + 1.                          
    
            find first tt-clinao where
                       tt-clinao.clicod = plani.dest exclusive-lock no-error.
            if not avail tt-clinao
            then do:            
                    create tt-clinao.
                    assign tt-clinao.clicod = plani.dest.
            end.
            else next.
            
            disp iconta label "Processando..."
                 with frame f-proc side-label centered.
            pause 0 no-message.     
                        
        end.
    end.

    hide frame f-proc.  

    /* DREBES */
    if opsys = "UNIX"
    then do:
            assign varquivo   = "/admcom/relat/relclnao." + string(time).
    end. 
    else do:
            assign varquivo   = "l:\relat\relclnao." + string(time).
    end.

    message "Montando Relatorio....".
        
    assign iconta   = 0.

    {mdad.i
         &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "80"
         &Page-Line = "66"
         &Nom-Rel   = ""RELCLNAO.P""
         &Nom-Sis   = """SISTEMA GERENCIAL"""
         &Tit-Rel   = """RELATORIO DE CLIENTES SEM COMPRAS  "" + 
                         vfiltro"
         &Width     = "80"
         &Form      = "frame f-rel01"}

        put "Codigo"    at 001
            "Nome"      at 015
            "Fone"      at 068
            skip
            fill("-",80)   form "x(80)"
            skip(1).  


        for each clien where
                 clien.dtcad >= (today - 360) no-lock
                 by clien.clinom
                 by clien.dtcad:

                find first tt-clinao where
                           tt-clinao.clicod = clien.clicod no-lock no-error.
                if avail tt-clinao
                then next.
                
                assign iconta = iconta + 1.

                /*
                put clien.clicod                    at 001
                    clien.clinom  form "x(35)"      at 012
                    clien.dtcad   form "99/99/9999" at 050
                    clien.fone                      at 063 
                    skip.
                */

                disp clien.clicod                    at 001
                     clien.clinom  form "x(35)"      at 012
                     clien.dtcad   form "99/99/9999" at 050
                     clien.fone                      at 063 
                     with frame f-rela centered width 80.
        end.

        put "Registros " iconta 
            skip.
        output close.


if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else {mrod.i}.

