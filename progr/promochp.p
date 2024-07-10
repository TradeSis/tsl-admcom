{admcab.i}

def temp-table tt-plani like plani.

def temp-table tt-produ
    field procod like produ.procod.
    
def var vsequencia like ctpromoc.sequencia.
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.

update vsequencia label "Codigo da promocao"
        with frame f1 1 down side-label
        width 80.
        
find ctpromoc where ctpromoc.sequencia = vsequencia and
                    ctpromoc.linha = 0 no-lock no-error.
if not avail ctpromoc 
then do:
    bell.
    message "Promoção não encontrada."
    view-as alert-box
    .
    undo.
end.


def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.

for each ctpromoc where ctpromoc.sequencia = vsequencia and
                        ctpromoc.linha <> 1 no-lock:
    if ctpromoc.procod <> 0
    then do:
        create tt-produ.
        tt-produ.procod = ctpromoc.procod.
    end.
    else if ctpromoc.clacod <> 0
    then do:
        run ver-classe.
    end. 
end.
                           
update vetbcod at 1 label "Filial" with frame f1.

if vetbcod > 0
then find estab where estab.etbcod = vetbcod no-lock.

update vdti at 1 label "Periodo de"
       vdtf label "Ate"
       with frame f1.

def var varquivo as char.

varquivo = "/admcom/relat/promochp." + string(time).

{mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64" 
        &Cond-Var  = "147" 
        &Page-Line = "64" 
        &Nom-Rel   = ""promochp""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """  """ 
        &Width     = "100"
        &Form      = "frame f-cabcab"}
 
disp with frame f1.
def var va as int.
def var num-ok as log.

for each titulo where titulo.empcod = 19
                  and titulo.titnat = yes
                  and titulo.modcod = "CHP"
                  and titulo.etbcod = 999
                  and titulo.clifor = 110165
                  and titulo.titdtven >= vdti 
                  and titulo.titdtven <= vdtf
                  no-lock,
    first plani where
          plani.etbcod = int(acha("ETBCODVENDACHP",titulo.titobs[1])) and
          plani.placod = int(acha("PLACODVENDACHP",titulo.titobs[1])) and
          plani.serie  = acha("SERIEVENDACHP",titulo.titobs[1])
          no-lock break by plani.etbcod by plani.pladat.
                           

    if titulo.titnumger = ""
         or titulo.titnumger <> string(vsequencia)
    then do:
        num-ok = no.
        if plani.usercod <> ""
        then do:
            do va = 1 to num-entries(plani.usercod,";"):
                if trim(entry(va,plani.usercod,";")) = string(vsequencia)
                then do:
                    num-ok = yes.
                    leave.
                end.
            end.
        end.
        if num-ok = no
        then do:
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
                find first tt-produ where
                           tt-produ.procod = movim.procod
                           no-lock no-error.
                if avail tt-produ
                then num-ok = yes.           
            end.         
            if num-ok = no
            then next.
        end.
    end.

    if vetbcod > 0 and
       plani.etbcod <> vetbcod
    then next.    
         
    disp plani.etbcod
         titulo.titnum
         plani.pladat /*titulo.titdtemi*/
         plani.numero format ">>>>>>>>9"
         titulo.titvlcob(total by plani.etbcod)
         with frame f-disp down.
end.     
output close.

if opsys = "UNIX"
then do:
    run visurel.p(input varquivo, input "").
end.
else do:
    {mrod.i}.
end.     

procedure ver-classe:
    find clase where clase.clacod = ctpromoc.clacod no-lock no-error.
    if avail clase 
    then do:
        if clase.clagrau = 4
        then do:
            for each produ where
                     produ.clacod = clase.clacod
                     no-lock:
                create tt-produ.
                tt-produ.procod = produ.procod.
            end.             
        end.
        else do:
            for each bclase where
                     bclase.clasup = clase.clacod no-lock:
                if bclase.clagrau = 4
                then do:
                    for each produ where
                        produ.clacod = bclase.clacod
                        no-lock:
                        create tt-produ.
                        tt-produ.procod = produ.procod.
                    end.
                end. 
                else do:
                    for each cclase where
                             cclase.clasup = bclase.clacod no-lock:
                        if cclase.clagrau = 4
                        then do:
                            for each produ where
                                produ.clacod = cclase.clacod
                                no-lock:
                                create tt-produ.
                                tt-produ.procod = produ.procod.
                            end.
                        end. 
                        else do:
                            for each dclase where
                                     dclase.clasup = cclase.clacod no-lock:
                                if dclase.clagrau = 4
                                then do:
                                    for each produ where
                                        produ.clacod = dclase.clacod
                                        no-lock:            
                                        create tt-produ.
                                        tt-produ.procod = produ.procod.
                                    end.
                                end.
                            end.
                        end. 
                     end.         
                end.
            end.         
        end.
    end.
end procedure.

/****
procedure ver-classe:
    find clase where clase.clacod = ctpromoc.clacod no-lock no-error.
    if avail clase 
    then do:
        if clase.clagrau = 4
        then do:
            for each produ where
                     produ.clacod = clase.clacod
                     no-lock:
                create tt-produ.
                tt-produ.procod = produ.procod.
            end.             
        end.
        else do:
            for each bclase where
                     bclase.clasup = clase.clacod no-lock:
                if bclase.clagrau = 4
                then do:
                    for each produ where
                        produ.clacod = bclase.clacod
                        no-lock:
                        create tt-produ.
                        tt-produ.procod = produ.procod.
                    end.
                end. 
                else do:
                    for each cclase where
                             cclase.clasup = bclase.clacod no-lock:
                        if cclase.clagrau = 4
                        then do:
                            for each produ where
                                produ.clacod = cclase.clacod
                                no-lock:
                                create tt-produ.
                                tt-produ.procod = produ.procod.
                            end.
                        end. 
                    end.         
                end.
            end.         
        end.
    end.
end procedure.
*****************/
