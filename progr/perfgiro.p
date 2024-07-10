/*************************INFORMA€OES DO PROGRAMA****************************** ***** Nome do Programa             : perfoped.p
*******************************************************************************/

{admcab.i}
{setbrw.i}

def var /*input parameter*/ p-pedtdc like pedid.pedtdc.
p-pedtdc = 1.

def var vestven as dec.
    def var vestcus as dec.
    def var qtdest as dec.
    def var qtdven as dec.
    def var vlcontrato as dec.
    def var vtotal_platot as dec.
    def var valven as dec.
    def var valcus as dec.
    

def var vdt-aux as date format "99/99/9999".

def var vi as int.
def var aux-i as int.
def var aux-etbcod like estab.etbcod.

def var vcont as int.
def var vdiastot as int.
def new shared var vdiasatu as int.
def buffer bestab for estab.
def var vforcod like forne.forcod. 
def var vdia as int.
def var vmes as int format "99".
def var vano as int format "9999".
def var vmesfim as int.
def var vanofim as int.
def var vdiafim as int.

def var v-totcom    as dec.
DEF VAR v-totperc   AS DEC.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok as logical.
def var vquant like movim.movqtm.
def var flgetb      as log.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var vetbcod     like plani.etbcod           no-undo.
def var v-totger    as dec.

def new shared      var vdti        as date format "99/99/99" no-undo.
def new shared      var vdtf        as date format "99/99/99" no-undo.

def var p-vencod     like func.funcod.
def new shared var p-loja      like estab.etbcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-percproj  as dec.
def var v-perdev    as dec label "% Dev" format ">9.99".

def buffer sclase   for clase.
def buffer grupo    for clase.

def new shared temp-table ttloja
   field etbcod        like estab.etbcod
   field nome          like estab.etbnom 
   field gqtdven  like plani.platot
   field gvalcus  like plani.platot
   field gvalven  like plani.platot
   field gqtdest  like plani.platot
   field gvestcus like plani.platot
   field gvestven like plani.platot
   field giro     like plani.platot

    index loja     is unique etbcod asc
    index totalqtd is primary giro desc etbcod desc.

def new shared temp-table ttsetor 
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index setor     etbcod  setcod 
    index valor     giro desc.

def new shared temp-table ttgrupo
    field grupo-clacod    like clase.clacod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field nome    like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index grupo     etbcod setcod grupo-clacod 
    index valor     giro desc.

def new shared temp-table ttclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field grupo-clacod    like clase.clacod
    field clase-clacod    like clase.clasup    
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique etbcod asc
                             setcod asc
                             grupo-clacod asc
                             clase-clacod asc
    index platot  is primary giro desc.    

def new shared temp-table ttsclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod  
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
    index platot  is primary giro desc.    

def new shared temp-table ttprodu
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field procod           like produ.procod 
    field nome     like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              procod       asc 
    index platot  is primary giro desc.    

def new shared temp-table ttfabri
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field fabcod           like produ.fabcod 
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    index platot  is primary giro desc.    

form
    ttloja.nome  column-label "    LOJAS"  format "x(20)"
    help "ENTER=Seleciona F4=Retorna " 
    ttloja.giro     format ">>>9.99"      column-label " Giro "
    ttloja.gqtdven  format "->>>>>9"        column-label "QVenda"
    ttloja.gqtdest  format "->>>>>9"       column-label "QEstoq"
    ttloja.gvalcus  format "->>>>>9"       column-label "VCusto"
    ttloja.gvalven  format "->>>>>9"       column-label "VVenda"
    ttloja.gvestcus format "->>>>>>>9"     column-label "ECusto"
    ttloja.gvestven format "->>>>>>>9"   column-label "EVenda"
     with frame f-lojas
        width 80
        centered
        down 
        row 5
        no-box  
        overlay.
  
def var vdiascmp as int. 
def var vcatcod like categoria.catcod.
form
    vetbcod  label  "Loja"
    estab.etbnom no-label format "x(20)" 
    vcatcod
    categoria.catnom no-label
    vdti     label "Periodo de" format "99/99/9999"
    vdtf     label "a" format "99/99/9999"
    vdiascmp label "Dias de compra" format ">>9"
    with frame f-etb
        centered
        1 down side-labels 
        row 3 width 80
        no-box .

def buffer bmovim for movim.
def buffer bplani for plani.

form "Processando.....>>> " 
    produ.procod bestab.etbcod plani.numero  format ">>>>>>>>9"
    with frame f-1 1 down centered row 10 no-label no-box
    overlay.
    
{selestab.i vetbcod f-etb}

repeat:                         
    hide frame f-lojas no-pause.

    for each ttloja :  delete ttloja. end.
    
    update vcatcod label "Departamento" with frame f-etb.
    if vcatcod > 0
    then do:
        find categoria where categoria.catcod = vcatcod no-lock.
        disp categoria.catnom no-label with frame f-etb.
    end.
    update  vdti  vdtf vdiascmp  with frame f-etb.
    
    run progiro.
    
    repeat :
        
        disp with frame f-etb color message.  
        pause 0.  
        assign  a-seeid = -1 a-recid = -1 
                a-seerec = ? 
                v-totdia = 0 v-totger = 0.
        
        {sklcls.i
            &File   = ttloja
            &CField = ttloja.nome
            &Ofield = " 
                     ttloja.gqtdven  
                     ttloja.gvalcus 
                     ttloja.gvalven  
                     ttloja.gqtdest 
                     ttloja.gvestcus 
                     ttloja.gvestven 
                     ttloja.giro   
                     "   
            &Where = " ttloja.etbcod  = (if vetbcod = 0
                                        then ttloja.etbcod
                                        else vetbcod)    
                        use-index totalqtd "                
            &AftSelect1 = " p-loja = ttloja.etbcod. 
                       leave keys-loop. "
            &Form = " frame f-lojas " 
        }.
        
        if keyfunction(lastkey) = "END-ERROR"
        then leave.

        clear frame f-lojas all no-pause.
        display 
                ttloja.nome 
                ttloja.gqtdven  
                     ttloja.gvalcus 
                     ttloja.gvalven  
                     ttloja.gqtdest 
                     ttloja.gvestcus 
                     ttloja.gvestven 
                     ttloja.giro 
                with frame f-lojas.
        pause 0.
        run perfog01.p ( ttloja.etbcod ).
    end. 
    hide frame f-1 no-pause.       
end.    

def buffer bcontnf for contnf.

procedure progiro:
    for each ttloja: delete ttloja. end.
    for each ttsetor: delete ttsetor. end.
    for each ttgrupo: delete ttgrupo. end.
    for each ttclase: delete ttclase. end.
    for each ttsclase: delete ttsclase. end.
    for each ttprodu: delete ttprodu. end.
    for each ttfabri: delete ttfabri. end.
    
    vdia = vdiascmp.
    for each categoria where
                (if vcatcod > 0
                 then categoria.catcod = vcatcod else true) no-lock:
    for each produ where produ.catcod = categoria.catcod no-lock:
        
        disp produ.procod  with frame f-1.
        pause 0.
        
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 4            and
                                bmovim.movdat >= vdti - vdia and
                                bmovim.movdat <= vdti no-error.
        if not avail bmovim
        then do:
            find first bmovim where bmovim.procod = produ.procod and
                                    bmovim.movtdc = 1            and
                                    bmovim.movdat >= vdti - vdia and
                                    bmovim.movdat <= vdti no-error.
            if not avail bmovim
            then next.
        end.
        for each tt-lj :
            find bestab where bestab.etbcod = tt-lj.etbcod
                    no-lock no-error.
            if not avail bestab
            then next.        
            assign
               valven = 0
               qtdven = 0
               valcus = 0
               qtdest = 0
               vestcus  = 0
               vestven  = 0
               .
            disp bestab.etbcod with frame f-1.
            pause 0.   
            find estoq where estoq.etbcod = bestab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then assign vestven = vestven + (estoq.estatual * estoq.estvenda) 
                        vestcus = vestcus + (estoq.estatual * estoq.estcusto)
                        qtdest = qtdest + estoq.estatual.

            for each movim where movim.etbcod = bestab.etbcod and
                                movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
                if movim.movqtm = 0 or
                   movim.movpc  = 0
                then next.
                
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat and
                                       plani.platot >= 1
                                            no-lock no-error.
                if not available plani
                then next.
                disp plani.numero with frame f-1.
                pause 0.
                vlcontrato = plani.platot - plani.vlserv.
                if avail plani and plani.crecod = 2
                then do:
                    vtotal_platot = 0.
                    find first bcontnf 
                        where bcontnf.etbcod = plani.etbcod and
                              bcontnf.placod = plani.placod no-lock no-error.
                    if available bcontnf
                    then do:
                        find contrato 
                                where contrato.contnum = bcontnf.contnum 
                                no-lock no-error.
                        if available contrato
                        then vlcontrato = contrato.vltotal.
                        else vlcontrato = plani.platot.
                    end.
                end.

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / plani.platot  ) ) > 0
                then do:
                    assign qtdven = qtdven + movim.movqtm
                           valven = valven + 
                                    ( ( movim.movqtm * movim.movpc ) * 
                                      ( vlcontrato / plani.platot ) ).
                    
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod 
                                            no-lock no-error.
                    if avail estoq
                    then assign
                        valcus = valcus + (movim.movqtm * estoq.estcusto). 
                end.
            end.
            if valven = 0 then next.
            if vetbcod = 0
            then do:
                aux-etbcod = 999. 
                find first ttloja where
                               ttloja.etbcod = aux-etbcod no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign
                        ttloja.etbcod = aux-etbcod
                        ttloja.nome   = if aux-etbcod = 999 then "GERAL"
                                        else (string(bestab.etbcod,"zz9") 
                                            + "-" + bestab.etbnom).
                end.

                assign
                    ttloja.gqtdven = ttloja.gqtdven + qtdven
                    ttloja.gvalcus = ttloja.gvalcus + valcus
                    ttloja.gvalven = ttloja.gvalven + valven
                    ttloja.gqtdest = ttloja.gqtdest + qtdest
                    ttloja.gvestcus = ttloja.gvestcus + vestcus
                    ttloja.gvestven = ttloja.gvestven + vestven
                    ttloja.giro     = (ttloja.gvestven / ttloja.gvalven)
                    .
                run criatt.    
            end.
            find first ttloja where
                       ttloja.etbcod = bestab.etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign
                    ttloja.etbcod = bestab.etbcod
                    ttloja.nome   =  (string(bestab.etbcod,"zz9") 
                                         + "-" + bestab.etbnom).
            end.

            assign
                    ttloja.gqtdven = ttloja.gqtdven + qtdven
                    ttloja.gvalcus = ttloja.gvalcus + valcus
                    ttloja.gvalven = ttloja.gvalven + valven
                    ttloja.gqtdest = ttloja.gqtdest + qtdest
                    ttloja.gvestcus = ttloja.gvestcus + vestcus
                    ttloja.gvestven = ttloja.gvestven + vestven
                    ttloja.giro     = (ttloja.gvestven / ttloja.gvalven)
                    .
  
            aux-etbcod = bestab.etbcod.
            run criatt.
            
        end.
    end.
    end.
end procedure.

procedure criatt:
    /*find produ where produ.procod = liped.procod no-lock no-error.
    if not avail produ then next.  
     */
    find sclase where sclase.clacod = produ.clacod no-lock no-error.
    if not avail sclase
    then next.
   
    find clase where clase.clacod = sclase.clasup  no-lock.
    find grupo where grupo.clacod = clase.clasup   no-lock.
    /*
    find categoria where categoria.catcod = produ.catcod no-lock.
    */
       
    find fabri of produ no-lock.
 
    find first ttsetor where 
                    ttsetor.etbcod = aux-etbcod and
                    ttsetor.setcod = categoria.catcod
                no-error.
    if not avail ttsetor
    then do:
        create ttsetor.
        assign 
            ttsetor.etbcod = aux-etbcod
            ttsetor.setcod = categoria.catcod 
            ttsetor.nome   = categoria.catnom 
            .
    end. 

    assign
                    ttsetor.gqtdven = ttsetor.gqtdven + qtdven
                    ttsetor.gvalcus = ttsetor.gvalcus + valcus
                    ttsetor.gvalven = ttsetor.gvalven + valven
                    ttsetor.gqtdest = ttsetor.gqtdest + qtdest
                    ttsetor.gvestcus = ttsetor.gvestcus + vestcus
                    ttsetor.gvestven = ttsetor.gvestven + vestven
                    ttsetor.giro     = (ttsetor.gvestven / ttsetor.gvalven)
                    .
    
    find first ttgrupo where 
                    ttgrupo.etbcod = aux-etbcod and
                    ttgrupo.setcod = categoria.catcod and
                    ttgrupo.grupo-clacod = grupo.clacod
                no-error.
    if not avail ttgrupo
    then do:
        create ttgrupo.
        assign 
            ttgrupo.etbcod = aux-etbcod
            ttgrupo.setcod = categoria.catcod
            ttgrupo.grupo-clacod = grupo.clacod
            ttgrupo.nome   = grupo.clanom.
    end. 
     assign
                    ttgrupo.gqtdven = ttgrupo.gqtdven + qtdven
                    ttgrupo.gvalcus = ttgrupo.gvalcus + valcus
                    ttgrupo.gvalven = ttgrupo.gvalven + valven
                    ttgrupo.gqtdest = ttgrupo.gqtdest + qtdest
                    ttgrupo.gvestcus = ttgrupo.gvestcus + vestcus
                    ttgrupo.gvestven = ttgrupo.gvestven + vestven
                    ttgrupo.giro     = (ttgrupo.gvestven / ttgrupo.gvalven)
                    .

    find first ttclase where 
                    ttclase.etbcod       = aux-etbcod and
                    ttclase.setcod       = categoria.catcod and
                    ttclase.grupo-clacod = grupo.clacod and
                    ttclase.clase-clacod = clase.clacod
                no-error.
    if not avail ttclase
    then do:
          create ttclase.
          assign 
              ttclase.etbcod          = aux-etbcod
              ttclase.setcod          = categoria.catcod 
              ttclase.grupo-clacod    = grupo.clacod
              ttclase.clase-clacod    = clase.clacod
              ttclase.nome            = clase.clanom.
    end. 
    assign
                    ttclase.gqtdven = ttclase.gqtdven + qtdven
                    ttclase.gvalcus = ttclase.gvalcus + valcus
                    ttclase.gvalven = ttclase.gvalven + valven
                    ttclase.gqtdest = ttclase.gqtdest + qtdest
                    ttclase.gvestcus = ttclase.gvestcus + vestcus
                    ttclase.gvestven = ttclase.gvestven + vestven
                    ttclase.giro     = (ttclase.gvestven / ttclase.gvalven)
                    .
    
    find first ttsclase where 
                    ttsclase.etbcod        = aux-etbcod and
                    ttsclase.setcod        = categoria.catcod and
                    ttsclase.grupo-clacod  = grupo.clacod and
                    ttsclase.clase-clacod  = clase.clacod and
                    ttsclase.sclase-clacod = sclase.clacod
                                    no-error.
    if not avail ttsclase
    then do:
        create ttsclase.
        assign 
            ttsclase.etbcod          = aux-etbcod
            ttsclase.setcod          = categoria.catcod
            ttsclase.grupo-clacod    = grupo.clacod
            ttsclase.clase-clacod    = clase.clacod
            ttsclase.sclase-clacod   = sclase.clacod
            ttsclase.nome            = sclase.clanom.
    end. 
    assign
                    ttsclase.gqtdven = ttsclase.gqtdven + qtdven
                    ttsclase.gvalcus = ttsclase.gvalcus + valcus
                    ttsclase.gvalven = ttsclase.gvalven + valven
                    ttsclase.gqtdest = ttsclase.gqtdest + qtdest
                    ttsclase.gvestcus = ttsclase.gvestcus + vestcus
                    ttsclase.gvestven = ttsclase.gvestven + vestven
                    ttsclase.giro     = (ttsclase.gvestven / ttsclase.gvalven)
                    .
    
    find first ttprodu where 
                    ttprodu.etbcod        = aux-etbcod and
                    ttprodu.setcod        = categoria.catcod and
                    ttprodu.grupo-clacod  = grupo.clacod and
                    ttprodu.clase-clacod  = clase.clacod and
                    ttprodu.sclase-clacod = sclase.clacod and
                    ttprodu.procod        = produ.procod  
                                    no-error.
    if not avail ttprodu
    then do:
        create ttprodu.
        assign 
            ttprodu.etbcod          = aux-etbcod
            ttprodu.setcod          = categoria.catcod 
            ttprodu.grupo-clacod    = grupo.clacod
            ttprodu.clase-clacod    = clase.clacod
            ttprodu.sclase-clacod   = sclase.clacod
            ttprodu.procod          = produ.procod
            ttprodu.nome            = produ.pronom.
    end.  
    assign
                    ttprodu.gqtdven = ttprodu.gqtdven + qtdven
                    ttprodu.gvalcus = ttprodu.gvalcus + valcus
                    ttprodu.gvalven = ttprodu.gvalven + valven
                    ttprodu.gqtdest = ttprodu.gqtdest + qtdest
                    ttprodu.gvestcus = ttprodu.gvestcus + vestcus
                    ttprodu.gvestven = ttprodu.gvestven + vestven
                    ttprodu.giro     = (ttprodu.gvestven / ttprodu.gvalven)
                    .

    find first ttfabri where 
                    ttfabri.etbcod        = aux-etbcod and
                    ttfabri.setcod        = categoria.catcod  and
                    ttfabri.grupo-clacod  = grupo.clacod and
                    ttfabri.clase-clacod  = clase.clacod and
                    ttfabri.sclase-clacod = sclase.clacod and
                    ttfabri.fabcod        = produ.fabcod  
                                    no-error.
   if not avail ttfabri
   then do:
       create ttfabri.
       assign 
           ttfabri.etbcod          = aux-etbcod
           ttfabri.setcod          = categoria.catcod 
           ttfabri.grupo-clacod    = grupo.clacod
           ttfabri.clase-clacod    = clase.clacod
           ttfabri.sclase-clacod   = sclase.clacod
           ttfabri.fabcod          = produ.fabcod
           ttfabri.nome            = fabri.fabnom.
    end. 
    assign
                    ttfabri.gqtdven = ttfabri.gqtdven + qtdven
                    ttfabri.gvalcus = ttfabri.gvalcus + valcus
                    ttfabri.gvalven = ttfabri.gvalven + valven
                    ttfabri.gqtdest = ttfabri.gqtdest + qtdest
                    ttfabri.gvestcus = ttfabri.gvestcus + vestcus
                    ttfabri.gvestven = ttfabri.gvestven + vestven
                    ttfabri.giro     = (ttfabri.gvestven / ttfabri.gvalven)
                    .
end procedure.

