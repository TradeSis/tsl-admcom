{admcab.i}

def var vdesc like produ.pronom extent 7.
def var valiq like produ.proipiper.
def var vdti as date.
def var vdtf as date.
def var vpcod like produ.procod.
def var valicms like movim.movalicms.
def var vali as char.
def var vetb like estab.etbcod.

update vetb at 1  label "Filial      "
        with frame f1.
if vetb > 0
then do:
    find estab where estab.etbcod = vetb no-lock no-error.
    if not avail estab
    then do:
        bell.
        message "Filial nao cadastrada."
            view-as alert-box.
        undo.    
    end.
    disp estab.etbnom no-label with frame f1. 
end.        
update    vpcod    at 1 label "Codigo      "
    with frame f1.
    if vpcod = 0
    then update
       vdesc[1] at 1 label "Descricao 01"
       vdesc[2] at 1 label "          02"
       vdesc[3] at 1 label "          03"
       vdesc[4] at 1 label "          04"
       vdesc[5] at 1 label "          05"
       vdesc[6] at 1 label "          06"
       vdesc[7] at 1 label "          07"
       with frame f1.

update valiq    at 1 label "Aliquota    "
       vdti     at 1 label "Periodo de  " format "99/99/9999"
       vdtf  label "Ate" format "99/99/9999"
              with frame f1 1 down side-label width 80.

def temp-table tt-rel
    field pladat like plani.pladat
    field numero like plani.numero 
    field etbcod like plani.etbcod 
    field procod like produ.procod 
    field movqtm like movim.movqtm 
    field movpc  like movim.movpc  
    field movalicms like movim.movalicms
    index i1 pladat etbcod  numero procod
    .
               
def buffer bestab for estab.
def var vi as int.
def stream stela.
form with frame fffpla.
sresp = no.
message "Confirma gerar relatorio? " update sresp.
if not sresp 
then undo.
else do:              
    def var varquivo as char.
    for each tt-rel.
        delete tt-rel.
    end.    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rmovicms." + string(time).
    else varquivo = "l:\relat\rmovicms." + string(time).

    output stream stela to terminal.
    
    if vpcod = 0 and vdesc[1] <> ""
    then do vi = 1 to 7:
        if vdesc[vi] = ""
        then next.
        for each produ where
            produ.pronom begins vdesc[vi]
            no-lock:
            disp stream stela produ.procod
                               produ.pronom
                               with frame fffpla centered color message
                               no-box row 16 no-label.
            pause 0.
            for each bestab where
                    if vetb > 0 then bestab.etbcod = vetb else true
                    no-lock:
            for each movim where 
                     movim.etbcod = bestab.etbcod and
                     movim.movtdc = 5 and
                     movim.procod = produ.procod and
                     movim.movdat >= vdti and
                     movim.movdat <= vdtf
                     no-lock:
                find plani where plani.etbcod = movim.etbcod and
                                 plani.placod = movim.placod and
                                 plani.movtdc = movim.movtdc and
                                 plani.pladat = movim.movdat
                                 no-lock no-error.
                if not avail plani then next.
                disp stream stela plani.pladat
                               with frame fffpla.
                pause 0.

                run alicms.

                valicms = 0.
                if vali = "01"
                then valicms = 17.
                else if vali = "02"
                    then valicms = 12.
                    else if vali = "03"
                        then valicms = 7.
                        else if vali = "04"
                            then valicms = 25.
                            else if vali = "FF"
                                then. 
                                else next.

                if valiq <> 0 and valicms <> valiq
                then next.
                find first tt-rel where
                           tt-rel.pladat = plani.pladat and
                           tt-rel.etbcod = plani.etbcod and
                           tt-rel.numero = plani.numero and
                           tt-rel.procod = movim.procod
                           no-lock no-error.
                if not avail tt-rel
                then do:           
                create tt-rel.
                assign
                    tt-rel.pladat = plani.pladat
                    tt-rel.numero = plani.numero 
                    tt-rel.etbcod = plani.etbcod 
                    tt-rel.procod = produ.procod 
                    tt-rel.movqtm = movim.movqtm 
                    tt-rel.movpc  = movim.movpc  
                    tt-rel.movalicms = valicms
                    .
                end.
            end.
            end.
        end.
    end.
    else if vpcod <> 0
    then do:
        for each produ where  produ.procod = vpcod
             no-lock:
            for each bestab where
                    if vetb > 0 then bestab.etbcod = vetb else true
                    no-lock:
            for each movim where 
                     movim.etbcod = bestab.etbcod and
                     movim.movtdc = 5 and
                     movim.procod = produ.procod and
                     movim.movdat >= vdti and
                     movim.movdat <= vdtf
                     no-lock:
                find plani where plani.etbcod = movim.etbcod and
                                 plani.placod = movim.placod and
                                 plani.movtdc = movim.movtdc and
                                 plani.pladat = movim.movdat
                                 no-lock no-error.
                if not avail plani then next.
                disp stream stela plani.pladat
                               with frame fffpla.
                pause 0.
                run alicms.
                
                valicms = 0.
                if vali = "01"
                then valicms = 17.
                else if vali = "02"
                    then valicms = 12.
                    else if vali = "03"
                        then valicms = 7.
                        else if vali = "04"
                            then valicms = 25.
                            else if vali = "FF"
                                then. 
                                else next.

                if valiq <> 0 and valicms <> valiq
                then next.
                find first tt-rel where
                           tt-rel.pladat = plani.pladat and
                           tt-rel.etbcod = plani.etbcod and
                           tt-rel.numero = plani.numero and
                           tt-rel.procod = movim.procod
                           no-lock no-error.
                if not avail tt-rel
                then do: 
                create tt-rel.
                assign
                    tt-rel.pladat = plani.pladat
                    tt-rel.numero = plani.numero 
                    tt-rel.etbcod = plani.etbcod 
                    tt-rel.procod = produ.procod 
                    tt-rel.movqtm = movim.movqtm 
                    tt-rel.movpc  = movim.movpc  
                    tt-rel.movalicms = valicms
                    .
                end.
            end.
            end.
        end.
    end.
    find first tt-rel no-error.
    if not avail tt-rel
    then return.
    
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "64"
            &Nom-Rel   = ""rproaliq""
            &Nom-Sis   = """ """
            &Tit-Rel   = """ """
            &Width     = "130"
            &Form      = "frame f-cabcab"}
     
     disp with frame f1.
     for each tt-rel no-lock:
        find produ where produ.procod = tt-rel.procod no-lock.
        disp tt-rel.pladat
             tt-rel.numero format ">>>>>>>9"
             tt-rel.etbcod 
             tt-rel.procod format ">>>>>>>9"
             produ.pronom format "x(30)"
             tt-rel.movqtm format ">>9" column-label "Qtd."
             tt-rel.movpc  format ">,>>9.99"  
                                column-label "Val.!Unitario" 
             tt-rel.movqtm * tt-rel.movpc (total)column-label "Total"
                                format ">,>>>,>>9.99"
             tt-rel.movalicms      
             (tt-rel.movpc * tt-rel.movqtm) * (tt-rel.movalicms / 100) (total) 
                     format ">>>,>>9.99" column-label "ICMS"
              produ.proclafis
              with frame f2 down width 140.
 
    end.
    output stream stela close.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.
return.

procedure alicms:
    def var ve like setbcod.
    def var vc like scxacod.
    def var vetbcod like estab.etbcod.
    def var vcxacod like caixa.cxacod.
    def var vok as log init no.
    vetbcod = plani.etbcod.
    vcxacod = plani.cxacod.
    vali = "".
    vok = no.
        if plani.crecod = 2
        then do:
        
            vali = "0".
            vok = no.
            if search("../import/tabecf.txt") <> ?
            then do on error undo:
                input from ../import/tabecf.txt no-echo.
                repeat:
                    import ve
                           vc.

                    if setbcod = ve and
                       scxacod = vc
                    then do:

                        if produ.proipiper = 12.00 or
                           produ.pronom begins "Computa"
                        then vali = "01".
                        else if produ.pronom begins "Pneu" or
                                produ.proipiper = 99
                             then vali = "FF".
                             else vali = "01".
                        if produ.proseq = 1
                        then vali = "03".
                        if produ.proseq = 3 and
                           plani.pladat < 04/11/08
                        then vali = "03".    
                        vok = yes.
                    end.
                    else do:
                        if not vok
                        then do:
                            if produ.proipiper = 12.00 or
                               produ.pronom begins "Computa"
                            then vali = "FF".
                            else if produ.pronom begins "Pneu" or
                                    produ.proipiper = 999
                                 then vali = "FF".
                                 else vali = "01".
                            
                            if produ.proseq = 1
                            then vali = "03".
                            if  produ.proseq = 3 and
                                plani.pladat < 04/11/08
                            then vali = "03". 
                        end.
                    end.
                end.
            end.
            else do:
                if produ.proipiper = 12.00 or
                   produ.pronom begins "Computa"
                then vali = "FF".
                else if produ.pronom begins "Pneu" or
                        produ.proipiper = 999
                     then vali = "FF".
                     else vali = "01".
  
                if produ.proseq = 1
                then vali = "03".
                if produ.proseq = 3 and
                   plani.pladat < 04/11/08
                then vali = "03". 
            end.
        end.

end procedure.    




