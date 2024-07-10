{admcab.i}
def input parameter vindex as int. 

def var mov-bonus as dec.

{ajusta-rateio-venda-def.i new}

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

def var vcatcod like produ.catcod initial 41.

def var vignora as logical initial no.

def var mcrepes as dec.
def var v-tem-movim as logical.
def var valormeta as dec.
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
def temp-table wplani no-undo
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
    field   wdia-m   like plani.platot
    field   wseg-q   as int
    field   wseg-v   as dec
    field   wseg-m   as int
    field   wmcpes   as dec
    field   wrcpes   as dec
    field   wminad   as dec
    field   wrinad   as dec
    index i1 wetbcod
     .

def temp-table tt-metacomis  no-undo
    field etbcod like estab.etbcod
    field funcod like func.funcod
    field folha  like func.usercod
    field g0 as dec           format ">>>>>>>9.99"
    field d0 as dec           format ">>>>>>>9.99"
    field g1 as dec           format ">>>>>>>9.99"
    field d1 as dec           format ">>>>>>>9.99"
    field b1 as dec           format ">>>>>>>9.99"
    field g2 as dec           format ">>>>>>>9.99"
    field d2 as dec           format ">>>>>>>9.99"
    field b2 as dec           format ">>>>>>>9.99"
    field g3 as dec           format ">>>>>>>9.99"
    field d3 as dec           format ">>>>>>>9.99"
    field g4 as dec           format ">>>>>>>9.99"
    field g5 as dec           format ">>>>>>>9.99"
    field g51 as int          format ">>>>>9" 
    field g6 as dec           format ">>>>>>>9.99"
    field d6 as dec           format ">>>>>>>9.99"
    field b6 as dec           format ">>>>>>>9.99"
    field rinadcp as dec      format ">>>>>>>9.99"
    field minadcp as dec      format ">>>>>>>9.99"
    field rvenda  as dec      format ">>>>>>>9.99"
    field mvenda  as dec      format ">>>>>>>9.99"
    field rseguro as int      
    field mseguro as int      
    field moveis  as dec      format ">>>>>>>9.99"
    field moda    as dec      format ">>>>>>>9.99"
    field devolucao as dec    format ">>>>>>>9.99"
    field bonus as dec        format ">>>>>>>9.99"
    index i1 etbcod funcod
    .
    
def temp-table tt-g no-undo
    field clacod like clase.clacod
    field tipo as char
    index i1 clacod.
    
def temp-table dev-movim
    field procod like movim.procod
    field movpc like movim.movpc
    field movqtm like movim.movqtm
    index i1 procod.

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
def var tt-acum-sq as dec.
def var tt-acum-sm as dec.
def var tt-acum-sv as dec.
def var acum-sq as dec.
def var acum-sm as dec.
def var acum-sv as dec.
def var r-inadim as dec.

def var    vtotalmeta as dec.
def var    vmeta-31 as dec.
def var    vende-31 as dec.
def var    vmeta-41 as dec.
def var    vende-41 as dec.
def var    msegu-31 as int.
def var    msegu-41 as int.
def var    minadin  as dec.
def var    rinadin  as dec.
def var    minadincp as dec.
def var    rinadincp as dec.
def var    acum-rcp as dec.

for each wplani:
    delete wplani.
end.

form vetbcod at 2 label "Filial" with frame f-etb side-label 1 down
            width 80.
if vindex <> 3 or setbcod = 999
then do:
    {selestab.i vetbcod f-etb}
end.
else do:
    vetbcod = setbcod.
    disp vetbcod with frame f-etb.
    disp estab.etbnom with frame f-etb.
    create tt-lj.
    tt-lj.etbcod = vetbcod.
end.    

def var vfuncod like func.funcod.

do:
    update vdti label "Periodo"
           "a"
           vdtf no-label with frame f-etb.
                
    if (vindex = 2 or vindex = 3) and
       vetbcod > 0
    then do:
        update vfuncod label "Vendedor"
            with frame f-func 1 down side-label.
        if vfuncod > 0
        then do:
            find func where func.etbcod = vetbcod and
                        func.funcod = vfuncod
                        no-lock no-error.
            if not avail func
            then do:
                bell.
                message color red/with
                        "Nenhum registro encontrato para vendedor x filial."
                         view-as alert-box.
                undo.
            end.
            disp func.funnom no-label with frame f-func.
            pause 0.
        end.                         
    end.

    sresp = yes.
    message "Confirma processamento com parametros informados?"
    update sresp.
    if not sresp then undo.
    
    assign vvldesc  = 0 vvlacre  = 0 vmov     = 0 vcon     = 0
               acum-m   = 0 acum-c   = 0 acum-sq  = 0 acum-sm  = 0
               aa-c     = 0 aa-m     = 0
               .

    for each tt-lj where
             tt-lj.etbcod > 0,
        first estab where estab.etbcod = tt-lj.etbcod no-lock:
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
               acum-sq = 0
               acum-sm = 0
               acum-sv = 0
               dia-m   = 0
               dia-c   = 0
               r-inadim = 0
               acum-rcp = 0.

        for each tt-g: delete tt-g. end.
        run mercadologico(estab.etbcod).

        do dt = vdti to vdtimp : 
          
            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:

                disp plani.etbcod 
                        plani.pladat 
                        plani.numero format ">>>>>>9"
                     with 1 down centered color white/red
                     title " venda ".
                pause 0.

                if vfuncod > 0 and
                   plani.vencod <> vfuncod
                then next.   

                vvldesc = 0.
                vvlacre = 0.
                vvalor = 0.

                for each tt-plani: delete tt-plani. end.
                for each tt-movim: delete tt-movim. end.
                
                create tt-plani.
                buffer-copy plani to tt-plani.
                
                find first tt-metacomis where
                           tt-metacomis.etbcod = plani.etbcod and
                           tt-metacomis.funcod = plani.vencod
                           no-error.
                if not avail tt-metacomis
                then do:
                    create tt-metacomis.
                    assign
                        tt-metacomis.etbcod = plani.etbcod 
                        tt-metacomis.funcod = plani.vencod
                            .
                end.            
                mov-bonus = 0.
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
                    if produ.proipiper <> 98
                    then mov-bonus = mov-bonus + 
                                (bmovim.movpc * bmovim.movqtm).
                    
                end.
                
                val_acr = 0.
                val_des = 0.
                
                run ajusta-rateio-venda-pro.p.
                
                val_com = 0.
                
                for each tt-movim no-lock:
                    find produ where produ.procod = tt-movim.procod
                            no-lock no-error.
                    if not avail produ then next.
                    val_acr = 0.
                    val_des = 0.
                    val_dev = 0.
                    val_fin = 0.

                    if tt-movim.movtot <> ?
                    then val_com = val_com + tt-movim.movtot.
                    else assign
                            tt-movim.movtot = 0
                            val_com = 0.

                    if (produ.procod = 559910 or
                        produ.procod = 559911 or
                        produ.procod = 578790 or
                        produ.procod = 579359 or
                        produ.procod = 569131 or
                        produ.procod = 569133 or
                        produ.procod = 569134) 
                    then do:
                        assign
                         acum-sq = acum-sq + 1
                         acum-sv = acum-sv + 
                         (if produ.catcod < 41 then tt-movim.movtot
                         else tt-movim.movpc)
                         tt-metacomis.rseguro = tt-metacomis.rseguro + 1
                         
                         tt-metacomis.g5 = tt-metacomis.g5 + 
                                (if tt-movim.movtot <> ?
                                 then tt-movim.movtot else tt-movim.movpc).
                                 
                           tt-metacomis.g51 = tt-metacomis.g51 + 1.        
                                 
                        if produ.catcod = 81
                        then acum-rcp = acum-rcp +
                                (if tt-movim.movtot <> ?
                                then tt-movim.movtot else tt-movim.movpc).
                    end.     
                    else if produ.catcod = 31 or
                            produ.catcod = 41 or
                            produ.catcod = 35 or
                            produ.catcod = 45
                    then do:
                        tt-metacomis.g3 = tt-metacomis.g3 + 
                                   (if tt-movim.movtot <> ? and
                                       tt-movim.movtot > 
                                       (tt-movim.movpc * tt-movim.movqtm)
                                    then (tt-movim.movtot - 
                                         (tt-movim.movpc * tt-movim.movqtm))
                                    else 0).
                        if produ.catcod = 41
                        then tt-metacomis.g6 = tt-metacomis.g6 +
                                   (tt-movim.movpc * tt-movim.movqtm).
                    end.
                    else if produ.catcod = 81
                    then do:
                        if produ.procod >= 8000 and
                           produ.procod <= 8010
                        then   
                        assign
                             tt-metacomis.g1 = tt-metacomis.g1 +
                                (if tt-movim.movpc <> ?
                                then tt-movim.movpc else 0)
                             acum-rcp = acum-rcp +
                                (if tt-movim.movtot <> ?
                                then tt-movim.movtot else 0)
                             tt-metacomis.g4 = tt-metacomis.g4 +
                                (if tt-movim.movtot <> ?
                                then tt-movim.movtot -
                                  (tt-movim.movpc * tt-movim.movqtm)
                                else 0).
                    end.            
                    find first tt-g where
                               tt-g.clacod = produ.clacod no-error.
                    if avail tt-g
                    then do:
                        
                        if tt-g.tipo = "G1"
                        then do:
                            tt-metacomis.g1 = tt-metacomis.g1 +
                                    (tt-movim.movpc * tt-movim.movqtm).
                                    /*
                                    (if tt-movim.movtot <> ?
                                    then tt-movim.movtot else 0).
                                    */
                        end.            
                        else if tt-g.tipo = "G2"
                        then tt-metacomis.g2 = tt-metacomis.g2 +
                                    (tt-movim.movpc * tt-movim.movqtm).
                                    /*
                                    (if tt-movim.movtot <> ?
                                    then tt-movim.movtot else 0).
                                    */
                    end.           
                    else do:
                        tt-metacomis.g0 = tt-metacomis.g0 +
                                (tt-movim.movpc * tt-movim.movqtm).
                    end.
                    if (produ.catcod = 31 or
                        produ.catcod = 35)
                    then do:
                        acum-m = acum-m + tt-movim.movtot.
                        if plani.pladat = vdtimp
                        then dia-m = dia-m + tt-movim.movtot.
                        tt-metacomis.rvenda = tt-metacomis.rvenda + 
                                                tt-movim.movtot.
                        tt-metacomis.moveis = tt-metacomis.moveis + 
                                            tt-movim.movtot.
                    end.
                    else if (produ.catcod = 41 or
                         produ.catcod = 45)
                    then do:
                         acum-c = acum-c + tt-movim.movtot.
                         if plani.pladat = vdtimp
                         then dia-c = dia-c + tt-movim.movtot.
                         tt-metacomis.rvenda = tt-metacomis.rvenda + 
                                        tt-movim.movtot.
                         tt-metacomis.moda   = tt-metacomis.moda   + 
                                        tt-movim.movtot.
                         /*
                         tt-metacomis.g6 = tt-metacomis.g6 + 
                                        (tt-movim.movpc * tt-movim.movqtm).
                        */
                    end.
                    else tt-metacomis.rvenda = tt-metacomis.rvenda +
                                        tt-movim.movtot.
                end.
                if plani.descprod > 0 and mov-bonus > 0
                then do:
                    run p-lebonus.
                end.
             end.
             run devolucao-de-vendas(estab.etbcod, vfuncod, dt).
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
        wplani.wseg-q  = acum-sq.
        wplani.wseg-v  = acum-sv.
        wplani.wseg-m  = acum-sm.
        wplani.wrcpes  = acum-rcp /*r-inadim*/.

        assign
                vtotalmeta = 0 vmeta-31 = 0 vende-31 = 0 
                        vmeta-41 = 0 vende-41 = 0
                        msegu-31 = 0 msegu-41 = 0 
                        minadin = 0 rinadin = 0
                        minadincp = 0 rinadincp = 0
                        mcrepes = 0.
        run leitura-das-metas(input tt-metacomis.etbcod,
                                  input vdtf,
                                  output vtotalmeta,
                                  output vmeta-31,
                                  output vende-31,
                                  output vmeta-41,
                                  output vende-41,
                                  output msegu-31,
                                  output msegu-41,
                                  output minadin,
                                  output rinadin,
                                  output minadincp,
                                  output rinadincp,
                                  output mcrepes).

        assign
            wplani.wmcpes = mcrepes
            wplani.wrinad = rinadin
            wplani.wminad = minadin.
                 
        tt-acum-c = tt-acum-c + acum-c.
        tt-acum-m = tt-acum-m + acum-m.
        tt-acum-sq = tt-acum-sq + acum-sq.
        tt-acum-sv = tt-acum-sv + acum-sv.
        tt-acum-sm = tt-acum-sm + acum-sm.
    end.

    if vindex = 1
    then do:

        varquivo = "/admcom/folha/export/pla-" + string(time).

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

    put
"                    MODA                                                     "
"      MOVEIS".
        /* SKIP
        fill("-",130) format "x(130)". */

        
        for each wplani by wplani.wetbcod:
            vdia = 0.
            vdia = wplani.wdia.

            valormeta = 0.
            run meta-seguro.
            wplani.wseg-m = valormeta.
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
                                    with no-box frame f-a down width 250.

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

                aa-m = aa-m + wplani.wacum-m.
                mm-m = mm-m + wplani.wmeta-m.
            end.
            disp wplani.wseg-v(total) column-label "Valor!Seguro"
                 wplani.wseg-q(total) column-label "Qtd.!Seguro"
                 wplani.wseg-m(total) column-label "Meta!Seguro"
                 wplani.wrcpes(total) column-label "Realizado!CPes"
                 wplani.wmcpes(total) column-label "Meta!CPes"
                 wplani.wrinad(total) column-label "Realizado!Inadin" 
                 wplani.wminad(total) column-label "Meta!Inadin"
                 with frame f-a.
 
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
                 
                then put fill("-",137) format "x(137)" skip. 
             
                 
        end.
        display (((aa-c / mm-c) * 100) - 100) at 51
                        format "->>>9.99%" no-label
                (((aa-m / mm-m) * 100) - 100) at 118
                        format "->>>9.99%" no-label with frame f-tot no-box
                            no-label width 145. /*137*/
        totmeta = 0.
        totvend = 0.

    output close.

    run visurel.p (input varquivo, input "").
                                        
    end.
    else if vindex = 2
    then do:
        varquivo = "/admcom/folha/export/exporta_rh_" +
                        string(vdti,"99999999") + "_" + 
                        string(vdtf,"99999999") + ".csv" 
                        .
        output to value(varquivo).
        
        put "Filial;Admcom;Folha;G1;G2;G3;G4;G5;G6;Real Inadin CP;
         Meta Inadin CP;Real Venda;Meta Venda;Real Seguro;Meta Seguro;
         Troca/Devol;Bonus"
         skip.
        for each tt-metacomis :
            if tt-metacomis.G1 = 0 and
               tt-metacomis.G2 = 0 and
               tt-metacomis.G3 = 0 and
               tt-metacomis.G4 = 0 and
               tt-metacomis.G6 = 0
            then next.   
            assign
                vtotalmeta = 0 vmeta-31 = 0 vende-31 = 0 
                        vmeta-41 = 0 vende-41 = 0
                        msegu-31 = 0 msegu-41 = 0 
                        minadin = 0 rinadin = 0
                        minadincp = 0 rinadincp = 0
                        mcrepes = 0.
            run leitura-das-metas(input tt-metacomis.etbcod,
                                  input vdtf,
                                  output vtotalmeta,
                                  output vmeta-31,
                                  output vende-31,
                                  output vmeta-41,
                                  output vende-41,
                                  output msegu-31,
                                  output msegu-41,
                                  output minadin,
                                  output rinadin,
                                  output minadincp,
                                  output rinadincp,
                                  output mcrepes).

            if  tt-metacomis.moveis > 0 and vende-31 > 0 and
                tt-metacomis.moveis >= tt-metacomis.moda 
            then assign
                    tt-metacomis.mvenda = vmeta-31 / vende-31
                    tt-metacomis.mseguro = msegu-31 / vende-31.
            else if tt-metacomis.moda > 0 and vende-41 > 0 and
                    tt-metacomis.moda > tt-metacomis.moveis
                then assign
                        tt-metacomis.mvenda = vmeta-41 / vende-41
                        tt-metacomis.mseguro = msegu-41 / vende-41
                        .    
            assign
                tt-metacomis.rinadcp = rinadincp
                tt-metacomis.minadcp = minadincp
                /*
                tt-metacomis.rvenda = tt-metacomis.rvenda -
                            (tt-metacomis.devolucao + tt-metacomis.bonus)
                */
                .
            find func where func.etbcod = tt-metacomis.etbcod and
                            func.funcod = tt-metacomis.funcod
                            no-lock no-error.
            if avail func
            then tt-metacomis.folha = func.usercod.                
            
            assign
                tt-metacomis.g1 = tt-metacomis.g1 -
                        (tt-metacomis.d1 + tt-metacomis.b1)
                tt-metacomis.g2 = tt-metacomis.g2 -
                        (tt-metacomis.d2 + tt-metacomis.b2)
                tt-metacomis.g6 = tt-metacomis.g6 -
                        (tt-metacomis.d6 + tt-metacomis.b6)
                .
                        
            if tt-metacomis.g1 < 0 then tt-metacomis.g1 = 0.
            if tt-metacomis.g2 < 0 then tt-metacomis.g2 = 0.
            if tt-metacomis.g6 < 0 then tt-metacomis.g6 = 0.

            if tt-metacomis.folha <> "" and
               tt-metacomis.rvenda > 0
            then

            put unformatted 
                tt-metacomis.etbcod ";"
                tt-metacomis.funcod ";"
                tt-metacomis.folha  ";"
                replace(string(tt-metacomis.g1, ">>>>>>>9.99"),".",",") ";"
                replace(string(tt-metacomis.g2, ">>>>>>>9.99"),".",",") ";"
                replace(string(tt-metacomis.g3),".",",") ";"
                replace(string(tt-metacomis.g4),".",",") ";"
                replace(string(tt-metacomis.g5),".",",") ";"
                replace(string(tt-metacomis.g6),".",",") ";"
                replace(string(tt-metacomis.rinadcp),".",",") ";"
                replace(string(tt-metacomis.minadcp),".",",") ";"
                replace(string(tt-metacomis.rvenda,">>>>>9.99"),".",",") ";"
                replace(string(tt-metacomis.mvenda,">>>>>9.99"),".",",") ";"
                tt-metacomis.rseguro ";"
                tt-metacomis.mseguro ";"
               replace(string(tt-metacomis.devolucao,">>>>>>>9.99"),".",",") ";"
                /*tt-metacomis.devolucao format ">>>>>>>9,99" ";"*/
                replace(string(tt-metacomis.bonus),".",",") ";"
                skip.
        end.
        output close.
        message color red/with
            "Arquivo gerado: " varquivo
            view-as alert-box.
    end.
    else if vindex = 3
    then do:
        def var v-sem-meta as dec.
        def var v-com-meta as dec.
        def var valorseguro as dec.
        def var tipovendedor as char.
        def var statusvendedor as char.
        def var statusseguro as char.
        def var comissao1 as dec.
        def var comissao2 as dec.
        def var comissao3 as dec. 
        def var comissao4 as dec. 
        def var comissao5 as dec. 
        def var comissao6 as dec. 
        
        
        
        vetbi = vetbcod.
        varquivo = "/admcom/relat/comissaolj_" +
                        string(vdti,"99999999") + "_" + 
                        string(vdtf,"99999999") + "." + string(time)
                        .
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "147"
            &Page-Line = "64"
            &Nom-Rel   = ""plani-4-i-rh""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """FILIAL - "" +
                          string(vetbi) 
                          + "" "" + string (vdti, ""99/99/9999"") +
                          "" ATE  "" + string(vdtf,""99/99/9999"")"
            &Width     = "147"
            &Form      = "frame f-cabcab1"}

        disp with frame f1.
        for each tt-lj no-lock:
            find estab where estab.etbcod = tt-lj.etbcod no-lock no-error.
            if not avail estab then next.
            assign
                vtotalmeta = 0 vmeta-31 = 0 vende-31 = 0 
                        vmeta-41 = 0 vende-41 = 0
                        msegu-31 = 0 msegu-41 = 0 
                        minadin = 0 rinadin = 0
                        minadincp = 0 rinadincp = 0
                        comissao1 = 0 comissao2 = 0 comissao3 = 0
                        comissao4 = 0 comissao5 = 0 comissao6 = 0
                        mcrepes = 0.
            run leitura-das-metas(input tt-lj.etbcod,
                                  input vdtf,
                                  output vtotalmeta,
                                  output vmeta-31,
                                  output vende-31,
                                  output vmeta-41,
                                  output vende-41,
                                  output msegu-31,
                                  output msegu-41,
                                  output minadin,
                                  output rinadin,
                                  output minadincp,
                                  output rinadincp,
                                  output mcrepes).

            for each tt-metacomis where
             (tt-metacomis.moveis > 0 or tt-metacomis.moda > 0):
                if  tt-metacomis.moveis > 0 and vende-31 > 0 and
                    tt-metacomis.moveis >= tt-metacomis.moda 
                then assign
                    tt-metacomis.mvenda = vmeta-31 / vende-31
                    tt-metacomis.mseguro = msegu-31 / vende-31
                    tipovendedor = "MOVEIS".
                else if tt-metacomis.moda > 0 and vende-41 > 0 and
                        tt-metacomis.moda > tt-metacomis.moveis
                    then assign
                        tt-metacomis.mvenda = vmeta-41 / vende-41
                        tt-metacomis.mseguro = msegu-41 / vende-41
                        tipovendedor = "MODA"
                        .    
                
                assign
                    tt-metacomis.rinadcp = rinadincp
                    tt-metacomis.minadcp = minadincp.
            
                find func where func.etbcod = tt-metacomis.etbcod and
                            func.funcod = tt-metacomis.funcod
                            no-lock no-error.
                if avail func
                then tt-metacomis.folha = func.usercod.  
                if tt-metacomis.folha <> "" 
                then do:
                    tt-metacomis.g1 = tt-metacomis.g1 - 
                                (tt-metacomis.d1 + tt-metacomis.b1).
                    if tt-metacomis.g1 < 0 then tt-metacomis.g1 = 0.
                    tt-metacomis.g2 = tt-metacomis.g2 - 
                                (tt-metacomis.d2 + tt-metacomis.b2).
                    if tt-metacomis.g2 < 0 then tt-metacomis.g2 = 0.
                    if tt-metacomis.g5 < 0 then tt-metacomis.g5 = 0.
                
                    tt-metacomis.g6 = tt-metacomis.g6 - 
                                (tt-metacomis.d6).
                    
                   if tt-metacomis.g6 < 0 then tt-metacomis.g6 = 0.   

                    v-sem-meta = 0.
                    v-com-meta = 0.

                     if tt-metacomis.rvenda < tt-metacomis.mvenda
                     then do:
                          statusvendedor = "NAO".
                     end.
                     else do:
                          statusvendedor = "SIM".
                     end.

                      valorseguro = 0.
                      /*CALCULA VALOR COMISSAO DE SEGURO*/
                     if(tt-metacomis.mseguro < tt-metacomis.g51) then do: 
                            statusseguro = "SIM".
                            valorseguro = (G5 * (7.5 / 100)).
                            comissao5 = valorseguro.
                                                           
                     end.
                     else do:
                            statusseguro = "NAO".
                            valorseguro = (G5 * (5 / 100)). 
                            comissao5 = valorseguro.
                     
                     end.




               /*se for moveis eh 1.3 se for moda eh 2.5 */
                 if(tt-metacomis.moveis >= tt-metacomis.moda) then do: 
        
                    v-sem-meta = ((G1 + G2 + G3 + G4) * (1.3 / 100)) +
                              valorseguro + (G6 * (2.5 / 100)).
                    

                   comissao1 = (G1 * (1.3 / 100)).
                   comissao2 = (G2 * (1.3 / 100)).
                   comissao3 = (G3 * (1.3 / 100)).
                   comissao4 = (G4 * (1.3 / 100)).   
                   comissao6 = (G6 * (2.5 / 100)). 

                    end.
                    else do:

                  v-sem-meta = ((G1 + G2 + G4) * (1.3 / 100)) + 
                (G3 * (2.5 / 100)) + valorseguro + (G6 * (2.5 / 100)).   
                    
                         comissao1 = (G1 * (1.3 / 100)). 
                         comissao2 = (G2 * (1.3 / 100)). 
                         comissao3 = (G3 * (2.5 / 100)). 
                         comissao4 = (G4 * (1.3 / 100)). 
                         comissao6 = (G6 * (2.5 / 100)). 

                    end.
                    
                    
                    /*else*/
                    v-com-meta = (G1 * (1.5 / 100)) + (G2 * (2.5 / 100)) +
                             (G3 * (3.5 / 100)) + (G4 * (3.5 / 100)) +
                             valorseguro + (G6 * (3.5 / 100)).
                    
                     comissao1 = (G1 * (1.5 / 100)).  
                     comissao2 = (G2 * (2.5 / 100)).  
                     comissao3 = (G3 * (3.5 / 100)).  
                     comissao4 = (G4 * (3.5 / 100)).  
                     comissao5 = valorseguro.
                     comissao6 = (G6 * (3.5 / 100)).  





                    if tt-metacomis.rvenda > 0
                    then do:


            if(tipovendedor = "MODA" 
            AND tt-metacomis.etbcod <> 1
            AND tt-metacomis.etbcod <> 7
            AND tt-metacomis.etbcod <> 8
            AND tt-metacomis.etbcod <> 9
            AND tt-metacomis.etbcod <> 13
            AND tt-metacomis.etbcod <> 20
            AND tt-metacomis.etbcod <> 21
            AND tt-metacomis.etbcod <> 39
            AND tt-metacomis.etbcod <> 44
            AND tt-metacomis.etbcod <> 48
            AND tt-metacomis.etbcod <> 50
            AND tt-metacomis.etbcod <> 52
            AND tt-metacomis.etbcod <> 64
            AND tt-metacomis.etbcod <> 66
            AND tt-metacomis.etbcod <> 70
            AND tt-metacomis.etbcod <> 72
            AND tt-metacomis.etbcod <> 78
            AND tt-metacomis.etbcod <> 106
            AND tt-metacomis.etbcod <> 108
            AND tt-metacomis.etbcod <> 121) then next.


                    disp tt-metacomis.etbcod column-label "Fl."
                         tipovendedor column-label "Setor"
                        tt-metacomis.funcod  column-label "Func"
                        tt-metacomis.folha   column-label "Folha"
                        func.funnom when avail func  format "x(30)"
                        v-com-meta  column-label "Comissao!Bate meta"
                        v-sem-meta  column-label "Comissao!Nao Bate Meta" 
                /*        statusvendedor  column-label "Meta batida?" */
                        tt-metacomis.rvenda 
                        column-label "Total Venda" format ">>>,>>9.99"
                        tt-metacomis.devol column-label "Troca!Devolucao"
                        /*tt-metacomis.bonus column-label "Bonus"*/
                        tt-metacomis.g1     column-label "G1"
                        tt-metacomis.g2     column-label "G2" 
                        tt-metacomis.g3     column-label "G3" 
                        tt-metacomis.g4     column-label "G4"
                        tt-metacomis.g5     column-label "G5"
               /*         statusseguro  column-label "Meta Seguro?" */
                        tt-metacomis.g6 column-label "G6"
                        /*
                        tt-metacomis.mseguro column-label "MetaSeg"
                        tt-metacomis.g51 column-label "VdaSeg" 
                        comissao1  column-label "C1" 
                        comissao2  column-label "C2" 
                        comissao3  column-label "C3" 
                        comissao4  column-label "C4" 
                        comissao5  column-label "C5" 
                        comissao6  column-label "C6" 
                        */ 
                        with frame f-lj down width 350.
                    down with frame f-lj.     
                    
                    
                    
                    
                    
                    end.
                end.       
            end.
        end.
        output close.
        run visurel.p (input varquivo, input "").
    end.
    
    return.
end.

procedure meta-seguro:
    find first tabaux where
                     tabaux.tabela = "META-VENDA-41" and
                     tabaux.nome_campo = string(wplani.wetbcod,"999") +
                            ";" + string(month(vdtf),"99")
                    no-lock no-error.
    if avail tabaux and
       num-entries(tabaux.valor_campo,";") > 1
    then do:
        valormeta =  valormeta + int(entry(2,tabaux.valor_campo,";")).
        /*if not avail tvendfil or
        tvendfil.moda > int(entry(1,tabaux.valor_campo,";"))
        then valormeta = valormeta / int(entry(1,tabaux.valor_campo,";")).
        else valormeta = valormeta / tvendfil.moda.
        */
    end.
    find first tabaux where
                     tabaux.tabela = "META-VENDA-31" and
                     tabaux.nome_campo = string(wplani.wetbcod,"999") +
                            ";" + string(month(vdtf),"99")
                    no-lock no-error.
    if avail tabaux and num-entries(tabaux.valor_campo,";") > 1
    then do:
        valormeta = valormeta + int(entry(2,tabaux.valor_campo,";")).
        /*if not avail tvendfil or
           tvendfil.moveis > int(entry(1,tabaux.valor_campo,";"))
        then valormeta = valormeta / int(entry(1,tabaux.valor_campo,";")).
        else valormeta = valormeta / tvendfil.moveis.
        */
    end.
end procedure.
procedure mercadologico:
    def input parameter p-etbcod like estab.etbcod.
    def var vclasse like clase.clacod.
    def var vtipo as char.
    def var vi as int.
    def buffer bclase for clase.
    def buffer cclase for clase.
    def buffer dclase for clase.
    find tabmeta where tabmeta.codtm  = 1 and
                   tabmeta.anoref = 0 and
                   tabmeta.mesref = 0 and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = p-etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   no-lock no-error.
    if avail tabmeta
    then do vi = 1 to 20:
        if vi < 11
        then do:
        if valger1[vi] = 0 and valger2[vi] = 0
        then leave.   
        if valger1[vi] > 0
        then do: 
            find clase where clase.clacod = int(valger1[vi]) no-lock no-error.
            if avail clase
            then do:
                if clase.clagrau = 4
                then do:
                    create tt-g.
                    assign
                        tt-g.clacod = clase.clacod
                        tt-g.tipo  = "G1".
                end.
                else do:
                    for each bclase where bclase.clasup = clase.clacod
                                            no-lock:
                        if bclase.clagrau = 4
                        then do:
                            create tt-g.
                            assign
                                tt-g.clacod = bclase.clacod
                                tt-g.tipo  = "G1".
                        end.
                        else do:
                            for each cclase where cclase.clasup = bclase.clacod
                                                no-lock.
                                if cclase.clagrau = 4
                                then do:
                                    create tt-g.
                                    assign
                                        tt-g.clacod = cclase.clacod
                                        tt-g.tipo  = "G1".
                                end.
                                else do:
                                    for each dclase where 
                                             dclase.clasup = cclase.clacod
                                             no-lock:
                                        if dclase.clagrau = 4
                                        then do:
                                            create tt-g.
                                            assign
                                                tt-g.clacod = dclase.clacod
                                                tt-g.tipo  = "G1".
                                        end.        
                                    end.         
                                end.
                            end.    
                        end.
                    end.                        
                end.
            end.
        end.
        if valger2[vi] > 0
        then do: 
            find clase where clase.clacod = int(valger2[vi]) no-lock no-error.
            if avail clase
            then do:
                if clase.clagrau = 4
                then do:
                    create tt-g.
                    assign
                        tt-g.clacod = clase.clacod
                        tt-g.tipo  = "G2".
                end.
                else do:
                    for each bclase where bclase.clasup = clase.clacod
                                            no-lock:
                        if bclase.clagrau = 4
                        then do:
                            create tt-g.
                            assign
                                tt-g.clacod = bclase.clacod
                                tt-g.tipo  = "G2".
                        end.
                        else do:
                            for each cclase where cclase.clasup = bclase.clacod
                                                no-lock.
                                if cclase.clagrau = 4
                                then do:
                                    create tt-g.
                                    assign
                                        tt-g.clacod = cclase.clacod
                                        tt-g.tipo  = "G2".
                                end.
                                else do:
                                    for each dclase where 
                                             dclase.clasup = cclase.clacod
                                             no-lock:
                                        if dclase.clagrau = 4
                                        then do:
                                            create tt-g.
                                            assign
                                                tt-g.clacod = dclase.clacod
                                                tt-g.tipo  = "G2".
                                        end.        
                                    end.         
                                end.
                            end.    
                        end.
                    end.                        
                end.
            end.
        end. 
        end.
        else do:
        if valger3[vi - 10] = 0 and valger4[vi - 10] = 0
        then leave.   
        if valger3[vi - 10] > 0
        then do: 
            find clase where clase.clacod = int(valger3[vi - 10]) no-lock no-error.
            if avail clase
            then do:
                if clase.clagrau = 4
                then do:
                    create tt-g.
                    assign
                        tt-g.clacod = clase.clacod
                        tt-g.tipo  = "G1".
                end.
                else do:
                    for each bclase where bclase.clasup = clase.clacod
                                            no-lock:
                        if bclase.clagrau = 4
                        then do:
                            create tt-g.
                            assign
                                tt-g.clacod = bclase.clacod
                                tt-g.tipo  = "G1".
                        end.
                        else do:
                            for each cclase where cclase.clasup = bclase.clacod
                                                no-lock.
                                if cclase.clagrau = 4
                                then do:
                                    create tt-g.
                                    assign
                                        tt-g.clacod = cclase.clacod
                                        tt-g.tipo  = "G1".
                                end.
                                else do:
                                    for each dclase where 
                                             dclase.clasup = cclase.clacod
                                             no-lock:
                                        if dclase.clagrau = 4
                                        then do:
                                            create tt-g.
                                            assign
                                                tt-g.clacod = dclase.clacod
                                                tt-g.tipo  = "G1".
                                        end.        
                                    end.         
                                end.
                            end.    
                        end.
                    end.                        
                end.
            end.
        end.
        if valger4[vi - 10] > 0
        then do: 
            find clase where clase.clacod = int(valger4[vi - 10]) 
                                no-lock no-error.
            if avail clase
            then do:
                if clase.clagrau = 4
                then do:
                    create tt-g.
                    assign
                        tt-g.clacod = clase.clacod
                        tt-g.tipo  = "G2".
                end.
                else do:
                    for each bclase where bclase.clasup = clase.clacod
                                            no-lock:
                        if bclase.clagrau = 4
                        then do:
                            create tt-g.
                            assign
                                tt-g.clacod = bclase.clacod
                                tt-g.tipo  = "G2".
                        end.
                        else do:
                            for each cclase where cclase.clasup = bclase.clacod
                                                no-lock.
                                if cclase.clagrau = 4
                                then do:
                                    create tt-g.
                                    assign
                                        tt-g.clacod = cclase.clacod
                                        tt-g.tipo  = "G2".
                                end.
                                else do:
                                    for each dclase where 
                                             dclase.clasup = cclase.clacod
                                             no-lock:
                                        if dclase.clagrau = 4
                                        then do:
                                            create tt-g.
                                            assign
                                                tt-g.clacod = dclase.clacod
                                                tt-g.tipo  = "G2".
                                        end.        
                                    end.         
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

procedure leitura-das-metas:    
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-data as date.
    def output parameter vtotalmeta as dec.
    def output parameter vmeta-31 as dec.
    def output parameter vende-31 as dec.
    def output parameter vmeta-41 as dec.
    def output parameter vende-41 as dec.
    def output parameter msegu-31 as dec.
    def output parameter msegu-41 as dec.
    def output parameter minadin  as dec.
    def output parameter rinadin  as dec.
    def output parameter minadincp as dec.
    def output parameter rinadincp as dec.
    def output parameter mcrepes   as dec.
    
    assign
        vtotalmeta = 0
        vmeta-31   = 0
        vende-31   = 0
        vmeta-41   = 0
        vende-41   = 0
        msegu-31   = 0
        msegu-41   = 0
        .
    
    for each duplic where duplic.fatnum = p-etbcod and
                          duplic.duppc = month(p-data)
                          no-lock.
        vtotalmeta = vtotalmeta + duplic.dupval + duplic.dupjur.
        vmeta-31 = vmeta-31 + duplic.dupjur.
        vmeta-41 = vmeta-41 + duplic.dupval.
    end.

    find first tvendfil where
                   tvendfil.anoref = year(p-data) and
                   tvendfil.mesref = month(p-data) and
                   tvendfil.etbcod = p-etbcod
                    no-lock no-error.
    
    /*if p-tipo = 31
    then*/ do:
        find first tabaux where
               tabaux.tabela = "META-VENDA-31" and
               tabaux.nome_campo = string(p-etbcod,"999") +
                                   ";" + string(month(p-data),"99")
                no-lock no-error.
        if avail tabaux and tabaux.valor_campo <> ""
        then do:
            if num-entries(tabaux.valor_campo,";") = 1
            then if not avail tvendfil
                    or tvendfil.moveis > int(tabaux.valor_campo)
                then vende-31 = int(tabaux.valor_campo).
                else vende-31 = tvendfil.moveis.
            else do:
                if not avail tvendfil
                    or tvendfil.moveis > int(entry(1,tabaux.valor_campo,";"))
                then vende-31 = int(entry(1,tabaux.valor_campo,";")).
                else vende-31 = tvendfil.moveis.
                msegu-31 = int(entry(2,tabaux.valor_campo,";")).
            end.
        end.
        else if avail tvendfil
            then vende-31 = tvendfil.moveis.
            else vende-31 = 0.
        if vende-31 = ? then vende-31 = 0.
        if msegu-31 = ? then msegu-31 = 0.
    end.
    /*if p-tipo = 41
    then*/ do:
        find first tabaux where
                   tabaux.tabela = "META-VENDA-41" and
                   tabaux.nome_campo = string(p-etbcod,"999") +
                                   ";" + string(month(p-data),"99")
               no-lock no-error.
        if avail tabaux and tabaux.valor_campo <> ""
        then do:
            if num-entries(tabaux.valor_campo,";") = 1
            then if not avail tvendfil
                            or tvendfil.moda > int(tabaux.valor_campo)
                    then vende-41 = int(tabaux.valor_campo).
                    else vende-41 = tvendfil.moda.
            else do:
                if not avail tvendfil
                    or tvendfil.moda > int(entry(1,tabaux.valor_campo,";"))
                    then vende-41 = int(entry(1,tabaux.valor_campo,";")).
                    else vende-41 = tvendfil.moda.
                msegu-41 = int(entry(2,tabaux.valor_campo,";")).
            end.
        end.
        else if avail tvendfil
            then vende-41 = tvendfil.moda.
            else vende-41 = 0.
        if vende-41 = ? then vende-41 = 0.
        if msegu-41 = ? then msegu-41 = 0.
    end.
    find tabmeta where tabmeta.codtm  = 4 and
                   tabmeta.anoref = year(p-data) and
                   tabmeta.mesref = month(p-data) and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = p-etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   no-lock no-error.
    if avail tabmeta
    then assign
             minadin = tabmeta.ValMeta4[1]
             rinadin = tabmeta.ValMeta5[1]
             minadincp = tabmeta.ValMeta4[2]
             rinadincp = tabmeta.ValMeta5[2]
             .  
    find tabmeta where tabmeta.codtm  = 3 and
                   tabmeta.anoref = year(p-data) and
                   tabmeta.mesref = month(p-data) and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = p-etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   no-lock no-error.
    if avail tabmeta
    then assign
             mcrepes = tabmeta.val_meta.
end procedure.

procedure devolucao-venda:
    /*****
    def buffer cplani for plani.
    def buffer dplani for plani.
    def buffer cmovim for movim.
    def buffer dmovim for movim.
    
    def var vtotal-dev as dec.
    vtotal-dev = 0.
    for each dplani where dplani.etbcod = estab.etbcod and
                             dplani.movtdc = 12 and
                             dplani.pladat = dt and
                             dplani.serie = "1" no-lock:

        for each ctdevven where
                     ctdevven.etbcod = dplani.etbcod and
                     ctdevven.placod = dplani.placod and
                     ctdevven.movtdc = dplani.movtdc
                     no-lock .

            find first cplani where
                           cplani.etbcod = ctdevven.etbcod-ori and
                           cplani.placod = ctdevven.placod-ori and
                           cplani.movtdc = ctdevven.movtdc-ori
                           no-lock no-error.
            if not avail cplani then next.
            if vetbcod > 0 and cplani.etbcod <> vetbcod
            then next.
            vtotal-dev = 0.
            for each dmovim where 
                     dmovim.etbcod = dplani.etbcod and
                     dmovim.placod = dplani.placod and
                     dmovim.movtdc = dplani.movtdc
                     no-lock:
                     
                find first cmovim where
                           cmovim.etbcod = cplani.etbcod and
                           cmovim.placod = cplani.placod and
                           cmovim.movtdc = cplani.movtdc and
                           cmovim.procod = dmovim.procod
                           no-lock no-error.
                if avail cmovim
                then do:
                    if dmovim.movqtm > cmovim.movqtm
                    then vtotal-dev = vtotal-dev + 
                            (cmovim.movpc * cmovim.movqtm).
                    else vtotal-dev = vtotal-dev +
                            (cmovim.movpc * dmovim.movqtm).

                    create dv-movim.
                    dv-movim.procod = cmovim.procod.
                    dv-movim.movpc = cmovim.movpc.
                    if dmovim.movqtm > cmovim.movqtm
                    then dv-movim.movqtm = cmovim.movqtm.
                    else dv-movim.movqtm = dmovim.movqtm.
                    
                end.
            end.
            /*
            find tippro where tippro.tprcod = tipo no-lock no-error.
            */
            
            disp cplani.etbcod 
                 cplani.pladat 
                 cplani.numero format ">>>>>>9"
                     with 1 down centered color white/red
                     title " devolucao ".
            pause 0.

            find first cmovim where cmovim.etbcod = cplani.etbcod and
                                   cmovim.placod = cplani.placod and
                                   cmovim.movtdc = cplani.movtdc and
                                   cmovim.movdat = cplani.pladat
                                                    no-lock no-error.

            /***
            if vtprcod = 3
            then vtprcod = 1.

            if vtprcod = 4
            then vtprcod = 2.


            if vtprcod = 1
            then vcatcod = 41.
            else vcatcod = 31.
 
            valtotal = 0.
            if vcatcod <> 31
            then vignora = no.
            else vignora = yes.
            if vcatcod > 0
            then*/
            for each cmovim where cmovim.etbcod = cplani.etbcod and
                                 cmovim.placod = cplani.placod and
                                 cmovim.movtdc = cplani.movtdc and
                                 cmovim.movdat = cplani.pladat
                                     no-lock:
                find first produ where produ.procod = cmovim.procod
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
 
            def var val-recarga as dec.
            def var acr-recarga as dec.
            def var des-recarga as dec.
            assign
                val-recarga = 0
                acr-recarga = 0
                des-recarga = 0.
                    
            for each cmovim where cmovim.etbcod = cplani.etbcod and
                                   cmovim.placod = cplani.placod and
                                   cmovim.movtdc = cplani.movtdc and
                                   cmovim.movdat = cplani.pladat
                                                    no-lock .

            
                find produ where produ.procod = cmovim.procod no-lock no-error.
                if avail produ and
                   produ.pronom matches "*recarga*"
                   then assign
                            val-recarga = val-recarga +
                                (cmovim.movpc * cmovim.movqtm)
                            acr-recarga = ((cmovim.movpc * cmovim.movqtm) /
                                            cplani.platot) * cplani.acfprod
                            des-recarga = ((cmovim.movpc * cmovim.movqtm) / 
                                            cplani.platot) * cplani.descprod.
                        
            end.
            if val-recarga < 0 or val-recarga = ?
            then val-recarga = 0.
            if acr-recarga < 0 or acr-recarga = ?
            then acr-recarga = 0.
            if des-recarga < 0 or des-recarga = ?
            then des-recarga = 0.
                        
            if vfuncod <> 0 and
               vfuncod <> cplani.vencod
            then next.
            /*
            vcatcod = vtprcod.
            */
            val_acr = 0.
            val_des = 0.
            
            if cplani.biss > (cplani.platot - cplani.vlserv)
            then val_acr = cplani.biss -
                        (cplani.platot - cplani.vlserv).
            else val_acr = cplani.acfprod.
            
            val_des = val_des + cplani.descprod.
                
            assign
                val_acr = val_acr - acr-recarga
                val_des = val_des - des-recarga
                .
                
            if val_acr < 0 or val_acr = ?
            then val_acr = 0.
            def var valtotal as dec.
            valtotal = valtotal + ((cplani.platot - val-recarga) -
                  val_des + val_acr) .
            
            valtotal = valtotal * (vtotal-dev / valtotal).
            def var valor-bonus as dec.
            run p-lebonus(output valor-bonus).
            if valor-bonus = ? then valor-bonus = 0.
            if valtotal = ? then valtotal = 0.
            if valtotal = 0 and
                valor-bonus = 0 then next.

            find first tt-metacomis where
                       tt-metacomis.etbcod = cplani.etbcod and
                       tt-metacomis.funcod = cplani.vencod
                       no-error.
            if not avail tt-metacomis
            then do:
                create tt-metacomis.
                assign
                        tt-metacomis.etbcod = cplani.etbcod 
                        tt-metacomis.funcod = cplani.vencod
                            .
            end.            

            tt-metacomis.devolucao = tt-metacomis.devolucao +
                                        (valtotal - valor-bonus). 


            for each dmovim where
             dmovim.etbcod = dplani.etbcod and
             dmovim.placod = dplani.placod and
             dmovim.movtdc = dplani.movtdc and
             dmovim.movdat = dplani.pladat
             no-lock:
            find produ where produ.procod = dmovim.procod no-lock no-error.
            if not avail produ
            then next.

            if produ.catcod >= 41 and
                    produ.catcod < 50
                then tt-metacomis.d6 = tt-metacomis.d6 +
                                        (dmovim.movpc * dmovim.movqtm).
                                             
            find first tt-g where
                       tt-g.clacod = produ.clacod no-error.
            if avail tt-g
            then do:
                if tt-g.tipo = "G1"
                then tt-metacomis.d1 = tt-metacomis.d1 +
                                        (dmovim.movpc * dmovim.movqtm).
                else if tt-g.tipo = "G2"
                then tt-metacomis.d2 = tt-metacomis.d2 +
                                        (dmovim.movpc * dmovim.movqtm).
             
            end. 
            tt-metacomis.devolucao = tt-metacomis.devolucao +
                            (dmovim.movpc * dmovim.movqtm).
            
        end.         end.
    end.
    ********/
end procedure.
procedure p-lebonus:
    
    def var /*output parameter*/ p-valor-bonus like titulo.titvlcob.
    
    find first titulo where titulo.empcod   = 19
                        and titulo.titnat   = yes
                        and titulo.clifor   = plani.desti 
                        and titulo.modcod   = "BON" 
                        and titulo.titdtpag = plani.pladat 
                        and titulo.titvlpag = plani.descprod no-lock no-error.
    if avail titulo
    then p-valor-bonus = titulo.titvlpag.
    else p-valor-bonus = 0.

    find first tt-metacomis where
                   tt-metacomis.etbcod = plani.etbcod
               and tt-metacomis.funcod = plani.vencod
                   no-error.
        if not avail tt-metacomis
        then do:
            create tt-metacomis.
            assign
                tt-metacomis.etbcod = plani.etbcod
                tt-metacomis.funcod = plani.vencod
                .
        end. 
        tt-metacomis.bonus = tt-metacomis.bonus + p-valor-bonus.
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc
                         no-lock:
        find produ where produ.procod = movim.procod no-lock no-error. 
        if not avail produ or produ.proipiper = 98
        then next.
        
        find first tt-g where
                       tt-g.clacod = produ.clacod no-error.
            if avail tt-g
            then do:
                if tt-g.tipo = "G1"
                then tt-metacomis.b1 = tt-metacomis.b1 +
                 (p-valor-bonus * ((movim.movpc * movim.movqtm) / mov-bonus)).
                else if tt-g.tipo = "G2"
                then tt-metacomis.b2 = tt-metacomis.b2 +
                 (p-valor-bonus * ((movim.movpc * movim.movqtm) / mov-bonus)).
            end. 
                             
    end.                     
 end procedure.

procedure nova-devolucao:
    def input parameter p-data as date.
    def input parameter p-etbcod like estab.etbcod.

    def var valor-bonus as dec.
    for each dev-movim: delete dev-movim. end.
    
    def var vtotal-des as dec.
    
    def buffer cplani for plani.
    def buffer dplani for plani.
    def buffer cmovim for movim.
    def buffer dmovim for movim.
    
    def var vtotal-dev as dec.
    vtotal-dev = 0.
    for each dplani where dplani.etbcod = p-etbcod and
                             dplani.movtdc = 12 and
                             dplani.pladat = p-data and
                             dplani.serie = "1" no-lock:

        for each ctdevven where
                     ctdevven.etbcod = dplani.etbcod and
                     ctdevven.placod = dplani.placod and
                     ctdevven.movtdc = dplani.movtdc
                     no-lock .

            find first cplani where
                           cplani.etbcod = ctdevven.etbcod-ori and
                           cplani.placod = ctdevven.placod-ori and
                           cplani.movtdc = ctdevven.movtdc-ori
                           no-lock no-error.
            if not avail cplani then next.
            if p-etbcod > 0 and cplani.etbcod <> p-etbcod
            then next.
            vtotal-dev = 0.
            for each dmovim where 
                     dmovim.etbcod = dplani.etbcod and
                     dmovim.placod = dplani.placod and
                     dmovim.movtdc = dplani.movtdc
                     no-lock:
                     
                find first cmovim where
                           cmovim.etbcod = cplani.etbcod and
                           cmovim.placod = cplani.placod and
                           cmovim.movtdc = cplani.movtdc and
                           cmovim.procod = dmovim.procod
                           no-lock no-error.
                if avail cmovim
                then do:
                    if dmovim.movqtm > cmovim.movqtm
                    then vtotal-dev = vtotal-dev + 
                            (cmovim.movpc * cmovim.movqtm).
                    else vtotal-dev = vtotal-dev +
                            (cmovim.movpc * dmovim.movqtm).
                    create dev-movim.
                    dev-movim.procod = cmovim.procod.
                    dev-movim.movpc = cmovim.movpc.
                    if dmovim.movqtm > cmovim.movqtm
                    then dev-movim.movqtm = cmovim.movqtm.
                    else dev-movim.movqtm = dmovim.movqtm.
                end.
            end.
            /*
            find tippro where tippro.tprcod = tipo no-lock no-error.
            */
            
            disp cplani.etbcod 
                 cplani.pladat 
                 cplani.numero format ">>>>>>9"
                     with 1 down centered color white/red
                     title " devolucao ".
            pause 0.

            find first cmovim where cmovim.etbcod = cplani.etbcod and
                                   cmovim.placod = cplani.placod and
                                   cmovim.movtdc = cplani.movtdc and
                                   cmovim.movdat = cplani.pladat
                                                    no-lock no-error.

            /***
            if vtprcod = 3
            then vtprcod = 1.

            if vtprcod = 4
            then vtprcod = 2.


            if vtprcod = 1
            then vcatcod = 41.
            else vcatcod = 31.
 
            valtotal = 0.
            if vcatcod <> 31
            then vignora = no.
            else vignora = yes.
            if vcatcod > 0
            then*/
            
            /***
            for each cmovim where cmovim.etbcod = cplani.etbcod and
                                 cmovim.placod = cplani.placod and
                                 cmovim.movtdc = cplani.movtdc and
                                 cmovim.movdat = cplani.pladat
                                     no-lock:
                find first produ where produ.procod = cmovim.procod
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
            ***/
            
            def var val-recarga as dec.
            def var acr-recarga as dec.
            def var des-recarga as dec.
            assign
                val-recarga = 0
                acr-recarga = 0
                des-recarga = 0.
                    
            for each cmovim where cmovim.etbcod = cplani.etbcod and
                                   cmovim.placod = cplani.placod and
                                   cmovim.movtdc = cplani.movtdc and
                                   cmovim.movdat = cplani.pladat
                                                    no-lock .

            
                find produ where produ.procod = cmovim.procod no-lock no-error.
                if avail produ and
                   produ.pronom matches "*recarga*"
                   then assign
                            val-recarga = val-recarga +
                                (cmovim.movpc * cmovim.movqtm)
                            acr-recarga = ((cmovim.movpc * cmovim.movqtm) /
                                            cplani.platot) * cplani.acfprod
                            des-recarga = ((cmovim.movpc * cmovim.movqtm) / 
                                            cplani.platot) * cplani.descprod.
                        
            end.
            if val-recarga < 0 or val-recarga = ?
            then val-recarga = 0.
            if acr-recarga < 0 or acr-recarga = ?
            then acr-recarga = 0.
            if des-recarga < 0 or des-recarga = ?
            then des-recarga = 0.
                        
            if vfuncod <> 0 and
               vfuncod <> cplani.vencod
            then next.
            
            /*
            vcatcod = vtprcod.
            */
            def var val_acr as dec. 
            def var val_des as dec.
            val_acr = 0.
            val_des = 0.
            
            if cplani.biss > (cplani.platot - cplani.vlserv)
            then val_acr = cplani.biss -
                        (cplani.platot - cplani.vlserv).
            else val_acr = cplani.acfprod.
            
            val_des = val_des + cplani.descprod.
                
            assign
                val_acr = val_acr - acr-recarga
                val_des = val_des - des-recarga
                .
                
            if val_acr < 0 or val_acr = ?
            then val_acr = 0.
            def var valtotal as dec.
            valtotal = valtotal + ((cplani.platot - val-recarga) -
                  val_des + val_acr) .
            
            
            valtotal = valtotal * (vtotal-dev / valtotal).

            /*
            if avail cplani
            then
            run p-lebonus(output valor-bonus).
            if valor-bonus = ? then valor-bonus = 0.
            */
            if valtotal = ? then valtotal = 0.
            if valtotal = 0 and
                valor-bonus = 0 then next.

            find first tt-metacomis where
                       tt-metacomis.etbcod = cplani.etbcod and
                       tt-metacomis.funcod = cplani.vencod
                       no-error.
            if not avail tt-metacomis
            then do:
                create tt-metacomis.
                assign
                        tt-metacomis.etbcod = cplani.etbcod 
                        tt-metacomis.funcod = cplani.vencod
                            .
            end.            

            tt-metacomis.devolucao = tt-metacomis.devolucao +
                                        (valtotal - valor-bonus). 

            for each dev-movim where
                     dev-movim.procod > 0 no-lock:
                find produ where produ.procod = dev-movim.procod
                         no-lock no-error.
                if not avail produ then next.

                if produ.catcod >= 41 and
                    produ.catcod < 50
                then tt-metacomis.d6 = tt-metacomis.d6 +
                    ((valtotal - valor-bonus) *
                     ((dev-movim.movpc * dev-movim.movqtm) / cplani.platot)).
                                             
                find first tt-g where
                       tt-g.clacod = produ.clacod no-error.
                if avail tt-g
                then do:
                    if tt-g.tipo = "G1"
                    then tt-metacomis.d1 = tt-metacomis.d1 +
                        ((valtotal - valor-bonus) *
                        ((dev-movim.movpc * dev-movim.movqtm) / cplani.platot)).
                    else if tt-g.tipo = "G2"
                    then tt-metacomis.d2 = tt-metacomis.d2 +
                        ((valtotal - valor-bonus) *
                        ((dev-movim.movpc * dev-movim.movqtm) / cplani.platot)).
                end. 
            end.             

        end.
    end.

    /*******    
    def input parameter p-data as date.
    def input parameter p-etbcod like estab.etbcod.
    
    def buffer dplani for plani.
    def buffer oplani for plani.
    def buffer nplani for plani.
    def buffer dmovim for movim.
    def buffer omovim for movim.
    def buffer nmovim for movim.
    def var m-etbcod like estab.etbcod.
    def var m-vencod like plani.vencod.
    
    for each ctdevven where
         ctdevven.pladat = p-data and
         ctdevven.etbcod = p-etbcod and
         ctdevven.etbcod-ori > 0 
         no-lock:
        find first dplani where
               dplani.etbcod = ctdevven.etbcod and
               dplani.placod = ctdevven.placod and
               dplani.movtdc = ctdevven.movtdc
               no-lock no-error.
        if not avail dplani then next.
        find first oplani where
               oplani.etbcod = ctdevven.etbcod-ori and
               oplani.placod = ctdevven.placod-ori and
               oplani.movtdc = ctdevven.movtdc-ori
               no-lock no-error.
        if not avail oplani or
            (ctdevven.etbcod-ven = 0 and
            oplani.etbcod <> ctdevven.etbcod)
        then next.
        find nplani where nplani.etbcod = ctdevven.etbcod-ven and
                            nplani.placod = ctdevven.placod-ven and
                            nplani.movtdc = ctdevven.movtdc-ven
                            no-lock no-error.
        
        if avail nplani
        then assign
                 m-etbcod = nplani.etbcod
                 m-vencod = nplani.vencod.
        else assign
                 m-etbcod = oplani.etbcod
                 m-vencod = oplani.vencod.
        find first tt-metacomis where
                   tt-metacomis.etbcod = m-etbcod
               and tt-metacomis.funcod = m-vencod
                   no-error.
        if not avail tt-metacomis
        then do:
            create tt-metacomis.
            assign
                tt-metacomis.etbcod = m-etbcod
                tt-metacomis.funcod = m-vencod
                .
        end. 
        for each dmovim where
             dmovim.etbcod = dplani.etbcod and
             dmovim.placod = dplani.placod and
             dmovim.movtdc = dplani.movtdc and
             dmovim.movdat = dplani.pladat
             no-lock:
            find produ where produ.procod = dmovim.procod no-lock no-error.
            if not avail produ
            then next.

            if produ.catcod >= 41 and
                    produ.catcod < 50
                then tt-metacomis.d6 = tt-metacomis.d6 +
                                        (dmovim.movpc * dmovim.movqtm).
                                             
            find first tt-g where
                       tt-g.clacod = produ.clacod no-error.
            if avail tt-g
            then do:
                if tt-g.tipo = "G1"
                then tt-metacomis.d1 = tt-metacomis.d1 +
                                        (dmovim.movpc * dmovim.movqtm).
                else if tt-g.tipo = "G2"
                then tt-metacomis.d2 = tt-metacomis.d2 +
                                        (dmovim.movpc * dmovim.movqtm).
             
            end. 
            tt-metacomis.devolucao = tt-metacomis.devolucao +
                            (dmovim.movpc * dmovim.movqtm).
            
        end.         
    end.
    *************/
end procedure.

procedure devolucao-de-vendas:
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-funcod like func.funcod.
    def input parameter p-data   like plani.pladat.

    def var valtotal as dec.
    def var valacrescimo as dec.
    def var valservico as dec.
    def buffer dplani for plani.
    def buffer dmovim for movim.
    def buffer oplani for plani.
    def buffer omovim for movim.

    for each ctdevven where
         ctdevven.etbcod = p-etbcod and
         ctdevven.movtdc = 12 and
         ctdevven.pladat = p-data 
         no-lock:
        find first dplani where dplani.etbcod = ctdevven.etbcod and
                           dplani.placod = ctdevven.placod and
                           dplani.movtdc = ctdevven.movtdc and
                           dplani.serie  = ctdevven.serie
                           no-lock no-error.
        if not avail dplani then next.
        find first oplani where
               oplani.etbcod = ctdevven.etbcod-ori and
               oplani.placod = ctdevven.placod-ori and
               oplani.movtdc = ctdevven.movtdc-ori and
               oplani.pladat = ctdevven.pladat-ori and
               oplani.serie  = ctdevven.serie-ori
               no-lock no-error.
        if not avail oplani then next.
        if oplani.etbcod <> p-etbcod then next.
        if p-funcod > 0 and oplani.vencod <> p-funcod then next.           
        valtotal = oplani.platot.
        valservico = oplani.vlserv.
        valacrescimo = 0. 
        if ctdevven.etbcod-ven = 0
        then valacrescimo = oplani.biss - (valtotal - valservico).
        if  valacrescimo = ? or
            valacrescimo < 0
        then valacrescimo = 0.   

        find first tt-metacomis where
               tt-metacomis.etbcod = oplani.etbcod and
               tt-metacomis.funcod = oplani.vencod
               no-error.
        if not avail tt-metacomis
        then do:
            create tt-metacomis.
            assign
                tt-metacomis.etbcod = oplani.etbcod 
                tt-metacomis.funcod = oplani.vencod
                .
        end. 
                
        for each dmovim where
             dmovim.etbcod = dplani.etbcod and
             dmovim.placod = dplani.placod and
             dmovim.movtdc = dplani.movtdc and
             dmovim.movdat = dplani.pladat
             no-lock:
            find produ where produ.procod = dmovim.procod no-lock no-error.
            if not avail produ then next.
            find first omovim where
                   omovim.etbcod = oplani.etbcod and
                   omovim.placod = oplani.placod and
                   omovim.movtdc = oplani.movtdc and
                   omovim.movdat = oplani.pladat and
                   omovim.procod = dmovim.procod
                   no-lock no-error.
            if avail omovim
            then do:           
                find produ where produ.procod = omovim.procod no-lock.

                tt-metacomis.devolucao = tt-metacomis.devolucao +
                    (omovim.movpc * dmovim.movqtm). 

                if  produ.catcod > 40 and
                    produ.catcod < 51         
                then tt-metacomis.d6 = tt-metacomis.d6 +
                        (omovim.movpc * dmovim.movqtm).
                if valacrescimo > 0
                then assign 
                    tt-metacomis.d3 = tt-metacomis.d3 +
                 (valacrescimo * ((omovim.movpc * dmovim.movqtm) / valtotal))
                    tt-metacomis.devolucao = tt-metacomis.devolucao +
                 (valacrescimo * ((omovim.movpc * dmovim.movqtm) / valtotal))   
                 .
            
                find first tt-g where
                       tt-g.clacod = produ.clacod no-error.
                if avail tt-g
                then do:
                    if tt-g.tipo = "G1"
                    then tt-metacomis.d1 = tt-metacomis.d1 +
                              (omovim.movpc * dmovim.movqtm).
                    if tt-g.tipo = "G2"
                    then tt-metacomis.d2 = tt-metacomis.d2 +
                              (omovim.movpc * dmovim.movqtm).
                end.                                  
            end.
        end.
    end.
end procedure.


