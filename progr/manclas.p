/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : zooclase.p
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

{admcab.i new}.
{setbrw.i}.
{anset.i}.


def buffer setor for clase.

def var i as int.
def var v-cont      as int.
def var v-procod    like produ.procod.
def buffer bprodu   for produ.

def temp-table ttprodu
    field procod like produ.procod.

def var p-setor     like clase.clacod.
def var p-clasesup  like clase.clacod.
def var p-clase     like clase.clacod.
def var spclase     like clase.clacod.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-stitcla   as char.
def var vclacod     like clase.clacod.
def var vclacod1    like setor.clacod.

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
        row 5
        overlay 
        down
        no-labels  color /*withe/red*/ yellow/blue
        title " SETORES ".

form
    clasesup.clacod
    clasesup.clanome
    with frame f-clasesup
        column 15 
        row 6
        overlay
        down
        no-labels  color /*withe/brown*/ yellow/blue
        title v-titgru.

form
    clase.clacod
    clase.clanome
    with frame f-clase
        column 30
        row  7
        overlay
        down
        no-labels  color /*withe/green*/ yellow/blue
        title v-titcla.
 
form
    sclase.clacod
    sclase.clanome
    with frame f-sclase
        column 45
        row  8
        overlay
        down
        no-labels   color /*withe/cyan*/ yellow/blue
        title v-stitcla.

l1: repeat :

    clear frame f-setor all.
    
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    {sklcls.i
        &color = withe
        &color1 = red
        &file       = setor
        &Cfield     = setor.clanom
        &OField     = " setor.clacod " 
        &Where      = " setor.clatipo = yes and
                        setor.clasup = 0
                      " 
        &AftSelect1 = " frame-value = setor.clacod.
                        p-setor = setor.clacod.
                        leave keys-loop. " 
        &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" 
                         then run p-comumset. "
        &LockType  = " no-lock "
        &naoexiste1 = " bell.
        /***
                       message color red/withe
                            ""Nenhum registro encontrado""
                            view-as alert-box title "" Mensagem "" .
        ***/                            
                       hide frame f-setor no-pause.
                       leave l1. " 
        &form       = " frame f-setor " 
    }.                

    if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO" 
    then do:
        hide frame f-setor no-pause.
        leave l1.
    end.

    view frame f-setor.
    pause 0.
    find first setor where setor.clacod = p-setor no-lock.
    v-titgru = "GRUPOS - SETOR " + 
            string(setor.clanom).
    l2: repeat :
        clear frame f-clasesup all.
        hide frame f-clasesup.
        clear frame f-clase all.
        hide frame f-clase.
        
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.
            
        {sklcls.i
            &color = withe/brown
            &file       = clasesup
            &CField     = clasesup.clanome
            &OField     = "clasesup.clacod" 
            &Where      = " clasesup.clasup = p-setor
                           " 
            &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then run p-comumsup. "
            &naoexiste1 = " bell.
            /***
                       message color red/withe
                            ""Nenhum registro encontrado""
                            view-as alert-box title "" Menssagem "".
            ***/                            
                       hide frame f-setor no-pause.
                       hide frame f-clasesup no-pause.
                       leave l1.                            
                       "
            &AftSelect1 = " p-clasesup = clasesup.clacod .
                            frame-value = clasesup.clacod.
                            leave keys-loop. " 
            &Form       = " frame f-clasesup " 
        }.
        if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO"
        then do:
            hide frame f-clasesup no-pause.
            leave l2.
        end.
        
        view frame f-clasesup.
        pause 0.
        find first clasesup where clasesup.clacod = p-clasesup no-lock.
        v-titcla = "CLASSES - GRUPO " + string(clasesup.clanome).
        l3: repeat :
            clear frame f-sclase all. hide frame f-sclase.
            assign
                a-seeid = -1
                a-recid = -1
                a-seerec = ?.
            
            {sklcls.i
                &color      = withe/green
                &file       = clase
                &CField     = clase.clanome
                &OField     = "clase.clacod
                              " 
                &Where      = " clase.clasup = p-clasesup" 
                &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then 
                        run p-comumcla. "
                &naoexiste1 = " 
                       bell.
                       /***
                       message color red/withe
                            ""Nenhum registro encontrado""
                            view-as alert-box title "" Mensagem "" .
                       ***/                             
                        hide frame f-setor no-pause.
                        hide frame f-clasesup no-pause.
                        hide frame f-clase no-pause.
                        leave l1.                       
                        " 
                &AftSelect1 = " frame-value = clase.clacod.
                                p-clase = clase.clacod.
                                leave keys-loop." 
                &Form       = "frame f-clase" 
           }.      
            if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO"            then do:
                hide frame f-lase no-pause.
                leave l3.
            end.

            view frame f-clase.
            pause 0.
            find first clase where clase.clacod = p-clase no-lock.
            v-stitcla = "SUBCLASSES - " + string(clase.clanome).
        
            l4: repeat :
                clear frame f-produ all. hide frame f-produ.
                clear frame f-sclase all. hide frame f-sclase.
                
                assign a-seeid = -1 a-recid = -1 a-seerec = ?.
            
                {sklcls.i
                    &color      = withe/cyan
                    &file       = sclase
                    &CField     = sclase.clanome
                    &OField     = "sclase.clacod" 
                    &Where      = "sclase.clasup  = p-clase" 
                    &naoexiste1 = " bell.
                    /***
                                message color red/withe
                                      ""Nenum registro encontrado""
                                      view-as alert-box title "" Menssagem "".
                    ***/                                      
                                  hide frame f-setor no-pause.
                                   hide frame f-sclase. 
                                   leave l1.
                                    " 
                    &AftSelect1 = " frame-value = sclase.clacod.
                                    leave l1. " 
                    &Form       = "frame f-sclase" 
                }.
                if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO"
                then do:
                    hide frame f-sclase no-pause.
                    leave l4.
                end.
            end.
        end.   
    end.  
end.      

/***message frame-value view-as alert-box.***/
hide frame f-sclase no-pause.
hide frame f-clase no-pause.
hide frame f-clasesup no-pause.
hide frame f-setor no-pause.
                            
procedure p-comumset.
/***message 1 view-as alert-box.***/
    frame-value = setor.clacod.
    p-setor = setor.clacod.
    
end procedure.

procedure p-comumsup.
/***message 2 view-as alert-box.***/
    frame-value = clasesup.clacod.
    p-setor = clasesup.clacod.
    
end procedure.

procedure p-comumcla.
/***message 3 view-as alert-box.***/
    frame-value = clase.clacod.
    p-setor = clase.clacod.
    
end procedure.
