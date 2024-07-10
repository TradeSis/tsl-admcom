{/admcom/progr/admcab-batch.i}

def output parameter varqsai as char.

def var fila as char.
def var recimp as recid.

def var vopimp as log format "Tela/Impressora".

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

def var ii as i.
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto no-undo.
def var vestven  like estoq.estvenda no-undo.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot decimals 10.
def var v-de like plani.platot decimals 10.
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def var vlcontrato  like fin.contrato.vltotal.
def var vtotal_platot as dec.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.


def temp-table tt-curva no-undo
    field pos    like curfab.pos
    field cod    like curfab.cod
    field valven like curfab.valven 
    field qtdven like curfab.qtdven
    field valcus like curfab.valcus
    field qtdest like curfab.qtdest
    field estcus like curfab.estcus
    field estven like curfab.estven
    field giro   like curfab.giro.

def temp-table tt-catcod
    field catcod like produ.catcod.

def temp-table tt-estab like estab.

def buffer btt-curva for tt-curva.

assign vetbi = 1
       vetbf = 999.

repeat:
    for each tt-catcod:
        delete tt-catcod.
    end.
    vcatcod = 31.
    find categoria where categoria.catcod = vcatcod no-lock.

    if vcatcod = 31
    then do:
        create tt-catcod.
        assign tt-catcod.catcod = 31.
        create tt-catcod.
        assign tt-catcod.catcod = 35.
        create tt-catcod.
        assign tt-catcod.catcod = 50.
    end.
    else do:
        create tt-catcod.
        assign tt-catcod.catcod = 41.
        create tt-catcod.
        assign tt-catcod.catcod = 45.
    end.
    if day(today) = 1
    then do:
        if month(today) = 1
        then vdti = date(12,01,year(today) - 1).
        else vdti = date(month(today) - 1,01,year(today)).
    end.
    else vdti = date(month(today),01,year(today)).
    
    if (year(today - 1) <> year(vdti)) or
     ((month(today - 1) <>  month(vdti)) and 
     (day(today - 1) > day(vdti))) then
        assign vdtf = today.
    else 
        assign vdtf = today - 1.
    
    
    /*
    for each estab where 
             estab.etbnom begiNs "DREBES-FIL"  no-lock:
             create tt-estab.
             buffer-copy estab to tt-estab.
    end.         
    */
    
    for each estab where
             estab.etbcod >=1 and
             estab.etbcod <=999 no-lock:
         create tt-estab.
         buffer-copy estab to tt-estab.
    end.
                                                   

    for each tt-curva:
        delete tt-curva.
    end.
    totcusto = 0.
    totvenda = 0.


    for each tt-catcod no-lock,
        each produ use-index catpro
            where produ.catcod = tt-catcod.catcod no-lock:
        /**
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5            and
                                bmovim.movdat >= vdti        and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.
        **/
        find first tt-curva where tt-curva.cod = produ.fabcod no-error.
        if not avail tt-curva
        then do:
            create tt-curva.
            find last btt-curva no-error.
            if not avail btt-curva
            then tt-curva.pos = 1000000.
            else tt-curva.pos = btt-curva.pos + 1.
            tt-curva.cod = produ.fabcod.
        end.

        vestven = 0.
        vcusto  = 0.
        ii = 0.
        /*
        for each tt-estab no-lock:
            find estoq where estoq.etbcod = tt-estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then do:
                             
                vestven = vestven + (estoq.estatual * estoq.estvenda).
                vcusto  = vcusto  + (estoq.estatual * estoq.estcusto).
                tt-curva.qtdest = tt-curva.qtdest + estoq.estatual.
                
            end.
        end.
        */
        
        do ii = vetbi to vetbf:
        
            release estoq.
            find estoq where estoq.etbcod = ii and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then do:
              
                vestven = vestven + (estoq.estatual * estoq.estvenda).
                vcusto  = vcusto  + (estoq.estatual * estoq.estcusto).
                tt-curva.qtdest = tt-curva.qtdest + estoq.estatual.

            end.

        end.
        
        assign tt-curva.estven = tt-curva.estven + vestven
               tt-curva.estcus = tt-curva.estcus + vcusto.
        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            if movim.movqtm = 0 or
               movim.movpc  = 0
            then next.
            v-de = 0.
            v-ac = 0.
            /*
            find first tt-estab where
                       tt-estab.etbcod = movim.etbcod
                       no-lock no-error.
            if avail tt-estab
            then do:
            */
            
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat and
                                       plani.platot >= 1
                                            no-lock no-error.
                if not available plani
                then next.
                
                vlcontrato = plani.platot - plani.vlserv.
               
                if avail plani and 
                         plani.crecod = 2
                then vlcontrato = plani.biss.

                tt-curva.qtdven = tt-curva.qtdven + movim.movqtm.
            
                run p-preco.
                                                             
                find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod 
                                            no-lock no-error.
                if avail estoq
                then assign tt-curva.valcus = tt-curva.valcus + 
                                          (movim.movqtm * estoq.estcusto).
            end.
        end.
    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each tt-curva by tt-curva.valven descending:
        tt-curva.pos = i.
        tot-v = tot-v + tt-curva.valven.
        tot-c = tot-c + (tt-curva.valven - tt-curva.valcus).
        i = i + 1.
    end.
    
    varquivo = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
                        "/ABCFG31-" + string(day(vdtf),"99") +  
                                   string(month(vdtf),"99") + 
                                   string(year(vdtf),"9999") +
                           "." + string(time).

    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""curva1-31-cron""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """ABC FORNECEDORES - GERAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" ATE "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "140"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    vacum = 0.

    for each tt-curva by tt-curva.pos:

        if tt-curva.estcus = 0 and
           tt-curva.estven = 0 and
           tt-curva.qtdven = 0 and
           tt-curva.qtdest = 0
        then next.

        vacum = vacum + ((tt-curva.valven / tot-v) * 100).
        find fabri where fabri.fabcod = tt-curva.cod no-lock no-error.

        tt-curva.giro = (tt-curva.estven / tt-curva.valven).

        disp tt-curva.pos format "9999" column-label "Pos."
             tt-curva.cod format ">>>>>9" column-label "Codigo"
             fabri.fabnom when avail fabri format "x(25)" column-label "Nome"
             tt-curva.qtdven(total) format ">>>>>9"    column-label "Qtd.Ven"
             tt-curva.valcus(total) format ">>>>>,>>9" column-label "Vl.Custo"
             tt-curva.valven(total) format ">>>>>,>>9" column-label "Val.Ven(1)"
             ((tt-curva.valven / tot-v) * 100)(total)
                                 format "->>9.99" column-label "%S/VEN"
             vacum               format "->>9.99" column-label "% ACUM"
             (tt-curva.valven - tt-curva.valcus)(total) format "->>>,>>9"
                                                      column-label "LUCRO"
             (((tt-curva.valven - tt-curva.valcus) / tot-c) * 100)(total)
                                 format "->>9.99"     column-label "%P/MAR"
             tt-curva.qtdest(total) format "->>>>>9"    column-label "Qtd.Est"
             tt-curva.estcus(total) format "->,>>>,>>9" column-label "Est.Cus"
             tt-curva.estven(total) format "->>>,>>>,>>9" 
                                                column-label "Est.Ven"
             tt-curva.giro when tt-curva.giro > 0
                                 format ">>>>>9.99" column-label "Giro(1)"
             ((tt-curva.valven / tt-curva.valcus) - 1) * 100
                                 format "->>9.99" column-label "Margem(3)"
                                   with frame f-imp width 200 down.
    end.
    output close.
    varqsai = varquivo.
    leave.
end.

procedure p-preco:

                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0.
                val_com = 0.
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                val_fin =  ((((movim.movpc * movim.movqtm) - 
                        val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) - val_dev - 
                        val_des + val_acr +  val_fin.
                if val_com = ?
                then assign val_com = 0.
                          
        tt-curva.valven = tt-curva.valven + val_com.
        
end procedure.
