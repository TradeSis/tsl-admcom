/*put screen row 24  search(program-name(1)). */

 
def new global shared var smencod       like menu.mencod.
def new global shared var senha_sis     as char.
def new global shared var sfunape     as char.


def buffer westab for estab.
def new global shared var setbcod   like estab.etbcod.

/*def new global shared var sUOCod    like uo.uocod.*/
def new global shared var stty      as   char format "x(15)".
def new global shared var sempcod   like empre.empcod.
def new global shared var sempresa  as int.
/*def new global shared var suopra    like uo.uocod.*/

if  sfuncod = 99999999
then do.
    message search(program-name(1)) . pause 2 no-message . 
end.    

def new global shared var scxacod   as int.
def new global shared var snumcod   as int.
def new global shared var sretorno  as   char.
def new global shared var stitnat   as log.
def new global shared var simpress  as char.
def new global shared var scgccpf   as dec. /*like clifor.cgccpf.*/
def new global shared var smentit   as char.
def new global shared var shome     as char.
def new global shared var sen-ok    as log.
def new global shared var sini     as char.

def var sfuncao          as char.
def var sparametro       as char format "x(80)".
def var sint    as int.
def var whora as char.
DEFINE NEW GLOBAL SHARED TEMP-TABLE paramsis 
  FIELD ParamSisCod   AS CHARACTER FORMAT "x(20)" LABEL "Parametro"
  FIELD ParamSisValor AS CHARACTER FORMAT "x(40)" LABEL "Valor"
  index paramsis is primary unique
        paramsiscod asc.
/*
shome = "../etc".
if opsys = "UNIX" then
if shome = ""
then do with frame fhome.
        input through echo $HOME no-echo.
        set shome format "x(40)" with frame fhome.
        input close.
    end.
    shome = "../etc".

if sini = ""
then sini = "admcom.ini".

message shome sini view-as alert-box.

input from value(shome + "/" + sini) no-echo.
repeat with width 100:
    set sfuncao sparametro.
    if sfuncao = "EMPRE"     then   sempcod = int(sparametro).
    if sfuncao = "ESTAB"     then   setbcod = int(sparametro).
/*    if sfuncao = "UO"        then   sUOCod  = int(sparametro).*/
/*    if sfuncao = "PRATE"     then   suopra  = int(sparametro).*/
    if sfuncao = "CAIXA"     then   scxacod = int(sparametro).
/*    if sfuncao = "MENS"      then   smens   = sparametro.*/
    if sfuncao = "EMPRESA"   then   sempresa = int(sparametro).
end.
input close.

find first empre where empre.empcod = sempcod no-lock no-error.
if not avail empre
then do:
    message "EMPRESA " sempcod " NAO CADASTRADA " .
    pause.
    quit.
end.
*/

/*
if westab.empcod <> empre.empcod
then do:
    message "ESTABELECIMENTO " setbcod
            " NAO E' CADASTRADO NA EMPRESA " sempcod .
    pause.
    quit.
end.
*/




FUNCTION paramsis return character
    (input par-paramsiscod as char):

    /**
    find parametrosis where parametrosis.etbcod = setbcod
                        and parametrosis.prmcod = par-paramsiscod
                      no-lock no-error.
    if avail parametrosis
    then return trim(parametrosis.prmValor).
    else do.
        find parametrosis where parametrosis.etbcod = 0
                            and parametrosis.prmcod = par-paramsiscod
                          no-lock no-error.
        if avail parametrosis
        then return trim(parametrosis.prmValor).
        else do.
            find first paramsis where ParamSis.ParamsisCod = par-paramsiscod
                        no-lock no-error.
            if avail paramsis
            then return trim(paramsis.paramsisValor).
            else return trim("").
        end.
    end.
    **/
    return "".
END function.

PROCEDURE ctdc.

def input        parameter par-nat          as log.
            /** par-nat invertido em 23.08.2016
                para ficar igual ao antigo titnat **/
                 
def input-output parameter par-mais-menos   as char.
def input-output parameter par-debcre       as log.

if par-debcre = ?
then do:
    if par-mais-menos = "+" and     /* SOMA                                   */
       par-nat        = no         /* CONTA DE DEBITO/DEVEDORA Ativo/Despesa */
    then par-debcre   = yes.        /* DEBITA                                 */

    if par-mais-menos = "-"  and    /* DIMINUI                                */
       par-nat        = no          /* CONTA DE DEBITO/DEVEDORA Ativo/Despesa */
    then par-debcre   = no.         /* CREDITA                                */

    if par-mais-menos = "+" and     /* SOMA                                   */
       par-nat        = yes         /* CONTA DE CREDITO/CREDORA Passivo/Recei */
    then par-debcre   = no.         /* CREDITA                                */

    if par-mais-menos = "-" and     /* DIMINUI                                */
       par-nat        = yes         /* CONTA DE CREDITO/CREDORA Passivo/Recei */
    then par-debcre   = yes.        /* DEBITA                                 */
end.
if par-mais-menos = ?
then do:
    if par-debcre     = yes and     /* DEBITO                                 */
       par-nat        = no          /* CONTA DE DEBITO/DEVEDORA Ativo/Despesa */
    then par-mais-menos = "+".      /* SOMA                                   */

    if par-debcre     = no   and    /* CREDITA                                */
       par-nat        = no          /* CONTA DE DEBITO/DEVEDORA Ativo/Despesa */
    then par-mais-menos = "-".      /* DIMINUI                                */

    if par-debcre     = no  and     /* CREDITA                                */
       par-nat        = yes         /* CONTA DE CREDITO/CREDORA Passivo/Recei */
    then par-mais-menos = "+".      /* SOMA                                   */

    if par-debcre     = yes and     /* DEBITA                                 */
       par-nat        = yes         /* CONTA DE CREDITO/CREDORA Passivo/Recei */
    then par-mais-menos = "-".      /* DIMINUI                                */
end.

end procedure.


function permissao returns logical
    (input par-programa as char,
     input par-funcod   as int):

     
    find first seguranca where
            seguranca.empcod    = 1 and
            seguranca.programa  = par-programa
        no-lock no-error.

    if not avail seguranca
    then return true.
    else do:
        find seguranca where seguranca.empcod   = 1 and
                            seguranca.funcod   = par-funcod       and
                              seguranca.programa = par-programa
            no-lock no-error.
        return
            if avail seguranca
            then true
            else false.
    end.

end function.



find westab where westab.etbcod = setbcod no-lock.


