
{admcab.i}.
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
    clase.clacod
    clase.clanom
    with frame f-depto
        column 40
        row 8
        overlay 
        down
        no-labels  color /*withe/red*/ yellow/blue
        title " CLASSE ".


         
l0: repeat:
    clear frame f-depto all.
    
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    {sklclstb.i
        &color = withe
        &color1 = red
        &file       = clase
        &Cfield     = clase.clanom
        &OField     = " clase.clacod " 
        &Where      = " clase.clatipo = yes and
                        clase.clagrau = 3
                        use-index iclanom
                      " 
        &AftSelect1 = " frame-value = string(clase.clacod).
                        leave l0. " 
        &LockType  = " no-lock "
        &naoexiste1 = " bell.
                        hide frame f-depto no-pause.
                       leave l0. " 
        &form       = " frame f-depto " 
    }.                

    if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO" 
    then do:
        hide frame f-depto no-pause.
        leave l0.
    end.

end.