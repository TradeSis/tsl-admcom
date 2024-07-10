{admcab.i new}
                                
def new shared temp-table tt-menu like ger.menu.
def new shared temp-table lj-menu like ger.menu.
def new shared temp-table mt-menu like ger.menu.

def temp-table dif-menu
    field etbcod      like ger.estab.etbcod
    field aplicod-ori like ger.menu.aplicod
    field menniv-ori  like ger.menu.menniv
    field ordsup-ori  like ger.menu.ordsup
    field menord-ori  like ger.menu.menord
    field mentit-ori  like ger.menu.mentit
    field menpro-ori  like ger.menu.menpro
    field aplicod-des like ger.menu.aplicod
    field menniv-des  like ger.menu.menniv
    field ordsup-des  like ger.menu.ordsup
    field menord-des  like ger.menu.menord
    field mentit-des  like ger.menu.mentit
    field menpro-des  like ger.menu.menpro
    .
    
def buffer bestab for ger.estab.

def var vdesnom as char init "FILIAL".
def var vetbcod like ger.estab.etbcod.
def var detbcod like ger.estab.etbcod.
def var cetbcod like ger.estab.etbcod.

update  vetbcod label "Filial REFERENCIA" 
        with frame f-1 side-label width 80.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f-1.        
update detbcod at 1 label "Filial REPLICAR de "
       cetbcod label "Ate " with frame f-1.
if detbcod > 0
then .
else return.
/*do:
find bestab where bestab.etbcod = detbcod no-lock.
disp bestab.etbnom no-label with frame f-1.
end.
else disp "Geral" @ bestab.etbnom with frame f-1.
*/
def var vip as char.
def var vstatus as char.
def var vcon as int.
def buffer cestab for estab.

form with frame f-4.
for each cestab where cestab.etbcod = vetbcod 
                        NO-LOCK:
    vip = "".       
    vcon = 0.                 
    repeat:
        vcon = vcon + 1.
        vip = "FILIAL" + string(cestab.etbcod,"999").
        
        if connected ("gerloja")
        then disconnect gerloja.    
                 
        pause 0.
        message "Conectando..." vip.
  
        connect ger -H value(vip) -S sdrebger -N tcp 
                                    -ld gerloja   no-error.
    
        display vip no-label format "x(20)"
                with frame f-4 down width 
                60 row 8 centered color white/red.
                    
        if not connected ("gerloja")
        then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-4.
                if vcon = 3
                then leave.
                undo, retry.    
        end.

        run ficonfme01.p ( input "REF", input cestab.etbcod, output vstatus ).
        
        display vstatus  label "STATUS" with frame f-4.
        
        if connected ("gerloja")
        then disconnect gerloja.    
        
        leave.
   end.
end.

hide frame f-3 .

for each cestab where /*(if detbcod > 0
                       then cestab.etbcod = detbcod else true) and*/
                       cestab.etbnom begins "DREBES-FIL"
                        NO-LOCK:
    
    if cestab.etbcod = vetbcod
    then next.
    
    if cestab.etbcod < detbcod or
       cestab.etbcod > cetbcod
    then next.
    vip = "".       
    vcon = 0.                 
    repeat:
        vcon = vcon + 1.
        vip = "FILIAL" + string(cestab.etbcod,"999").
        
        if connected ("gerloja")
        then disconnect gerloja.    
                 
        pause 0.
        message "Conectando..." vip.
  
        connect ger -H value(vip) -S sdrebger -N tcp 
                                    -ld gerloja   no-error.
    
        display vip no-label format "x(20)"
                with frame f-4 down width 
                60 row 8 centered color white/red.
                    
        if not connected ("gerloja")
        then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-4.
                if vcon = 5
                then leave.
                undo, retry.    
        end.
        /* "REP" */
        run ficonfme01.p (input "CFE", input cestab.etbcod, output vstatus ).
        
        display vstatus  label "STATUS" with frame f-4.
        
        if connected ("gerloja")
        then disconnect gerloja.    
        
        leave.
    end.

    for each mt-menu no-lock:
        create dif-menu.
        assign
            dif-menu.etbcod = cestab.etbcod
            dif-menu.aplicod-ori = mt-menu.aplicod
            dif-menu.menniv-ori  = mt-menu.menniv
            dif-menu.ordsup-ori  = mt-menu.ordsup
            dif-menu.menord-ori  = mt-menu.menord
            dif-menu.mentit-ori  = mt-menu.mentit
            dif-menu.menpro-ori  = mt-menu.menpro
            .
    end.    
    for each lj-menu no-lock:
        find first dif-menu where
                   dif-menu.etbcod = cestab.etbcod        and
                   dif-menu.aplicod-ori = lj-menu.aplicod and
                   dif-menu.menniv-ori  = lj-menu.menniv  and
                   dif-menu.ordsup-ori  = lj-menu.ordsup  and
                   dif-menu.menord-ori  = lj-menu.menord
                   no-error.
        if avail dif-menu
        then assign
                dif-menu.aplicod-des = lj-menu.aplicod
                dif-menu.menniv-des  = lj-menu.menniv
                dif-menu.ordsup-des  = lj-menu.ordsup
                dif-menu.menord-des  = lj-menu.menord
                dif-menu.mentit-des  = lj-menu.mentit
                dif-menu.menpro-des  = lj-menu.menpro
                .
        else do:
            create dif-menu.
            assign
                dif-menu.etbcod = cestab.etbcod
                dif-menu.aplicod-ori = lj-menu.aplicod
                dif-menu.menniv-ori  = lj-menu.menniv
                dif-menu.ordsup-ori  = lj-menu.ordsup
                dif-menu.menord-ori  = lj-menu.menord
                dif-menu.mentit-ori  = lj-menu.mentit
                dif-menu.menpro-ori  = lj-menu.menpro
                .
        end.
    end.
    for each mt-menu: delete mt-menu. end.
    for each lj-menu: delete lj-menu. end.
end.

def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/ficonfme." + string(time).
    else varquivo = "..~\relat~\ficonfme." + string(time).
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""ficonfme""
                &Nom-Sis   = """""""" 
                &Tit-Rel   = """ CONFERENCIA DE MENU """ 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

disp with frame f-1.
for each estab /*where
        (if detbcod > 0
         then estab.etbcod = detbcod else true)*/
          no-lock:
    if estab.etbcod < detbcod or
       estab.etbcod > cetbcod
    then next.   
    disp estab.etbcod column-label "Fil"
            with frame f-disp width 120.
    for each dif-menu where
             dif-menu.etbcod = estab.etbcod
             no-lock:
        disp dif-menu.mentit-ori column-label "Referencia" 
             dif-menu.menpro-ori column-label "Programa"
             dif-menu.mentit-des column-label "Filial"
             dif-menu.menpro-des column-label "Programa"
             with frame f-disp down.
        down with frame f-disp.        
    end.
    put skip(1)
        fill("=",80) format "x(80)"
        skip(1). 
end. 
output close.
    
    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"") .
    end.
    else do:
        {mrod.i}
    end.

            
