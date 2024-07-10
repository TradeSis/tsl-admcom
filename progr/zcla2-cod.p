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
    depto.clacod
    depto.clanom
    with frame f-depto
        row 10
        overlay 
        down
        no-labels  color /*withe/red*/ yellow/blue
        title " SETORES ".


form
    setor.clacod
    setor.clanom
    with frame f-setor
        row 10
        overlay 
        down
        no-labels  color /*withe/red*/ yellow/blue
        title " SETORES ".

form
    clasesup.clacod
    clasesup.clanome
    with frame f-clasesup
        column 15 
        row 10
        overlay
        down
        no-labels  color /*withe/brown*/ yellow/blue
        title v-titgru.

form
    sclase.clacod
    sclase.clanome  format "x(20)"
    with frame f-sclase
        column 45
        row  10
        overlay
        down
        no-labels   color /*withe/cyan*/ yellow/blue
        width 35
        title v-stitcla.

form
    clase.clacod
    clase.clanome format "x(20)"
    with frame f-clase
        column 30
        row  10
        overlay
        down
        no-labels  color /*withe/green*/ yellow/blue width 35
        title v-titcla.
         
l0: repeat:
    clear frame f-depto all.
    
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    {sklcls2.i
        &color = withe
        &color1 = red
        &file       = depto
        &Cfield     = depto.clanom
        &OField     = " depto.clacod " 
        &Where      = " depto.clatipo = yes and
                        depto.clasup = 0
                      " 
        &AftSelect1 = " frame-value = ?.
                        p-depto = depto.clacod.
                        leave keys-loop. " 
        &OtherKeys1  = " /*if keyfunction(lastkey) = ""GO"" 
                            then run p-comumset.*/ "
        &LockType  = " no-lock "
        &naoexiste1 = " bell.
        /***
                       message color red/withe
                            ""Nenhum registro encontrado""
                            view-as alert-box title "" Mensagem "" .
        ***/                            
                       hide frame f-depto no-pause.
                       leave l0. " 
        &form       = " frame f-depto " 
        
    }.                
    
    if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO" 
    then do:
        hide frame f-depto no-pause.
        leave l0.
    end.

    view frame f-setor.
    pause 0.
    
    find first depto where depto.clacod = p-depto no-lock no-error.
    v-titgru = "SETOR - " + 
            string(depto.clanom).
 
    l1: repeat :

    clear frame f-setor all.
    
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    {sklcls2.i
        &color = withe
        &color1 = red
        &file       = setor
        &Cfield     = setor.clanom
        &OField     = " setor.clacod " 
        &Where      = " setor.clatipo = yes and
                        setor.clasup = p-depto
                      " 
        &AftSelect1 = " frame-value = setor.clacod.
                        p-setor = setor.clacod.
                        leave keys-loop. " 
        /****************************************************************                &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then run p-comumset. "
        &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then leave l0."
        ****************************************************************/
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
    
    find first setor where setor.clacod = p-setor no-lock no-error.
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
            
        {sklcls2.i
            &color = withe/brown
            &file       = clasesup
            &CField     = clasesup.clanome
            &OField     = "clasesup.clacod" 
            &Where      = " clasesup.clasup = p-setor "
            /*****************************************************      
            &OtherKeys1  = " if keyfunction(lastkey) = ""GO""
                                then run p-comumsup. "
            &OtherKeys1  = " if keyfunction(lastkey) = ""GO""
                                then leave l0. "
            ************************************************ ****/                    
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
        
        find first clasesup where clasesup.clacod = p-clasesup no-lock no-error.
        v-titcla = "CLASSES - GRUPO " + string(clasesup.clanome).
        l3: repeat :
            clear frame f-sclase all. hide frame f-sclase.
            assign
                a-seeid = -1
                a-recid = -1
                a-seerec = ?.
            
            {sklcls2.i
                &color      = withe/green
                &file       = clase
                &CField     = clase.clanome
                &OField     = "clase.clacod
                              " 
                &Where      = " clase.clasup = p-clasesup" 
                
                /****************************************************
                &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then 
                        run p-comumcla. "
                &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then
                        run leave l0. "
                ****************************************************/        
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
            
            find first clase where clase.clacod = p-clase no-lock no-error.
            v-stitcla = "SUBCLASSES - " + string(clase.clanome).
        
            l4: repeat :
                clear frame f-produ all. hide frame f-produ.
                clear frame f-sclase all. hide frame f-sclase.
                
                assign a-seeid = -1 a-recid = -1 a-seerec = ?.
            
                {sklcls2.i
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
                                    leave l0. " 
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
                         
end.

/***message frame-value view-as alert-box.***/

hide frame f-depto no-pause.
hide frame f-sclase no-pause.
hide frame f-clase no-pause.
hide frame f-clasesup no-pause.
hide frame f-setor no-pause.
                            
procedure p-comumset.

/*
message 1 avail setor view-as alert-box.
    frame-value = setor.clacod.
    p-setor = setor.clacod.
message 1.1 view-as alert-box.    

*/
end procedure.

procedure p-comumsup.

/**
message 2 avail clasesup view-as alert-box.
    frame-value = clasesup.clacod.
    p-setor = clasesup.clacod.
message 2.2 view-as alert-box.
*/    
end procedure.

procedure p-comumcla.
/*
message 3 avail clase view-as alert-box.
    frame-value = clase.clacod.
    p-setor = clase.clacod.
message 3.2 view-as alert-box.
*/    
end procedure.
