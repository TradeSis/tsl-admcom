{admcab.i}
def input parameter varquivo as char.
def input parameter vtitulo as char.

def var fila as char.
def var recimp as recid.
def var vindex as int.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
if sparam = "AniTA"
then vindex = 2.
else vindex = 1.
def var vsaida as char extent 2 format "x(15)"
    init["    LINUX    ","    WINDOWS   "].
/**
repeat on endkey undo, return:
    disp vsaida with frame f1 1 down no-label  centered
            row 18 title " editor ".
    choose field vsaida pause 1 with frame f1.
    if keyfunction(lastkey) = "return"
    then do:
        message "".
        hide frame f1 no-pause.
        leave.
    end.
    message "    Selecione editor WINDOWS somente quando estiver usando uma conexao AniTA     ".
end.
vindex = frame-index.
**/
if vindex = 2
then do:
    /**
    output to value(varquivo + ".cab").
        /**
        scabrel = trim(varquivo)  + "@" +
                  trim(wempre.emprazsoc) + "@" +
                  trim(scabrel)       + "@".
        **/

        scabrel = varquivo  + "@" +
                  wempre.emprazsoc + "@" +
                  scabrel       + "@".
        put scabrel format "x(400)" skip.

    output close.
    /*                
    scabrel = varquivo + "@".
    */

    pause 1 no-message.
    sretorno = "windows".
    run editarqr.p(varquivo + ".cab").
    ***/
    def var vi as int.
    vi = num-entries(varquivo,"/").
    /*
    message vi entry(vi,varquivo,"/"). pause.
    */
    unix silent  value("./imp-anita " + varquivo + " " + 
                entry(vi,varquivo,"/")).
    
end.
else do:
    pause 0. 
    run visurel0.p(varquivo, vtitulo).
    if setbcod = 998 or setbcod = 993 or setbcod = 900
    then do:    
        sresp = no.
        message "Deseja imprimir?" update sresp.
        if sresp then do:
        find first impress where impress.codimp = setbcod 
                            no-lock no-error.
        if avail impress 
        then do:
            run acha_imp.p (input recid(impress),
                              output recimp).     
            find impress where recid(impress) = recimp
                            no-lock no-error.
                            
            assign fila = string(impress.dfimp). 
        end. 
        os-command silent lpr value(fila + " " + varquivo).
        end.
    end. 
 end.    
