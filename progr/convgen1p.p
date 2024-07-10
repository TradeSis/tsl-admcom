/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : convgen1.p
***** Diretorio                    : movim
***** Autor                        : Andre
***** Descri‡ao Abreviada da Funcao: Performance de vendas
***** Data de Criacao              : ??????

                                ALTERACOES
***** 1) Autor     : Claudir Santolin
***** 1) Descricao : Adaptacoes Sale2000
***** 1) Data      : ????2001

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

{admcab-palm.i}.
{anset.i}.

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.



def var v-titulo as char format "X(50)".
def var varquivo as char.

def new shared temp-table tresu
    field etbcod      like estab.etbcod
    field etbnom      like estab.etbnom
    field platot      like plani.platot
    field qtd         like movim.movqtm
    field perc-val    as dec format "->>9.99"
    field perc-qtd    as dec format "->>9.99".

def input parameter vfabcod like fabri.fabcod.
def var v-imagem as char.

def temp-table ttaux-produ
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod
    index produ     procod etbcod clacod
    index valor     platot desc.

def var v-data-aux as date format "99/99/9999".
def var v-acre      as dec.
def var v-totcom    as dec.
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
def var vetbcod     like plani.etbcod           no-undo.
def var v-totger    as dec.
def shared      var vdti        as date format "99/99/9999" no-undo.
def shared      var vdtf        as date format "99/99/9999" no-undo.
def var p-vende     like func.funcod.
def shared var p-loja      like estab.etbcod.
def var p-setor     like produ.catcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-clase1 like clase.clacod.
def var p-clase2 like clase.clacod.

def var p-sclase    like clase.clacod.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titcla-nivel1 as char.
def var v-titcla-nivel2 as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perdia-imp as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-perc-imp  as dec label "% Acum".

def var v-perdev    as dec label "% Dev" format ">9.99".
def var vnomabr like produ.pronom format "x(20)". 

def var vfapro as char extent 2  format "x(15)"
                init["  PRODUTO  "," FABRICANTE "].
                
def var vfapro-op as char extent 3  format "x(15)"
                init[" DESCER ", "  PRODUTO  "," FABRICANTE "].
                       

def buffer testab   for estab.
def buffer sclase   for clase.
def buffer grupo    for clase.

/***/

def buffer nivel1 for clase.
def buffer nivel2 for clase.

def shared temp-table ttnivel1
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

def shared temp-table ttnivel2 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

/***/    


def shared temp-table ttloja
    field medven    like plani.platot
    field medqtd    like movim.movqtm
    field metlj     like plani.platot
    field platot    like plani.platot
    field etbnom    like estab.etbnom
    field etbcod    like plani.etbcod
    field pladia    like plani.platot
    index loja      etbcod
    index ranking platot desc.

def shared  temp-table ttsetor 
    field platot    like plani.platot
    field setcod    like setor.setcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field etbcod    like plani.etbcod
    index setor     etbcod setcod 
    index valor     platot desc.
    
def shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
    
def shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.
    
def shared temp-table ttprodu
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    index produ     procod etbcod clacod
    index valor     platot desc.
    
def shared temp-table ttclase 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

def shared temp-table ttsclase 
    field platot    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index sclase    etbcod clacod.

def temp-table tt-fabri
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field fabcod    like fabri.fabcod
    field clacod    like plani.placod 
    index valor1     platot desc.

form
    clase.clacod
    clase.clanom
        help " " /*" ENTER = Seleciona" */
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttvend.numseq   column-label "Rk" format ">>9" 
    help " " /*" F8= Imprime "*/
    ttvend.funcod   column-label "Cod" format ">>9"
    func.funnom    format "x(18)" 
    ttvend.qtd     column-label "Qtd" format ">>>>9" 
    ttvend.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvend.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vend
        centered
        down 
        title v-titven.
        
form
    ttvenpro.procod
       help " " /*"F8=Imprime"*/
    produ.pronom    format "x(18)" 
    ttvenpro.qtd     column-label "Qtd" format ">>>9" 
    ttvenpro.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down 
        title v-titvenpro.
 
form
    ttloja.etbcod
        help " " /*"ENTER=Seleciona F4=Encerra F8=Imprime" */
    ttloja.etbnom  format "x(16)" column-label "Estabel." 
    ttloja.metlj  column-label "Meta Loja" format "->>>,>>9.99" 
    ttloja.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia"
    v-perdia
    ttloja.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perc 
    with frame f-lojas
        width 80
        centered
        color white/red
        down 
        title " VENDAS POR LOJA ".
        
form
    ttloja.etbcod
    estab.etbnom  format "x(20)" 
    ttloja.metlj  column-label "Meta da Loja" format "->,>>>,>>9.99"
    ttloja.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia"
    v-perdia
    ttloja.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perc 
    with frame f-lojaimp
        width 180 
        centered
        down
        no-box.

form
    ttsetor.setcod
    help " " /*"P = Informacoes Filiais"*/
    setor.setnom    format "x(16)" 
    ttsetor.qtd     format "->>>>9"  column-label "Qtd"
    ttsetor.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia"
    v-perdia        format "->>9.99" column-label "% Dia" 
    ttsetor.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum" 
    v-perc          format "->>9.99" column-label "% Acum" 
    with frame f-setor 
        centered
        width 80
        color white/green
        down  overlay
        title v-titset.
        
form
    ttprodu.procod  column-label "Cod" 
    help " " /*"ENTER=Estoque  F8=Imagem  I=Imprime  P=Informacoes Filiais"*/
    vnomabr    format "x(25)" 
    ttprodu.qtd     format "->>9" column-label "Qtd" 
    /* v-perdev  format ">9.99" column-label "% Dev"  */
    ttprodu.pladia  format "->>>,>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    ttprodu.platot  format "->>>,>>9.99"    column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-produ
        width 80
        down 
        title v-titpro.
        
form
    ttaux-produ.procod  column-label "Cod" 
    help " " /*"ENTER=Estoque  F8=Imagem  I=Imprime  P=Informacoes Filiais"*/
    vnomabr    format "x(25)" 
    ttaux-produ.qtd     format "->>9" column-label "Qtd" 
    ttaux-produ.pladia  format "->>>,>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    ttaux-produ.platot  format "->>>,>>9.99"    column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-produ-aux
        width 80
        down 
        title v-titpro.
        
form
    ttclase.clacod
    help " " /*"P = Informacoes Filiais"*/
    clase.clanom    format "x(18)" 
    ttclase.qtd     column-label "Qtd" format "->>>9" 
    ttclase.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttclase.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-clase
        centered
        down 
        title v-titcla.
        
/***/
form
    ttnivel1.clacod
    help " " /*"P = Informacoes Filiais"*/
    clase.clanom    format "x(18)" 
    ttnivel1.qtd     column-label "Qtd" format "->>>9" 
    ttnivel1.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttnivel1.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-nivel1
        centered
        down 
        title v-titcla-nivel1.
        
form
    ttnivel2.clacod
    help " " /*"P = Informacoes Filiais"*/
    clase.clanom    format "x(18)" 
    ttnivel2.qtd     column-label "Qtd" format "->>>9" 
    ttnivel2.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttnivel2.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-nivel2
        centered
        down 
        title v-titcla-nivel2.
        
/***/        

form
    tt-fabri.fabcod  column-label "Cod" 
    vnomabr    format "x(20)"
    tt-fabri.qtd     format "->>>9" column-label "Qtd" 
    v-perdev  format ">9.99" column-label "% Dev"  
    tt-fabri.pladia  format "->>,>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    tt-fabri.platot  format "->>,>>9.99"   column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-fabri
       /* width 80*/
        down 
        title v-titpro.

form
    "Aguarde, Processando sua Solicitacao ..."
    plani.pladat
    estab.etbnom
    with frame f-mostr1 1 down row 10 centered
        no-labels. 

form
       with frame f-moxtr1s centered no-labels 1 down.
form
    ttsclase.clacod
    help " " /*"P = Informacoes Filiais"*/
    sclase.clanom    format "x(18)" 
    ttsclase.qtd        column-label "Qtd"   format "->>>9"    
    ttsclase.pladia  column-label "Vnd.Dia" format "->>,>>>,>>9.99" 
    v-perdia         format "->>9.99" column-label "% Dia" 
    ttsclase.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perc           format "->>9.99" column-label "% Acum" 
    with frame f-sclase
        centered
        down 
        title v-titscla.

vetbcod = p-loja.        

form
    vetbcod  label  "Lj"
    estab.etbnom no-label format "x(15)" 
    vdti     label "Dt.Inic"
    vdtf     label "Dt.Fim"
    vhora    label "H"
    with frame f-etb
        centered
        1 down side-labels title "Dados Iniciais"
        color white/bronw row 4 width 80.

def var v-opcao as char format "x(12)" extent 2 initial
    ["POR VENDEDOR","POR PRODUTOS"].
    
form
    v-opcao[1]  format "x(12)"
    v-opcao[2]  format "x(12)"
    with frame f-opcao
        centered 1 down no-labels overlay row 10 color white/green. 


            
            for each ttaux-produ. delete ttaux-produ. end.
            
            vetbcod = p-loja.
            if vetbcod <> 0
            then do :
                find first ttsetor where ttsetor.etbcod = vetbcod no-error.
                if not avail ttsetor
                then do:
                    
                    /*{calcv101.i}.*/
                    run calcv101.
                    
                end.    
            end.
            else do :
                for each testab where testab.etbcod < 900 no-lock :
                    if {conv_igual.i testab.etbcod} then next.
                    find first ttsetor where ttsetor.etbcod = testab.etbcod
                                       no-error.
                    if not avail ttsetor
                    then do :
                        vetbcod = testab.etbcod.
                        
                        /*{calcv101.i}.*/
                        run calcv101.
                    end.
                end.            
            end.
            clear frame f-opcao all.
            hide frame f-opcao.
            l95:
            repeat :
                if p-loja <> 0 
                then
                    find first estab where estab.etbcod = p-loja no-lock.
            
                assign an-seeid = -1 an-recid = -1 an-seerec = ?
                v-titset  = "CATEGORIAS DA LOJA " + 
                    if p-loja <> 0 
                    then string(estab.etbnom) else "EMPRESA"
                v-totger = 0 v-totdia = 0.
            
                for each ttsetor where ttsetor.etbcod = p-loja:
                    assign  v-totdia = v-totdia + ttsetor.pladia
                            v-totger = v-totger + ttsetor.platot.
                end.

                hide frame f-mostr1.

                {anbrowse.i
                    &File   = ttsetor
                    &CField = ttsetor.setcod
                    &color  = write/cyan
                    &Ofield = " ttsetor.platot 
                                setor.setnom when avail setor
                                ttsetor.pladia v-perc v-perdia ttsetor.qtd"
                    &Where = "ttsetor.etbcod = p-loja"
                    &NonCharacter = /*
                    &AftFnd = " find first setor where 
                                   setor.setcod = ttsetor.setcod no-lock
                                   no-error. 
                     assign v-perc = (if ttsetor.platot > 0
                                      then ttsetor.platot * 100 / v-totger
                                      else 0)  
                            v-perdia = ( if ttsetor.pladia > 0
                                        then ttsetor.pladia * 100 / v-totdia
                                        else 0). "
                    &AftSelect1 = "p-setor = ttsetor.setcod. 
                               leave keys-loop. "
                    &Otherkeys = " 
                                 IF KEYFUNCTION(LASTKEY) = ""CUT""
                                 or keyfunction(lastkey) = ""p""
                                 or keyfunction(lastkey) = ""P""
                                 THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttsetor where 
                                        recid(ttsetor) = an-seerec[frame-line]
                                        no-error.
                                   find setor where setor.setcod = 
                                        ttsetor.setcod no-lock no-error.
                                   
                                   for each ttsetor where
                                            ttsetor.setcod = setor.setcod.
                                       find first tresu where tresu.etbcod = 
                                            ttsetor.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign tresu.etbcod = ttsetor.etbcod
                                                  tresu.qtd    = ttsetor.qtd
                                                  tresu.platot = ttsetor.platot.
                                       end.
                                      
                                   end.
                                   hide frame f-etb no-pause.
                                   hide frame f-setor no-pause.
                                   v-titulo = ''.
                                   v-titulo = string(setor.setcod) + 
                                             ' - ' + setor.setnom.
                                   run perf-brw.p
                                      (input v-titulo).
                                   next l95.

                                 END.  
                                 "
                    &LockType = "use-index valor"           
                    &Form = " frame f-setor" 
                }.
        
/****/

                if keyfunction(lastkey) = "END-ERROR"
                then leave l95.

                l96:
                repeat :

                    find first setor where setor.setcod = p-setor no-lock
                       no-error.
                    if not avail setor
                    then do:
                         message "Setor " p-setor "nao cadastrado"
                                    view-as alert-box.
                         return.
                         end.
                    
                    if p-loja <> 0 
                    then
                    find first estab where estab.etbcod = p-loja no-lock.
            
                    assign 
                        an-seeid = -1 an-recid = -1 an-seerec = ?
                        v-titcla-nivel1  = "SETORES DA CATEGORIA " 
                        + string(p-setor) + " - LOJA " + 

                    if p-loja <> 0
                    then string(estab.etbnom) else "EMPRESA"
                    
                    v-totdia = 0 v-totger = 0.        
    
                    for each ttnivel1 where ttnivel1.etbcod = p-loja 
                                       and ttnivel1.clasup = p-setor :
                        assign
                            v-totdia = v-totdia + ttnivel1.pladia
                            v-totger = v-totger + ttnivel1.platot.
                    end.

                    {anbrowse.i
                        &File   = ttnivel1
                        &CField = ttnivel1.clacod
                        &color  = write/cyan
                        &Ofield = "ttnivel1.platot clase.clanom 
                                   ttnivel1.pladia  
                                   v-perc v-perdia ttnivel1.qtd "
                        &Where = "ttnivel1.etbcod = p-loja and
                                  ttnivel1.clasup = p-setor "
                        &NonCharacter = /*
                        &AftFnd = " find first clase where 
                                    clase.clacod= ttnivel1.clacod no-lock.
                            assign v-perc = (if ttnivel1.platot > 0
                                          then ttnivel1.platot * 100 / v-totger
                                          else 0)
                                v-perdia = (if ttnivel1.pladia > 0
                                           then ttnivel1.pladia * 100 / v-totdia
                                           else 0). "
                        &AftSelect1 = "p-clase1 = ttnivel1.clacod. 
                                        run pro-op (input ""p-clase1"",
                                                    input p-clase1).
                                        if keyfunction(lastkey) = ""END-ERROR""
                                        then next l96. leave keys-loop. "
                    &Otherkeys = "  IF KEYFUNCTION(LASTKEY) = ""CUT""
                                    or keyfunction(lastkey) = ""p""
                                    or keyfunction(lastkey) = ""P""
                                 THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttnivel1 where
                                        recid(ttnivel1) = an-seerec[frame-line]
                                        no-error.
                                   find clase where clase.clacod = 
                                        ttnivel1.clacod no-lock no-error.
                                   
                                   for each ttnivel1 where
                                            ttnivel1.clacod = clase.clacod.
                                       find first tresu where tresu.etbcod = 
                                            ttnivel1.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign tresu.etbcod = ttnivel1.etbcod
                                                  tresu.qtd = ttnivel1.qtd
                                                tresu.platot = ttnivel1.platot.
                                       end.
                                   end.
                                   hide frame f-etb no-pause.
                                   hide frame f-nivel1 no-pause.
                                   v-titulo = ' '.
                                   v-titulo = string(clase.clacod) + 
                                             ' - ' + clase.clanom.
                                   run perf-brw.p
                                       (input v-titulo).
                                   next l96.
                                 END.
                                 "
                                        
                        &Form = " frame f-nivel1" 
                    }.

/************************/ 
                                
                if keyfunction(lastkey) = "END-ERROR"
                then leave l96.

                l97:
                repeat :
                    find first setor where setor.setcod = p-setor no-lock
                       no-error.
                    if not avail setor
                    then do:
                         message "Setor " p-setor "nao cadastrado"
                                    view-as alert-box.
                         return.
                         end.
                    
                    if p-loja <> 0 
                    then
                    find first estab where estab.etbcod = p-loja no-lock.
            
                    assign 
                        an-seeid = -1 an-recid = -1 an-seerec = ?
                        v-titcla-nivel2  = "GRUPOS DO SETOR " + 
                            string(p-clase1) +
                                   " - LOJA " + 
                    if p-loja <> 0
                    then string(estab.etbnom) else "EMPRESA"
                    
                    v-totdia = 0 v-totger = 0.        
    
                    for each ttnivel2 where ttnivel2.etbcod = p-loja 
                                       and ttnivel2.clasup = p-clase1 :
                        assign 
                            v-totdia = v-totdia + ttnivel2.pladia
                            v-totger = v-totger + ttnivel2.platot.
                    end.    
                        
                    {anbrowse.i
                        &File   = ttnivel2
                        &CField = ttnivel2.clacod
                        &color  = write/cyan
                        &Ofield = "ttnivel2.platot clase.clanom 
                                   ttnivel2.pladia  
                                   v-perc v-perdia ttnivel2.qtd "
                        &Where = "ttnivel2.etbcod = p-loja and
                                  ttnivel2.clasup = p-clase1 "
                        &NonCharacter = /*
                        &AftFnd = " find first clase where 
                                    clase.clacod= ttnivel2.clacod no-lock.
                            assign 
                                v-perc = (if ttnivel2.platot > 0
                                          then ttnivel2.platot * 100 / v-totger
                                          else 0)
                                v-perdia = (if ttnivel2.pladia > 0
                                           then ttnivel2.pladia * 100 / v-totdia
                                           else 0). "
                        &AftSelect1 = "p-clase2 = ttnivel2.clacod. 
                                        run pro-op (input ""p-clase2"",
                                                    input p-clase2).
                                       if keyfunction(lastkey) = ""END-ERROR""
                                       then next l97.
                                       leave keys-loop."
                    &Otherkeys = " 
                                 IF KEYFUNCTION(LASTKEY) = ""CUT""
                                 or keyfunction(lastkey) = ""p""
                                 or keyfunction(lastkey) = ""P""
                                 THEN DO:
                                   for each tresu. delete tresu. end.
                                   find ttnivel2 where
                                        recid(ttnivel2) = an-seerec[frame-line]
                                        no-error.
                                   find clase where clase.clacod = 
                                        ttnivel2.clacod no-lock no-error.
                                   
                                   for each ttnivel2 where
                                            ttnivel2.clacod = clase.clacod.
                                       find first tresu where tresu.etbcod = 
                                            ttnivel2.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign tresu.etbcod = ttnivel2.etbcod
                                                  tresu.qtd = ttnivel2.qtd
                                               tresu.platot = ttnivel2.platot.
                                       end.
                                   end.
                                   hide frame f-etb no-pause.
                                   hide frame f-nivel2 no-pause.
                                   v-titulo = ' '.
                                   v-titulo = string(clase.clacod) + ' - ' +
                                              clase.clanom.
                                   run perf-brw.p
                                       (input v-titulo).
                                   next l97.

                                 END."
                        &Form = " frame f-nivel2"
                    }.
                
/****/                
                
                if keyfunction(lastkey) = "END-ERROR"
                then leave l97.
                
                
                l98:
                repeat :
                    find first setor where setor.setcod = p-setor no-lock
                       no-error.
                    if not avail setor
                    then do:
                         message "Setor " p-setor "nao cadastrado"
                                    view-as alert-box.
                         return.
                         end.
                    
                    if p-loja <> 0 
                    then
                    find first estab where estab.etbcod = p-loja no-lock.
            
                    assign 
                        an-seeid = -1 an-recid = -1 an-seerec = ?
                        v-titcla  = "CLASSES DO GRUPO " + 
                                    string(p-clase2) + " - LOJA " + 
                    if p-loja <> 0
                    then string(estab.etbnom) else "EMPRESA"
                    
                    v-totdia = 0 v-totger = 0.        
    
                    for each ttclase where ttclase.etbcod = p-loja 
                                       and ttclase.clasup = p-clase2 :
                        assign 
                            v-totdia = v-totdia + ttclase.pladia
                            v-totger = v-totger + ttclase.platot.
                    end.    
                        
                    {anbrowse.i
                        &File   = ttclase
                        &CField = ttclase.clacod
                        &color  = write/cyan
                        &Ofield = "ttclase.platot clase.clanom 
                                   ttclase.pladia  v-perc v-perdia ttclase.qtd "
                        &Where = "ttclase.etbcod = p-loja and
                                  ttclase.clasup = p-clase2 "
                        &NonCharacter = /*
                        &AftFnd = " find first clase where 
                                    clase.clacod= ttclase.clacod no-lock.
                            assign 
                                v-perc = (if ttclase.platot > 0
                                          then ttclase.platot * 100 / v-totger
                                          else 0)
                                v-perdia = (if ttclase.pladia > 0
                                           then ttclase.pladia * 100 / v-totdia
                                           else 0)."
                        &AftSelect1 = "p-clase = ttclase.clacod.
                                        run pro-op (input ""p-clase"",
                                                    input p-clase).
                                       if keyfunction(lastkey) = ""END-ERROR""
                                       then next l98.
                                       leave keys-loop. "
                    &Otherkeys = " 
                                 IF KEYFUNCTION(LASTKEY) = ""CUT""
                                 or keyfunction(lastkey) = ""p""
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
                                           assign tresu.etbcod = ttclase.etbcod
                                                  tresu.qtd = ttclase.qtd
                                                tresu.platot = ttclase.platot.
                                       end.
                                   end.
                                   hide frame f-etb no-pause.
                                   hide frame f-clase no-pause.
                                   v-titulo = ' '.
                                   v-titulo = string(clase.clacod) + ' - ' +
                                              clase.clanom.
                                   run perf-brw.p
                                       (input v-titulo).
                                   next l98.
                                 END."
                        &Form = " frame f-clase" 
                    }.

                    if keyfunction(lastkey) = "END-ERROR"
                    then leave l98.
                  
                    l99:    
                    repeat :
                        find first clase where clase.clacod = p-clase 
                                         no-lock no-error.
                        if p-loja <> 0 
                        then
                            find first estab where estab.etbcod = p-loja 
                                        no-lock.
        
                        assign 
                            an-seeid = -1 an-recid = -1 an-seerec = ?
                            v-titscla  = "SUBCLASSES DA CLASSE " + 
                                  /*string(clase.clanom)*/
                                  string(clase.clacod) 
                                   + " - LOJA " + 
                        if p-loja <> 0
                        then string(estab.etbnom) else "EMPRESA"
                        
                        v-totdia = 0 v-totger = 0.
    
                        for each ttsclase where ttsclase.etbcod = p-loja 
                                              and ttsclase.clasup = p-clase :
                            assign v-totdia = v-totdia + ttsclase.pladia
                                v-totger = v-totger + ttsclase.platot.
                        end.    

                        {anbrowse.i
                            &File   = ttsclase
                            &CField = ttsclase.clacod
                            &color  = write/cyan
                            &Ofield = "ttsclase.platot sclase.clanom 
                                       ttsclase.pladia v-perc v-perdia 
                                       ttsclase.qtd "
                            &Where = "ttsclase.etbcod = p-loja and
                                      ttsclase.clasup = p-clase"
                            &NonCharacter = /*
                            &AftSelect1 = "p-sclase = ttsclase.clacod .
                                           leave keys-loop."
                            &AftFnd = " find first sclase where 
                                        sclase.clacod= ttsclase.clacod no-lock.
                                assign  
                                v-perc = (if ttsclase.platot > 0
                                          then ttsclase.platot * 100 / v-totger
                                          else 0)                        
                                v-perdia = (if ttsclase.pladia > 0
                                           then ttsclase.pladia * 100 / v-totdia
                                            else 0). "
                    &Otherkeys = " 
                                 IF KEYFUNCTION(LASTKEY) = ""CUT""
                                 or keyfunction(lastkey) = ""p""
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
                                           assign tresu.etbcod = ttsclase.etbcod
                                                  tresu.qtd = ttsclase.qtd
                                               tresu.platot = ttsclase.platot.
                                       end.
                                   end.
                                   
                                   hide frame f-etb no-pause.
                                   hide frame f-sclase no-pause.
                                   v-titulo = ' '.
                                   v-titulo = string(clase.clacod) + ' - ' +
                                              clase.clanom.
                                   run perf-brw.p
                                       (input v-titulo).
                                   next l99.
                                 END."
                            &Form = " frame f-sclase" 
                        }.

                        if keyfunction(lastkey) = "END-ERROR"
                        then leave l99.

                            disp vfapro with frame f-esc 1 down
                                 centered color with/black no-label 
                                 overlay.
                            choose field vfapro with frame f-esc.

                            clear frame f-esc all.
                            hide frame f-esc.

                            if frame-index = 1 
                            then do : 
                            l1:
                            repeat :
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if p-loja <> 0
                                then
                                find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "PRODUTOS DA SUBCLASSE " + 
                                    /*string(clase.clanom)*/
                                    string(clase.clacod)
                                     + " - LOJA " + 
                                    if p-loja <> 0
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                            
                                for each ttprodu where ttprodu.etbcod = p-loja
                                           and ttprodu.clacod = sclase.clacod:
                                    assign 
                                        v-totdia = v-totdia + ttprodu.pladia
                                        v-totger = v-totger + ttprodu.platot.
                                end.    
                                
                                {anbrowse.i
                                    &File   = ttprodu
                                    &CField = ttprodu.procod
                                    &color  = write/cyan
                                    &Ofield = " ttprodu.platot vnomabr
                                        ttprodu.qtd v-perc
                                        v-perdia ttprodu.pladia "
                                    &Where = "ttprodu.etbcod = p-loja and
                                              ttprodu.clacod = p-sclase "
                                    &NonCharacter = /*
                                    &AftFnd = " find first produ where 
                                       produ.procod = ttprodu.procod no-lock
                                       no-error.
                                       if avail produ
                                       then vnomabr = produ.pronom.
                                       else vnomabr = ' '.    
                                v-perc = (if ttprodu.platot > 0
                                          then ttprodu.platot * 100 / v-totger
                                          else 0).
                                v-perdia = (if ttprodu.pladia > 0
                                   then ttprodu.pladia * 100 / v-totdia
                                   else 0)."
                                   &AftSelect1 = "run convgen-est.p
                                            (input string(ttprodu.procod),
                                             input vdti, input vdtf ).
                                        next keys-loop."
                                    &otherkeys = "
                                    IF keyfunction(lastkey) = ""p""
                                    or keyfunction(lastkey) = ""P""
                                    THEN DO: 
                                   find ttprodu where
                                        recid(ttprodu) = an-seerec[frame-line]
                                        no-error.

                                   find produ where produ.procod = 
                                        ttprodu.procod no-lock no-error.

                                      hide frame f-etb no-pause.
                                      hide frame f-produ no-pause.
                                      run pro-cut-ttprodu.
                                      
                                      next l1.
                                    END.         
                                        if keyfunction(lastkey) = ""I"" or
                                           keyfunction(lastkey) = ""i""
                                        then do:
                                            run imp-pro (input ""ttprodu"",
                                                         input p-loja,
                                                         input p-sclase).
                                        end.
                                        
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
                                        end."
                                    &LockType = "use-index valor"
                                    &Form = " frame f-produ" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l1.
                            end.
                        end.
                        else do :
                            l2:
                            repeat :
                                for each tt-fabri: delete tt-fabri. end.    
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if p-loja <> 0 
                                then
                                    find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "FABRICANTES DA SUBCLASSE " + 
                                    /*string(clase.clanom)*/
                                     string(clase.clacod) + " - LOJA " + 
                                    if p-loja <> 0
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                                
                                for each ttprodu where ttprodu.etbcod = p-loja
                                           and ttprodu.clacod = sclase.clacod:
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
                                        tt-fabri.platot = tt-fabri.platot + 
                                                ttprodu.platot
                                        tt-fabri.qtd    = tt-fabri.qtd + 
                                                ttprodu.qtd
                                        tt-fabri.pladia = tt-fabri.pladia + 
                                                ttprodu.pladia.
                                    assign 
                                        v-totdia = v-totdia + ttprodu.pladia
                                        v-totger = v-totger + ttprodu.platot.
                                end.    
                                
                                {anbrowse.i
                                    &File   = tt-fabri
                                    &CField = tt-fabri.fabcod
                                    &color  = write/cyan
                                    &Ofield = " tt-fabri.platot vnomabr
                                        tt-fabri.qtd /* v-perdev */ v-perc
                                        v-perdia tt-fabri.pladia "
                                    &Where = " true "
                                    &NonCharacter = /*
                                    &AftFnd = " find first fabri where 
                                       fabri.fabcod = tt-fabri.fabcod no-lock
                                       no-error.
                                       if avail fabri
                                       then vnomabr = fabri.fabnom.
                                       else vnomabr = ' '.    
                                v-perc = (if tt-fabri.platot > 0
                                          then tt-fabri.platot * 100 / v-totger
                                          else 0).
                                v-perdia = (if tt-fabri.pladia > 0
                                   then tt-fabri.pladia * 100 / v-totdia
                                   else 0). "
                                    &AftSelect1 = "next keys-loop."
                                    &LockType = " use-index valor "
                                    &Form = " frame f-fabri" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l2.
                            end.
                        end.
                    end.  
                end.        
            end.
         end. end.


procedure calcv101:




IF VFABCOD = 0
THEN DO:
 for each tipmov where movtdc = 5 /* or tipmov.movtdc = 12 */ no-lock,
    each estab where estab.etbcod = (if vetbcod = 0 
                                     then estab.etbcod
                                     else vetbcod) 
                 and estab.etbcod <= 900 no-lock, 
    each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = estab.etbcod
                 and plani.pladat >= vdti
                 and plani.pladat <= vdtf no-lock,
            each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
            first produ where produ.procod = movim.procod no-lock,
            first sclase where sclase.clacod = produ.clacod no-lock,
            first clase where clase.clacod = sclase.clasup no-lock,

            first nivel2 where nivel2.clacod = clase.clasup no-lock,
            first nivel1 where nivel1.clacod = nivel2.clasup no-lock.
            
            if  {conv_igual.i estab.etbcod} then next.

            disp  "Processando " estab.etbnom no-label
                  plani.pladat format "99/99/9999" 
                /*skip
                 produ.procod no-label produ.pronom format "x(40)" no-label*/
                 with frame f-vvv1
                            side-labels width 80. pause 0.

            
            val_fin = 0.                    
            val_des = 0.   
            val_dev = 0.   
            val_acr = 0. 
                         
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
    
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + 
                          val_fin. 

   
             
           
            v-valor = val_com.

            find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor
            then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = plani.etbcod.
            end.

            ttsetor.platot = ttsetor.platot + val_com. 
            ttsetor.qtd = ttsetor.qtd + movim.movqtm.
            if plani.pladat = vdtf 
            then ttsetor.pladia = ttsetor.pladia + val_com.

            find first ttsetor where ttsetor.etbcod = 0
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = 0.
            end. 
            
            ttsetor.platot = ttsetor.platot + v-valor. 
            ttsetor.qtd = ttsetor.qtd + movim.movqtm.
            if plani.pladat = vdtf
            then ttsetor.pladia = ttsetor.pladia + v-valor.

/*******/

            find first ttnivel1 where ttnivel1.etbcod = plani.etbcod
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
            
            find first ttnivel1 where ttnivel1.etbcod = 0 
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
  
  /**************/
  
            find first ttnivel2 where ttnivel2.etbcod = plani.etbcod 
                                 and ttnivel2.clacod = nivel2.clacod
                                 use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
            
            find first ttnivel2 where ttnivel2.etbcod = 0 
                                 and ttnivel2.clacod = nivel2.clacod
                               use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
    

/******/


            find first ttclase where ttclase.etbcod = plani.etbcod 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = /*produ.catcod*/ nivel2.clacod
                        ttclase.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    
            
            find first ttclase where ttclase.etbcod = 0 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = /*produ.catcod*/ nivel2.clacod
                        ttclase.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    
 
                        
                        
            find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign ttsclase.clacod = sclase.clacod
                       ttsclase.clasup = clase.clacod
                       ttsclase.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12 then do:
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    

            find first ttsclase where ttsclase.etbcod = 0
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign  ttsclase.clacod = sclase.clacod
                        ttsclase.clasup = clase.clacod
                        ttsclase.etbcod = 0.
            end.
            if movim.movtdc <> 12 then do:
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    

            find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                 and ttprodu.procod = produ.procod
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12 then do:
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    

            find first ttprodu where ttprodu.etbcod = 0
                                 and ttprodu.procod = produ.procod 
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do:
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    
 end.
 hide frame f-vvv1 no-pause.
END.
ELSE DO:

      for each produ use-index iprofab where produ.fabcod = vfabcod no-lock:  
    
    do v-data-aux = vdti to vdtf:

      disp  v-data-aux format "99/99/9999"
            label "Processando"   /*skip
            produ.procod no-label produ.pronom format "x(40)" no-label*/
            
            with frame f-vvv2 width 80 side-labels. pause 0.
    
        if vetbcod <> 0 then do:
            for each movim use-index icurva 
                       where movim.etbcod = vetbcod
                         and movim.movtdc = 5
                         and movim.procod = produ.procod
                         and movim.movdat = v-data-aux no-lock:
                
                find plani where plani.etbcod = movim.etbcod
                             and plani.placod = movim.placod 
                             and plani.pladat = movim.movdat
                             and plani.movtdc = movim.movtdc no-lock.
        
                find estab where estab.etbcod = plani.etbcod no-lock.
             
                find sclase where sclase.clacod = produ.clacod no-lock.
                find clase where clase.clacod = sclase.clasup no-lock.
            
                find nivel2 where nivel2.clacod = clase.clasup no-lock.
                find nivel1 where nivel1.clacod = nivel2.clasup no-lock.
 
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + 
                          val_fin. 

   
                 
                v-valor = val_com.

                find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = plani.etbcod.
                end.

                ttsetor.platot = ttsetor.platot + v-valor. 
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.

                find first ttsetor where ttsetor.etbcod = 0
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = 0.
                end.

                if movim.movtdc <> 12 then do:
                    ttsetor.platot = ttsetor.platot + v-valor.
                    ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                    if plani.pladat = vdtf
                    then ttsetor.pladia = ttsetor.pladia + v-valor.
                end.    

/*******/

            find first ttnivel1 where ttnivel1.etbcod = plani.etbcod
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
            
            find first ttnivel1 where ttnivel1.etbcod = 0 
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
  
  /**************/
  
            find first ttnivel2 where ttnivel2.etbcod = plani.etbcod 
                                 and ttnivel2.clacod = nivel2.clacod
                                 use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
            
            find first ttnivel2 where ttnivel2.etbcod = 0 
                                 and ttnivel2.clacod = nivel2.clacod
                               use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
    

/******/



                
                
                /************ gerando vendas para a clase *******/

                find first ttclase where ttclase.etbcod = plani.etbcod 
                                     and ttclase.clacod = clase.clacod
                                     use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = /*produ.catcod*/ nivel2.clacod
                            ttclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    
            
                find first ttclase where ttclase.etbcod = 0 
                                     and ttclase.clacod = clase.clacod
                                   use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = /*produ.catcod*/ nivel2.clacod
                            ttclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    

                /******** gerando vendas para a sclase *******/
                            
                find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    

                find first ttsclase where ttsclase.etbcod = 0
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    
                        
                /************ gerando vendas para os produtos ********/

                find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                     and ttprodu.procod = produ.procod
                                     and ttprodu.clacod = sclase.clacod
                                   use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    

                find first ttprodu where ttprodu.etbcod = 0
                                     and ttprodu.procod = produ.procod 
                                     and ttprodu.clacod = sclase.clacod
                                     use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = 0.
                end.
            
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    
        
            end.
        end.
        else do:
        
            for each movim use-index datsai where movim.procod = produ.procod
                                      and movim.movtdc = 5
                                      and movim.movdat = v-data-aux no-lock:
                find plani where plani.etbcod = movim.etbcod
                     and plani.placod = movim.placod 
                     and plani.pladat = movim.movdat
                     and plani.movtdc = movim.movtdc no-lock.
                find estab where estab.etbcod = plani.etbcod no-lock.
                find sclase where sclase.clacod = produ.clacod no-lock.
                find clase where clase.clacod = sclase.clasup no-lock.

                find nivel2 where nivel2.clacod = clase.clasup no-lock.
                find nivel1 where nivel1.clacod = nivel2.clasup no-lock.
                
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + 
                          val_fin. 

   
 
                
            
                v-valor = val_com.

            find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor
            then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = plani.etbcod.
            end.

            ttsetor.platot = ttsetor.platot + v-valor.
            ttsetor.qtd = ttsetor.qtd + movim.movqtm.
            if plani.pladat = vdtf
            then ttsetor.pladia = ttsetor.pladia + v-valor.

            find first ttsetor where ttsetor.etbcod = 0
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor
            then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = 0.
            end.

            if movim.movtdc <> 12
            then do :
                ttsetor.platot = ttsetor.platot + v-valor.
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.
            end.    


/*******/

            find first ttnivel1 where ttnivel1.etbcod = plani.etbcod
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
            
            find first ttnivel1 where ttnivel1.etbcod = 0 
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
  
  /**************/
  
            find first ttnivel2 where ttnivel2.etbcod = plani.etbcod 
                                 and ttnivel2.clacod = nivel2.clacod
                                 use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
            
            find first ttnivel2 where ttnivel2.etbcod = 0 
                                 and ttnivel2.clacod = nivel2.clacod
                               use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
    

/******/



            /************ gerando vendas para a clase *******/

            find first ttclase where ttclase.etbcod = plani.etbcod 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = /*produ.catcod*/ nivel1.clacod
                        ttclase.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    
            
            find first ttclase where ttclase.etbcod = 0 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = /*produ.catcod*/ nivel1.clacod
                        ttclase.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    

            /******** gerando vendas para a sclase *******/
                        
            find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign  ttsclase.clacod = sclase.clacod
                        ttsclase.clasup = clase.clacod
                        ttsclase.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    

            find first ttsclase where ttsclase.etbcod = 0
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign  ttsclase.clacod = sclase.clacod
                        ttsclase.clasup = clase.clacod
                        ttsclase.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    
                        
            /************ gerando vendas para os produtos ********/

            find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                 and ttprodu.procod = produ.procod
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    

            find first ttprodu where ttprodu.etbcod = 0
                                 and ttprodu.procod = produ.procod 
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do:
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    
        
        end.
      end.
    end.
    end.
    hide frame f-vvv2 no-pause.
END.
end procedure.



procedure pro-op.
    
    def input parameter p-var as char.
    def input parameter p-cla like clase.clacod.
    for each ttaux-produ: delete ttaux-produ. end.
    
    disp vfapro-op
         with frame f-esc-op 1 down centered color with/black no-label overlay.
   
    choose field vfapro-op with frame f-esc-op.
    
    clear frame f-esc-op all. 
    hide frame f-esc-op no-pause.
    
    if frame-index <> 1
    then do:
        if p-var = "p-clase1" /* ttnivel1 passando o p-clase1 */
        then do:
            for each ttnivel2 where ttnivel2.etbcod = p-loja
                                and ttnivel2.clasup = p-clase1 no-lock:
               for each ttclase where ttclase.etbcod = p-loja
                                  and ttclase.clasup = ttnivel2.clacod no-lock:
                  for each ttsclase where ttsclase.etbcod = p-loja
                                      and ttsclase.clasup = ttclase.clacod
                                      no-lock:
                     for each ttprodu where ttprodu.etbcod = p-loja
                                        and ttprodu.clacod = ttsclase.clacod:
              
                         find first ttaux-produ where 
                                    ttaux-produ.etbcod = p-loja and
                                    ttaux-produ.procod = ttprodu.procod and
                                    ttaux-produ.clacod = ttprodu.clacod
                                    use-index produ no-error.
                                    
                        if not avail ttaux-produ
                        then do:
                            create ttaux-produ.
                            assign ttaux-produ.procod = ttprodu.procod
                                   ttaux-produ.clacod = ttprodu.clacod
                                   ttaux-produ.etbcod = ttprodu.etbcod
                                   ttaux-produ.platot = ttprodu.platot
                                   ttaux-produ.qtd    = ttprodu.qtd
                                   ttaux-produ.pladia = ttprodu.pladia.
                        end.
                     end.
                  end.
               end.                   
            end.
        end.
        else
        if p-var = "p-clase2" /* ttnivel2 passando o p-clase2 */
        then do:
            for each ttclase where ttclase.etbcod = p-loja
                               and ttclase.clasup = p-clase2 no-lock: 
               for each ttsclase where ttsclase.etbcod = p-loja 
                                   and ttsclase.clasup = ttclase.clacod no-lock:
                  for each ttprodu where ttprodu.etbcod = p-loja 
                                    and ttprodu.clacod = ttsclase.clacod:
              
                     find first ttaux-produ 
                          where ttaux-produ.etbcod = p-loja 
                            and ttaux-produ.procod = ttprodu.procod
                            and ttaux-produ.clacod = ttprodu.clacod
                            use-index produ no-error.
                                    
                     if not avail ttaux-produ
                     then do:
                         create ttaux-produ.
                         assign ttaux-produ.procod = ttprodu.procod
                                ttaux-produ.clacod = ttprodu.clacod
                                ttaux-produ.etbcod = ttprodu.etbcod
                                ttaux-produ.platot = ttprodu.platot
                                ttaux-produ.qtd    = ttprodu.qtd
                                ttaux-produ.pladia = ttprodu.pladia.
                     end.
                  end.
               end.
            end.
        end.
        else
        if p-var = "p-clase" /* ttclase passando o p-clase */
        then do:
            for each ttsclase where ttsclase.etbcod = p-loja 
                                and ttsclase.clasup = p-clase no-lock:
               for each ttprodu where ttprodu.etbcod = p-loja 
                                  and ttprodu.clacod = ttsclase.clacod:
              
                  find first ttaux-produ 
                       where ttaux-produ.etbcod = p-loja 
                         and ttaux-produ.procod = ttprodu.procod
                         and ttaux-produ.clacod = ttprodu.clacod
                         use-index produ no-error.
                                    
                  if not avail ttaux-produ
                  then do:
                      create ttaux-produ.
                      assign ttaux-produ.procod = ttprodu.procod
                             ttaux-produ.clacod = ttprodu.clacod
                             ttaux-produ.etbcod = ttprodu.etbcod
                             ttaux-produ.platot = ttprodu.platot
                             ttaux-produ.qtd    = ttprodu.qtd
                             ttaux-produ.pladia = ttprodu.pladia.
                  end.
               end.
            end.
        end.
    end.
    
    if frame-index = 2 
    then do: 
        l1:
            repeat: 
                           
                if p-loja <> 0 
                then 
                    find first estab where
                               estab.etbcod = p-loja no-lock no-error.

                assign an-seeid = -1 an-recid = -1 an-seerec = ?
                       v-titpro  = "PRODUTOS DA CLASSE ".

                       if p-var = "p-clase1"
                       then v-titpro = v-titpro + string(p-clase1).
                       else
                       if p-var = "p-clase2"
                       then v-titpro = v-titpro + string(p-clase2).
                       else
                       if p-var = "p-clase"
                       then v-titpro = v-titpro + string(p-clase).
                                   
                       v-titpro =  v-titpro + " - LOJA ".
                       
                       if p-loja <> 0
                       then v-titpro = v-titpro + string(estab.etbnom) .
                       else v-titpro = v-titpro + "EMPRESA".
                       
                       assign v-totdia = 0 v-totger = 0.
                 
                for each ttaux-produ no-lock:
                
                    assign v-totdia = v-totdia + ttaux-produ.pladia 
                           v-totger = v-totger + ttaux-produ.platot.

                end.    
                
                {anbrowse.i 
                    &File   = ttaux-produ 
                    &CField = ttaux-produ.procod 
                    &color  = write/cyan 
                    &Ofield = " ttaux-produ.platot vnomabr 
                                ttaux-produ.qtd v-perc 
                                v-perdia ttaux-produ.pladia " 
                    &Where = " true "
                    &NonCharacter = /* 
                    &AftFnd = " find first produ where  
                                           produ.procod = ttaux-produ.procod
                                           no-lock no-error.
                                if avail produ 
                                then vnomabr = produ.pronom. 
                                else vnomabr = ' '.    
                                
                                v-perc = (if ttaux-produ.platot > 0
                                          then
                                           ttaux-produ.platot * 100 / v-totger
                                          else 0).
                                
                                v-perdia = (if ttaux-produ.pladia > 0
                                   then ttaux-produ.pladia * 100 / v-totdia
                                   else 0). "
                    &AftSelect1 = " run convgen-est.p
                                        (input string(ttaux-produ.procod),
                                         input vdti, input vdtf).
                                    next keys-loop."
                    &otherkeys = "
                                        if keyfunction(lastkey) = ""p""
                                        or keyfunction(lastkey) = ""P""
                                        then do:

                                find ttaux-produ where 
                                recid(ttaux-produ) = an-seerec[frame-line] 
                                no-error.
                                find produ where  
                                produ.procod = ttaux-produ.procod  
                                no-lock no-error.
                                            hide frame f-etb no-pause.
                                            hide frame f-produ-aux no-pause.
                                            run pro-cut-ttaux-produ.
                                            
                                            next l1.
                                        end.
                                        if keyfunction(lastkey) = ""I"" or
                                           keyfunction(lastkey) = ""i""
                                        then do:
                                            run imp-pro (input ""ttaux-produ"",
                                                         input 0,
                                                         input 0).
                                        end.
                                        
                                        if keyfunction(lastkey) = ""CLEAR""
                                        then do:
                                           
                                           find ttaux-produ where
                                                recid(ttaux-produ) =
                                                an-seerec[frame-line]
                                                no-error.

                                           v-imagem = ""l:\pro_im\"" + 
                                           trim(string(ttaux-produ.procod)) +
                                           "".jpg"".
                                
                                           os-command silent start
                                                      value(v-imagem).
                                           next keys-loop.
                                        end."
                    &LockType = "use-index valor"
                    &Form = " frame f-produ-aux"}. 
                    
                    if keyfunction(lastkey) = "END-ERROR"
                    then leave l1.
                        
            end.
        end.
                        
    if frame-index = 3 
    then do : 
        l2: 
            repeat : 
                for each tt-fabri: delete tt-fabri. end.     
                
                if p-loja <> 0  
                then find first estab where estab.etbcod = p-loja no-lock.
                                    
                assign an-seeid = -1 an-recid = -1 an-seerec = ?.
                
                       v-titpro  = "FABRICANTES DA CLASSE ".
                       
                       if p-var = "p-clase1"
                       then v-titpro = v-titpro + string(p-clase1).  
                       else 
                       if p-var = "p-clase2" 
                       then v-titpro = v-titpro + string(p-clase2). 
                       else 
                       if p-var = "p-clase" 
                       then v-titpro = v-titpro + string(p-clase).
                       
                       v-titpro  = v-titpro +  " - LOJA ".
                        
                       if p-loja <> 0
                       then v-titpro = v-titpro + string(estab.etbnom).
                       else v-titpro = v-titpro + "EMPRESA".
                       
                       assign v-totdia = 0 v-totger = 0.
                                
                for each ttaux-produ:
                     find first produ where 
                                produ.procod = ttaux-produ.procod no-lock. 
                    
                     find first tt-fabri where 
                                tt-fabri.fabcod = produ.fabcod no-error.
                     
                     if not avail tt-fabri 
                     then do: 
                         create tt-fabri. 
                         tt-fabri.fabcod = produ.fabcod.
                     end. 
                     
                     assign tt-fabri.platot = tt-fabri.platot + 
                                              ttaux-produ.platot
                            tt-fabri.qtd    = tt-fabri.qtd + 
                                              ttaux-produ.qtd
                            tt-fabri.pladia = tt-fabri.pladia + 
                                              ttaux-produ.pladia. 
                     
                     assign v-totdia = v-totdia + ttaux-produ.pladia 
                            v-totger = v-totger + ttaux-produ.platot.
                            
                end.    
                                
                {anbrowse.i 
                    &File   = tt-fabri 
                    &CField = tt-fabri.fabcod 
                    &color  = write/cyan 
                    &Ofield = " tt-fabri.platot vnomabr 
                                tt-fabri.qtd v-perc
                                v-perdia tt-fabri.pladia " 
                    &Where = " true " 
                    &NonCharacter = /* 
                    &AftFnd = " find first fabri where  
                                           fabri.fabcod = tt-fabri.fabcod
                                           no-lock no-error.
                                if avail fabri 
                                then vnomabr = fabri.fabnom. 
                                else vnomabr = ' '.    
                                
                                v-perc = (if tt-fabri.platot > 0
                                          then tt-fabri.platot * 100 / v-totger
                                          else 0).
                                
                                v-perdia = (if tt-fabri.pladia > 0
                                   then tt-fabri.pladia * 100 / v-totdia
                                   else 0). " 
                    &AftSelect1 = "next keys-loop."
                    &LockType = " use-index valor "
                    &Form = " frame f-fabri" 
                }.
                
                if keyfunction(lastkey) = "END-ERROR"
                then leave l2.
            
            end.
    end.

end procedure.

procedure pro-cut-ttprodu:

                                    for each tresu. delete tresu. end.
                                   for each ttprodu where
                                            ttprodu.procod = produ.procod.
                                       find first tresu where tresu.etbcod = 
                                            ttprodu.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           create tresu.
                                           assign tresu.etbcod = ttprodu.etbcod
                                                  tresu.qtd    = ttprodu.qtd
                                                tresu.platot = ttprodu.platot.
                                       end.
                                   end.
                                   hide frame f-etb no-pause.
                                   hide frame f-produ no-pause.
                                   v-titulo = ' '.
                                   v-titulo = string(produ.procod) + 
                                             ' - ' + produ.pronom.
                                   run perf-brw.p
                                       (input v-titulo).


end procedure.

procedure pro-cut-ttaux-produ:

    for each tresu. 
        delete tresu. 
    end.

    for each ttprodu where 
             ttprodu.procod = produ.procod:
        
        find first tresu where tresu.etbcod = ttprodu.etbcod no-error.
        
        if not avail tresu
        then do:
            create tresu. 
            assign tresu.etbcod = ttprodu.etbcod 
                   tresu.qtd    = ttprodu.qtd 
                   tresu.platot = ttprodu.platot.
        end.
    end. 
    
    hide frame f-etb no-pause. 
    hide frame f-produ-aux no-pause. 
    
    v-titulo = ' '. 
    v-titulo = string(produ.procod) + ' - ' + produ.pronom. 
    
    run perf-brw.p (input v-titulo).

end procedure.

procedure imp-pro:
                                   
    def input parameter pro-tabela as   char.
    def input parameter pro-loja   like estab.etbcod.
    def input parameter pro-sclase like clase.clacod.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/perfven." + string(time).
    else varquivo = "l:\relat\perfven." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "115"
        &Page-Line = "0"
        &Nom-Rel   = ""convgen2""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFORMANCE DE VENDAS - PRODUTOS"""
        &Width     = "115"
        &Form      = "frame f-cabcab"}

    if pro-tabela = "ttprodu"
    then do:
        for each ttprodu where ttprodu.etbcod = pro-loja
                           and ttprodu.clacod = pro-sclase no-lock,
            first produ where produ.procod = ttprodu.procod
                              no-lock break by produ.pronom:

            vnomabr = "".

            if avail produ 
            then vnomabr = produ.pronom + " " + 
                           produ.corcod. 
            else vnomabr = " ".
            v-perc-imp = 0. v-perdia-imp = 0.
            
            v-perc-imp   = (if ttprodu.platot > 0
                           then ttprodu.platot * 100 / v-totger
                           else 0).
            v-perdia-imp = (if ttprodu.pladia > 0
                           then ttprodu.pladia * 100 / v-totdia
                           else 0).

            disp
                ttprodu.procod  column-label "Cod" 
                vnomabr    format "x(50)" column-label "Produto"
                ttprodu.qtd     format "->>>>>>9" column-label "Qtd"
                ttprodu.pladia  format "->>>,>>9.99"  column-label "V.Dia"
                v-perdia-imp    column-label "% Dia"  format "->>9.99" 
                ttprodu.platot  format "->>>,>>9.99"  column-label "V.Acum" 
                v-perc-imp      format "->>9.99" column-label "% Acum"
                with frame f-produ-imp centered down width 150.
                           
        end.
    end.    
    else do:     
        for each ttaux-produ no-lock,
            first produ where produ.procod = ttaux-produ.procod 
                              no-lock break by produ.pronom:

            vnomabr = "".
            
            if avail produ 
            then vnomabr = produ.pronom + " " + 
                           produ.corcod. 
            else vnomabr = " ".
            
            v-perc-imp = 0. v-perdia-imp = 0.
            
            v-perc-imp   = (if ttaux-produ.platot > 0
                           then ttaux-produ.platot * 100 / v-totger
                           else 0).
            v-perdia-imp = (if ttaux-produ.pladia > 0
                           then ttaux-produ.pladia * 100 / v-totdia
                           else 0).

            disp
                ttaux-produ.procod  column-label "Cod" 
                vnomabr  format "x(50)" column-label "Produto"
                ttaux-produ.qtd     format "->>>>>>9" column-label "Qtd"
                ttaux-produ.pladia  format "->>>,>>9.99"  column-label "V.Dia"
                v-perdia-imp       column-label "% Dia"  format "->>9.99" 
                ttaux-produ.platot  format "->>>,>>9.99"  column-label "V.Acum" 
                v-perc-imp         format "->>9.99" column-label "% Acum"
                with frame f-produ-imp-aux centered down width 150.
                           
            
        end.    
    end.

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.    
    
end procedure.

