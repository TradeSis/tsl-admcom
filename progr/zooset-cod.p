/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : zooset-cod.p
***** Diretorio                    : cadas
***** Autor                        : Caludir Santolin
***** Descri‡ao Abreviada da Funcao: Classificacao de Mercadorias
***** Data de Criacao              : 28/08/2000

                                ALTERACOES
***** 1) Autor     :
***** 1) Descricao : 
***** 1) Data      :

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

{setbrw.i}.
{anset.i}.


def buffer setor for clase.

def var i as int.
def var v-cont      as int.
def var v-procod    like produ.procod.
def buffer bprodu   for produ.

def temp-table ttprodu
    field procod like produ.procod.

def var p-depto     like clase.clacod.
def var p-setor     like clase.clacod.
def var p-clasesup  like clase.clacod.
def var p-clase     like clase.clacod.
def var spclase     like clase.clacod.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-stitcla   as char.
def var vclacod     like clase.clacod.
def var vclacod1    like setor.clacod.

def buffer depto for clase.
def buffer bclase   for clase.
def buffer clasesup for clase.
def buffer bsetor   for setor.
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer iclase   for clase.
def var v-titpro    as char format "x(25)".

form
    setor.clacod
    setor.clanom
    with frame f-setor
        row 10
        overlay 
        down
        no-labels  color /*withe/red*/ yellow/blue
        title v-titgru.

assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

v-titgru = " SETORES ".
    
l1: repeat :

    clear frame f-setor all.
    
    {sklcls.i
        &color = withe
        &color1 = red
        &file       = setor
        &Cfield     = setor.clanom
        &OField     = " setor.clacod " 
        &Where      = " setor.clatipo = yes and
                        setor.clagrau = 1
                      " 
        &AftSelect1 = " frame-value = setor.clacod.
                        do: leave l1. end. 
                      "  
        &OtherKeys1  = " "
        &LockType  = " no-lock "
        &naoexiste1 = " bell.
                       hide frame f-setor no-pause.
                       do: leave l1. end. " 
        &form       = " frame f-setor " 
    }.                

    if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO" 
    then do:
        hide frame f-setor no-pause.
        do:
        leave l1.
        end.
    end.

end.      

hide frame f-setor no-pause.
                            
