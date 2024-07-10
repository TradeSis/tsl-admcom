/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

/**
    message search(program-name(1)) program-name(2) transaction. PAUSE 2 NO-MESSAGE.
**/

def {1} shared variable wdata as date format "99/99/9999"
                      label "Data de Processamento".
def {1} shared variable wtittela as char format "x(30)".
def {1} shared buffer wempre for empre.
def {1} shared variable wmodulo as c.
def {1} shared variable wareasis as char format "x(38)".
def {1} shared variable wtitulo  as char format "x(80)".
def {1} shared variable sfuncod  like func.funcod.
def {1} shared var lclifor as log .

def var b1 as char format "x".
def var b2 as char format "x".
def var b3 as char format "x".
def var b4 as char format "x".
def var smens as char format "x(20)".
b1 = "|".
b2 = "|".
b3 = "|".
b4 = "|".
define variable ytit like wtittela.
def new global shared var sparam      as char.
def new global shared var sresp      as log format "Sim/Nao".
def new global shared var setbcod    like estab.etbcod.
def new global shared var scxacod    like estab.etbcod.
def new global shared var scliente   like admcom.cliente.
def new global shared var sautoriza  as char. /* like autoriz.motivo. */
def new global shared var svalor1    as dec . /* like autoriz.valor1. */
def new global shared var svalor2    as dec . /* like autoriz.valor2. */
def new global shared var svalor3    as dec . /* like autoriz.valor3. */
def new global shared var scliaut    like clien.clicod.
def new global shared var stprcod    as int. /* like tippro.tprcod.  */

def new global shared var slancod       like tablan.lancod.

def new global shared var scabrel       as char.
def new global shared var sretorno      as char.
def new global shared var scopias       as int.
def new global shared var schave        as char.
def new global shared var sremoto       as log.
def new global shared var scarne        as char format "x(40)".

define            variable vmesabr  as char format "x(04)" extent 12 initial
    ["Jan","Fev","Mar","Abr","Maio","Jun","Jul","Ago","Set","Out","Nov","Dez"].
define            variable vmescomp as char format "x(09)" extent 12 initial
    ["Janeiro","Fevereiro","Mar‡o","Abril","Maio","Junho",
     "Julho","Agosto", "Setembro","Outubro","Novembro","Dezembro"].
define            variable vsemabr  as char extent  7 format "x(03)" initial
    ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"].
define            variable vsemcomp as char format "x(7)" extent 7 initial
    ["Domingo","Segunda","Ter‡a","Quarta","Quinta","Sexta","S bado"].

def {1} shared frame fc1.
def {1} shared frame fc2.
if "{1}" = "new"
then do:
    find first wempre no-lock.
    wdata    = today.
    wareasis = " TESTE ".
    wtittela = "teste".
    wtitulo  = "                             ADMCOM VERSAO 2.0".
    setbcod = 999.
    scxacod = 1.
    stprcod = ?.
    on F6  help.
    on PF6 help.
    on F5  help.
    on PF5 help.
    on F7  help.
    on PF7 help.
end.
sparam = SESSION:PARAMETER.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

find estab where estab.etbcod = setbcod no-lock.

form space(1)
    wempre.emprazsoc format "x(65)" 
    wdata
    with column 1 page-top no-labels top-only row 1 width 81 no-hide frame fc1
        no-box color black/gray.

form
    wtitulo          format "x(80)"
    with column 1 page-top no-labels top-only row 2 width 81 no-hide frame fc2
        no-box color blue/cyan overlay.

find first func where func.funcod = sfuncod and
                      func.etbcod = 999      no-lock no-error.
if avail func
then 
    display wempre.emprazsoc + "/" + estab.etbnom + "-" + 
        func.funnom @ wempre.emprazsoc
            wdata with frame fc1.
else
    display wempre.emprazsoc + "/" + estab.etbnom  @ wempre.emprazsoc
            wdata with frame fc1.

display wtitulo                with frame fc2.

status input "Digite os dados ou pressione [F4] para encerrar.".
if num-entries(sparam,";") > 1
then status default "Verus - Lojas Lebes                     Servidor: "
                + entry(1,sparam,";").
else                
status default "Verus - Lojas Lebes ".

def var senha-segur as char.
def var men-tit like menu.mentit.
if avail menu
then men-tit = menu.mentit.
else men-tit = "".

def buffer bsegur for seguranca.

if not sremoto
then do.

if entry(1,sparam,";") <> "sv-ca-dbr.lebes.com.br"
then
find first seguranca where
           seguranca.empcod = 19 and
           /*seguranca.etbcod = setbcod and
           seguranca.funcod = sfuncod and*/
           seguranca.programa = program-name(1)
           no-lock no-error.
if avail seguranca
then do:
    find first bsegur where
           bsegur.empcod = 19 and
           /*bsegur.etbcod = setbcod and*/
           bsegur.funcod = sfuncod and
           bsegur.programa = program-name(1)
           no-lock no-error.
    if not avail bsegur
    then do:
        message color red/with
        "Usuario " sfuncod " sem permissao de acesso " program-name(1) skip
        men-tit 
        view-as alert-box.
        return.
    end.
    
    repeat :
        senha-segur = "".
        update senha-segur blank  label "Senha" with frame f-senhaseg 1 down
            centered row 7 side-label.
        if senha-segur = ""
        then next.
        if senha-segur <> seguranca.senha and
           senha-segur <> func.senha
        then do:
            message color red/with
                "Senha Invalida.". 
            pause.    
            next.
        end.
        hide frame f-senhaseg no-pause. 
        leave.
    end.            
end.   

end.


if keyfunction(lastkey) = "END-ERROR"
then return.            

FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
         
FUNCTION sel-arq01 returns character .
    
    DEFINE VARIABLE procname AS CHARACTER NO-UNDO.
    DEFINE VARIABLE OKpressed AS LOGICAL INITIAL TRUE.

    def var varquivo as char.
    Main: 
    REPEAT:
        SYSTEM-DIALOG GET-FILE procname
            TITLE      "Selecione o arquivo ..."
            FILTERS   " " "*.*",
                    "txt"  "*.txt", 
                 "csv"  "*.csv"
            MUST-EXIST
            USE-FILENAME
            UPDATE OKpressed.
      
        IF OKpressed = TRUE THEN
            varquivo = procname.
            LEAVE Main.
    END.     
    return varquivo. 
END FUNCTION.


FUNCTION fusohr returns character.
    return SUBSTRING(  STRING(DATETIME-TZ(DATE(STRING(DAY(today),"99") + "/" +
        STRING(MONTH(today),"99") + "/" + STRING(YEAR(today),"9999")), MTIME,
        TIMEZONE)),  24,6).
END FUNCTION.
