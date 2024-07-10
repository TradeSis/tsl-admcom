/*----------------------------------------------------------------------------*/
/* /usr/admger/cab.i                           Cabecalho Geral das Aplicacoes */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
def {1} shared variable wdata as date format "99/99/9999"
                      label "Data de Processamento".
def {1} shared variable wtittela as char format "x(30)".
def {1} shared buffer wempre for ger.empre.
def {1} shared variable wmodulo as c.
def {1} shared variable wareasis as char format "x(38)".
def {1} shared variable wtitulo  as char format "x(80)".
def {1} shared variable sfuncod  like ger.func.funcod.
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
def new global shared var setbcod    like ger.estab.etbcod.
def new global shared var scxacod    like ger.estab.etbcod.
def new global shared var scliente   like ger.admcom.cliente.
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

/*def new global shared var sPROGRAMA  like PROGRAMA.PROGRAMA. */

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

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

find ger.estab where ger.estab.etbcod = setbcod no-lock.

form space(1)
    wempre.emprazsoc format "x(65)" 
    wdata
    with column 1 page-top no-labels top-only row 1 width 81 no-hide frame fc1
        no-box color black/gray.

form
    wtitulo          format "x(80)"
    with column 1 page-top no-labels top-only row 2 width 81 no-hide frame fc2
        no-box color blue/cyan overlay.


find first ger.func where func.funcod = sfuncod and
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
status default "CUSTOM Business Solutions              - F5 -> Solicitacoes".


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

/***
FUNCTION venda-liquida-item return decimal
    (input rec-movim as recid).
    def var val_fin as dec init 0.
    def var val_des as dec init 0.
    def var val_dev as dec init 0.
    def var val_acr as dec init 0.
    def var val_com as dec init 0.
    assign
        val_fin = 0                   
        val_des = 0   
        val_dev = 0   
        val_acr = 0
        val_com = 0. 
                         
    find movim where recid(movim) = rec-movim no-lock no-error.
    if avail movim
    then do:
        find first plani where plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat
                           no-lock no-error.
        if avail plani
        then do:                       
            
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
            if val_acr = ? then val_acr = 0.
            
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
            if val_des = ? then val_des = 0.
        
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
            if val_dev = ? then val_dev = 0.
        
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then val_fin =  
                ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                         / (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            
            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
                        val_acr +  val_fin. 

            if val_com = ? then val_com = 0.
             
        end.
    end.
    return val_com.
END FUNCTION.
**/

