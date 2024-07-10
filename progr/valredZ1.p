{admcab.i new}

def input parameter vetbi like estab.etbcod.
def input parameter vetbf like estab.etbcod.
def input parameter vdti as date.
def input parameter vdtf as date.

def var vstatus as char.
def var vip as char.
def var varq_log as char format "x(40)".
varq_log = "/admcom/logs/valZcup.log".

def var t1 as dec decimals 4 format ">>,>>>,>>9.9999".
def var t2 as dec decimals 4 format ">>,>>>,>>9.9999".
def var t3 as dec decimals 4 format ">>,>>>,>>9.9999".
def var t4 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d1 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d2 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d3 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d4 as dec decimals 4 format ">>,>>>,>>9.9999".
def var dcan as dec.

def var agt as dec.

def buffer cmapctb for mapctb.
def buffer emapctb for mapctb.

def temp-table tt-caixa
    field etbcod as int format ">>9"
    field cxacod as int format ">>9"
    field equip  as int format ">>9"
    field serie  as char format "x(20)"        label "Serial     "
    field datmov as date
    field datatu as date
    field datred as date 
    field gti as dec  format "->>,>>>,>>9.99"  label "GT Inicial "
    field gtf as dec  format "->>,>>>,>>9.99"  label "GT Final   "
    field t01 as dec  label "Reducao 17%"
    field t02 as dec
    field t03 as dec
    field t04 as dec
    field t05 as dec
    field tsub as dec label "Reducao ST "
    field tcan as dec label "Reducao Can"
    field c01 as dec  label "Cupom 17%  "
    field c02 as dec
    field c03 as dec
    field c04 as dec
    field c05 as dec
    field csub as dec label "Cupom ST   "
    field ccan as dec label "Cupom Can  "
    field d01 as dec  label "Dif 17%  "
    field d02 as dec
    field d03 as dec
    field d04 as dec
    field d05 as dec
    field dsub as dec label "Dif ST   "
    field dcan as dec label "Dif Can  "
    field difer as log init no 
    field red as char format "x"
    field cup as char format "x"
    field difred as dec
    field valctb as dec
    field totdif as dec
    field nrored like mapctb.nrored
    field cooini like mapctb.cooini
    field coofin like mapctb.coofin
    field vldes  like mapctb.vldes
    .

def temp-table tt-redz
    field etbcod like estab.etbcod
    field equipa as int
    field datref as date
    index i1 etbcod datref
.    
def buffer bmapctb for mapctb.

def var vlinha as char.

def var dgt as dec.
def var d01 as dec.
def var d04 as dec.
def var dca as dec. 

def var vda1 as dec.
def var vda2 as dec.
def var tvda as dec.   

def var vgt as dec.
def var vgtf as dec.
def var totecf as dec.

def var vetbcod like estab.etbcod.
def var vdata as date.

def var vequip as int.

def var vdif1 as dec.
def var vdif2 as dec.
def var vdif3 as dec.
def var vdif4 as dec.
def var vequip1 as int.

def temp-table tt-tabecf like tabecf.

def var vetbcod1 like estab.etbcod.

def var vqc as int.

vgt = 0.
vgtf = 0. 

def var vmovpc like movim.movpc.
def var valor as dec.
def var vl-can as dec.
def var vl1-can as dec.
def var vqtd as int.

procedure valida-cupom:

for each estab where estab.etbcod < 200 /*and
                estab.etbnom begins "DREBES-FIL"*/ no-lock:
            
    if estab.etbcod >= vetbi and
       estab.etbcod <= vetbf
    then. else next.

    if estab.etbcod = 22 or
       estab.etbcod = 189
    then next.
    
    disp estab.etbcod  with frame f2. pause 0.

    for each  tt-tabecf . delete tt-tabecf . end.

    if vequip1 = 0
    then do:
        for each tabecf where
             tabecf.etbcod = estab.etbcod no-lock:
        if (tabecf.datini <= vdti and
           tabecf.datfin >= vdtf) or
           (tabecf.datini <= vdti and
            tabecf.datfin >= vdti and
            tabecf.datfin <= vdtf) or
           (tabecf.datini >= vdti and
            tabecf.datini <= vdtf and
            tabecf.datfin > tabecf.datini)
        then do:   
            create tt-tabecf.
            buffer-copy tabecf to tt-tabecf.
        end.
    end.
    end.
    else do:
        find first tabecf where
               tabecf.etbcod = estab.etbcod and
               tabecf.equip = vequip1 and
               tabecf.datini <= vdti and
               tabecf.datfin >= vdtf
               no-lock no-error.
        if avail tabecf
        then do:
            create tt-tabecf.
            buffer-copy tabecf to tt-tabecf.
        end.
    end.                
    for each tt-tabecf where tt-tabecf.equipa > 0:
        vequip = tt-tabecf.equipa.
         
        disp vequip with frame f2 .
        pause 0.
        
        vgt = 0.
        vgtf = 0. 

        do vdata = vdti to vdtf:

            disp vdata with frame f2.
            pause 0.
            t1 = 0.
            t4 = 0.

            find last tabecf where tabecf.etbcod = estab.etbcod and
                       tabecf.equip  = vequip and
                       /*tabecf.datini <= vdata and
                       tabecf.datfin >= vdata*/
                       tabecf.datini = tt-tabecf.datini and
                       tabecf.datfin = tt-tabecf.datfin
                       no-lock no-error.
    
            
            find first bmapctb where bmapctb.etbcod = estab.etbcod and
                       bmapctb.ch1    = tabecf.serie and 
                       bmapctb.datmov = vdata and
                       bmapctb.cxacod = vequip
                       no-error.

            if not avail bmapctb
            then do:
                find first bmapctb where 
                           bmapctb.etbcod = estab.etbcod and
                           bmapctb.datmov = vdata and
                           bmapctb.cxacod = vequip
                           no-error.
                if avail bmapctb
                then do:
                    run ver-mapctb.
                    find first bmapctb where bmapctb.etbcod = estab.etbcod and
                       bmapctb.ch1    = tabecf.serie and 
                       bmapctb.datmov = vdata and
                       bmapctb.cxacod = vequip
                       no-error.
                    if not avail bmapctb
                    then next.   
                end.
                else next.
            end.

            if bmapctb.ch1 = ""
            then find last mapctb use-index ind-2 
                        where mapctb.etbcod = bmapctb.etbcod and
                              mapctb.ch1    = bmapctb.ch1    and
                              mapctb.cxacod = bmapctb.cxacod and
                              /*mapctb.ch2 <> "E"             and*/ 
                              mapctb.datmov < bmapctb.datmov
                              
                                         no-error.
                                        
            else find last mapctb use-index ind-1 
                        where mapctb.ch1    = bmapctb.ch1 and 
                              /*mapctb.ch2 <> "E"          and*/    
                              mapctb.datmov < bmapctb.datmov 
                                      no-error.
        
            if avail mapctb  
            then vgt = mapctb.gtotal.  
            else vgt = bmapctb.gtotal - 
                   (bmapctb.t01 + bmapctb.t02 + bmapctb.t03 +
                        bmapctb.vlsub) -
                            bmapctb.vlcan +  
                            bmapctb.vlacr.

    
            if bmapctb.ch2 = "E"                 
            then next.               
    
            create tt-caixa.
            assign
                    tt-caixa.etbcod = estab.etbcod
                    tt-caixa.cxacod = tabecf.de1
                    tt-caixa.equip  = tabecf.equip
                    tt-caixa.serie  = bmapctb.ch1
                    tt-caixa.nrored = bmapctb.nrored
                    tt-caixa.datmov = vdata
                    tt-caixa.gti    = vgt
                    tt-caixa.gtf    = bmapctb.gtotal
                    tt-caixa.t01    = bmapctb.t01
                    tt-caixa.t02    = bmapctb.t02
                    tt-caixa.t03    = bmapctb.t03
                    tt-caixa.t04    = bmapctb.t04
                    tt-caixa.t05    = bmapctb.t05
                    tt-caixa.tsub  = bmapctb.vlsub
                    tt-caixa.tcan  = bmapctb.vlcan
                    tt-caixa.cooini = bmapctb.cooini
                    tt-caixa.coofin = bmapctb.coofin
                    tt-caixa.vldes  = bmapctb.vldes
                                        .
        end.
    end.
 end.
 end.

run valida-cupom.
def buffer btt-caixa for tt-caixa.
def var ired as int.
def var vdifred as dec.
def var val-ctb as dec.
for each tt-caixa.

    assign
        vdifred = tt-caixa.gtf - tt-caixa.gti
        val-ctb = tt-caixa.t01 + tt-caixa.t02 +
                  tt-caixa.t03 + tt-caixa.t04 +
                  tt-caixa.t05 + tt-caixa.tsub +
                  tt-caixa.tcan + tt-caixa.vldes.
                  
    if vdifred = val-ctb and tt-caixa.serie <> ""
    then do:
        ired = 0.
        for each bmapctb where 
                 bmapctb.etbcod = tt-caixa.etbcod and
                 bmapctb.cxacod = tt-caixa.cxacod and
                 bmapctb.ch1    = tt-caixa.serie  and
                 bmapctb.datmov = tt-caixa.datmov and
                 bmapctb.nrored <> tt-caixa.nrored
                 no-lock:
            ired = ired + 1.
            if ired > 0
            then do:
                create btt-caixa.
                assign
                    btt-caixa.etbcod = bmapctb.etbcod
                    btt-caixa.cxacod = bmapctb.cxacod
                    btt-caixa.equip  = bmapctb.de1
                    btt-caixa.serie  = bmapctb.ch1
                    btt-caixa.nrored = bmapctb.nrored
                    btt-caixa.datmov = bmapctb.datmov
                    btt-caixa.gti    = bmapctb.gtotal
                    btt-caixa.gtf    = bmapctb.gtotal
                    btt-caixa.t01    = bmapctb.t01
                    btt-caixa.t02    = bmapctb.t02
                    btt-caixa.t03    = bmapctb.t03
                    btt-caixa.t04    = bmapctb.t04
                    btt-caixa.t05    = bmapctb.t05
                    btt-caixa.tsub  = bmapctb.vlsub
                    btt-caixa.tcan  = bmapctb.vlcan
                    btt-caixa.difer = yes
                    btt-caixa.valctb =
                            bmapctb.t01 + bmapctb.t02 +
                            bmapctb.t03 + bmapctb.t04 +
                            bmapctb.t05 + bmapctb.vlsub +
                            bmapctb.vlcan - bmapctb.vldes.
                  
            end.
        end.  
        if ired > 0
        then tt-caixa.difer = yes.       
                 
    end.
    else do:
        assign
            tt-caixa.difred = vdifred
            tt-caixa.valctb = val-ctb
            tt-caixa.totdif = tt-caixa.difred - tt-caixa.valctb
            tt-caixa.difer = yes.
        /*
        disp tt-caixa.etbcod
             tt-caixa.equip
             tt-caixa.serie
             tt-caixa.datmov
             tt-caixa.gti
             tt-caixa.gtf
             vdifred
             valctb
             vdifred - valctb
             with frame f-difred.
        */
    end.
    if tt-caixa.cooini = 0 or
       tt-caixa.coofin = 0
    then tt-caixa.difer = yes.   
end.

{setbrw.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  CONSULTAR","  ","  ","  RECUPERAR"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","   RED Z","BUSCAR FILIAL","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "Mostra divergencias",
             "Altera numero fabricação",
             "Busca Z nas filiais",
             "Recupera do ECF"
             ].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def buffer btbcntgen for tbcntgen.                            
def var i as int.

def var vcup as char format "x".
def var vred as char format "x".

form tt-caixa.etbcod column-label "Fil"
     tt-caixa.nrored column-label "NR" format ">>>>>9"
     tt-caixa.datmov
     tt-caixa.equip  column-label "Eq"
     tt-caixa.serie 
     tt-caixa.difred column-label "DifRdZ"
     tt-caixa.valctb column-label "ValBru"
     tt-caixa.totdif column-label "TotDif"
     with frame f-linha 11 down width 80
     row 5 overlay
      .
 
def var vreg as int.
def var va as log init yes.



l1: repeat:

    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    pause 0.

 
    {sklclstb.i  
        &color = with/cyan
        &file =  tt-caixa 
        &cfield = tt-caixa.etbcod
        &noncharacter = /* 
        &ofield = "  tt-caixa.nrored  
                     tt-caixa.datmov
                     tt-caixa.equip
                     tt-caixa.serie 
                     tt-caixa.difred
                     tt-caixa.valctb
                     tt-caixa.totdif
                     "  
        &aftfnd1 = " "
        &where  = " tt-caixa.difer "
        &aftselect1 = " a-recid = recid(tt-caixa).
                        run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  ALTERAR"" or 
                           esqcom1[esqpos1] = ""  RECUPERAR"" or
                           esqcom1[esqpos1] = ""  ATUALIZAR"" or
                           esqcom2[esqpos2] = ""VENDAS""
                        then do:
                            va = yes.
                            next l1.
                        end.
                        else IF esqcom1[esqpos1] = ""  BUSCAR""
                        THEN LEAVE l1.
                        ELSE next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhuma divergencia encontrada.""
                        view-as alert-box.
                        leave l1 . " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  CONSULTAR"
    THEN DO on error undo:
        find first tt-caixa where recid(tt-caixa) = a-recid.
        disp tt-caixa.serie skip(1)
             tt-caixa.gti   skip(1)
             tt-caixa.t01
             tt-caixa.t02
             tt-caixa.t03
             tt-caixa.t04
             tt-caixa.t05
             tt-caixa.tsub
             tt-caixa.tcan skip(1)  
             tt-caixa.gtf 
             tt-caixa.cooini
             tt-caixa.coofin
             with frame f-con1 width 80 1 down side-label
             row 5
             1 column. 
             pause.
             hide frame f-con1 no-pause.
        
    END.
    if esqcom1[esqpos1] = "  ALTERAR"
    THEN DO:
        
        find first tt-caixa where recid(tt-caixa) = a-recid.
        /*
        run reccupmp.p( tt-caixa.etbcod, tt-caixa.datmov, tt-caixa.equip,
                        tt-caixa.serie).
                        pause.
        */
    END.
    if esqcom1[esqpos1] = "  RECUPERAR"
    THEN DO:
        
        RUN valZcup4.p (tt-caixa.etbcod, tt-caixa.datmov, tt-caixa.equip).
        
    END.
    if esqcom2[esqpos2] = "RELATORIO"
    THEN DO on error undo:
        RUN relatorio.
    END.
    if esqcom2[esqpos2] = "   RED Z"
    THEN DO on error undo:
        
        run valredZ2.p( tt-caixa.etbcod, tt-caixa.equip,
                        tt-caixa.serie, vdti, vdtf).
        pause.

    END.
    if esqcom2[esqpos2] = "BUSCAR FILIAL"
    THEN DO on error undo:
        RUN buscar-filial.
    END.    
end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure buscar-filial:

    FIND first estab where 
                estab.etbcod = tt-caixa.etbcod 
                no-lock no-error.
    if avail estab and
       estab.etbcod <> 10 and
       estab.etbcod <> 22 and
       estab.etbcod <> 189 and
       estab.etbcod <> 200
    then do:

    vip = "filial" + string(estab.etbcod,"999").   

    if connected ("admloja")
    then disconnect admloja.    
    
    display estab.etbcod column-label "Filial"
            vip column-label "IP" format "x(15)"
            "Conectando" column-label "Estatus"
            with frame f-3 down width 80 color white/red
                    row 5.
    pause 0.

    output to value(varq_log) append.
    connect adm -H value(vip) -S sadm -N tcp -ld admloja
                no-error.
    output close.
    
    if not connected ("admloja")
    then do:
        vstatus = "FALHA NA CONEXAO COM A FILIAL".
        display vstatus  label "STATUS"
        with frame f-3.
        undo, retry.    
    end.

    run busca_admlj.

    display vstatus  no-label format "x(20)" with frame f-3.

    output to value(varq_log) append.
        put vip space(2) vstatus skip.
    output close.
    
    if connected ("admloja")
    then disconnect admloja.
    end.

end procedure.

procedure busca_admlj:
    run valZcup1.p ( estab.etbcod, vdti, vdtf, "MAPCXA", output vstatus ).
end procedure.
    
procedure ver-mapctb:
    if bmapctb.ch1 = ""
    then do:
        find last emapctb where emapctb.etbcod = estab.etbcod and
                       emapctb.ch1    = tabecf.serie and 
                       emapctb.cxacod = vequip and
                       emapctb.datmov < vdata 
                       no-lock no-error.
        if avail emapctb and
                 emapctb.ch1 <> ""
        then bmapctb.ch1 = emapctb.ch1.
    end.
end procedure.
    
