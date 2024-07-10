{admcab.i}
def var vmes as i.
def var vano as i.
def buffer estoq for estoq.
def var t-ven  like estoq.estvenda format "->>>,>>9.99".
DEF VAR t-val  like estoq.estvenda format "->>>,>>9.99".
def var t-venda  like estoq.estvenda format "->>>,>>9.99".
DEF VAR t-valest like estoq.estvenda format ">>,>>>,>>9.99".
def var v-giro   like estoq.estvenda format "->,>>9.99".
def var tot-v    like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-ven  like estoq.estvenda format "->>>,>>9" .
DEF VAR venda    like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-com  like estoq.estvenda format "->>>,>>9"   .
DEF VAR compra   like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-atu  like estoq.estvenda format "->>>,>>9"   .
DEF VAR valest   like estoq.estvenda format "->>,>>>,>>9.99".
DEF VAR valcus   like estoq.estvenda format "->>>,>>9.99".

def var totcusto like estoq.estcusto.
def var totvenda like estoq.estcusto.
def buffer bestoq for estoq.
def var acre like plani.platot.
def var des like plani.platot.
def buffer bmovim for movim.
def var totc like plani.platot.
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
def var vvltotal as dec.
def var vvlcont  as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vcatcod     like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def var vclasup like clase.clasup.
def temp-table tt-catcod
    field catcod like produ.catcod.

def var tot-ven-fisico like plani.platot.
def var tot-ven-financ like plani.platot.
def var tot-com-fisico like plani.platot.
def var tot-com-financ like plani.platot.
def var tot-est-fisico like plani.platot.
def var tot-est-finven like plani.platot.
def var tot-est-fincus like plani.platot.
def temp-table tt-acumula
  field tt-classe  like clase.clacod
  field tt-clasup like clase.clasup
  field tt-ven-fisico like plani.platot
  field tt-ven-financ like plani.platot
  field tt-ven-percen like plani.platot
  field tt-com-fisico like plani.platot
  field tt-com-financ like plani.platot
  field tt-est-fisico like plani.platot
  field tt-est-finven like plani.platot
  field tt-est-fincus like plani.platot.

def buffer bacumula for tt-acumula.
for each tt-acumula.
  delete tt-acumula.
end.

repeat:
    for each tt-catcod:
        delete tt-catcod.
    end.
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

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


    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
    update vclasup with frame f-dat side-label.
    if vclasup = 0
    then display "GERAL" @ clase.clanom with frame f-dat.
    else do:
        find clase where clase.clacod = vclasup no-lock.
        display clase.clanom no-label with frame f-dat.
    end.
    if vclasup = 0
    then do:
        for each clase no-lock.
            create tt-acumula.
            assign tt-classe = clase.clacod
                   tt-clasup = clase.clasup
                   tt-ven-fisico = 0
                   tt-ven-financ = 0
                   tt-ven-percen = 0
                   tt-com-fisico = 0
                   tt-com-financ = 0
                   tt-est-fisico = 0
                   tt-est-finven = 0
                   tt-est-fincus = 0.
        end.    
    end.
    else do:
        for each clase where clase.clasup = vclasup no-lock.
            create tt-acumula.
            assign tt-classe = clase.clacod
                   tt-clasup = clase.clasup
                   tt-ven-fisico = 0
                   tt-ven-financ = 0
                   tt-ven-percen = 0
                   tt-com-fisico = 0
                   tt-com-financ = 0
                   tt-est-fisico = 0
                   tt-est-finven = 0
                   tt-est-fincus = 0.
        end.    
    end.




    assign est-ven = 0
           venda   = 0
           est-com = 0
           compra = 0
           est-atu = 0
           valest  = 0
           valcus  = 0.


    {mdadmcab.i
        &Saida     = "I:\admcom\relat\resumo.txt"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""RESUMO""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RESUMO VENDA/COMPRA/ESTOQUE - DA FILIAL "" +
                            string(vetbi,"">>9"") + "" A "" +
                            string(vetbf,"">>9"") +
                      "" PERIODO DE "" +
                         string(vdti,""99/99/9999"") + "" A "" +
                         string(vdtf,""99/99/9999"") "
       &Width     = "135"
       &Form      = "frame f-cabcab"}

    tot-v = 0.
    for each tt-acumula:
        for each tt-catcod, 
            each produ where produ.catcod = tt-catcod.catcod and
                             produ.clacod = tt-acumula.tt-classe no-lock. 
        
           output stream stela to terminal.
              disp stream stela produ.procod produ.clacod
                        with frame ffff centered color white/red 1 down.
                pause 0.
           output stream stela close.

           find first movim where movim.procod = produ.procod and
                                  movim.movdat >= vdti        and
                                  movim.movdat <= vdtf no-lock no-error.
           if not avail movim
           then do:
                find first estoq where estoq.procod = produ.procod and
                                       estoq.estatual <> 0 no-lock no-error.
                if not avail estoq
                then next.
           end.
           for each movim where movim.procod = produ.procod and
                                movim.movtdc = 5            and
                                movim.movdat >= vdti        and
                                movim.movdat <= vdtf        no-lock:

                totc = 0.
                des = 0.
                acre = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.pladat = movim.movdat and
                                       plani.movtdc = movim.movtdc
                                                          no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                            no-lock no-error.
                        if avail contrato
                        then do:
                           if contrato.vltotal > ( plani.platot - plani.vlserv)
                           then acre = contrato.vltotal / (plani.platot - 
                                                           plani.vlserv).
                           if contrato.vltotal < ( plani.platot - plani.vlserv)
                           then des = (plani.platot - plani.vlserv)
                                                        / contrato.vltotal.
                        end.
                        else do:
                            if plani.acfprod > 0
                            then acre = (plani.platot + plani.acfprod) / 
                                         plani.platot.
                            if plani.descprod > 0
                            then des = plani.platot / (plani.platot -
                                                       plani.descprod).
                        end.
                    end.
                    if plani.platot < 1
                    then assign des = 0
                                acre = 0.
                end.

                if not available plani
                then next.

                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.

                if acre > 0
                then do:
                    if ( movim.movqtm * movim.movpc * acre ) - 
                       ( ( ( movim.movqtm * movim.movpc ) /
                             plani.platot ) * plani.vlserv ) <> ?
                    then
                    venda = venda + ( movim.movqtm * movim.movpc * acre ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) /
                                       plani.platot ) * plani.vlserv ).
                end.
                                
                if des > 0
                then do: 
                    
                    if ( movim.movqtm * movim.movpc / des ) - 
                         ( ( ( movim.movqtm * movim.movpc ) / 
                               plani.platot ) * plani.vlserv ) <> ?
                    then 
                    venda = venda + ( movim.movqtm * movim.movpc / des ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) / 
                                       plani.platot ) * plani.vlserv ).
                
                end.
                if acre = 0 and des = 0
                then do:
                   if  ( ( movim.movqtm * movim.movpc ) - 
                         ( ( ( movim.movqtm * movim.movpc ) / 
                               plani.platot ) * plani.vlserv ) ) <> ?
                   then 
                     venda = venda + ( ( movim.movqtm * movim.movpc ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) / 
                                       plani.platot ) * plani.vlserv ) ).
                end.
                est-ven = est-ven + movim.movqtm.
           end.
           for each movim where movim.procod = produ.procod and
                                movim.movtdc = 4  and
                                movim.movdat >= vdti - 30 and
                                movim.movdat <= vdtf + 30 no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                                            no-lock no-error.

                if avail plani
                then do:
                   if  plani.datexp >= vdti  and
                       plani.datexp <= vdtf
                   then assign compra  = compra + (movim.movpc * movim.movqtm)
                               est-com = est-com + movim.movqtm.
                end.
           end.
           for each movim where movim.procod = produ.procod and
                                movim.movtdc = 1            and
                                movim.movdat >= vdti - 30   and
                                movim.movdat <= vdtf + 30 no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                                         no-lock no-error.

                if avail plani
                then do:
                    if plani.datexp >= vdti  and
                       plani.datexp <= vdtf
                    then assign compra  = compra + (movim.movpc * movim.movqtm)
                                est-com = est-com + movim.movqtm.
                end.
           end.
            
           for each estab no-lock:
                find bestoq where bestoq.etbcod = estab.etbcod and
                                  bestoq.procod = produ.procod 
                                                            no-lock no-error.
                if not avail bestoq
                then next.
                find hiest where hiest.etbcod = estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hiemes = month(vdtf)  and
                                 hiest.hieano = year(vdtf)  no-lock no-error.
                if not avail hiest
                then do:
                    if month(vdtf) = 1
                    then assign vano = year(vdtf) - 1
                                vmes = 12.
                    else assign vano = year(vdtf)
                                vmes = month(vdtf).
                    find last hiest where hiest.etbcod = estab.etbcod and
                                          hiest.procod = produ.procod and
                                          hiest.hiemes <= vmes        and
                                          hiest.hieano = vano no-lock no-error.
                    if not avail hiest
                    then do:
                        find bestoq where bestoq.etbcod = estab.etbcod and
                                          bestoq.procod = produ.procod
                                                              no-lock no-error.
                        if avail bestoq
                        then do:
                          valest = valest + (bestoq.estatual * bestoq.estvenda).
                          valcus = valcus + (bestoq.estatual * bestoq.estcusto).
                          est-atu = est-atu + bestoq.estatual.
                        end.
                    end.
                    else do:
                        valest  = valest + (hiest.hiestf * bestoq.estvenda).
                        valcus  = valcus + (hiest.hiestf * bestoq.estcusto).
                        est-atu = est-atu + hiest.hiestf.
                    end.
                end.
                else do:
                    valest  = valest + (hiest.hiestf * bestoq.estvenda).
                    valcus  = valcus + (hiest.hiestf * bestoq.estcusto).
                    est-atu = est-atu + hiest.hiestf.
                end.
           end.
           
           tt-ven-fisico = tt-ven-fisico + est-ven.
           tt-ven-financ = tt-ven-financ + venda.
           tt-com-fisico = tt-com-fisico + est-com.
           tt-com-financ = tt-com-financ + compra.
           tt-est-fisico = tt-est-fisico + est-atu.
           tt-est-finven = tt-est-finven + valest.
           tt-est-fincus = tt-est-fincus + valcus.

           t-venda = t-venda + venda.
           t-valest = t-valest + valest.
           t-ven = t-venda + venda.
           t-val = t-valest + valest.
     
        
           assign est-ven = 0
                  venda   = 0
                  est-com = 0
                  compra = 0
                  est-atu = 0
                  valest  = 0
                  valcus  = 0.
        end.
    end.

    for each tt-acumula where tt-est-fisico > 0 and
                              tt-ven-fisico > 0. 
        tot-ven-financ = tot-ven-financ + tt-ven-financ.
        tot-ven-fisico = tot-ven-fisico + tt-ven-fisico.
        tot-com-fisico = tot-com-fisico + tt-com-fisico.
        tot-com-financ = tot-com-financ + tt-com-financ.
        tot-est-fisico = tot-est-fisico + tt-est-fisico.
        tot-est-finven = tot-est-finven + tt-est-finven.
        tot-est-fincus = tot-est-fincus + tt-est-fincus.
    end.       
                  
    for each tt-acumula where tt-est-fisico > 0 and
                              tt-ven-fisico > 0 
                                                break by tt-acumula.tt-clasup
                                                      by tt-acumula.tt-classe:
        
        
        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S  "  at 35
                 "               E S T O Q U E S        "
                                 skip fill("-",135) format "x(135)".

        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S   " at 35
                 "               E S T O Q U E S "
                      skip fill("-",135) format "x(135)".


        
        
        find clase where clase.clacod = tt-acumula.tt-classe no-lock. 
        disp tt-classe column-label "Classe"
             tt-clasup column-label " Sup "
             clase.clanom format "x(15)" column-label "Descri‡Æo"
             tt-ven-fisico(total by tt-acumula.tt-clasup) 
                        format "->>>,>>9" column-label "F¡sico"
             tt-ven-financ(total by tt-acumula.tt-clasup) 
                        format "->>>,>>9.99" column-label "Financ"
             ((tt-ven-financ / tot-ven-financ) * 100)
                        (total by tt-acumula.tt-clasup)
                             format "->>9.99" column-label "%/Par"  
             tt-com-fisico(total by tt-acumula.tt-clasup) 
                             format "->>>,>>9" column-label "Fisico"
             tt-com-financ(total by tt-acumula.tt-clasup) 
                             format "->>>,>>9.99" column-label "Financ"
             tt-est-fisico(total by tt-acumula.tt-clasup) 
                             format "->>>,>>9" column-label "Est/Fisico"
             tt-est-finven(total by tt-acumula.tt-clasup) 
                             format "->>,>>>,>>9.99" column-label "Fin/Venda"
             tt-est-fincus(total by tt-acumula.tt-clasup) 
                             format "->>>,>>9.99" column-label "Fin/Custo"
             (tt-est-finven / tt-ven-financ)
                             format "->>9.99" column-label "Giro"
                                        with frame ff down width 200.  

    end.    
    put (tot-est-finven / tot-ven-financ) at 115 skip.
    output close.
    message "Deseja imprimir relatorio" update sresp.
    if sresp
    then dos silent value("ved i:\admcom\relat\resumo.txt > prn").
end.



 
 
 
