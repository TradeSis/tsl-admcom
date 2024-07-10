{admcab.i}

{/admcom/progr/calculo_vendas.def}
/*
def stream debug .
def stream total.

def new shared temp-table tt-movim like movim
    field movtot    like plani.platot 
    field chpres    like plani.platot
    field bonus     like plani.platot
    field vencod    like func.funcod
    field vendedor  like func.funnom
    field acr-fin   as dec
    field tipmov    as char 
    field crecod    as integer
    field planobiz  as character
    field clicod    as integer
    field serie     as char
      index idx01 etbcod                
      index idx02 etbcod procod
      index idx03 etbcod asc placod asc movtot desc
      index idx04 etbcod movdat
      index idx05 etbcod placod movdat movtdc
      index idx_pk is primary unique etbcod placod procod movdat tipmov.        

def new shared temp-table tt-plani like plani
    field chpres like plani.platot
    field bonus  like plani.platot
    field tipmov as char   
    field clicod like plani.desti   
      index idx01 etbcod
      index idx_pk is primary unique etbcod placod serie.

def new shared temp-table tt-planobiz
    field crecod as integer
            index idx01 crecod.
            
for each tabaux where tabaux.tabela = "PlanoBiz" no-lock:

    create tt-planobiz.
    assign tt-planobiz.crecod = integer(tabaux.valor_campo).    
      
end.
*/


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
             with frame f-subcod column 10 row 8 .
             
def temp-table tt-subcarac
    field subcar like subcarac.subcod
    field subdes like subcarac.subdes
           index idx01 is primary unique subcar.


                
def var val-movim-tot as dec.                        
                        
def buffer bprocar for procar.

def var tt-acum-c as dec.
def var tt-acum-m as dec.

form "Processando Movimento... " 
     with frame f-disp side-label 1 down no-box 
     color message centered row 10.
     

repeat:
    for each wplani:
        delete wplani.
    end.
    update vetbi at 2 label "Filial"
           vetbf label "a"
            with frame f-etb 1 down
            width 80 side-label.

    update vdti at 1 label "Periodo"
           "a"
           vdtf no-label with frame f-etb.
                                    
    sresp = no.
    
    empty temp-table tt-plani.
    empty temp-table tt-movim.
                                            
    message "Deseja informar Subcaracterísticas para descarte?"
        update sresp.
        
    if sresp
    then do:
                       
            bl_subcar:
            repeat on error undo, retry:
                                                
                update v-carcod-exc go-on ("end-error")
                      with frame f-subcod column 10.
                    
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
                         with frame f-subcaract row 8 down column 50 overlay
                                                    title "Descartar:".
                                                     
                next bl_subcar.
                
            end.
            
    end.                            
                                    
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        
        disp estab.etbcod label "Filial" with frame f-disp.
        
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

        do dt = vdti to vdtimp : 
          
            disp dt label "Data" with frame f-disp.
            
            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
 
                find first movim where movim.etbcod = plani.etbcod and
                           movim.placod = plani.placod and
                           movim.movtdc = plani.movtdc and
                           movim.movdat = plani.pladat
                           no-lock no-error.
                if not avail movim
                then next.
                            
                run grava-movimento.
                
           end.

        end.            
    end.


    disp "Aplicando regras ... " at 1 no-label
         with frame f-disp.
    
    sretorno = "/admcom/lebesintel/debugplani-4b.csv".
    
    output stream debug to value(sretorno).
    put "Inicio..:" skip.
    output stream debug close.

    run ajusta-rateio-venda-x.p.
    
    sretorno = "".

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
    
    disp "Montando relatorio..." at 1 no-label with frame f-disp.
    
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
          
          do: /* vj = 1 to 2:
            
            if vj = 1 then vcatcod = 31 . /* Moveis */
            if vj = 2 then vcatcod = 41 . /*  Confeccoes */ 

            val-movim-tot = 0.
            
            if vcatcod <> 31
            then vignora = no.
            else vignora = yes.
               */
               
            for each tt-movim where tt-movim.etbcod = estab.etbcod and
                                     tt-movim.movtdc = 5 and
                                     tt-movim.movdat = dt
                                     no-lock:
                
                if tt-movim.bonus > tt-movim.movtot
                then next.
                            
                find first produ where produ.procod = tt-movim.procod
                            no-lock no-error.
                if not avail produ then next.

                
                run pega-categoria.
                vcatcod = tt-setor.setsup.
                
                /*
                vcatcod = produ.catcod.
                */
                if (vcatcod = 31 or
                    vcatcod = 35 or
                    vcatcod = 50)
                then do:
                    acum-m = acum-m + tt-movim.movtot.
                 
                    if tt-movim.movdat = vdtimp
                    then dia-m = dia-m + tt-movim.movtot.

                end.
                else if vcatcod <> 88
                then do:
                    acum-c = acum-c + tt-movim.movtot.
                    if tt-movim.movdat = vdtimp
                    then dia-c = dia-c + tt-movim.movtot.
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

    if opsys <> "UNIX"
    then varquivo = "..\relat\pla-4b" + string(time).
    else varquivo = "/admcom/relat/pla-4b" + string(time).

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
            &Width     = "160"
            &Form      = "frame f-cabcab"}


    
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
                                column-label "Venda(2)" format ">>,>>>,>>9.99"
                        "(" wplani.wdia no-label ")"
                        
                        (((wplani.wacum-c / wplani.wmeta-c) * 100) - 100)
                            when wplani.wacum-c > 0
                        format "->>9.99" column-label " % "
                        
                        wplani.wdia-c(total) column-label "Venda Dia" 
                                      format ">>,>>>,>>9"
                        "    "
                        vetbcod column-label "Fl" format ">>9" 
                                    with no-box frame f-a down width 170.
                                                                  /*137*/
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
                        (wplani.wacum-m)(total) column-label "Venda(2)"
                                        format ">>,>>>,>>9.99"
                        "(" vdia no-label ")"
                        (((wplani.wacum-m / wplani.wmeta-m) * 100) - 100)
                            when wplani.wacum-m > 0 
                            format "->>>>>9.99" column-label " % " 
                        wplani.wdia-m(total) column-label "Venda Dia" 
                                      format ">>,>>>,>>9" 
                                                    with no-box frame f-a.
    
                aa-m = aa-m + wplani.wacum-m.
                mm-m = mm-m + wplani.wmeta-m.
            end.
            /*
            disp wplani.wacum-m + wplani.wacum-c(total) 
                column-label "Tot.Venda(2)" format ">>,>>>,>>9.99"
                with frame f-a.

 
            output stream total to value("/admcom/relat/plan-b4.csv") append.
            put stream total wplani.wetbcod  ";"
                    wplani.wacum-m + wplani.wacum-c format ">>>>>>>9.99"
                    skip
                    .
            output stream total close.        
            */
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

def var vtipo-nota as char.

procedure grava-movimento:

    vtipo-nota = "".
            
    if plani.movtdc = 4
    then vtipo-nota = "E".
    else if plani.movtdc = 5
        then vtipo-nota = "V".
            
    create tt-plani.
    buffer-copy plani to tt-plani.                       
                 
    assign tt-plani.chpres = 
                        dec(acha("VALCHQPRESENTEUTILIZACAO1",plani.notobs[3]))
           tt-plani.tipmov = vtipo-nota
           tt-plani.clicod = plani.desti
           tt-plani.serie  = plani.serie.
                
    release titulo.
    if plani.descprod > 0
    then do:
    find last titulo where titulo.empcod = 19
                                and titulo.modcod = "BON"
                                and titulo.clifor = plani.desti
                                and titulo.titnat   = yes
                                and titulo.titdtpag = plani.pladat
                                and titulo.titvlpag = plani.descprod
                                     no-lock no-error.
                                        
    if avail titulo
    then assign tt-plani.bonus = plani.descprod.
    end.
             
    for each movim where
                movim.etbcod = plani.etbcod and
                movim.placod = plani.placod and
                movim.movtdc = plani.movtdc and
                movim.movdat = plani.pladat
                no-lock.
                
        find last produ of movim no-lock no-error.
                
        if not avail produ
        then next.
                
        find last Clase of produ no-lock no-error.
                
        create tt-movim.
                
        buffer-copy movim to tt-movim.
        assign tt-movim.vencod = plani.vencod.
                
                
    end.

end procedure.

