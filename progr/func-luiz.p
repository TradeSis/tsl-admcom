{admcab.i}

def var vcla-sup like clase.clacod.
def input  parameter vprocod like produ.procod.
def output parameter par-cla like clase.clacod.


def var vclacod like clase.clacod.

def new shared temp-table tclase
    field clacod like clase.clacod
    field clanom like clase.clanom
    field clasup like clase.clasup
    index iclase is primary unique clacod.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

for each tclase.
    delete tclase.
end.


/* update vprocod with frame fd. */

find produ where produ.procod = vprocod no-lock no-error.



run verif-cla.
run cria-tclase.

/* disp vcla-sup label "Classe" with frame fd. */

/*** browse ***/

par-cla = 0. pause 0.
run tclabrow.p (output par-cla).

/* disp par-cla with frame fd. pause 0. */


/**** Procedures ****/

procedure verif-cla.

find clase where 
     clase.clacod = produ.clacod  no-lock no-error.
if clase.clasup <> 0
then do:
    find bclase where 
         bclase.clacod = clase.clasup no-lock no-error.
    if bclase.clasup <> 0
    then do:
        find cclase where 
             cclase.clacod = bclase.clasup no-lock no-error.
        if cclase.clasup <> 0
        then do:
            find dclase where 
                 dclase.clacod = cclase.clasup no-lock no-error.
            if dclase.clasup <> 0
            then do:
                find eclase where 
                     eclase.clacod = dclase.clasup no-lock no-error.
                if eclase.clasup <> 0
                then do:
                    find fclase where
                         fclase.clacod = eclase.clasup no-lock no-error.
                    if fclase.clasup <> 0
                    then vcla-sup = 0.
                    else vcla-sup = fclase.clacod.
                end.
                else vcla-sup = eclase.clacod.
            end.
            else vcla-sup = dclase.clacod.
        end.
        else vcla-sup = cclase.clacod.
    end.
    else vcla-sup = bclase.clacod.
end.
else vcla-sup = clase.clacod.

end procedure.

procedure cria-tclase.
 
 find clase where clase.clacod = vcla-sup no-lock.
 
 create tclase.
 assign tclase.clacod = clase.clacod
        tclase.clanom = clase.clanom
        tclase.clasup = clase.clasup.
 
 for each clase where clase.clasup = vcla-sup no-lock:
     find tclase where tclase.clacod = clase.clacod no-error. 
     if not avail tclase 
     then do: 
       create tclase. 
       assign tclase.clacod = clase.clacod 
              tclase.clanom = "  " + clase.clanom
              tclase.clasup = clase.clasup.
     end.
     
     for each bclase where bclase.clasup = clase.clacod no-lock: 
           find tclase where tclase.clacod = bclase.clacod no-error. 
           if not avail tclase 
           then do: 
             create tclase. 
             assign tclase.clacod = bclase.clacod 
                    tclase.clanom = "    " + bclase.clanom
                    tclase.clasup = bclase.clasup.
           end.
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
               find tclase where tclase.clacod = cclase.clacod no-error. 
               if not avail tclase 
               then do: 
                 create tclase. 
                 assign tclase.clacod = cclase.clacod 
                        tclase.clanom = "      " + cclase.clanom
                        tclase.clasup = cclase.clasup.
               end.                          
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                   find tclase where tclase.clacod = dclase.clacod no-error.
                   if not avail tclase 
                   then do: 
                     create tclase. 
                     assign tclase.clacod = dclase.clacod 
                            tclase.clanom = "        " + dclase.clanom
                            tclase.clasup = dclase.clasup. 
                   end.       
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                       find tclase where tclase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tclase 
                       then do: 
                         create tclase. 
                         assign tclase.clacod = eclase.clacod 
                                tclase.clanom = "          " + eclase.clanom
                                tclase.clasup = eclase.clasup.
                       end.
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                           find tclase where tclase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tclase 
                           then do: 
                             create tclase. 
                             assign tclase.clacod = fclase.clacod 
                                    tclase.clanom = 
                                        "            " + fclase.clanom
                                    tclase.clasup = fclase.clasup.
                           end.
                       end.
                   end.
               end.
           end.                                  
     end.
 end.
end procedure.
