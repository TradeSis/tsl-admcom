/*************************INFORMA€OES DO PROGRAMA******************************
*******************************************************************************/

{admcab.i}.
{anset.i}.

def var v-titulo as char format "X(50)".

def var recimp as recid.
def var fila as char.

def buffer icategoria for categoria.
def buffer iclase for clase.

def new shared temp-table tresu
    field etbcod   like estab.etbcod
    field etbnom   like estab.etbnom
    field valorcto like plani.platot
    field valorven like plani.platot
    field qtd      like movim.movqtm
    field perc-cto as   dec format "->>>>9.99"
    field perc-ven as   dec format "->>>>9.99"
    field perc-qtd as   dec format "->>>>9.99".

def var varquivo as char.
def var v-imagem as char.
def var vforcod like forne.forcod.
def var vfapro-op as char extent 3  format "x(15)"
                init[" DESCER ", "  PRODUTO  "," FABRICANTE "].

def var v-titclasup1 as char.
def var vfabcod like fabri.fabcod.
def var varqsai as char format "x(30)".
def var v-clanom like clase.clanom.
def var v-totcom    as dec.
def var v-ttmet     as dec.
def var v-totperc   as dec.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok as logical.
def var vquant like movim.movqtm.
def var flgetb      as log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-movtdc    like plani.movtdc.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var vetbcod     like plani.etbcod no-undo.
def var v-totger    as  dec.
def new shared      var vdti as date format "99/99/9999" no-undo.
def new shared      var vdtf as date format "99/99/9999" no-undo.
def var p-vende     like func.funcod.
def new shared      var p-loja like estab.etbcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-clase1    like clase.clacod.
def var p-sclase    like clase.clacod.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-titproaux as char.

def var v-perdia     as dec label "% Est".
def var v-perdia-imp as dec label "% Est".

def var v-perc       as dec label "% ".
def var v-perc-imp   as dec label "% ".

def var v-perdev    as dec label "% Dev" format ">9.99".

def var vlojas as int.
def var vfoi as int.
def var vtotal as int.

def var v-etccod    like estac.etccod.
def var v-carcod    like caract.carcod.
def var v-subcod    like subcaract.subcar.
def var vcomcod     like compr.comcod.

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer clasup1 for clase.

def var vfapro as char extent 2  format "x(15)"
                init["  PRODUTO  "," FABRICANTE "].
def var vnomabr         like produ.pronom format "x(25)" /*nomabr*/ .

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 

def temp-table tt-fabri no-undo
    field valorven  like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field valorcto  like plani.platot
    field fabcod    like fabri.fabcod
    field clacod    like plani.placod 
    index fabcod    fabcod   asc
    index valor1    valorcto desc.

form
    tt-fabri.fabcod  column-label "Cod" 
    help "F4=Retorna"
    vnomabr    format "x(30)"      /*9.99*/
    tt-fabri.qtd        format "->>>>>>>9" column-label "Qtd.Est" 
    tt-fabri.valorcto   format "->>>>9.99" column-label "Est.Cus" 
    tt-fabri.valorven   format "->>,>>9.99" column-label "Est.Ven" 
    /*v-perc              column-label "% V/E"  format "->>9.99" */
    v-perdia            format ">>9.99"
    with frame f-fabri width 80 down title v-titpro.

def new shared temp-table ttloja no-undo
    field medven    like plani.platot
    field medqtd    like movim.movqtm
    field valorven    like plani.platot
    field qtd       as dec
    field etbnom    like estab.etbnom
    field etbcod    like plani.etbcod
    field valorcto    like plani.platot
    index loja      etbcod asc
    index valor      valorcto desc.

def new shared temp-table ttsetor  no-undo
    field valorven  like plani.platot
    field metset    as dec
    field setcod    like setor.setcod
    field qtd       like movim.movqtm
    field valorcto  like plani.platot
    field etbcod    like plani.etbcod
    index setor     etbcod setcod 
    index valor     valorven desc.
    
def new shared temp-table ttgrupo no-undo
    field valorven  like plani.platot
    field clacod    like clase.clacod
    field valorcto  like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field setcod    like setor.setcod
    index grupo     etbcod setcod clacod 
    index valor     valorven desc.
    
def new shared temp-table ttvenpro no-undo
    field valorven    like plani.platot
    field funcod    like /*movim.funcod */ func.funcod
    field valorcto    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     valorven desc.

def new shared temp-table ttprodu no-undo
    field valorven    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field valorcto    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    field setcod    like setor.setcod
    index produ     procod etbcod clacod
    index valor     valorven desc.

def new shared temp-table ttproduaux no-undo
    field valorven    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field valorcto    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    field setcod    like setor.setcod
    index produ     procod etbcod clacod
    index valor     valorven desc.

def new shared temp-table ttclasup1  no-undo
    field valorven    like plani.platot
    field etbcod      like plani.etbcod
    field qtd         like movim.movqtm
    field clacod      like clase.clacod
    field valorcto    like plani.platot
    field clasup      like clase.clasup
    field setcod      like setor.setcod
    index clase       etbcod clacod.


def new shared temp-table ttclase  no-undo
    field valorven  like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field valorcto  like plani.platot
    field clasup    like clase.clasup
    field setcod    like setor.setcod
    index clase     etbcod clacod.

def new shared temp-table ttsclase no-undo
    field valorven  like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field clacod    like clase.clacod
    field valorcto  like plani.platot
    field clasup    like clase.clasup
    field setcod    like setor.setcod
    index sclase    etbcod clacod.

form
    clase.clacod
        help "ENTER = Seleciona  P = Informacoes Filiais "
    clase.clanom
    categoria.catcod
    categoria.catnom
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttvenpro.procod
    help "F4 = Retorna  F8 = Imprime"
    produ.pronom        format "x(18)"              /*9.99*/
    ttvenpro.qtd        column-label "Qtd.Est" format "->>>>>>9" 
    ttvenpro.valorcto   format "->,>>9.99" column-label "Est.Cus" 
    ttvenpro.valorven   format "->,>>9.99" column-label "Est.Ven"
    v-perdia            column-label "% V/E" format "->>9.99" 
    with frame f-vendpro
        centered
        down 
        title v-titvenpro.
 
form
    ttloja.etbcod
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttloja.etbnom  format "x(18)" column-label "Estabel." 
    ttloja.qtd      column-label "Qtd.Est" format "->>>>>>9" 
    ttloja.valorcto  format "->>,>>>,>>9.99" column-label "Est.Cus"
    ttloja.valorven  format "->>,>>>,>>9.99" column-label "Est.Ven"
    v-perc           column-label "% V/E" format "->>9.99" 
    v-perdia         format "->>9.99"
    with frame f-lojas
        width 80
        centered
        color white/red
        down 
        title " ESTOQUES POR LOJA ".
        
form
    ttsetor.setcod
    help "ENTER=Seleciona F4=Retorna F8=Imprime P=Informacoes Filiais"
    categoria.catnom /*setor.setnom*/      format "x(17)" 
    ttsetor.qtd       format "->>>>>>>>>9" column-label "Qtd.Est"
    ttsetor.valorcto  format "->>,>>>,>>9.99" column-label "Est.Cus"
    ttsetor.valorven  format "->>,>>>,>>9.99" column-label "Est.Ven" 
    v-perc            format "-9.99" column-label "% V/E" 
    v-perdia          format "->>9.99"
    with frame f-setor 
        centered
        width 80
        color white/green
        down  overlay
        title v-titset.
        
form
    ttgrupo.clacod   column-label "Grupo"
        help "ENTER=Seleciona F4=Retorna F8=Imprime P=Informacoes Filiais"
    clase.clanom   format "x(14)" column-label "Desc."
    ttgrupo.qtd      format "->>>>>>>9" column-label "Qtd.Est"
    ttgrupo.valorcto format "->,>>>,>>9.99" column-label "Est.Cus"
    ttgrupo.valorven format "->,>>>,>>9.99" column-label "Est.Ven" 
    v-perc           column-label "% V/E" format "->>9.99" 
    v-perdia         format "->>9.99"
    with frame f-grupo centered down title v-titgru
    width 80.
        
form
    ttprodu.procod  column-label "Cod" 
    help "F8=Imagem do Produto I=Imprime P=Informacoes Filiais"
    vnomabr    format "x(29)" 
    ttprodu.qtd     format "->>>>>>>>>9" column-label "Qtd" 
    ttprodu.valorcto  format "->,>>9.99"  column-label "V.Cto" 
    ttprodu.valorven  format "->,>>9.99"  column-label "V.Vnd" 
/**    v-perc          column-label "% V/E"  format "->>9.99" **/
    v-perdia        format "->>9.99"
    with frame f-produ
        centered
        down 
        title v-titpro.
        
form
    ttproduaux.procod  column-label "Cod" 
    help "F8=Imagem do Produto I=Imprime P=Informacoes Filiais"
    vnomabr    format "x(29)"
    ttproduaux.qtd     format "->>>>>>>>>9" column-label "Qtd" 
    ttproduaux.valorcto  format "->>,>>9.99"  column-label "V.Cto" 
    ttproduaux.valorven  format "->>,>>9.99"  column-label "V.Vnd" 
/**    v-perc          column-label "% V/E"  format "->>9.99" **/
    v-perdia        format "->>9.99"
    with frame f-produaux centered down title v-titproaux.

form
    ttclase.clacod
    help "ENTER=Seleciona F4=Retorna F8=Imprime P=Informacoes Filiais"
    clase.clanom    format "x(14)"  column-label "Desc."
    ttclase.qtd     column-label "Qtd.Est" format "->>>>>>>9" 
    ttclase.valorcto  format "->,>>>,>>9.99" column-label "Est.Cus" 
    ttclase.valorven  format "->,>>>,>>9.99"  column-label "Est.Ven" 
    v-perc          column-label "% V/E"    format "->>9.99"
    v-perdia        format "->>9.99"
    with frame f-clase centered down title v-titcla
    width 80.
        
form
    ttclasup1.clacod
    help "ENTER=Seleciona F4=Retorna F8=Imprime P=Informacoes Filiais"
    clase.clanom    format "x(14)"  column-label "Desc."
    ttclasup1.qtd     column-label "Qtd.Est" format "->>>>>>>9" 
    ttclasup1.valorcto  format "->,>>>,>>9.99" column-label "Est.Cus" 
    ttclasup1.valorven  format "->,>>>,>>9.99"  column-label "Est.Ven" 
    v-perc          column-label "% V/E"    format "->>9.99"
    v-perdia        format "->>9.99"
    with frame f-clasup1 centered down title v-titclasup1
    width 80.
        
        
       
form
    ttsclase.clacod
help "ENTER=Seleciona F4=Retorna F8=Imprime P=Informacoes Filiais"

    sclase.clanom     format "x(14)" column-label "Desc."
    ttsclase.qtd      column-label "Qtd.Est"       format "->>>>>>>9"
    ttsclase.valorcto column-label "Est.Cus" format "->,>>>,>>9.99" 
    ttsclase.valorven format "->,>>>,>>9.99"   column-label "Est.Ven"
    v-perc            column-label "% V/E"     format "->>9.99"
    v-perdia          format "->>9.99"
    with frame f-sclase centered down title v-titscla
    width 80.
    
def var vetbcod2 like estab.etbcod.
def buffer zestab for estab.

form
    vetbcod  label  "Lj Inicial"
/*    estab.etbnom no-label format "x(15)"  */
    vetbcod2 label  "Lj Final"
/*    zestab.etbnom no-label format "x(15)" */
    vforcod label "For"
    fabri.fabnom format "x(25)" no-label skip
    v-etccod label "Estacao"
    v-carcod label "Caracteristica"
    v-subcod label "Sub-Caract."
    subcaract.subdes format "x(15)" no-label
    vhora    label "H" skip
    vcomcod label "Comprador"
    with frame f-etb centered 1 down side-labels title "Dados Iniciais" 
                     color white/bronw row 3 width 80.

repeat:
    
    find first estab where estab.etbcod = setbcod no-lock.
    find first zestab where zestab.etbcod = setbcod no-lock.

    /*{selestab.i vetbcod f-etb}*/
    
    DO on error undo:

    vetbcod = setbcod.
    vetbcod2 = setbcod.

    IF estab.etbcod > 0
    THEN DO:
        vetbcod = 0.
        update vetbcod with frame f-etb.
        if vetbcod > 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message color red/white "Estabelecimento nao Cadastrado"
                view-as alert-box title "Menssagem".
                undo, retry.
            end.
            disp vetbcod /* estab.etbnom no-label */ with frame f-etb. 
        end.
        else do:
             vetbcod2 = vetbcod.
             disp vetbcod vetbcod2
                 with frame f-etb.
             end.
    END.
    else disp vetbcod /* estab.etbnom */ with frame f-etb.

     if vetbcod <> 0
     then
        IF zestab.etbcod > 0
        THEN DO:
            vetbcod2 = vetbcod.
            update vetbcod2 with frame f-etb.
            if vetbcod2 > 0
            then do:
                find zestab where zestab.etbcod = vetbcod2 no-lock no-error.
                if not avail zestab
                then do:
                    message color red/white "Estabelecimento nao Cadastrado"
                            view-as alert-box title "Menssagem".
                    undo, retry.
                   end.
              disp vetbcod2  with frame f-etb. 
         end.
        else disp vetbcod2 /* "EMPRESA" @ zestab.etbnom */ with frame f-etb.
    END.
    else disp vetbcod2 /* zestab.etbnom */ with frame f-etb.
    
    
    END. 
    /***/

    update /*vfabcod*/ vforcod with frame f-etb.
    if /*vfabcod*/ vforcod <> 0
    then do:
        find fabri where fabri.fabcod = vforcod /*vfabcod*/ no-lock no-error.
        if not avail fabri
        then do:
            message "Fabricante nao Cadastrado".
            undo.
        end.    
        display fabri.fabnom  with frame f-etb.
    end.
    else disp "Geral" @ fabri.fabnom with frame f-etb.
   

    update v-etccod with frame f-etb.
    if v-etccod > 0
    then do:
        find estac where estac.etccod = v-etccod no-lock. 
    end.
    update v-carcod with frame f-etb.
    if v-carcod > 0
    then  find caract where caract.carcod = v-carcod no-lock.
    if v-carcod > 0
    then do on error undo: 
        scopias = caract.carcod.    
        update v-subcod with frame f-etb.
        if v-subcod = 0
        then undo.
        find first subcaract where 
                    subcaract.carcod = v-carcod and
                    subcaract.subcar = v-subcod no-lock.
        disp subcaract.subdes with frame f-etb.
    end.
    else do:
         v-subcod = 0.
         disp v-subcod
              "" @ subcaract.subdes with frame f-etb.
    end.
    
    update vcomcod label "Comprador" format ">>>9"
               with frame f-etb .
            
    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                               
    if avail compr then display compr.comnom format "x(27)" no-label
                                   with frame f-etb.
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                                  with frame f-etb.
    else do:
        message "Comprador não encontrado!" view-as alert-box.
        undo, retry.
     
    end.
     
    clear frame f-mat all.
    hide frame f-mat no-pause.

    for each ttvenpro : delete ttvenpro.  end.
    for each ttprodu  : delete ttprodu.   end.
    for each ttloja   : delete ttloja.    end.
    for each ttsetor  : delete ttsetor.   end.
    for each ttgrupo  : delete ttgrupo.   end.
    for each ttclase  : delete ttclase.   end. 
    for each ttsclase : delete ttsclase.  end.
    for each ttclasup1: delete ttclasup1. end.
    
    assign vdti = today - 7 vdtf = today.

    vfoi = 0. 

    def var vdtini as date.
    def var vdtfin as date.
    def var vmes as i.
    def var vano as i.

    vtotal = 0.
        assign
        vdtini   = date(month(today),01,year(today))
        vano     = year(vdtini) + if month(vdtini) = 12 then 1 else 0
        vmes     = if month(vdtini) = 12 then 1 else month(vdtini) + 1
        vdtfin    = date(vmes,01,vano) - 1.
    def var vtime as int.
    vtime = time.
    run calcesto.
    
    hide frame f-mostr no-pause.

    vhora = string(time,"hh:mm:ss").
    disp vhora with frame f-etb.
        
        an-seeid = -1.
        an-recid = -1.  
        an-seerec = ?.

    repeat :
        
        assign  /*an-seeid = -1 an-recid = -1 
                an-seerec = ?*/ v-totdia = 0. v-totger = 0.
        for each ttloja where ttloja.etbcod <> /*999*/ 0:  
                   assign  v-totdia = v-totdia + ttloja.valorcto
                    v-totger = v-totger + ttloja.valorven.
        end.    
        clear frame f-lojas all.
        hide frame f-lojas no-pause.
         
        an-seeid = -1.
        an-recid = -1.
        an-seerec = ?.
        
        {anbrowse.i
            &File   = ttloja
            &CField = ttloja.etbcod
            &color  = write/cyan
            &Ofield = " ttloja.valorven ttloja.etbnom ttloja.qtd
                        ttloja.valorcto v-perc v-perdia"
            &Where = " (if vetbcod = 0
                        then ttloja.etbcod  = ttloja.etbcod
                        else ((ttloja.etbcod >= vetbcod and
                              ttloja.etbcod <= vetbcod2) or
                              ttloja.etbcod = 0))"
            &NonCharacter = /*
            &Aftfnd = "
                
                
                assign v-perc = ttloja.valorven / ttloja.valorcto.
                v-perdia = ttloja.valorven * 100 / v-totger. "
            &AftSelect1 = "p-loja = ttloja.etbcod. 
                       leave keys-loop. "
            &otherkeys = "
            if keyfunction(lastkey) = ""i"" /* F8 Impressao */
            then do.  run imprimeloja.
                an-seeid = -1.
                next keys-loop. 
            end. 
            "
            &LockType = "use-index loja" 
            &Form = " frame f-lojas" 
        }.

        if keyfunction(lastkey) = "END-ERROR"
        then leave.
        l95:
        repeat :
            if p-loja <> /*999*/ 0
            then
                find first estab where estab.etbcod = p-loja no-lock.
            
            assign an-seeid = -1 an-recid = -1 an-seerec = ?
            v-titset  = "CATEGORIAS DA LOJA " + 
                        if p-loja <> /*999*/ 0
                        then string(estab.etbnom) else "EMPRESA"
            v-totger = 0 v-totdia = 0.
            
            for each ttsetor where ttsetor.etbcod = p-loja :
                assign  v-totdia = v-totdia + ttsetor.valorcto
                        v-totger = v-totger + ttsetor.valorven.
            end.    
            
            hide frame f-mostr1 no-pause.

            {anbrowse.i
                &File   = ttsetor
                &CField = ttsetor.setcod
                &color  = write/cyan
                &Ofield = " categoria.catnom when avail categoria
                            ttsetor.valorcto v-perc ttsetor.qtd
                            ttsetor.valorven v-perdia"
                &Where = "ttsetor.etbcod = p-loja"
                &NonCharacter = /*
                &AftFnd = " find first categoria where 
                            categoria.catcod = ttsetor.setcod no-lock
                            no-error. 
                    assign v-perc = ttsetor.valorven / ttsetor.valorcto.
                    v-perdia = ttsetor.valorven * 100 / v-totger. "
                &AftSelect1 = "p-setor = ttsetor.setcod. 
                               leave keys-loop. "
                &OtherKeys = " 
                            if keyfunction(lastkey) = ""CLEAR""
                            then do.
                              
                              run imprime-setor(input p-loja). 
                                an-seeid = -1. 
                                next keys-loop.  
                                
                            end. 

                if keyfunction(lastkey) = ""P""
                               or keyfunction(lastkey) = ""p""
                               THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttsetor where 
                                        recid(ttsetor) = an-seerec[frame-line]
                                        no-error.
                                   if not avail ttsetor 
                                   then find first ttsetor no-error.     
                                   find setor where setor.setcod = 
                                        ttsetor.setcod no-lock no-error.
                                   
                                   for each ttsetor where
                                            ttsetor.setcod = setor.setcod.
                                       find first tresu where tresu.etbcod = 
                                            ttsetor.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign 
                                             tresu.etbcod   = ttsetor.etbcod
                                             tresu.qtd      = ttsetor.qtd
                                             tresu.valorven = ttsetor.valorven
                                             tresu.valorcto = ttsetor.valorcto.
                                       end.
                                       /*
                                       find first tresu where tresu.etbcod = 0
                                            no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           tresu.etbcod   = 0.
                                       end.
                                       assign    
                                           tresu.qtd = tresu.qtd + ttsetor.qtd
                                           tresu.valorven = tresu.valorven +
                                                ttsetor.valorven
                                           tresu.valorcto = tresu.valorcto 
                                            + ttsetor.valorcto.
                                         */
                                   end.

                                   hide frame f-setor   no-pause.
                                   hide frame f-lojas   no-pause.
                                   hide frame f-grupo   no-pause.
                                   hide frame f-clasup1 no-pause.
                                   hide frame f-clase   no-pause.
                                   hide frame f-sclase  no-pause.
                                   hide frame f-produ   no-pause.
                                   hide frame f-produ-aux no-pause.
                                   hide frame f-fabri   no-pause.
                                   
                                   v-titulo = ''.
                                   v-titulo = string(setor.setcod) + 
                                             ' - ' + setor.setnom.
                                   run perf-brwe.p
                                      (input v-titulo).

                                   next l95.

                               END.  
                             "
                
                &LockType = "use-index valor"           
                &Form = " frame f-setor" 
            }.
        
            if keyfunction(lastkey) = "END-ERROR"
            then leave l95.

            l96:
            repeat :
                find first categoria where categoria.catcod = p-setor
                    no-lock no-error.
                if not avail categoria
                then do:
                    message "Categoria " p-setor "nao cadastrada"
                             view-as alert-box.
                    return.
                end.
                if p-loja <> 0
                then
                    find first estab where estab.etbcod = p-loja no-lock.
                assign an-seeid = -1 an-recid = -1 an-seerec = ?
                       v-titgru  = "GRUPOS DO SETOR " + 
                               string(categoria.catnom)  + " DA LOJA " + 
                if p-loja <> 0
                then string(estab.etbnom) else "EMPRESA"
                
                v-totdia = 0 v-totger = 0.        
                                
                for each ttgrupo where ttgrupo.etbcod = p-loja
                                   and ttgrupo.setcod = p-setor:
                    assign  v-totdia = v-totdia + ttgrupo.valorcto
                            v-totger = v-totger + ttgrupo.valorven.
                end.    
                {anbrowse.i
                    &File   = ttgrupo
                    &CField = ttgrupo.clacod
                    &color  = write/cyan
                    &Ofield = " ttgrupo.valorven clase.clanom 
                                ttgrupo.valorcto v-perc ttgrupo.qtd v-perdia"
                    &Where = "ttgrupo.etbcod = p-loja and
                              ttgrupo.setcod = p-setor"
                    &NonCharacter = /*
                    &AftFnd = " find first clase where 
                                clase.clacod = ttgrupo.clacod no-lock.
                        assign v-perc = ttgrupo.valorven / ttgrupo.valorcto.
                        v-perdia = ttgrupo.valorven * 100 / v-totger."
                    &AftSelect1 = " p-grupo = ttgrupo.clacod.
                                  run pro-op (input ""p-grupo"", 
                                              input p-grupo).
                                        if keyfunction(lastkey) = ""END-ERROR""
                                        then next l96. 
                                  leave keys-loop. "
                                  
                &OtherKeys = " if keyfunction(lastkey) = ""CLEAR""
                            then do.  run imprime-grupo(input p-loja,
                                                        input p-setor). 
                                an-seeid = -1. 
                                next keys-loop.  
                            end.
                               IF keyfunction(lastkey) = ""p""
                               or keyfunction(lastkey) = ""P""
                               THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttgrupo where 
                                        recid(ttgrupo) = an-seerec[frame-line]
                                        no-error.

                                   find clase where clase.clacod = 
                                        ttgrupo.clacod no-lock no-error.
                                   
                                   for each ttgrupo where
                                            ttgrupo.clacod = clase.clacod.
                                       find first tresu where tresu.etbcod = 
                                            ttgrupo.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                             tresu.etbcod   = ttgrupo.etbcod
                                             tresu.qtd      = ttgrupo.qtd
                                             tresu.valorven = ttgrupo.valorven
                                             tresu.valorcto = ttgrupo.valorcto.
                                       end.
                                       /*
                                       find first tresu where tresu.etbcod = 
                                            0 no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                             tresu.etbcod   = 0.
                                       end.
                                       assign      
                                             tresu.qtd      = 
                                                tresu.qtd + ttgrupo.qtd
                                             tresu.valorven =  tresu.valorven
                                                + ttgrupo.valorven
                                             tresu.valorcto = tresu.valorcto
                                                + ttgrupo.valorcto.
                                        */
                                   end.

                                   hide frame f-setor   no-pause.
                                   hide frame f-lojas   no-pause.
                                   hide frame f-grupo   no-pause.
                                   hide frame f-clasup1 no-pause.
                                   hide frame f-clase   no-pause.
                                   hide frame f-sclase  no-pause.
                                   hide frame f-produ   no-pause.
                                   hide frame f-produ-aux no-pause.
                                   hide frame f-fabri   no-pause.
                                   v-titulo = ''.
                                   v-titulo = string(clase.clacod) + 
                                             ' - ' + clase.clanom.
                                   run perf-brwe.p
                                      (input v-titulo).
                                   next l96.
                               END."
                    &Form = " frame f-grupo" 
                }.

                if keyfunction(lastkey) = "END-ERROR"
                then leave l96.

                l97:
                repeat:
                    find first grupo where grupo.clacod = p-grupo no-lock.
                    if p-loja <> 0
                    then
                        find first estab where estab.etbcod = p-loja no-lock.
        
                    assign an-seeid = -1 an-recid = -1 an-seerec = ?
                           v-titclasup1  = "CLASSES DO GRUPO " + 
                           string(grupo.clanom) + " DA LOJA " + 
                    if p-loja <> 0
                    then string(estab.etbnom) else "EMPRESA"
                         v-totdia = 0 v-totger = 0.        
    
                    for each ttclasup1 where ttclasup1.etbcod = p-loja 
                                       and ttclasup1.clasup = p-grupo
                                       and ttclasup1.setcod = p-setor:
                        assign v-totdia = v-totdia + ttclasup1.valorcto
                               v-totger = v-totger + ttclasup1.valorven.
                    end.    
                    {anbrowse.i
                     &File  = ttclasup1
                     &CField = ttclasup1.clacod
                     &color = write/cyan
                        &Ofield = "ttclasup1.valorven clase.clanom 
                            ttclasup1.valorcto  v-perc v-perdia
                            ttclasup1.qtd "
                        &Where = "ttclasup1.etbcod = p-loja and
                                  ttclasup1.clasup = p-grupo and
                                  ttclasup1.setcod = p-setor"
                        &NonCharacter = /*
                        &AftFnd = " find first clase where 
                                       clase.clacod= ttclasup1.clacod no-lock.
                            v-perc = ttclasup1.valorven / ttclasup1.valorcto.
                            v-perdia = ttclasup1.valorven * 100 / v-totger. "
                        &AftSelect1 = "p-clase1 = ttclasup1.clacod. 
                                      run pro-op (input ""p-clase1"", 
                                                  input p-clase1).
                                        if keyfunction(lastkey) = ""END-ERROR""
                                        then next l97. 
                                       leave keys-loop."
                &OtherKeys = " if keyfunction(lastkey) = ""CLEAR""
                              then do. run imprime-cla1(input p-loja,
                                  input p-grupo,input p-setor).
                                an-seeid = -1. next keys-loop.
                              end.
                               iF keyfunction(lastkey) = ""p""
                               or keyfunction(lastkey) = ""P""
                               THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttclasup1 where 
                                        recid(ttclasup1) = an-seerec[frame-line]
                                        no-error.
                                   find clase where clase.clacod = 
                                        ttclasup1.clacod no-lock no-error.
                                   for each ttclasup1 where
                                            ttclasup1.clacod = clase.clacod.
                                       find first tresu where tresu.etbcod = 
                                            ttclasup1.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                            tresu.etbcod   = ttclasup1.etbcod
                                            tresu.qtd      = ttclasup1.qtd
                                            tresu.valorven = ttclasup1.valorven
                                            tresu.valorcto = ttclasup1.valorcto.
                                       end.
                                       /*
                                       find first tresu where tresu.etbcod = 
                                            0 no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                            tresu.etbcod   = 0.
                                       end.
                                       assign     
                                            tresu.qtd      = tresu.qtd
                                                    + ttclasup1.qtd
                                            tresu.valorven =   tresu.valorven
                                                + ttclasup1.valorven
                                            tresu.valorcto = tresu.valorcto
                                                + ttclasup1.valorcto.
                                         */
                                   end.
                                   hide frame f-setor   no-pause.
                                   hide frame f-lojas   no-pause.
                                   hide frame f-grupo   no-pause.
                                   hide frame f-clasup1 no-pause.
                                   hide frame f-clase   no-pause.
                                   hide frame f-sclase  no-pause.
                                   hide frame f-produ   no-pause.
                                   hide frame f-produ-aux no-pause.
                                   hide frame f-fabri   no-pause.
                                   v-titulo = string(clase.clacod) + 
                                             ' - ' + clase.clanom.
                                   run perf-brwe.p (input v-titulo).
                                   next l97.
                               END.  
                             "
                        &Form = " frame f-clasup1" 
                    }.
                if keyfunction(lastkey) = "END-ERROR"
                then leave l97.

                l98:
                repeat:
                    find first grupo where grupo.clacod = p-grupo no-lock.
                    if p-loja <> 0
                    then
                        find first estab where estab.etbcod = p-loja no-lock.
        
                    assign an-seeid = -1 an-recid = -1 an-seerec = ?
                           v-titcla  = "CLASSES DO GRUPO " + 
                           string(grupo.clanom) + " DA LOJA " + 
                    if p-loja <> 0
                    then string(estab.etbnom) else "EMPRESA"
                         v-totdia = 0 v-totger = 0.        
    
                    for each ttclase where ttclase.etbcod = p-loja 
                                       and ttclase.clasup = p-clase1
                                       and ttclase.setcod = p-setor:
                        assign v-totdia = v-totdia + ttclase.valorcto
                               v-totger = v-totger + ttclase.valorven.
                    end.    
                    {anbrowse.i
                        &File   = ttclase
                        &CField = ttclase.clacod
                        &color  = write/cyan
                        &Ofield = " ttclase.valorven clase.clanom 
                                ttclase.valorcto  v-perc v-perdia ttclase.qtd "
                        &Where = "ttclase.etbcod = p-loja   and
                                  ttclase.clasup = p-clase1 and
                                  ttclase.setcod = p-setor"
                        &NonCharacter = /*
                        &AftFnd = " find first clase where 
                                       clase.clacod= ttclase.clacod no-lock.
                            v-perc = ttclase.valorven / ttclase.valorcto.
                            v-perdia = ttclase.valorven * 100 / v-totger. "
                        &AftSelect1 = "p-clase = ttclase.clacod. 
                                      run pro-op (input ""p-clase"",
                                                  input p-clase).
                        if keyfunction(lastkey) = ""END-ERROR""
                        then next l98. 
                                       leave keys-loop."
                &OtherKeys = "if keyfunction(lastkey) = ""CLEAR""
                              then do.
                                run imprime-cla(input p-loja,
                                                input p-clase1,
                                                input p-setor).
                                an-seeid = -1. 
                                next keys-loop.  
                            end. 
                               IF keyfunction(lastkey) = ""p""
                               or keyfunction(lastkey) = ""P""
                               THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttclase where 
                                        recid(ttclase) = an-seerec[frame-line]
                                        no-error.
                                   find clase where clase.clacod = 
                                        ttclase.clacod no-lock no-error.
                                   for each ttclase where
                                            ttclase.clacod = clase.clacod.
                                       find first tresu where tresu.etbcod = 
                                            ttclase.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                             tresu.etbcod   = ttclase.etbcod
                                             tresu.qtd      = ttclase.qtd
                                             tresu.valorven = ttclase.valorven
                                             tresu.valorcto = ttclase.valorcto.
                                       end.
                                       /*
                                       find first tresu where tresu.etbcod = 
                                            0 no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                             tresu.etbcod   = 0  .
                                       end.
                                       assign
                                             tresu.qtd      =   tresu.qtd
                                                + ttclase.qtd
                                             tresu.valorven = tresu.valorven
                                                + ttclase.valorven
                                             tresu.valorcto = tresu.valorcto
                                                + ttclase.valorcto.
                                         */
                                   end.
                                   hide frame f-setor   no-pause.
                                   hide frame f-lojas   no-pause.
                                   hide frame f-grupo   no-pause.
                                   hide frame f-clasup1 no-pause.
                                   hide frame f-clase   no-pause.
                                   hide frame f-sclase  no-pause.
                                   hide frame f-produ   no-pause.
                                   hide frame f-produ-aux no-pause.
                                   hide frame f-fabri   no-pause.
                                   v-titulo = string(clase.clacod) + 
                                             ' - ' + clase.clanom.
                                   run perf-brwe.p 
                                       (input v-titulo). next l98.
                               END.  
                             "
                        &Form = " frame f-clase" 
                    }.

                    if keyfunction(lastkey) = "END-ERROR"
                    then leave l98.

                    l99:
                    repeat:
                        find first clase where clase.clacod = p-clase 
                                       no-lock no-error.
                        if p-loja <> 0
                        then
                            find first estab where estab.etbcod = p-loja 
                                        no-lock.
        
                        assign an-seeid = -1 an-recid = -1 an-seerec = ?
                               v-titscla  = "SUBCLASSES DA CLASSE " + 
                               string(clase.clanom) + " DA LOJA " + 
                        
                        if p-loja <> /*999*/ 0
                        then string(estab.etbnom) else "EMPRESA"
                        v-totdia = 0 v-totger = 0.
    
                        for each ttsclase where ttsclase.etbcod = p-loja 
                                            and ttsclase.clasup = p-clase
                                            and ttsclase.setcod = p-setor:
                            assign 
                                v-totdia = v-totdia + ttsclase.valorcto
                                v-totger = v-totger + ttsclase.valorven.
                        end.    

                        {anbrowse.i
                            &File   = ttsclase
                            &CField = ttsclase.clacod
                            &color  = write/cyan
                            &Ofield = "ttsclase.valorven sclase.clanom v-perdia
                                       ttsclase.valorcto v-perc ttsclase.qtd "
                            &Where = "ttsclase.etbcod = p-loja and
                                      ttsclase.clasup = p-clase and
                                      ttsclase.setcod = p-setor"
                            &NonCharacter = /*
                            &AftSelect1 = "p-sclase = ttsclase.clacod .
                                           leave keys-loop."
                            &AftFnd = " find first sclase where 
                                       sclase.clacod= ttsclase.clacod no-lock.
                              v-perc = ttsclase.valorven / ttsclase.valorcto.
                              v-perdia = ttsclase.valorven * 100 / v-totger."
                              
                &OtherKeys = "if keyfunction(lastkey) = ""CLEAR""
                              then do. run imprime-scla(input p-loja,
                                input p-clase, input p-setor).
                                an-seeid = -1. 
                                next keys-loop.  
                            end. IF keyfunction(lastkey) = ""p""
                               or keyfunction(lastkey) = ""P""
                               THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttsclase where 
                                        recid(ttsclase) = an-seerec[frame-line]
                                        no-error.

                                   find clase where clase.clacod = 
                                        ttsclase.clacod no-lock no-error.
                                   
                                   for each ttsclase where
                                            ttsclase.clacod = clase.clacod.
                                       find first tresu where tresu.etbcod = 
                                            ttsclase.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                             tresu.etbcod   = ttsclase.etbcod
                                             tresu.qtd      = ttsclase.qtd
                                             tresu.valorven = ttsclase.valorven
                                             tresu.valorcto = ttsclase.valorcto.
                                       end.
                                       /*
                                       find first tresu where tresu.etbcod = 
                                            0 no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign
                                             tresu.etbcod   = 0.
                                       end.
                                       assign
                                             tresu.qtd      =  tresu.qtd
                                                + ttsclase.qtd
                                             tresu.valorven = tresu.valorven
                                                + ttsclase.valorven
                                             tresu.valorcto = tresu.valorcto
                                                + ttsclase.valorcto.
                                         */
                                   end.

                                   hide frame f-setor   no-pause.
                                   hide frame f-lojas   no-pause.
                                   hide frame f-grupo   no-pause.
                                   hide frame f-clasup1 no-pause.
                                   hide frame f-clase   no-pause.
                                   hide frame f-sclase  no-pause.
                                   hide frame f-produ   no-pause.
                                   hide frame f-produ-aux no-pause.
                                   hide frame f-fabri   no-pause.
                                   
                                   v-titulo = ''.
                                   v-titulo = string(clase.clacod) + 
                                             ' - ' + clase.clanom.
                                   run perf-brwe.p 
                                       (input v-titulo).

                                   next l99.

                               END.  
                             "
                            &Form = " frame f-sclase" 
                        }.

                        if keyfunction(lastkey) = "END-ERROR"
                        then leave l99.

                        hide frame f-setor   no-pause.
                        hide frame f-lojas   no-pause. 
                        hide frame f-grupo   no-pause. 
                        hide frame f-clasup1 no-pause. 
                        hide frame f-clase   no-pause. 
                        hide frame f-sclase  no-pause. 
                        hide frame f-produ   no-pause. 
                        hide frame f-produ-aux no-pause.
                        hide frame f-fabri   no-pause.
                                   

                        run aux1.
                        hide frame f-esc no-pause.
                    end.  
                end.        
            end. 
        end. end.
    end.        
end.    

procedure aux1.

                        disp vfapro with frame f-esc 1 down
                             centered color with/black no-label 
                             overlay.
                        choose field vfapro with frame f-esc.
                        hide frame f-esc no-pause.
                        
                        if frame-index = 1
                        then do:
                            l1:
                            repeat :
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.

                                if p-loja <> /*999*/ 0
                                then
                                find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "PRODUTOS DA SUBCLASSE " + 
                                    string(clase.clanom) + " DA LOJA " + 
                                    if p-loja <> /*999*/ 0
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                            
                                for each ttprodu where ttprodu.etbcod = p-loja
                                           and ttprodu.clacod = sclase.clacod
                                           and ttprodu.setcod = p-setor:
                              assign v-totdia = v-totdia + ttprodu.valorcto
                                    v-totger = v-totger + ttprodu.valorven.
                                end.    
                                /*tirei o v-perc do browse (penultimo)*/
                                {anbrowse.i
                                    &File   = ttprodu
                                    &CField = ttprodu.procod
                                    &color  = write/cyan
                                    &Ofield = " ttprodu.valorven 
                                        vnomabr v-perdia
                                        ttprodu.qtd ttprodu.valorcto "
                                    &Where = "ttprodu.etbcod = p-loja and
                                              ttprodu.clacod = p-sclase and
                                              ttprodu.setcod = p-setor"
                                    &NonCharacter = /*
                                    &AftFnd = " find first produ where 
                                       produ.procod = ttprodu.procod no-lock
                                       no-error.
                                       if avail produ
                                       then vnomabr = produ.pronom + ' ' +
                                          produ.corcod.
                                       else vnomabr = ' '.    
                                v-perc = ttprodu.valorven / ttprodu.valorcto.
                                v-perdia = ttprodu.valorven * 100 / v-totger."
                                    &AftSelect1 = "next keys-loop."
                                    &otherkeys = "
                                        IF keyfunction(lastkey) = ""p""
                                        or keyfunction(lastkey) = ""P""
                                        THEN DO:

                                           find ttprodu where recid(ttprodu) = 
                                              an-seerec[frame-line] no-error.

                                           find produ where produ.procod = 
                                                ttprodu.procod no-lock no-error.

                                           run pro-cut-ttprodu.
                                           next l1.
                                        END.
                                        if keyfunction(lastkey) = ""CLEAR""
                                        then do:
                                           find ttprodu where
                                                recid(ttprodu) =
                                                an-seerec[frame-line]
                                                no-error.

                                           v-imagem = ""l:\pro_im\"" + 
                                           trim(string(ttprodu.procod)) +
                                           "".jpg"".
                                
                                           os-command silent start
                                                      value(v-imagem).
                                           next keys-loop. 
                                        end.
                                        
                                        if keyfunction(lastkey) = ""I"" or
                                           keyfunction(lastkey) = ""i""
                                        then do:
                                            run imp-pro (input ""ttprodu"",
                                                         input p-loja,
                                                         input p-sclase,
                                                         input p-setor).
                                            
                                        end.
                                    "

                                    &LockType = "use-index valor"
                                    &Form = " frame f-produ" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l1.
                            end.
                        end.
                        else do:
                            l2:
                            repeat :
                                for each tt-fabri:
                                    delete tt-fabri.
                                end.    
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if p-loja <> /*999*/ 0
                                then
                                find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "FABRICANTES DA SUBCLASSE " + 
                                    string(clase.clanom) + " DA LOJA " + 
                                    if p-loja <> /*999*/ 0
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                            
                                for each ttprodu where ttprodu.etbcod = p-loja
                                           and ttprodu.clacod = sclase.clacod
                                           and ttprodu.setcod = p-setor:
                                    find first produ where 
                                               produ.procod = ttprodu.procod
                                               no-lock.
                                    find first tt-fabri where
                                               tt-fabri.fabcod = produ.fabcod 
                                               no-error.
                                    if not avail tt-fabri
                                    then do:
                                        create tt-fabri.
                                        tt-fabri.fabcod = produ.fabcod.
                                    end.
                                assign
                       tt-fabri.valorven = tt-fabri.valorven + ttprodu.valorven
                       tt-fabri.qtd    = tt-fabri.qtd    + ttprodu.qtd
                       tt-fabri.valorcto = tt-fabri.valorcto + ttprodu.valorcto.
                             assign 
                                 v-totdia = v-totdia + ttprodu.valorcto
                                 v-totger = v-totger + ttprodu.valorven.
                                end.    
                                /*tirei v-perc*/
                                {anbrowse.i
                                    &File   = tt-fabri
                                    &CField = tt-fabri.fabcod
                                    &color  = write/cyan
                                    &Ofield = " tt-fabri.valorven vnomabr
                                        tt-fabri.qtd v-perdia
                                        tt-fabri.valorcto "
                                    &Where = " true "
                                    &NonCharacter = /*
                                    &AftFnd = " find first fabri where 
                                       fabri.fabcod = tt-fabri.fabcod no-lock
                                       no-error.
                                       if avail fabri
                                       then vnomabr = fabri.fabnom.
                                       else vnomabr = ' '.    
                               v-perc = tt-fabri.valorven / tt-fabri.valorcto.
                               v-perdia = tt-fabri.valorven * 100 / v-totger."
                                    &AftSelect1 = "next keys-loop."
                                    &LockType = " use-index valor "
                                    &Form = " frame f-fabri" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l2.
                            end.
                        end.
                        


end procedure.

PROCEDURE calcesto.

/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : calcesto.i
***** Diretorio                    : movim
***** Autor                        : Andre
***** Descri‡ao Abreviada da Funcao: Include Performance de Estoque
***** Data de Criacao              : ??????

                                ALTERACOES
***** 1) Autor     : Caludir Santolin
***** 1) Descricao : Adaptacoes Sale2000
***** 1) Data      : ????2001

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

/*def var estoq.estatual as dec.
def var produ.procmed as dec.*/
v-totalzao = 0.

vtotal = 0.
message color normal "Preparando...".

hide message no-pause.
message color normal "Calculando...". 
for each estab where if vetbcod = 0
                     then true
                     else (estab.etbcod >= vetbcod and
                           estab.etbcod <= vetbcod2) no-lock.

for each estoq where estoq.etbcod = estab.etbcod 
                     and estoq.estatual > 0 no-lock.
    
    find produ of estoq no-lock.
    
    if vcomcod > 0
    then do:
        release liped.
        release pedid.
        find last liped where liped.procod = produ.procod
                          and liped.pedtdc = 1
                              no-lock use-index liped2 no-error.

        find first pedid of liped no-lock no-error.
    
        if (avail pedid and pedid.comcod <> vcomcod)
           or not avail pedid
        then next.
                    
    end.
     
     if v-etccod > 0 and
        produ.etccod <> v-etccod
     then next.
        
     if v-carcod > 0 and 
        v-subcod > 0 and
        not can-find(first procar where procar.procod = produ.procod and
                                       procar.subcod = v-subcod)
     then next.                         


    if /*vfabcod*/ vforcod <> 0
    then if produ.fabcod <> /*vfabcod*/ vforcod then next.
    
    find sclase where sclase.clacod = produ.clacod no-lock no-error.
    if not avail sclase
    then next.
    find clase where clase.clacod = sclase.clasup no-lock.
    find clasup1 where clasup1.clacod = clase.clasup no-lock.

    find grupo where grupo.clacod = clasup1.clasup no-lock.
    
    /*find setor where setor.setcod = clase.setcod no-lock.*/
    find categoria where categoria.catcod = produ.catcod no-lock no-error.
    

    
    /***vfoi = vfoi + 1.
    if vfoi mod 50 = 0 or
       vfoi < 50 or
       vfoi >= vtotal - 50
    then do :
        disp "Processando .."
        string(time - vtime,"HH:MM:SS")
        vfoi * 100 / vtotal format ">>>9.99 %" 
        with frame f-mostr 1 down 
            row 10 centered no-labels color white/black.
        pause 0.
    end.****/

        disp "Processando .."
        string(time - vtime,"HH:MM:SS")
        with frame f-mostr 1 down 
            row 10 centered no-labels color white/black.
        pause 0.
           
           
    find first ttloja where ttloja.etbcod = estoq.etbcod no-error.
    if not avail ttloja
    then do:
        create ttloja.
        assign ttloja.etbcod = estoq.etbcod
               ttloja.etbnom = estab.etbnom.
    end.
    ttloja.valorven = ttloja.valorven + 
                        (estoq.estatual * estoq.estvenda).
    ttloja.valorcto = ttloja.valorcto +
                        (estoq.estatual * estoq.estcusto).
                        
    /*
    ttloja.valorcto = ttloja.valorcto + 
           (estoq.estatual * produ.procmed).
   
    else ttloja.valorcto = ttloja.valorcto + 
           (estoq.estatual * produ.procmed).
    */
    
    ttloja.qtd = ttloja.qtd + estoq.estatual.
            
    if vetbcod = 0 or
      (vetbcod <> vetbcod2)
    then do :
        find first ttloja where ttloja.etbcod = /*999*/ 0 no-error.
        if not avail ttloja
        then do:
            create ttloja.
            assign ttloja.etbcod = /*999*/ 0
                   ttloja.etbnom = "G E R A L".
        end.
        ttloja.valorven = ttloja.valorven + 
                (estoq.estatual * estoq.estvenda).
        ttloja.valorcto = ttloja.valorcto +
                (estoq.estatual * estoq.estcusto).
                
        /*if avail precohrg and
           produ.procmed > 0 
        then  ttloja.valorcto = ttloja.valorcto + 
                (estoq.estatual * produ.procmed).
        else ttloja.valorcto = ttloja.valorcto + 
                (estoq.estatual * produ.procmed).
        */        
        
        ttloja.qtd = ttloja.qtd + estoq.estatual.
         
    end.

    /*********** ACERTANDO SETORES  *************/
    find first ttsetor where ttsetor.etbcod = estoq.etbcod
                         and ttsetor.setcod = categoria.catcod /*setor.setcod*/
                         no-error.
    if not avail ttsetor
    then do:
        create ttsetor.
        assign ttsetor.etbcod = estoq.etbcod
               ttsetor.setcod = categoria.catcod /*setor.setcod*/.
    end.
        
    ttsetor.valorven = ttsetor.valorven + 
           (estoq.estatual * estoq.estvenda /*if avail precohrg
                             then precohrg.prvenda
                             else 0*/ ).
    ttsetor.valorcto = ttsetor.valorcto +
           (estoq.estatual * estoq.estcusto).
           
    /*if avail precohrg
       and produ.procmed > 0
    then ttsetor.valorcto = ttsetor.valorcto + 
           (estoq.estatual * produ.procmed).
    else ttsetor.valorcto = ttsetor.valorcto + 
           (estoq.estatual * produ.procmed).   */
           
    ttsetor.qtd = ttsetor.qtd + estoq.estatual.
            
    if vetbcod = 0 or (vetbcod <> vetbcod2)
    then do :
        find first ttsetor where ttsetor.etbcod = /*999*/ 0
                             and ttsetor.setcod = categoria.catcod 
                             /*setor.setcod*/ no-error.
        if not avail ttsetor
        then do:
            create ttsetor.
            assign ttsetor.etbcod = /*999*/ 0
                   ttsetor.setcod = /*setor.setcod*/ categoria.catcod.
        end.
        ttsetor.valorven = ttsetor.valorven + 
                (estoq.estatual * estoq.estvenda /*if avail precohrg
                                  then precohrg.prvenda
                                  else 0*/ ).
        ttsetor.valorcto = ttsetor.valorcto +
                (estoq.estatual * estoq.estcusto).
                
        /*
        if avail precohrg and produ.procmed > 0 
        then  ttsetor.valorcto = ttsetor.valorcto + 
                (estoq.estatual * produ.procmed).
        else ttsetor.valorcto = ttsetor.valorcto + 
                (estoq.estatual * produ.procmed).
        */        
        ttsetor.qtd = ttsetor.qtd + estoq.estatual.
         
    end.

    /************** GERANDO INFORMACOES GRUPO **************/
    find first ttgrupo where ttgrupo.etbcod = estoq.etbcod
                         and ttgrupo.clacod = grupo.clacod
                         and ttgrupo.setcod = categoria.catcod /*setor.setcod*/
                         no-error.
    if not avail ttgrupo
    then do:
        create ttgrupo.
        assign ttgrupo.etbcod = estoq.etbcod
               ttgrupo.clacod = grupo.clacod
               ttgrupo.setcod = categoria.catcod /*setor.setcod*/.
    end.
        
    ttgrupo.valorven = ttgrupo.valorven + 
           (estoq.estatual * /*if avail precohrg
                             then precohrg.prvenda
                             else 0*/ estoq.estvenda).
    ttgrupo.valorcto = ttgrupo.valorcto +
           (estoq.estatual * estoq.estcusto).
                             
    /*if avail precohrg and produ.procmed > 0 
    then ttgrupo.valorcto = ttgrupo.valorcto + 
           (estoq.estatual * produ.procmed).
    else ttgrupo.valorcto = ttgrupo.valorcto + 
           (estoq.estatual * produ.procmed).*/
           
    ttgrupo.qtd = ttgrupo.qtd + estoq.estatual.
            
    if vetbcod = 0 or (vetbcod <> vetbcod2)
    then do :
        find first ttgrupo where ttgrupo.etbcod = /*999*/ 0
                             and ttgrupo.clacod = grupo.clacod
                             and ttgrupo.setcod = categoria.catcod
                             /*setor.setcod*/ no-error.
        if not avail ttgrupo
        then do:
            create ttgrupo.
            assign ttgrupo.etbcod = /*999*/ 0
                   ttgrupo.clacod = grupo.clacod
                   ttgrupo.setcod = categoria.catcod /*setor.setcod*/.
        end.
        ttgrupo.valorven = ttgrupo.valorven + 
                (estoq.estatual * /*if avail precohrg 
                                  then precohrg.prvenda
                                  else 0*/ estoq.estvenda).
        ttgrupo.valorcto = ttgrupo.valorcto +
                (estoq.estatual * estoq.estcusto).
        
        /*if avail precohrg and
           produ.procmed > 0 
        then  ttgrupo.valorcto = ttgrupo.valorcto + 
                (estoq.estatual * produ.procmed).
        else ttgrupo.valorcto = ttgrupo.valorcto + 
                (estoq.estatual * produ.procmed).*/
                
        ttgrupo.qtd = ttgrupo.qtd + estoq.estatual.
         
    end.

/******/

    /************** GERANDO INFORMACOES CLASUP1 **************/
    find first ttclasup1 where ttclasup1.etbcod = estoq.etbcod
                         and ttclasup1.clacod = clasup1.clacod
                         and ttclasup1.setcod = categoria.catcod no-error.
    if not avail ttclasup1
    then do:
        create ttclasup1.
        assign ttclasup1.etbcod = estoq.etbcod
               ttclasup1.clasup = grupo.clacod 
               ttclasup1.clacod = clasup1.clacod
               ttclasup1.setcod = categoria.catcod.
    end.
        
    ttclasup1.valorven = ttclasup1.valorven + 
           (estoq.estatual * estoq.estvenda).
    ttclasup1.valorcto = ttclasup1.valorcto +
           (estoq.estatual * estoq.estcusto).
    
    ttclasup1.qtd = ttclasup1.qtd + estoq.estatual.
            
    if vetbcod = 0 or (vetbcod <> vetbcod2)
    then do :
        find first ttclasup1 where ttclasup1.etbcod = /*999*/ 0
                              and ttclasup1.clacod = clasup1.clacod
                              and ttclasup1.setcod = categoria.catcod
                           no-error.
        if not avail ttclasup1
        then do:
            create ttclasup1.
            assign ttclasup1.etbcod = /*999*/ 0
                   ttclasup1.clasup = grupo.clacod
                   ttclasup1.clacod = clasup1.clacod
                   ttclasup1.setcod = categoria.catcod.
        end.

        ttclasup1.valorven = ttclasup1.valorven + 
                (estoq.estatual * estoq.estvenda).
        ttclasup1.valorcto = ttclasup1.valorcto +
                (estoq.estatual * estoq.estcusto).
                
        ttclasup1.qtd = ttclasup1.qtd + estoq.estatual.
         
    end.

    
    
/*******/    
    
    /************** GERANDO INFORMACOES CLASSE **************/
    find first ttclase where ttclase.etbcod = estoq.etbcod
                         and ttclase.clacod = clase.clacod
                         and ttclase.setcod = categoria.catcod no-error.
    if not avail ttclase
    then do:
        create ttclase.
        assign ttclase.etbcod = estoq.etbcod
               ttclase.clasup = /*grupo.clacod*/ clasup1.clacod
               ttclase.clacod = clase.clacod
               ttclase.setcod = categoria.catcod.
    end.
        
    ttclase.valorven = ttclase.valorven + 
           (estoq.estatual * /*if avail precohrg 
                             then precohrg.prvenda
                             else 0*/ estoq.estvenda).
    ttclase.valorcto = ttclase.valorcto +
           (estoq.estatual * estoq.estcusto).
    
    /*if avail precohrg and produ.procmed > 0 
    then  ttclase.valorcto = ttclase.valorcto + 
           (estoq.estatual * produ.procmed).
    else ttclase.valorcto = ttclase.valorcto + 
           (estoq.estatual * produ.procmed).*/
           
    ttclase.qtd = ttclase.qtd + estoq.estatual.
            
    if vetbcod = 0 or (vetbcod <> vetbcod2)
    then do :
        find first ttclase where ttclase.etbcod = /*999*/ 0
                             and ttclase.clacod = clase.clacod
                             and ttclase.setcod = categoria.catcod
                           no-error.
        if not avail ttclase
        then do:
            create ttclase.
            assign ttclase.etbcod = /*999 */ 0
                   ttclase.clasup = /*grupo.clacod*/ clasup1.clacod
                   ttclase.clacod = clase.clacod
                   ttclase.setcod = categoria.catcod.
        end.
        ttclase.valorven = ttclase.valorven + 
                (estoq.estatual * /*if avail precohrg
                                  then precohrg.prvenda
                                  else 0*/ estoq.estvenda).
        ttclase.valorcto = ttclase.valorcto +
                (estoq.estatual * estoq.estcusto).
        
        /*if avail precohrg and produ.procmed > 0 
        then  ttclase.valorcto = ttclase.valorcto + 
                (estoq.estatual * produ.procmed).
        else ttclase.valorcto = ttclase.valorcto + 
                (estoq.estatual * produ.procmed).*/
                
        ttclase.qtd = ttclase.qtd + estoq.estatual.
         
    end.

    /************** GERANDO INFORMACOES SUB-CLASSE **************/
    find first ttsclase where ttsclase.etbcod = estoq.etbcod
                          and ttsclase.clacod = sclase.clacod
                          and ttsclase.setcod = categoria.catcod no-error.
    if not avail ttsclase
    then do:
        create ttsclase.
        assign ttsclase.etbcod = estoq.etbcod
               ttsclase.clasup = clase.clacod
               ttsclase.clacod = sclase.clacod
               ttsclase.setcod = categoria.catcod.
    end.
        
    ttsclase.valorven = ttsclase.valorven + 
           (estoq.estatual * /*if avail precohrg
                             then precohrg.prvenda
                             else 0*/ estoq.estvenda).
    ttsclase.valorcto = ttsclase.valorcto +
           (estoq.estatual * estoq.estcusto).                             
                             
    /*if avail precohrg and produ.procmed > 0 
    then  ttsclase.valorcto = ttsclase.valorcto + 
           (estoq.estatual * produ.procmed).
    else ttsclase.valorcto = ttsclase.valorcto + 
           (estoq.estatual * produ.procmed).     */
    ttsclase.qtd = ttsclase.qtd + estoq.estatual.
    
            
    if vetbcod = 0 or (vetbcod <> vetbcod2)
    then do :
        find first ttsclase where ttsclase.etbcod = /*999*/ 0
                             and ttsclase.clacod = sclase.clacod
                             and ttsclase.setcod = categoria.catcod
                           no-error.
        if not avail ttsclase
        then do:
            create ttsclase.
            assign ttsclase.etbcod = /*999*/ 0
                   ttsclase.clasup = clase.clacod
                   ttsclase.clacod = sclase.clacod
                   ttsclase.setcod = categoria.catcod.
        end.
        ttsclase.valorven = ttsclase.valorven + 
                (estoq.estatual * /*if avail precohrg
                                  then precohrg.prvenda
                                  else 0*/ estoq.estvenda).
                                  
        ttsclase.valorcto = ttsclase.valorcto +
                (estoq.estatual * estoq.estcusto).
        
        /*if avail precohrg and produ.procmed > 0 
        then  ttsclase.valorcto = ttsclase.valorcto + 
                (estoq.estatual * produ.procmed).
        else ttsclase.valorcto = ttsclase.valorcto + 
                (estoq.estatual * produ.procmed).*/
                
        ttsclase.qtd = ttsclase.qtd + estoq.estatual.
         
    end.

    /************** GERANDO INFORMACOES PRODUTOS **************/
    find first ttprodu where ttprodu.etbcod = estoq.etbcod
                         and ttprodu.clacod = sclase.clacod
                         and ttprodu.procod = produ.procod
                         and ttprodu.setcod = categoria.catcod
                       no-error.
    if not avail ttprodu
    then do:
        create ttprodu.
        assign ttprodu.etbcod = estoq.etbcod
               ttprodu.clacod = sclase.clacod
               ttprodu.procod = produ.procod
               ttprodu.setcod = categoria.catcod.
    end.
        
    ttprodu.valorven = ttprodu.valorven + 
           (estoq.estatual * /*if avail precohrg 
                             then precohrg.prvenda
                             else 0*/ estoq.estvenda).
    ttprodu.valorcto = ttprodu.valorcto +
           (estoq.estatual * estoq.estcusto).
                                 
    /*if avail precohrg and produ.procmed > 0 
    then   ttprodu.valorcto = ttprodu.valorcto + 
           (estoq.estatual * produ.procmed).
    else ttprodu.valorcto = ttprodu.valorcto + 
           (estoq.estatual * produ.procmed).*/
           
    ttprodu.qtd = ttprodu.qtd + estoq.estatual.
            
    if vetbcod = 0 or (vetbcod <> vetbcod2)
    then do :
        find first ttprodu where ttprodu.etbcod = /*999*/ 0
                             and ttprodu.clacod = sclase.clacod
                             and ttprodu.procod = produ.procod
                             and ttprodu.setcod = categoria.catcod
                           no-error.
        if not avail ttprodu
        then do:
            create ttprodu.
            assign ttprodu.etbcod = /*999*/ 0
                   ttprodu.clacod = sclase.clacod
                   ttprodu.procod = produ.procod
                   ttprodu.setcod = categoria.catcod.
        end.
        ttprodu.valorven = ttprodu.valorven + 
                (estoq.estatual * /*if avail precohrg 
                                  then precohrg.prvenda
                                  else 0*/ estoq.estvenda).

        ttprodu.valorcto = ttprodu.valorcto +
                (estoq.estatual * estoq.estcusto).
        
        /*if avail precohrg and produ.procmed > 0 
        then ttprodu.valorcto = ttprodu.valorcto + 
                (estoq.estatual * produ.procmed).
        else ttprodu.valorcto = ttprodu.valorcto + 
                (estoq.estatual * produ.procmed).*/
        
        ttprodu.qtd = ttprodu.qtd + estoq.estatual.
    end.
end.
end.

end procedure.

procedure imprimeloja.

    if opsys = "UNIX"
    then varquivo = "../relat/perfoest." + string(time).
    else varquivo = "l:\relat\perfoest." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""perfoest""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFOMANCE DE ESTOQUES """
        &Width     = "100"
        &Form      = "frame f-cabcab"
    }.

for each ttloja.
  assign v-perc = ttloja.valorven / ttloja.valorcto
         v-perdia = ttloja.valorven * 100 / v-totger. 

  display
    ttloja.etbcod
    ttloja.etbnom  format "x(20)" column-label "Estabel." 
    ttloja.qtd      column-label "Qtd.Est" 
    ttloja.valorcto  format "->,>>>,>>9.99" column-label "Est.Cus"
    ttloja.valorven  format "->,>>>,>>9.99" column-label "Est.Ven"
    v-perc           column-label "% V/E" format "->>9.99" 
    v-perdia         format "->>9.99"
    with frame f-implojas width 100.
    
end.  

    /*{mdadmrod.i &Saida     = "value(varqsai)"
                &NomRel    = """perfoest"""
                &Page-Size = "60"
                &Width     = "100"
                &Traco     = "65"
                &Form      = "frame f-rod3"}.*/
                
    output close.                
    
    if opsys = "UNIX" and sparam <> "AniTA"
    then do:

        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).
            
    end.
    else if sparam = "AniTA"
    then do:
    
         run visurel.p (input varquivo, input ""). 
    
    end.
    else do:
        {mrod.i}.
    end.    


end procedure.


procedure pro-op.
    
    def input parameter p-var as char.
    def input parameter p-cla like clase.clacod.

    for each ttproduaux: delete ttproduaux. end.
    
    disp vfapro-op
         with frame f-esc-op 1 down centered color with/black no-label overlay.
   
    choose field vfapro-op with frame f-esc-op.
    
    clear frame f-esc-op all. 
    hide frame f-esc-op no-pause.
    
    if frame-index <> 1
    then do:
        
        if p-var = "p-grupo"
        then do:
            /*if p-grupo <> 0
            then do:
            for each ttclasup1 where ttclasup1.etbcod = p-loja
                              and ttclasup1.clasup = p-grupo
                              and ttclasup1.setcod = p-setor 
                                  no-lock:
               for each ttclase where ttclase.etbcod = p-loja
                                  and ttclase.clasup = ttclasup1.clacod no-lock:
                  for each ttsclase where ttsclase.etbcod = p-loja
                                      and ttsclase.clasup = ttclase.clacod
                                      no-lock:
                     for each ttprodu where ttprodu.etbcod = p-loja
                                        and ttprodu.clacod = ttsclase.clacod
                                        and ttprodu.setcod = p-setor:
              
                         find first ttproduaux where 
                                    ttproduaux.etbcod = p-loja and
                                    ttproduaux.procod = ttprodu.procod and
                                    ttproduaux.clacod = ttprodu.clacod
                                    use-index produ no-error.
                                    
                        if not avail ttproduaux
                        then do:              
                            create ttproduaux.
                            assign ttproduaux.procod = ttprodu.procod
                                   ttproduaux.clacod = ttprodu.clacod
                                   ttproduaux.etbcod = ttprodu.etbcod
                                   ttproduaux.qtd    = ttprodu.qtd
                                   ttproduaux.valorven = ttprodu.valorven
                                   ttproduaux.valorcto = ttprodu.valorcto
                                   ttproduaux.setcod = ttprodu.setcod.
                                   
                        end.
                     end.
                  end.
               end.                   
            end.
            end.
            else*/ do:
            for each ttsetor where ttsetor.etbcod = p-loja and
                                   ttsetor.setcod = p-setor no-lock:
            for each ttgrupo where ttgrupo.etbcod = p-loja and
                                   ttgrupo.setcod = ttsetor.setcod and
                                   ttgrupo.clacod = p-grupo no-lock:
            for each ttclasup1 where ttclasup1.etbcod = p-loja
                              and ttclasup1.clasup = ttgrupo.clacod
                              and ttclasup1.setcod = ttgrupo.setcod 
                                  no-lock:
               for each ttclase where ttclase.etbcod = p-loja
                                  and ttclase.clasup = ttclasup1.clacod
                                  and ttclase.setcod = ttsetor.setcod no-lock:
                  for each ttsclase where ttsclase.etbcod = p-loja
                                      and ttsclase.clasup = ttclase.clacod
                                      and ttsclase.setcod = ttsetor.setcod
                                      no-lock:
                     for each ttprodu where ttprodu.etbcod = p-loja
                                        and ttprodu.clacod = ttsclase.clacod
                                        and ttprodu.setcod = p-setor:
              
                         find first ttproduaux where 
                                    ttproduaux.etbcod = p-loja and
                                    ttproduaux.procod = ttprodu.procod and
                                    ttproduaux.clacod = ttprodu.clacod
                                    use-index produ no-error.
                                    
                        if not avail ttproduaux
                        then do:              
                            create ttproduaux.
                            assign ttproduaux.procod = ttprodu.procod
                                   ttproduaux.clacod = ttprodu.clacod
                                   ttproduaux.etbcod = ttprodu.etbcod
                                   ttproduaux.qtd    = ttprodu.qtd
                                   ttproduaux.valorven = ttprodu.valorven
                                   ttproduaux.valorcto = ttprodu.valorcto
                                   ttproduaux.setcod = ttprodu.setcod.
                                   
                        end.
                     end.
                  end.
               end.                   
            end.
            end.
            end.
            end.
        end.
        else
        if p-var = "p-clase1"
        then do:
            for each ttsetor where ttsetor.etbcod = p-loja and
                                   ttsetor.setcod = p-setor no-lock:
            for each ttgrupo where ttgrupo.etbcod = p-loja and
                                   ttgrupo.setcod = ttsetor.setcod and
                                   ttgrupo.clacod = p-grupo no-lock:
            for each ttclasup1 where ttclasup1.etbcod = p-loja
                              and ttclasup1.clasup = ttgrupo.clacod
                              and ttclasup1.setcod = ttgrupo.setcod
                              and ttclasup1.clacod = p-clase1 
                                  no-lock:
            for each ttclase where ttclase.etbcod = p-loja
                                  and ttclase.clasup = ttclasup1.clacod
                                  and ttclase.setcod = ttsetor.setcod no-lock:
                  for each ttsclase where ttsclase.etbcod = p-loja
                                      and ttsclase.clasup = ttclase.clacod
                                      and ttsclase.setcod = ttsetor.setcod
                                      no-lock:
                  for each ttprodu where ttprodu.etbcod = p-loja 
                                    and ttprodu.clacod = ttsclase.clacod
                                    and ttprodu.setcod = ttsetor.setcod:
              
                     find first ttproduaux
                          where ttproduaux.etbcod = p-loja 
                            and ttproduaux.procod = ttprodu.procod
                            and ttproduaux.clacod = ttprodu.clacod
                            use-index produ no-error.
                                    
                     if not avail ttproduaux
                     then do:
                            create ttproduaux.
                            assign ttproduaux.procod = ttprodu.procod
                                   ttproduaux.clacod = ttprodu.clacod
                                   ttproduaux.etbcod = ttprodu.etbcod
                                   ttproduaux.qtd    = ttprodu.qtd
                                   ttproduaux.valorven = ttprodu.valorven
                                   ttproduaux.valorcto = ttprodu.valorcto
                                   ttproduaux.setcod = ttprodu.setcod.

                     
                     end.
                  end.
               end.
            end.
            end.
            end.
            end.
        end.
        else
        if p-var = "p-clase"
        then do:
            for each ttsetor where ttsetor.etbcod = p-loja and
                                   ttsetor.setcod = p-setor no-lock:
            for each ttgrupo where ttgrupo.etbcod = p-loja and
                                   ttgrupo.setcod = ttsetor.setcod and
                                   ttgrupo.clacod = p-grupo no-lock:
            for each ttclasup1 where ttclasup1.etbcod = p-loja
                              and ttclasup1.clasup = ttgrupo.clacod
                              and ttclasup1.setcod = ttgrupo.setcod
                              and ttclasup1.clacod = p-clase1 
                                  no-lock:
            for each ttclase where ttclase.etbcod = p-loja
                                  and ttclase.clasup = ttclasup1.clacod
                                  and ttclase.clacod = p-clase
                                  and ttclase.setcod = ttsetor.setcod no-lock:
                  for each ttsclase where ttsclase.etbcod = p-loja
                                      and ttsclase.clasup = ttclase.clacod
                                      and ttsclase.setcod = ttsetor.setcod
                                      no-lock:

               for each ttprodu where ttprodu.etbcod = p-loja 
                                  and ttprodu.clacod = ttsclase.clacod
                                  and ttprodu.setcod = ttsetor.setcod:
              
                  find first ttproduaux
                       where ttproduaux.etbcod = p-loja 
                         and ttproduaux.procod = ttprodu.procod
                         and ttproduaux.clacod = ttprodu.clacod
                         use-index produ no-error.
                                    
                  if not avail ttproduaux
                  then do:
                            create ttproduaux.
                            assign ttproduaux.procod = ttprodu.procod
                                   ttproduaux.clacod = ttprodu.clacod
                                   ttproduaux.etbcod = ttprodu.etbcod
                                   ttproduaux.qtd    = ttprodu.qtd
                                   ttproduaux.valorven = ttprodu.valorven
                                   ttproduaux.valorcto = ttprodu.valorcto
                                   ttproduaux.setcod = ttprodu.setcod.

                  end.
               end.
            end.
            end.
            end.
            end.
            end.
        end.
    end.
    
    
                        if frame-index = 2
                        then do:
                            l1:
                            repeat :
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if p-loja <> /*999*/ 0
                                then
                                find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                assign an-seeid = -1 an-recid = -1 an-seerec = ?
                       v-titpro  = "PRODUTOS DA CLASSE ".

                       if p-var = "p-grupo"
                       then v-titpro = v-titpro + string(p-grupo).
                       else
                       if p-var = "p-clase1"
                       then v-titpro = v-titpro + string(p-clase1).
                       else
                       if p-var = "p-clase"
                       then v-titpro = v-titpro + string(p-clase).
                                   
                       v-titpro =  v-titpro + " - LOJA ".
                       
                       if p-loja <> 0
                       then v-titpro = v-titpro + string(estab.etbnom) .
                       else v-titpro = v-titpro + "EMPRESA".
                       
                       assign v-totdia = 0 v-totger = 0.
              
                                
                                for each ttproduaux .
                                  assign v-totdia = v-totdia + 
                                        ttproduaux.valorcto
                                        v-totger = v-totger + 
                                        ttproduaux.valorven.
                                end.    
                                /*tirei v-perc do browse (penultimo)*/
                                {anbrowse.i
                                    &File   = ttproduaux
                                    &CField = ttproduaux.procod
                                    &color  = write/cyan
                                    &Ofield = " ttproduaux.valorven 
                                        vnomabr v-perdia
                                        ttproduaux.qtd 
                                        ttproduaux.valorcto "
                                    &Where = " true "
                                    &NonCharacter = /*
                                    &AftFnd = " 
                                        find first produ where 
                                       produ.procod = ttproduaux.procod no-lock
                                       no-error.
                                       if avail produ
                                       then vnomabr = produ.pronom + ' ' +
                                          produ.corcod.
                                       else vnomabr = ' '.    
                         v-perc = ttproduaux.valorven / ttproduaux.valorcto.
                         v-perdia = ttproduaux.valorven * 100 / v-totger."
                                    &AftSelect1 = "next keys-loop."
                                    &Otherkeys = "
                                        if keyfunction(lastkey) = ""p""
                                        or keyfunction(lastkey) = ""P""
                                        then do:
                                            find ttproduaux where 
                                                recid(ttproduaux) =
                                                an-seerec[frame-line] no-error.
                                            find produ where  
                                              produ.procod = ttproduaux.procod
                                                             no-lock no-error.
                                            hide frame f-produ-aux no-pause.
                                            run pro-cut-ttaux-produ.
                                            next l1.
                                        end.
                                        if keyfunction(lastkey) = ""CLEAR""
                                        then do:
     find ttproduaux where recid(ttproduaux) = an-seerec[frame-line] no-error.
                                                
                                           if avail ttproduaux
                                           then do:
                                               v-imagem = ""l:\pro_im\"" + 
                                               trim(string(ttproduaux.procod)) +
                                               "".jpg"".
                                               os-command silent start
                                                          value(v-imagem).
                                           end.           
                                           next keys-loop. 
                                        end.
                                        
                                        if keyfunction(lastkey) = ""I"" or
                                           keyfunction(lastkey) = ""i""
                                        then do:
                                            run imp-pro (input ""ttproduaux"",
                                                         input 0,
                                                         input 0,
                                                         input 0).
                                        end.
                                    "                                    
                                    &LockType = "use-index valor"
                                    &Form = " frame f-produaux" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l1.
                            end.
                        end.
                        
                        if frame-index = 3
                        then do:
                            l2:
                            repeat :
                                for each tt-fabri:
                                    delete tt-fabri.
                                end.    
                                if p-loja <> /*999*/ 0
                                then
                                find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                assign an-seeid = -1 an-recid = -1 an-seerec = ?.
                
                       v-titpro  = "FABRICANTES DA CLASSE ".
                       
                       if p-var = "p-grupo"
                       then v-titpro = v-titpro + string(p-grupo).  
                       else 
                       if p-var = "p-clase1" 
                       then v-titpro = v-titpro + string(p-clase1). 
                       else 
                       if p-var = "p-clase" 
                       then v-titpro = v-titpro + string(p-clase).
                       
                       v-titpro  = v-titpro +  " - LOJA ".
                        
                       if p-loja <> 0
                       then v-titpro = v-titpro + string(estab.etbnom).
                       else v-titpro = v-titpro + "EMPRESA".
                       
                       assign v-totdia = 0 v-totger = 0.
                            
                                for each ttproduaux:

                                    find first produ where 
                                         produ.procod = ttproduaux.procod
                                               no-lock.
                                    find first tt-fabri where
                                               tt-fabri.fabcod = produ.fabcod 
                                               no-error.
                                    if not avail tt-fabri
                                    then do:
                                        create tt-fabri.
                                        tt-fabri.fabcod = produ.fabcod.
                                    end.
                                assign
                    tt-fabri.valorven = tt-fabri.valorven + 
                            ttproduaux.valorven
                    tt-fabri.qtd    = tt-fabri.qtd    + ttproduaux.qtd
                    tt-fabri.valorcto = tt-fabri.valorcto + ttproduaux.valorcto.
                             assign 
                                 v-totdia = v-totdia + ttproduaux.valorcto
                                 v-totger = v-totger + ttproduaux.valorven.
                                end.    
                                /*tirei v-perc*/
                                {anbrowse.i
                                    &File   = tt-fabri
                                    &CField = tt-fabri.fabcod
                                    &color  = write/cyan
                                    &Ofield = " tt-fabri.valorven vnomabr
                                        tt-fabri.qtd  v-perdia
                                        tt-fabri.valorcto "
                                    &Where = " true "
                                    &NonCharacter = /*
                                    &AftFnd = " find first fabri where 
                                       fabri.fabcod = tt-fabri.fabcod no-lock
                                       no-error.
                                       if avail fabri
                                       then vnomabr = fabri.fabnom.
                                       else vnomabr = ' '.    
                               v-perc = tt-fabri.valorven / tt-fabri.valorcto.
                               v-perdia = tt-fabri.valorven * 100 / v-totger."
                                    &AftSelect1 = "next keys-loop."
                                    &LockType = " use-index valor "
                                    &Form = " frame f-fabri" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l2.
                            end.
                        end.
                        

end procedure.    

procedure imp-pro:
    
    def input parameter pro-tabela as   char.
    def input parameter pro-loja   like estab.etbcod.
    def input parameter pro-sclase like clase.clacod.
    def input parameter pro-setor  like setor.setcod.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rcob9" + string(time).
    else varquivo = "l:\relat\rcob9" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "115"
        &Page-Line = "0"
        &Nom-Rel   = ""perfoest""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """PERFORMANCE DE ESTOQUE - PRODUTOS"""
        &Width     = "115"
        &Form      = "frame f-cabcab"}

    if pro-tabela = "ttprodu"
    then do:
        for each ttprodu where ttprodu.etbcod = pro-loja
                           and ttprodu.clacod = pro-sclase
                           and ttprodu.setcod = pro-setor no-lock,
            first produ where produ.procod = ttprodu.procod
                              no-lock break by produ.pronom:

            vnomabr = "".
            
            if avail produ 
            then vnomabr = produ.pronom + " " + 
                           produ.corcod. 
            else vnomabr = " ".
            
            v-perc-imp = 0. v-perdia-imp = 0.
            
            v-perc-imp = ttprodu.valorven / ttprodu.valorcto.
            v-perdia-imp = ttprodu.valorven * 100 / v-totger.
            
            disp
                ttprodu.procod  column-label "Cod" 
                vnomabr    format "x(50)" 
                ttprodu.qtd (total)    format "->>>>>>>>>9" column-label "Qtd.Est" 
                ttprodu.valorcto 
                        format "->>>,>>9.99"  column-label "Est.Cus" 
                ttprodu.valorven (total)
                    format "->>>,>>9.99"  column-label "Est.Ven" 
                v-perc          column-label "% V/E"  format "->>9.99" 
                v-perdia        format "->>9.99"
                with frame f-produ-imp centered down width 150.
                           
        end.
    end.    
    else do:
        for each ttproduaux no-lock,
            first produ where produ.procod = ttproduaux.procod 
                              no-lock break by produ.pronom:

            vnomabr = "".
            
            if avail produ 
            then vnomabr = produ.pronom + " " + 
                           produ.corcod. 
            else vnomabr = " ".
            
            v-perc-imp = 0. v-perdia-imp = 0.
            
            v-perc-imp = ttproduaux.valorven / ttproduaux.valorcto.
            v-perdia-imp = ttproduaux.valorven * 100 / v-totger.
            
            disp
                ttproduaux.procod  column-label "Cod"
                vnomabr              format "x(50)" 
                ttproduaux.qtd      format "->>>>>>>>>9" column-label "Qtd.Est" 
                ttproduaux.valorcto  format "->>>,>>9.99"  column-label "Est.Cus" 
                ttproduaux.valorven  format "->>>,>>9.99"  column-label "Est.Ven" 
                v-perc-imp           column-label "% V/E" format "->>9.99" 
                v-perdia-imp         format "->>9.99"
                with frame f-produ-imp-aux centered down width 150.
                           
            
        end.    
    end.

    output close.
        
    if opsys = "UNIX" and sparam <> "AniTA"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).

    end.
    else if sparam = "AniTA"
    then do:
        
        run visurel.p (input varquivo, input "").
                 
    end.                
    else do:
        {mrod.i}.
    end.    
    
end procedure.

/******************************************/

procedure pro-cut-ttprodu:
    hide frame f-setor   no-pause. 
    hide frame f-lojas   no-pause. 
    hide frame f-grupo   no-pause. 
    hide frame f-clasup1 no-pause. 
    hide frame f-clase   no-pause. 
    hide frame f-sclase  no-pause. 
    hide frame f-produ   no-pause. 
    hide frame f-produ-aux no-pause.
    hide frame f-fabri   no-pause.

    for each tresu. delete tresu. end. 
    for each ttprodu where 
             ttprodu.procod = produ.procod. 
             
        find first tresu where tresu.etbcod = ttprodu.etbcod no-error.
        if not avail tresu 
        then do: 
            create tresu.
            assign tresu.etbcod   = ttsetor.etbcod 
                   tresu.qtd      = ttsetor.qtd 
                   tresu.valorven = ttsetor.valorven 
                   tresu.valorcto = ttsetor.valorcto.
        end. 
    end. 
    hide frame f-produ no-pause. 
    v-titulo = ' '. 
    v-titulo = string(produ.procod) + ' - ' + produ.pronom. 
    run perf-brwe.p (input v-titulo).

end procedure.

procedure pro-cut-ttaux-produ:
    hide frame f-setor   no-pause. 
    hide frame f-lojas   no-pause. 
    hide frame f-grupo   no-pause. 
    hide frame f-clasup1 no-pause. 
    hide frame f-clase   no-pause. 
    hide frame f-sclase  no-pause. 
    hide frame f-produ   no-pause. 
    hide frame f-produ-aux no-pause.
    hide frame f-fabri   no-pause.
    
    for each tresu. delete tresu. end.

    for each ttprodu where ttprodu.procod = produ.procod:
        find first tresu where tresu.etbcod = ttprodu.etbcod no-error.
        if not avail tresu
        then do: 
            create tresu.
            assign tresu.etbcod   = ttsetor.etbcod 
                   tresu.qtd      = ttsetor.qtd 
                   tresu.valorven = ttsetor.valorven 
                   tresu.valorcto = ttsetor.valorcto.
        end.
    end. 
    
    hide frame f-produ-aux no-pause. 
    
    v-titulo = ' '. 
    v-titulo = string(produ.procod) + ' - ' + produ.pronom. 
    
    run perf-brwe.p (input v-titulo).

end procedure.



procedure imprime-setor.
    def input parameter par-loja like p-loja.
    
    if opsys = "UNIX"
    then varquivo = "../relat/perfoest." + string(time).
    else varquivo = "l:\relat\perfoest." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""perfoest""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFOMANCE DE ESTOQUES """
        &Width     = "100"
        &Form      = "frame f-cabcab"
    }.

for each ttsetor where ttsetor.etbcod = par-loja
                       break by ttsetor.valorven desc.
  assign v-perc = ttsetor.valorven / ttsetor.valorcto
         v-perdia = ttsetor.valorven * 100 / v-totger. 

  find icategoria where icategoria.catcod = ttsetor.setcod no-lock no-error.
  
  display
    ttsetor.setcod
    icategoria.catnom  format "x(20)" column-label "Descricao" 
        when avail categoria
    ttsetor.qtd      column-label "Qtd.Est"                              
    ttsetor.valorcto  format "->,>>>,>>9.99" column-label "Est.Cus"
    ttsetor.valorven  format "->,>>>,>>9.99" column-label "Est.Ven"
    v-perc           column-label "% V/E" format "->>9.99" 
    v-perdia         format "->>9.99"
    with frame f-impsetor width 100 down.
    
end.  

    output close.                
    
    if opsys = "UNIX" and sparam <> "AniTA"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).

    end.
    else if sparam = "AniTA"
    then do:
            
         run visurel.p (input varquivo, input "").
                    
    end.
    else do:
        {mrod.i}.
    end.    


end procedure.

procedure imprime-grupo.

    def input parameter par-etbcod as int.
    def input parameter par-setcod as int.
    
    if opsys = "UNIX"
    then varquivo = "../relat/perfoest." + string(time).
    else varquivo = "l:\relat\perfoest." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""perfoest""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFOMANCE DE ESTOQUES """
        &Width     = "100"
        &Form      = "frame f-cabcab"
    }.

for each ttgrupo where ttgrupo.etbcod = par-etbcod
                   and ttgrupo.setcod = par-setcod 
                       break by ttgrupo.clacod.
  assign v-perc = ttgrupo.valorven / ttgrupo.valorcto
         v-perdia = ttgrupo.valorven * 100 / v-totger. 


  find iclase where iclase.clacod = ttgrupo.clacod no-lock no-error.
  
  display
    ttgrupo.clacod column-label "Grupo"
    iclase.clanom  format "x(20)" column-label "Nome" 
    ttgrupo.qtd      column-label "Qtd.Est"
    ttgrupo.valorcto  format "->,>>>,>>9.99" column-label "Est.Cus"
    ttgrupo.valorven  format "->,>>>,>>9.99" column-label "Est.Ven"
    v-perc           column-label "% V/E" format "->>9.99" 
    v-perdia         format "->>9.99"
    with frame f-impgrupo width 100 down.
    
end.  

    output close.                
    
    if opsys = "UNIX" and sparam <> "AniTA"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).

    end.
    else if sparam = "AniTA"
    then do:
            
        run visurel.p (input varquivo, input "").
                     
    end.
    else do:
        {mrod.i}.
    end.    


end procedure.

procedure imprime-cla1.
    def input parameter par-etbcod as int.
    def input parameter par-grupo as int.
    def input parameter par-setcod as int.
    
    if opsys = "UNIX"
    then varquivo = "../relat/perfoest." + string(time).
    else varquivo = "l:\relat\perfoest." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""perfoest""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFOMANCE DE ESTOQUES """
        &Width     = "100"
        &Form      = "frame f-cabcab"
    }.

for each ttclasup1 where ttclasup1.etbcod = par-etbcod
                     and ttclasup1.clasup = par-grupo
                     and ttclasup1.setcod = par-setcod 
                         break by ttclasup1.clacod.

  assign v-perc = ttclasup1.valorven / ttclasup1.valorcto
         v-perdia = ttclasup1.valorven * 100 / v-totger. 

  find iclase where iclase.clacod = ttclasup1.clacod no-lock no-error.

  display
    ttclasup1.clacod 
    iclase.clanom      format "x(20)"
    ttclasup1.qtd      column-label "Qtd.Est"
    ttclasup1.valorcto format "->,>>>,>>9.99" column-label "Est.Cus"
    ttclasup1.valorven format "->,>>>,>>9.99" column-label "Est.Ven"
    v-perc             column-label "% V/E" format "->>9.99" 
    v-perdia           format "->>9.99"
    with frame f-impclase width 100 down.
    
end.  

    output close.                
    
    if opsys = "UNIX" and sparam <> "AniTA"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).

    end.
    else if sparam = "AniTA"
    then do:
            
        run visurel.p (input varquivo, input "").
                     
    end.
    else do:
        {mrod.i}.
    end.    


end procedure.

 procedure imprime-cla.
    def input parameter par-etbcod as int.
    def input parameter par-clase1 as int.
    def input parameter par-setcod as int.
    
    if opsys = "UNIX"
    then varquivo = "../relat/perfoest." + string(time).
    else varquivo = "l:\relat\perfoest." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""perfoest""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFOMANCE DE ESTOQUES """
        &Width     = "100"
        &Form      = "frame f-cabcab"
    }.

for each ttclase where ttclase.etbcod = par-etbcod
                   and ttclase.clasup = par-clase1
                   and ttclase.setcod = par-setcod 
                       break by ttclase.clacod.

  assign v-perc = ttclase.valorven / ttclase.valorcto
         v-perdia = ttclase.valorven * 100 / v-totger. 

  find iclase where iclase.clacod = ttclase.clacod no-lock no-error.

  display
    ttclase.clacod 
    iclase.clanom  format "x(20)"
    ttclase.qtd      column-label "Qtd.Est"
    ttclase.valorcto  format "->,>>>,>>9.99" column-label "Est.Cus"
    ttclase.valorven  format "->,>>>,>>9.99" column-label "Est.Ven"
    v-perc           column-label "% V/E" format "->>9.99" 
    v-perdia         format "->>9.99"
    with frame f-impclase width 100 down.
    
end.  

    output close.                
    
    if opsys = "UNIX" and sparam <> "AniTA"
    then do:

        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).
    
    end.
    else if sparam = "AniTA"
    then do:
            
         run visurel.p (input varquivo, input "").
                    
    end.
    else do:
        {mrod.i}.
    end.    


end procedure.

procedure imprime-scla.
    
    def input parameter par-etbcod as int.
    def input parameter par-clase  as int.
    def input parameter par-setcod as int.
    
    if opsys = "UNIX"
    then varquivo = "../relat/perfoest." + string(time).
    else varquivo = "l:\relat\perfoest." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""perfoest""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFOMANCE DE ESTOQUES """
        &Width     = "100"
        &Form      = "frame f-cabcab"
    }.

for each ttsclase where ttsclase.etbcod = par-etbcod
                    and ttsclase.clasup  = par-clase
                    and ttsclase.setcod  = par-setcod 
                        break by ttclase.clacod.

  assign v-perc   = ttsclase.valorven / ttsclase.valorcto
         v-perdia = ttsclase.valorven * 100 / v-totger. 

  find iclase where iclase.clacod = ttsclase.clacod no-lock no-error.

  disp
    ttsclase.clacod
    iclase.clanom     format "x(15)" 
    ttsclase.qtd      column-label "Qtd.Est"   format "->>>>>>>>>9"
    ttsclase.valorcto column-label "Est.Cus" format "->,>>>,>>9.99" 
    ttsclase.valorven format "->,>>>,>>9.99"   column-label "Est.Ven"
    v-perc            column-label "% V/E"     format "->>9.99"
    v-perdia          format "->>9.99"
    with frame f-impsclase width 100.
    
end.  

    output close.                
    
    if opsys = "UNIX" and sparam <> "AniTA"
    then do:

        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).
    
    end.
    else if sparam = "AniTA"
    then do:
            
         run visurel.p (input varquivo, input "").
                     
    end.
    else do:
        {mrod.i}.
    end.    


end procedure.

