{admcab.i}

def var varquivo    as char format "X(20)". 
def buffer aclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.

sresp = yes.
message "Gerar Listagem de Classes" update sresp.
if not sresp then leave.

varquivo = "l:\relat\list-classes" + string(time).


    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "64"
        &Nom-Rel   = ""listcla9""
        &Nom-Sis   = """ """
        &Tit-Rel   = """LISTAGEM DE CLASSES """
        &Width     = "135"
        &Form      = "frame f-cab"}


for each aclase where aclase.clasup = 0 no-lock.

    put skip(1) aclase.clacod space(3) aclase.clanom skip.
    
    for each bclase where bclase.clasup = aclase.clacod no-lock.

        put space(10) bclase.clacod space(3) bclase.clanom skip.
        
        for each cclase where cclase.clasup = bclase.clacod no-lock.

            put space(20) cclase.clacod space(3) cclase.clanom skip.

            for each dclase where dclase.clasup = cclase.clacod no-lock.

                put space(30) dclase.clacod space(3) dclase.clanom skip.
                
                for each eclase where eclase.clasup = dclase.clacod no-lock.

                    put space(40) eclase.clacod space(3) eclase.clanom skip.
                    
                    for each fclase where fclase.clasup = eclase.clacod no-lock.

                        put space(50) fclase.clacod space(3) fclase.clanom 
                        skip.
                                                   
                                                   
end. end. end. end. end. end.

output close.

{mrod.i}.
