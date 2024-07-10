{admcab.i}

update vdtini as date format "99/99/9999" label "Inicial"
       vdtfin as date format "99/99/9999" label "Final"
       with frame fdt 1 down side-label width 80.
def var vindex as int.
def var vesc as char format "x(40)" extent 2.
vesc[1] = "Relatorio de desconto movei/confecção".
vesc[2] = "Relatorio de quantidade por funcionario".
disp vesc with frame fesc 1 down no-label 1 column.
choose field vesc with frame fesc.
vindex = frame-index.

def var sl-catcod like produ.catcod.
    def var sl-valpro as dec.
    def var sl-procod like produ.procod. 
    def var vtotalmov as dec.

def temp-table tt-func
    field clicod like clien.clicod
    field qtd as int.
def temp-table tt-desc
        field catcod like produ.catcod
        field valtotal as dec FORMAT ">>>,>>>,>>9.99"
        field valdesc as dec  format ">>>,>>>,>>9.99".
        
def temp-table tt-titluc like titluc.    
for each titluc where
         titluc.clifor = 110302 and
         titluc.titdtemi >= vdtini and
         titluc.titdtemi <= vdtfin
         no-lock:

    if acha("PROMOCAO",titluc.titobs[1]) = "SOU-LEBES"
    then do:
        create tt-titluc.
        buffer-copy titluc to tt-titluc.
        if  titluc.titnumger <> ""
        then do:
            find first tt-func where
                       tt-func.clicod = int(titluc.titnumger)
                       no-error.
            if not avail tt-func
            then do:
                create tt-func.
                tt-func.clicod = int(titluc.titnumger).
            end.
            tt-func.qtd = tt-func.qtd + 1.           
        end.
        find plani where plani.movtdc = 5 and
                         plani.etbcod = titluc.etbcod and
                         plani.emite = titluc.etbcod and
                         plani.serie = "V" and
                         plani.numero = int(titluc.titnum)
                             no-lock no-error.
        if avail plani
        then do:
            sl-catcod = 0.
            for each movim where 
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock .
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ then next. 
                
                if sl-catcod <> produ.catcod and
                   (sl-catcod = 0 or
                    sl-catcod = 31)
                then do:
                    sl-catcod = produ.catcod.
                    if movim.movpc > sl-valpro and
                         sl-catcod = 31
                    then assign
                             sl-procod = produ.procod
                             sl-valpro = movim.movpc .
                end.
            end.
            if sl-catcod = 31
            then do:
                for each movim where 
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock .
                     find produ where produ.procod = movim.procod
                                        no-lock no-error.
                     if not avail produ then next.
                     find first tt-desc where
                              tt-desc.catcod = 31 no-error.
                     if not avail tt-desc
                     then do:
                         create tt-desc.
                         tt-desc.catcod = 31.
                     end.
                     tt-desc.valtotal = tt-desc.valtotal +
                                (movim.movpc * movim.movqtm).
                    /*if produ.procod = sl-procod
                    then*/
                     
                    tt-desc.valdesc = tt-desc.valdesc +
                                    movim.movdes.
                end.
            end.
            if sl-catcod = 41
            then do:
                for each movim where 
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock .
                     find produ where produ.procod = movim.procod
                                        no-lock no-error.
                     if not avail produ then next.
                     find first tt-desc where
                              tt-desc.catcod = 41 no-error.
                     if not avail tt-desc
                     then do:
                         create tt-desc.
                         tt-desc.catcod = 41.
                     end.
                     tt-desc.valtotal = tt-desc.valtotal +
                                (movim.movpc * movim.movqtm).
                     tt-desc.valdesc = tt-desc.valdesc +
                                    movim.movdes.
                end.
            end.
        end.
    end.
end.

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/soulebes." + string(time).
else varquivo = "l:\relat\soulebes." + string(time).

def var vtitulo as char.
if vindex = 1
then vtitulo = " DESCONTOS SOU LEBES ".
else vtitulo = " INDICACOES SOU LEBES ".
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""soulebes"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = " VTITULO " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

if vindex = 1
then do:
    for each tt-desc:
        disp tt-desc
            with frame f-desc down.
        down with frame f-desc.    
    end.    
end.
else if vindex = 2
then do:
    for each tt-func.
        find clien where clien.clicod = tt-func.clicod 
                    no-lock no-error.
                    
        disp tt-func.clicod column-label "Conta"
             clien.clinom when avail clien
             tt-func.qtd    column-label "Qauntidade"
             with frame f-func down.
        down with frame f-func.     
    end.    
end.    
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
