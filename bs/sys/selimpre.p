/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : selimpre.p
***** Descri‡ao Abreviada da Funcao: Selecao de impressora
*******************************************************************************/

{cabec.i}
{setbrw.i}.

scopias  = 0.
scabrel = "".
                        /** ADMCOM **/
def temp-table tt-impre like impress.

form
    tt-impre.nomeimp format "x(35)" no-label 
    with frame f-linha down row 10 
          title " Selecione a Impressora "
          color withe/brown overlay.

/**
if opsys = "WIN32" or
   paramsis("EMULADOR-USA-GERIMP") = "SIM"
then do:
**/

    create tt-impre.
    tt-impre.nomeimp = "VISUALIZADOR WINDOWS" .
    tt-impre.codimp  = -100.
/**
end. 
**/

 
do:
    create tt-impre.
    tt-impre.nomeimp = "VISUALIZADOR CARACTER" .
    tt-impre.codimp  = -90.
end. 


for each impress where impress.etbcod = 0 or impress.etbcod = setbcod no-lock:
   create tt-impre.
   raw-transfer impress to tt-impre.
end.   

l1: repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1.

    {sklcls.i
        &file         = tt-impre
        &cfield       = tt-impre.nomeimp
        &ofield       = " 
                         tt-impre.nomeimp "
                        " 
        &where        = "true"
        &color        = withe
        &color1       = brown
        &locktype     = " no-lock " 
        &naoexiste1   = " bell. 
                          message color red/withe
                            "" Nenhum registro encontrado ""
                            view-as alert-box title "" Mensagem "".
                          leave l1.  
                          " 
        &aftselect1   = "   
                    if keyfunction(lastkey) = ""return""
                    then do:
                        simpress = tt-impre.nomeimp.
                        leave l1. 
                    end.
                    next keys-loop."
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
hide frame f-linha no-pause.
/*
if simpress <> ""
then do:
    display 
        "IMPRESSORA SELECIONADA " +
        string(SIMPRESS,"x(25)") + "  " 
         format "x(70)"
        with frame f-cabimp no-label row 22 1 down no-box
        color red/withe. 
end.    
*/
