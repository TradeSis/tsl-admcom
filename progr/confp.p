{admcab.i}

def var vpercdiver as dec format ">>9.99 %".

def var vdiver as log.

def temp-table tt-brinde
    field procod like produ.procod.


def var varq as char.
def temp-table tt-livre
    field procod like produ.procod
    field fincod like finan.fincod
    field preco  like estoq.estvenda.
   
def var vetbcod like estab.etbcod.
def var vdata   like plani.pladat.

def var vent-ven like contrato.vlentra.
def var vent-mov like contrato.vlentra.

def var vfin like finan.finfat.
def var vpre like finan.finnpc.
def var vperc  like estoq.estproper format "->>9.99".
def var totglo like globa.gloval.
def var vvenda like estoq.estvenda.
def var    vqtdcon    as i label "QTD".
def var    vvalcon    as dec label "VALOR".
def var    vqtdconesp as i label "QTD".
def var    vvalconesp as dec label "VALOR".
def buffer btitulo    for titulo.
def buffer bcontrato  for contrato.
def buffer bmovim for movim.
def var wpla like contrato.crecod.
def var vlpres      like plani.platot.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var conta1      as integer.
def var conta2      as integer.
def var conta4      as integer.
def var varquivo as char.
def stream stela.
def temp-table wpreco
    field  wcatcod like produ.procod
    field  wetbcod like estab.etbcod
    field  wnumero like plani.numero format ">>>>>>9"
    field  wserie  like plani.serie
    field  wvencod like plani.vencod
    field  wprocod like produ.procod
    field  wpronom like produ.pronom
    field  wmovpc  like movim.movpc
    field  wvenda  like estoq.estvenda
    field  wvalor  like plani.platot
    field  wdif    like plani.platot
    field  wcrecod like plani.crecod
    field  wprotot like plani.protot
    field  wmovqtm like movim.movqtm.

repeat with 1 down side-label width 80 row 3 color blue/white:
    
    for each tt-livre:
        delete tt-livre.
    end.
    
    for each tt-brinde:
        delete tt-brinde.
    end.
 
    for each wpreco:
        delete wpreco.
    end.
    
    if opsys = "UNIX"
    then input from ../progr/autoriza.txt.
    else input from ..\progr\autoriza.txt.
    
    repeat:
    
        import varq.
                                                        
        find first tt-livre where tt-livre.procod = int(substring(varq,1,6))
                              and tt-livre.fincod = int(substring(varq,7,2))
                                  no-error. 
        if not avail tt-livre 
        then do:
        
            create tt-livre.
            assign tt-livre.procod = int(substring(varq,1,6))
                   tt-livre.fincod = int(substring(varq,7,2))
                   tt-livre.preco  = dec(substring(varq,9,9)).
               
        end.

    
    end.
    input close.
    for each tt-livre.
        find produ where produ.procod = tt-livre.procod no-lock no-error.
        if not avail produ
        then delete tt-livre.
    end.
    
    if opsys = "UNIX"
    then input from ../progr/brinde.txt.
    else input from ..\progr\brinde.txt.
    
    repeat:
        create tt-brinde.
        import tt-brinde.
    end.
    input close.

    for each tt-brinde.

        find produ where produ.procod = tt-brinde.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-brinde.
            next.
        end.
    
    end.    
 
    
    
    update vetbcod label "Filial......." 
           vdata label "Data".

    find estab where estab.etbcod = vetbcod no-lock.

    update skip vpercdiver label "% Divergencia" .

    find first bmovim where bmovim.movdat = vdata no-lock no-error.
    if not avail bmovim
    then leave.

    if opsys = "UNIX"
    then varquivo = "../relat/confp" + string(time).
    else varquivo = "..\relat\confp" + string(time).
    
    {mdad.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""confp""
                &Nom-Sis   = """SISTEMA ESTOQUE FILIAL     versao 3.0"""
                &Tit-Rel   = """LISTAGEM DE DIVERGENCIAS DE PRECOS NO DIA "" +
                             STRING(VDATA,""99/99/9999"") +
                              "" - "" + estab.etbnom + ""  Fone: "" +  
                              string(estab.etbserie,""x(15)"")"
                &Width     = "160"
                &Form      = "frame f-cabcab2"}

    for each plani where plani.movtdc = 5            and
                         plani.etbcod = estab.etbcod and
                         plani.pladat = vdata no-lock:

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movdat = plani.pladat and
                         movim.movtdc = plani.movtdc no-lock:

        output stream stela to terminal.
            disp stream stela movim.procod 
                with 1 down frame ffff. pause 0.
        output stream stela close.

        wpla = 0.
        
        /*if movim.ocnum[5] <> 0 and movim.ocnum[6] <> 0
        then next.*/
        
        find produ of movim no-lock no-error.
        if not avail produ
        then next.
        if produ.procod = 454478 or
           produ.procod = 457331 or
           produ.procod = 401425
        then next.
        
        if produ.pronom begins "*"
        then next.
        
        if produ.clacod = 100 or 
           produ.clacod = 101 or 
           produ.clacod = 102 or 
           produ.clacod = 107 or
           produ.clacod = 190 or 
           produ.clacod = 191 
        then next.          

        find divpre where divpre.etbcod = plani.etbcod
                      and divpre.placod = plani.placod
                      and divpre.procod = movim.procod no-lock no-error.
        if not avail divpre
        then next.
        
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = movim.procod no-lock no-error.
        if not avail estoq
        then next.

        vvenda = ESTOQ.ESTVENDA.
        if estprodat <> ?
        then if estprodat >= VDATA
             then vvenda = estoq.estproper.
             else vvenda = estoq.estvenda.

        wpla = plani.pedcod.
        
        if wpla <> 72 and
           wpla <> 16 and
           wpla <> 73 and
           wpla <> 74 and
           wpla <> 40
        then do:
        
            if vvenda = movim.movpc
            then next.

            if plani.crecod = 1 and 
               estoq.estrep > 0 and 
               estoq.estinvdat >= today and
               estoq.estinvdat <> ?
            then do:
                if movim.movpc >= estoq.estrep    
                then next.
            end.

            if produ.pronom begins "Saldo"
            then next.

            if produ.proabc = "B" 
            then next.
        
            if plani.crecod = 1 and 
               produ.etccod = 2 and
               ( 100 - ((movim.movpc / vvenda) * 100)) <= 54
            then next.

            if (vvenda - movim.movpc) < 1
            then next.



            if produ.etccod = 2 and
              ( 100 - ((movim.movpc / vvenda) * 100)) <= 33 and
              (wpla = 56 or
               wpla = 57)
            then next.

            if produ.etccod = 2 and
               ( 100 - ((movim.movpc / vvenda) * 100)) <= 18 and
               (wpla = 60 or
                wpla = 61)
            then next.
        end.

        find first tt-brinde where tt-brinde.procod = produ.procod  no-error.
        if avail tt-brinde
        then do: 
            if movim.movpc <= 1
            then next.
        end.
        
        find first tt-livre where tt-livre.procod = produ.procod and
                                  tt-livre.fincod = wpla no-error.
        if avail tt-livre
        then do: 
            if vvenda = movim.movpc
            then next.
            
            if tt-livre.preco > 0 
            then do: 
                if tt-livre.preco >= movim.movpc
                then next. 
            end.
            
        end.
         
        vdiver = yes. 
        run p-altpreco3per ( output vdiver ).   
        
        if not vdiver 
        then next.
        
        create wpreco.
        assign wpreco.wcatcod = produ.catcod
               wpreco.wetbcod = plani.etbcod
               wpreco.wnumero = plani.numero
               wpreco.wserie  = plani.serie
               wpreco.wprocod = produ.procod
               wpreco.wpronom = produ.pronom
               wpreco.wmovqtm = movim.movqtm
               wpreco.wmovpc  = movim.movpc
               wpreco.wvenda  = vvenda
               wpreco.wvalor  = (movim.movpc - vvenda)
               wpreco.wdif    = ((movim.movpc / vvenda) - 1) * 100
               wpreco.wcrecod = wpla
               wpreco.wprotot = plani.protot
               wpreco.wvencod = plani.vencod.
    end.
    end.
    
    for each wpreco by wpreco.wcatcod
                    by wpreco.wpronom:

        find produ where produ.procod = wpreco.wprocod no-lock no-error.
        
        if not avail produ
        then next.
        if produ.catcod = 41
        then do:
            if wpreco.wvalor >= 0
            then next.
        end.
        
        vfin = 1.
        vpre = 1.
        vent-ven = 0.
        vent-mov = 0.

        find finan where finan.fincod = wpreco.wcrecod no-lock no-error.
        if avail finan
        then do:
             assign vfin = finan.finfat
                    vpre = finan.finnpc.
             if finan.finent
             then assign vent-ven = wpreco.wvenda * vfin
                         vent-mov = wpreco.wmovpc * vfin.
             else assign vent-ven = 0
                         vent-mov = 0.
        end.

        if vpre = 0
        then assign vpre = 1
                    vent-ven = 0
                    vent-mov = 0.

        if (((wpreco.wmovpc * vfin) * vpre) + vent-mov) -
           (((wpreco.wvenda * vfin) * vpre) + vent-ven) = 0 and
              wpreco.wvalor = 0
        then next.

        if (wpreco.wvenda < wpreco.wmovpc) and
           ( (((wpreco.wvenda * vfin) * vpre) + vent-ven) <
             (((wpreco.wmovpc * vfin) * vpre) + vent-mov) )
        then next.

        find first simil where simil.procod = wpreco.wprocod  no-lock no-error.
        
        if wpreco.wcrecod = 73 and
           wpreco.wvalor >= 0
        then next.
 

        display "*" when avail simil
                wpreco.wnumero   column-label "Numero" format ">>>>>>9"
                wpreco.wserie    column-label "Sr" format "x(02)"
                wpreco.wvencod   column-label "Ven" format ">>9"
                wpreco.wprocod
                wpreco.wpronom   format "x(28)"
                wpreco.wmovqtm   column-label "Qtd" format ">>>9"
                wpreco.wvenda    column-label "Preco!Certo"  format ">>,>>9.99"
                wpreco.wmovpc column-label "Preco!Vendido" format ">>,>>9.99"

                wpreco.wvalor column-label "Difer.!Preco" format "->>,>>9.9"

                ((wpreco.wvenda * vfin) * vpre) + vent-ven
                    column-label "Fin.!Certo" format ">>,>>9.99"
                        when wpreco.wcrecod <> 0
                ((wpreco.wmovpc * vfin) * vpre) + vent-mov
                    column-label "Fin.!Vendido" format ">>,>>9.99"
                        when wpreco.wcrecod <> 0

                (((wpreco.wmovpc * vfin) * vpre) + vent-mov) -
                (((wpreco.wvenda * vfin) * vpre) + vent-ven)
                    column-label "Difer.!Finan." format "->>,>>9.9"
                        when wpreco.wcrecod <> 0
                ( 100 - ((wpreco.wmovpc / wpreco.wvenda) * 100))
                    column-label "Dif%" format "->>9.9"
                   wpreco.wcrecod column-label "Pl"
                "_______________________________"
                    column-label "    J U S T I F I C A T I V A"
                    with no-box width 200.
    end.

    put skip(01).
    
    for each wpreco by wpreco.wcatcod
                    by wpreco.wpronom:
        
        if wpreco.wcrecod = 72 or
           wpreco.wcrecod = 16 or
           wpreco.wcrecod = 73 or
           wpreco.wcrecod = 74 or
           wpreco.wcrecod = 40
        then.
        else next.
        
        find produ where produ.procod = wpreco.wprocod no-lock no-error.
        
        if not avail produ
        then next.
        
        
        if produ.catcod = 41
        then next.
        
        if wpreco.wvalor < 0
        then next.
        
        
        vfin = 1.
        vpre = 1.
        vent-ven = 0.
        vent-mov = 0.

        find finan where finan.fincod = wpreco.wcrecod no-lock no-error.
        if avail finan
        then do:
             assign vfin = finan.finfat
                    vpre = finan.finnpc.
             if finan.finent
             then assign vent-ven = wpreco.wvenda * vfin
                         vent-mov = wpreco.wmovpc * vfin.
             else assign vent-ven = 0
                         vent-mov = 0.
        end.

        if vpre = 0
        then assign vpre = 1
                    vent-ven = 0
                    vent-mov = 0.


        find first simil where simil.procod = wpreco.wprocod no-lock no-error.
                                    
        if wpreco.wcrecod = 73 and
           wpreco.wvalor >= 0
        then next.
        display "*" when avail simil
                wpreco.wnumero   column-label "Numero" format ">>>>>>9"
                wpreco.wserie    column-label "Sr" format "x(02)"
                wpreco.wvencod   column-label "Ven" format ">>9"
                wpreco.wprocod
                wpreco.wpronom   format "x(28)"
                wpreco.wmovqtm   column-label "Qtd" format ">>>9"
                wpreco.wvenda    column-label "Preco!Certo"  format ">>,>>9.99"
                wpreco.wmovpc column-label "Preco!Vendido" format ">>,>>9.99"

                wpreco.wvalor column-label "Difer.!Preco" format "->>,>>9.9"

                ((wpreco.wvenda * vfin) * vpre) + vent-ven
                    column-label "Fin.!Certo" format ">>,>>9.99"
                        when wpreco.wcrecod <> 0
                ((wpreco.wmovpc * vfin) * vpre) + vent-mov
                    column-label "Fin.!Vendido" format ">>,>>9.99"
                        when wpreco.wcrecod <> 0

                (((wpreco.wmovpc * vfin) * vpre) + vent-mov) -
                (((wpreco.wvenda * vfin) * vpre) + vent-ven)
                    column-label "Difer.!Finan." format "->>,>>9.9"
                        when wpreco.wcrecod <> 0
                ( 100 - ((wpreco.wmovpc / wpreco.wvenda) * 100))
                    column-label "Dif%" format "->>9.9"
                   wpreco.wcrecod column-label "Pl"
                "_______________________________"
                    column-label "    J U S T I F I C A T I V A"
                    with no-box width 200.
    end.
    
    
    put skip(7)
        "Data:___/___/___" at 2
        "_______________________________"  at 30 skip
        "           GERENTE             "  at 30.


    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}
    
end.

procedure p-altpreco3per:

    def output parameter p-diver as log.
    def var percentual-altp as dec.
    
    percentual-altp = 0.
    percentual-altp = 
            (((movim.movpc - vvenda) / vvenda ) * 100).

    if percentual-altp < 0
    then percentual-altp = percentual-altp * -1.

    if percentual-altp <= vpercdiver
    then p-diver = no.
    else p-diver = yes.

    if produ.pronom begins "*"
    then p-diver = no.

end procedure.

