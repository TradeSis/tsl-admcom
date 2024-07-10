{admcab.i}

{ajusta-rateio-venda-def.i new}

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

def var vcatcod like produ.catcod initial 41.

def var vignora as logical initial no.

def var v-tem-movim as logical.

def buffer bestab for estab.
def var vetbcod like estab.etbcod.
def var dia-c like plani.platot.
def var dia-m like plani.platot.
def var varquivo as char format "x(30)".
def var aa-c like plani.platot.
def var aa-m like plani.platot.
def var mm-c like plani.platot.
def var mm-m like plani.platot.
def buffer bplani for plani.
def var xx as i format "99".
def var vfer as int.
def var ii as i.
def var vv as date.
def var vdtimp                  like plani.pladat.
def var totmeta like plani.platot.
def var totvend like plani.platot.
def temp-table wplani
    field   wetbcod  like estab.etbcod
    field   wmeta    as char format "X"
    field   wetbcon  like estab.etbcon format ">>,>>>,>>9.99"
    field   wetbmov  like estab.etbmov format ">>,>>>,>>9.99"
    field   wdia     as int format "99"
    field   wmes     as int format "99"
    field   wmeta-c  like plani.platot
    field   wacum-c  like plani.platot
    field   wmeta-m  like plani.platot
    field   wacum-m  like plani.platot
    field   wdia-c   like plani.platot
    field   wdia-m   like plani.platot.
def var dt     like plani.pladat.
def var acum-c like plani.platot.
def var acum-m like plani.platot.
def var vdia as int format ">9".
def var meta-c like plani.platot.
def var meta-m like plani.platot.
def var vcon like plani.platot.
def var vmov like plani.platot.
def buffer cmovim for movim.
def var vcat like produ.catcod initial 41.
def var vj   as int.
def var lfin as log.
def var lcod as i.
def var vok as l.
def var vldev like plani.vlserv.
def buffer bmovim for movim.
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
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vdtultatu   as date format "99/99/9999" no-undo.
def stream stela.
def buffer bcontnf for contnf.
def var vvalor as dec.

def var v-carcod-exc like caract.carcod.
def var v-exc-subcod like subcaract.subcod.
def var v-exclui-prod as logical.

form v-carcod-exc  column-label "Caract"
     v-exc-subcod  column-label "SubCaracteristica"
             with frame f-subcod centere  column 35 row 14 .
             
def temp-table tt-subcarac
    field subcar like subcarac.subcod
    field subdes like subcarac.subdes
           index idx01 is primary unique subcar.


                        
                        
def buffer bprocar for procar.

def var tt-acum-c as dec.
def var tt-acum-m as dec.

repeat:
    for each wplani:
        delete wplani.
    end.
    update vetbi label "Estabelecimento"
           vetbf no-label
            with frame f-etb centered color blue/cyan row 12
                                    title " Filial " side-label.
    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
                                    
        sresp = no.
                                            
        message "Deseja informar Subcaracterísticas para descarte?"
        update sresp.
        
        if sresp
        then do:
                       
            bl_subcar:
            repeat on error undo, retry:
                                                
                update v-carcod-exc go-on ("end-error")
                      with frame f-subcod column 30.
                    
                find first caract where caract.carcod = v-carcod-exc
                            no-lock no-error.
                if keyfunction(lastkey) = "end-error"
                then leave bl_subcar.
                           
                scopias = caract.carcod.
                                       
                update v-exc-subcod go-on ("end-error")
                      with frame f-subcod column 0.
                    
                if keyfunction(lastkey) = "end-error"
                then leave bl_subcar.
                                                  
                if v-exc-subcod = 0
                then undo, retry.
               
                find first subcaract where
                           subcaract.carcod = v-carcod-exc and
                           subcaract.subcar = v-exc-subcod no-lock.
                          
                create tt-subcarac.
                assign tt-subcarac.subcar = subcaract.subcar
                       tt-subcarac.subdes = subcaract.subdes.
                      
                disp tt-subcarac.subcar column-label "Cod."
                     tt-subcarac.subdes format "x(23)"
                              column-label "SubCaracterística"
                         with frame f-subcaract row 5 down column 50 overlay
                                                    title "Descartar:".
                                                     
                next bl_subcar.
                
            end.
            
        end.                            
                                    
        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.
        if opsys <> "UNIX"
        then varquivo = "..\relat\pla-" + string(time).
        else varquivo = "/admcom/relat/pla-" + string(time).
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "147"
            &Page-Line = "64"
            &Nom-Rel   = ""PLANI-4""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """FILIAL - "" +
                          string(vetbi) + "" A "" +
                          string(vetbf) + "" DE  "" 
                          + string (vdti, ""99/99/9999"") +
                          "" ATE  "" + string(vdtf,""99/99/9999"")"
            &Width     = "147"
            &Form      = "frame f-cabcab"}

        assign vvldesc  = 0
               vvlacre  = 0
               vmov    = 0
               vcon    = 0
               acum-m   = 0
               acum-c   = 0
               mm-c     = 0
               mm-m     = 0
               aa-c     = 0
               aa-m     = 0.
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.
        if not avail duplic
        then next.
        
        if estab.etbcod = 22
        then next.
        vdtimp = today.
        vfer = 0.

        find last bplani where bplani.etbcod = estab.etbcod and
                               bplani.movtdc = 5 and
                               month(bplani.pladat) <= month(vdti) no-lock
                                    use-index pladat no-error.

        if avail bplani
        then vdtultatu = bplani.pladat.
                              
        if vdtf > vdtultatu
        then vdtimp = vdtultatu.
        else vdtimp = vdtf.

        ii = 0.
        vfer = 0.
        vdia = 0.
        do vv = vdti to vdtf /*vdtimp*/:
           if weekday(vv) = 1
           then ii = ii + 1.
           find dtextra where dtextra.exdata  = vv no-lock no-error.
           if avail dtextra
           then vfer = vfer + 1.
           find dtesp where dtesp.datesp = vv and
                            dtesp.etbcod = estab.etbcod no-lock no-error.
           if avail dtesp
           then vfer = vfer + 1.
        end.
        
        vdia = int(day(vdtimp)) - ii - vfer.
        assign vmov    = 0
               vcon    = 0
               acum-c  = 0
               acum-m  = 0
               dia-m   = 0
               dia-c   = 0.

        do dt = vdti to vdtimp : 
          
          do vj = 1 to 2:

            if vj = 1 then vcatcod = 31 . /* Moveis */
            if vj = 2 then vcatcod = 41 . /*  Confeccoes */ 
          
            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                vvldesc = 0.
                vvlacre = 0.
                vvalor = 0.

                /***************************************
                if vcatcod <> 31
                then vignora = no.
                else vignora = yes.
                
                assign v-tem-movim = no.
                
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                                     
                       if v-tem-movim = no
                       then assign v-tem-movim = yes.              
                                     
                       find first produ where produ.procod = movim.procod
                            no-lock no-error.
                       if avail produ
                       then do:
                            if vcatcod <> 31 
                            then if produ.catcod <> vcatcod 
                                 then vignora = yes.
                            if vcatcod = 31 
                            then if produ.catcod = vcatcod or
                                    produ.procod = 88888
                                 then vignora = no. /* pelo menos 1 movel */
                       end.
                end.
                if vignora = yes then next.
                
                if not v-tem-movim
                then next.

                val_com = 0.

                for each bmovim where bmovim.etbcod = plani.etbcod and
                                      bmovim.placod = plani.placod and
                                      bmovim.movtdc = plani.movtdc and
                                      bmovim.movdat = plani.pladat
                                      no-lock:

                    find first produ where produ.procod = bmovim.procod
                                                        no-lock no-error.
                    if avail produ
                    then do:
                        if produ.procod = 88888
                        then vcat = 31.
                        else vcat = produ.catcod.
                    end.
                
                    val_acr = 0.
                    val_des = 0.
                    val_dev = 0.
                    val_fin = 0.

                    if can-find (first tt-subcarac)
                    then do:
                                                                       
                        assign v-exclui-prod = no.

                        bl_tt-sub:
                        for each tt-subcarac no-lock:

                            if can-find(first bprocar
                                      where bprocar.procod = produ.procod
                                        and bprocar.subcod = tt-subcarac.subcar)
                            then do:
                                
                                assign v-exclui-prod = yes.
                                leave bl_tt-sub.
                                    
                            end.
                                                                            
                        end.    
                            
                        if v-exclui-prod
                        then do:    
                        
                            val_acr =  val_acr + ((bmovim.movpc * bmovim.movqtm)                                                 / plani.platot) * plani.acfprod.
                            if val_acr = ? then val_acr = 0.
                
                            val_des = val_des + ((bmovim.movpc * bmovim.movqtm)
                                               / plani.platot) * plani.descprod.
                            if val_des = ? then val_des = 0.
              
                            val_dev =  val_dev + ((bmovim.movpc * bmovim.movqtm)
                                              / plani.platot) * plani.vlserv.
                            if val_dev = ? then val_dev = 0.
                    
                            if (plani.platot - plani.vlserv - plani.descprod)
                                    < plani.biss
                            then
                                val_fin =  ((((bmovim.movpc * bmovim.movqtm) -
                                           val_dev - val_des) /
                                 (plani.platot - plani.vlserv - plani.descprod))
                                * plani.biss) - ((bmovim.movpc * bmovim.movqtm)                                 - val_dev - val_des).
                           
                            if val_fin = ? then val_fin = 0.

                            val_com = val_com + (bmovim.movpc * bmovim.movqtm) -                                         val_dev - val_des + val_acr + val_fin.
                                                          
                            if val_com = ? then val_com = 0.

                        end.                        
                        
                    end.
                    
                    find estoq where estoq.etbcod = plani.etbcod and
                                     estoq.procod = produ.procod
                                                no-lock no-error.
                    if not avail estoq
                    then next.
                    /*
                    run calculo.
                    vvalor = vvalor + val_com.
                    */
                end.

                output stream stela to terminal.
                disp stream stela plani.etbcod
                                  plani.pladat
                                    with frame fffpla centered color white/red.
                pause 0.
                output stream stela close.

                /************* Calculo do acrescimo *****************/

                wacr = 0.
                if plani.crecod >= 1
                then do:
                    if plani.biss > (plani.platot - plani.vlserv)
                    then assign wacr = plani.biss - 
                                      (plani.platot - plani.vlserv).
                    else wacr = plani.acfprod.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.
                end.
                /*
                else assign vvldesc  = vvldesc  + plani.descprod
                            vvlacre  = vvlacre  + plani.acfprod.
                  */
                ***********************************/
                
                for each tt-plani: delete tt-plani. end.
                for each tt-movim: delete tt-movim. end.
                
                create tt-plani.
                buffer-copy plani to tt-plani.
                
                for each bmovim where bmovim.etbcod = plani.etbcod and
                                      bmovim.placod = plani.placod and
                                      bmovim.movtdc = plani.movtdc and
                                      bmovim.movdat = plani.pladat
                                      no-lock:

                    find first produ where produ.procod = bmovim.procod
                                                        no-lock no-error.
                    if not avail produ then next.
                    
                    create tt-movim.
                    buffer-copy bmovim to tt-movim.
                    
                end.
                
                run ajusta-rateio-venda-pro.p.
                
                val_com = 0.
                
                for each tt-movim no-lock:
                    find produ where produ.procod = tt-movim.procod
                            no-lock no-error.
                    if not avail produ then next.
                            
                    if vcatcod > 0 and
                        produ.catcod <> vcatcod
                    then next.    
                    
                    val_acr = 0.
                    val_des = 0.
                    val_dev = 0.
                    val_fin = 0.

                    if can-find (first tt-subcarac)
                    then do:
                                                                       
                        assign v-exclui-prod = no.

                        bl_tt-sub:
                        for each tt-subcarac no-lock:

                            if can-find(first bprocar
                                      where bprocar.procod = produ.procod
                                        and bprocar.subcod = tt-subcarac.subcar)
                            then do:
                                
                                assign v-exclui-prod = yes.
                                leave bl_tt-sub.
                                    
                            end.
                                                                            
                        end.    
                            
                        if v-exclui-prod = no
                        then do:    

                            if tt-movim.movtot = ?
                            then.
                            else val_com = val_com + tt-movim.movtot.

                        end.                        
                        
                    end.
                    else if tt-movim.movtot <> ?
                        then val_com = val_com + tt-movim.movtot.
 
                end.

                if (vcatcod = 31 or
                    vcatcod = 35 or
                    vcatcod = 50)
                then do:
                    acum-m = acum-m + val_com.
                    if plani.pladat = vdtimp
                    then dia-m = dia-m + val_com.
                end.
                else if vcatcod <> 88
                then do:
                     acum-c = acum-c + val_com.
                     if plani.pladat = vdtimp
                     then dia-c = dia-c + val_com.
                end.
            end.
          end.
        end.
        
        create wplani.
        assign wplani.wetbcod = estab.etbcod
               wplani.wdia    = day(vdtimp)
               wplani.wmes    = month(vdtimp)
               wplani.wdia-c  = dia-c
               wplani.wdia-m  = dia-m.
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.
        if avail duplic
        then assign wplani.wetbcon = duplic.dupval
                    wplani.wetbmov = duplic.dupjur.

        if duplic.dupval > 0 and
           duplic.dupjur = 0
        then wplani.wmeta = "C".
                   
        if duplic.dupval = 0 and
           duplic.dupjur > 0
        then wplani.wmeta = "M".


        if duplic.dupval > 0
        then assign wplani.wmeta-c  = ((duplic.dupval / duplic.dupdia) * vdia).

        wplani.wacum-c  = acum-c.


        if duplic.dupjur > 0
        then assign wplani.wmeta-m  = ((duplic.dupjur / duplic.dupdia) * vdia).

        wplani.wacum-m  = acum-m.

        tt-acum-c = tt-acum-c + acum-c.
        tt-acum-m = tt-acum-m + acum-m.
    end.

    put
"                    MODA                                                     "
"      MOVEIS".
        /* SKIP
        fill("-",130) format "x(130)". */

        for each wplani by wplani.wetbcod:
            vdia = 0.
            vdia = wplani.wdia.

            if (wplani.wmeta = "C" or
                wplani.wmeta = "") or
                wplani.wacum-c > 0
            then do:
                 vetbcod = wplani.wetbcod.
                 if wplani.wmes <> month(vdtf)
                 then wplani.wmeta-c = 0.
                 find bestab where bestab.etbcod = vetbcod no-lock no-error.
                 display wplani.wetbcod column-label "Fl"
                                        format "99"
                         bestab.munic column-label "Cidade" format "x(8)"
                         wplani.wetbcon(total) when wplani.wetbcon > 0
                                column-label "META/MES" format ">>,>>>,>>9"
                        
                        (wplani.wmeta-c)(total) when wplani.wacum-c > 0
                                column-label "META" format ">>,>>>,>>9"
                        (wplani.wacum-c)(total) 
                                column-label "Venda(i2)" format ">>,>>>,>>9"
                        "(" wplani.wdia no-label ")"
                        
                        (((wplani.wacum-c / wplani.wmeta-c) * 100) - 100)
                            when wplani.wacum-c > 0
                        format "->>9.99" column-label " % "
                        
                        wplani.wdia-c(total) column-label "Venda Dia" 
                                      format ">>,>>>,>>9"
                        "    "
                        vetbcod column-label "Fl" format ">>9" 
                                    with no-box frame f-a down width 150.
                                                                  /*137*/
                if (wplani.wmeta = "M" or
                    wplani.wmeta = "") or
                    wplani.wacum-m > 0
                then.
                else do:
                    if wplani.wetbcod mod 2 = 0
                     and wplani.wetbcod <> 1
                     and wplani.wetbcod <> 4
                     and wplani.wetbcod <> 6
                     and wplani.wetbcod <> 8
                     and wplani.wetbcod <> 10
                     and wplani.wetbcod <> 12
                     and wplani.wetbcod <> 16
                     and wplani.wetbcod <> 20
                     and wplani.wetbcod <> 22
                     and wplani.wetbcod <> 24
                     and wplani.wetbcod <> 28
                     and wplani.wetbcod <> 30
                     and wplani.wetbcod <> 32
                     and wplani.wetbcod <> 36
                     and wplani.wetbcod <> 38
                     and wplani.wetbcod <> 40
                     and wplani.wetbcod <> 42
                     and wplani.wetbcod <> 44
                     and wplani.wetbcod <> 48
                     and wplani.wetbcod <> 52
                     and wplani.wetbcod <> 56
                     and wplani.wetbcod <> 58
                     and wplani.wetbcod <> 60
                     and wplani.wetbcod <> 62
                     and wplani.wetbcod <> 64
                     and wplani.wetbcod <> 68
                     and wplani.wetbcod <> 70    
                     and wplani.wetbcod <> 72
                     and wplani.wetbcod <> 76
                     and wplani.wetbcod <> 80
                     and wplani.wetbcod <> 82
                     and wplani.wetbcod <> 84
                     and wplani.wetbcod <> 88
                     and wplani.wetbcod <> 90
                     and wplani.wetbcod <> 92
                     and wplani.wetbcod <> 96
                     and wplani.wetbcod <> 100
                     and wplani.wetbcod <> 104
                     
            /*130~ */
                    then put fill("-",137) format "x(137)" skip.  
                    /* put skip(1). */
                end.    
                
                mm-c = mm-c + wplani.wmeta-c.
                aa-c = aa-c + wplani.wacum-c.
            end.

            if (wplani.wmeta = "M" or
                wplani.wmeta = "") or
                wplani.wacum-m > 0  
            then do:
                 vetbcod = wplani.wetbcod.
                 if wplani.wmes <> month(vdtf)
                 then wplani.wmeta-m = 0.
                 find bestab where bestab.etbcod = vetbcod no-lock no-error.
                 
                 display wplani.wetbcod column-label "Fl" format ">>9" 
                         vetbcod column-label "Fl" format ">>9" 
                         bestab.munic column-label "Cidade" format "x(8)"

                         wplani.wetbmov(total) when wplani.wetbmov > 0
                                 column-label "META/MES" format ">>,>>>,>>9"
                        (wplani.wmeta-m)(total) when wplani.wacum-m > 0
                                 column-label "META" format ">>,>>>,>>9"
                        (wplani.wacum-m)(total) column-label "Venda(i2)"
                                        format ">>,>>>,>>9"
                        "(" vdia no-label ")"
                        (((wplani.wacum-m / wplani.wmeta-m) * 100) - 100)
                            when wplani.wacum-m > 0 
                            format "->>>>>9.99" column-label " % " 
                        wplani.wdia-m(total) column-label "Venda Dia" 
                                      format ">>,>>>,>>9" 
                                                    with no-box frame f-a.
                if wplani.wetbcod mod 2 = 0
                 and wplani.wetbcod <> 1
                 and wplani.wetbcod <> 4
                 and wplani.wetbcod <> 6
                 and wplani.wetbcod <> 8
                 and wplani.wetbcod <> 10
                 and wplani.wetbcod <> 12
                 and wplani.wetbcod <> 16
                 and wplani.wetbcod <> 20
                 and wplani.wetbcod <> 22
                 and wplani.wetbcod <> 24
                 and wplani.wetbcod <> 28
                 and wplani.wetbcod <> 30
                 and wplani.wetbcod <> 32
                 and wplani.wetbcod <> 36
                 and wplani.wetbcod <> 38
                 and wplani.wetbcod <> 40
                 and wplani.wetbcod <> 42
                 and wplani.wetbcod <> 44
                 and wplani.wetbcod <> 48
                 and wplani.wetbcod <> 52
                 and wplani.wetbcod <> 56
                 and wplani.wetbcod <> 58
                 and wplani.wetbcod <> 60
                 and wplani.wetbcod <> 62
                 and wplani.wetbcod <> 64
                 and wplani.wetbcod <> 68
                 and wplani.wetbcod <> 70
                 and wplani.wetbcod <> 72
                 and wplani.wetbcod <> 76
                 and wplani.wetbcod <> 80
                 and wplani.wetbcod <> 82
                 and wplani.wetbcod <> 84
                 and wplani.wetbcod <> 88
                 and wplani.wetbcod <> 90
                 and wplani.wetbcod <> 92
                 and wplani.wetbcod <> 96
                 and wplani.wetbcod <> 100
                 and wplani.wetbcod <> 104
                 
            /*130*/ then put fill("-",~ 137)~  format "x(137)~ " skip.                      /* put skip(1).  */

                aa-m = aa-m + wplani.wacum-m.
                mm-m = mm-m + wplani.wmeta-m.
            end.
        end.
        display (((aa-c / mm-c) * 100) - 100) at 51
                        format "->>>9.99%" no-label
                (((aa-m / mm-m) * 100) - 100) at 118
                        format "->>>9.99%" no-label with frame f-tot no-box
                            no-label width 145. /*137*/
        totmeta = 0.
        totvend = 0.

    output close.
    if opsys <> "UNIX"
    then do:
        {mrod_l.i} 
    end.
    else run visurel.p (input varquivo, input "").
end.
