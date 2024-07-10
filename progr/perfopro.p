/*************************INFORMA€OES DO PROGRRAMA******************************
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

{admcab.i}.
{anset.i}.
def var vheader as char format "x(20)".
def var aux-i as int.
def var aux-etbcod like estab.etbcod.
def buffer bestab for estab.
def var vacfprod like plani.acfprod.
def var vplatot like plani.platot.
def var v-percproj  as dec.
def var v-totcom    as dec.
def var v-ttmet     like metven.vlmeta.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok         as logical.
def var vquant      like movim.movqtm.
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
def var v-totger    as dec.
def shared      var vdti        as date format "99/99/9999" no-undo.
def shared      var vdtf        as date format "99/99/9999" no-undo.
def shared      var vdiasatu    as int.
def var p-vende     like func.funcod.
def input parameter par-etbcod      like estab.etbcod.
def input parameter par-vencod      like func.funcod.
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
def var v-titpro    as char format "x(78)".
def var v-perdia    as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-perdev    as dec label "% Dev" format ">9.99".
def var vnomabr like produ.nomabr. 

def var vfapro as char extent 2  format "x(15)"
                init["  PRODUTO  "," FABRICANTE "].

def buffer sclase   for clase.
def buffer grupo    for clase.

def new shared temp-table tt------vendedor
    field etbcod    like plani.etbcod
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    index loja     is unique etbcod asc vencod asc 
    index platot  is primary platot desc.



def  temp-table tt---loja
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field etbcod    like plani.etbcod
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    index loja     is unique etbcod 
    index platot  is primary platot desc.

def shared temp-table ttsetor 
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm    as dec
    index setor     etbcod vencod setcod 
    index valor     platot desc.

/*
def temp-table ttsetor 
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    index loja     is unique etbcod asc
                             setcod asc  
    index platot  is primary platot desc.    
*/

        
def shared temp-table ttgrupo
    field grupo-clacod    like clase.clacod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm    as dec

    index grupo     etbcod vencod setcod grupo-clacod 
    index valor     platot desc.


def temp-table ttclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field grupo-clacod    like clase.clacod
    field clase-clacod    like clase.clasup    
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    field tktmed  as dec
    field qtdnota as int
    index loja     is unique etbcod asc
                             setcod asc
                             grupo-clacod asc
                             clase-clacod asc
    index platot  is primary platot desc.    

def temp-table ttsclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    field tktmed  as dec
    field qtdnota as int
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
    index platot  is primary platot desc.    

    
def temp-table tt-------vend
    field platot    like plani.platot
    field funcod    like movim.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field vlmeta    like metven.vlmeta
    field vlmdia    like metven.vlmeta
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
    
def temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like movim.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def temp-table tt--------produ
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    index produ     procod etbcod clacod
    index valor     platot desc.

def temp-table ttprodu
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field procod           like produ.procod 
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              procod       asc 
    index platot  is primary platot desc.    

def temp-table ttfabri
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field fabcod           like produ.fabcod 
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    field qtdnota as int
    field tktmed as dec
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    index platot  is primary platot desc.    
    


def temp-table tt-----fabri
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field fabcod    like fabri.fabcod
    field clacod    like plani.placod 
    index valor1     platot desc.
    
/*    
def temp-table ttclase 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

def temp-table ttsclase 
    field platot    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index sclase    etbcod clacod.
*/
form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    clase.setcod 
    setor.setnom
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttvenpro.procod
       help "F8=Imprime"
    produ.pronom    format "x(18)" 
    ttvenpro.qtd     column-label "Qtd" format ">>>9" 
    ttvenpro.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down   overlay
        title v-titvenpro.

form header "*** S E T O R E S *** "
     with frame f-setor.
form        
    ttsetor.nome format "x(10)" column-label "Estabel." 
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttsetor.cusmed  format "->>>>>9" column-label "CMV"
    ttsetor.margem column-label "Marg" format "->>9.9"
    ttsetor.platot  format "->>>>,>>9" column-label "Venda"
    ttsetor.acfprod format ">>>>9" column-label "Out"
    ttsetor.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"

    ttsetor.medven   column-label "DiaM" format ">>>>>9"
    ttsetor.tktmed   column-label "TktM" format ">>>9"
    ttsetor.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>>9"

    with frame f-setor
        width 80
        centered 
        11 down 
        row if par-vencod = 0 then 8 else 11
        no-box  no-label
        overlay.
        
        
form header "*** GRUPOS ***"
     with frame f-grupo. 
form        
    ttgrupo.nome format "x(10)" column-label "Estabel." 
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttgrupo.cusmed  format "->>>>>9" column-label "CMV"
    ttgrupo.margem column-label "Marg" format "->>9.9"
    ttgrupo.platot  format "->>>>,>>9" column-label "Venda"
    ttgrupo.acfprod format ">>>>9" column-label "Out"
    ttgrupo.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"

    ttgrupo.medven   column-label "DiaM" format ">>>>>9"
    ttgrupo.tktmed   column-label "TktM" format ">>>9"
    ttgrupo.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>>9"

 
    with frame f-grupo
        width 81
        centered 
        7 down 
        row if par-vencod = 0 then 11 else 14

        no-box no-label
        overlay.
form header "*** CLASSES ***"
     with frame f-clase. 
form        
    ttclase.nome format "x(10)" column-label "Estabel." 
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttclase.cusmed  format "->>>>>9" column-label "CMV"
    ttclase.margem column-label "Marg" format "->>9.9"
    ttclase.platot  format "->>>>,>>9" column-label "Venda"
    ttclase.acfprod format ">>>>9" column-label "Out"
    ttclase.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"

    ttclase.medven   column-label "DiaM" format ">>>>>9"
    ttclase.tktmed   column-label "TktM" format ">>>9"
    ttclase.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>>9"    
    with frame f-clase
        width 80
        centered 
        3 down 
        row if par-vencod = 0 then 14 else 17

        no-box no-label
        overlay.
form header "*** SUB-CLASSES ***"
     with frame f-sclase. 
form        
    ttsclase.nome format "x(10)" column-label "Estabel." 
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttsclase.cusmed  format "->>>>>9" column-label "CMV"
    ttsclase.margem column-label "Marg" format "->>9.9"
    ttsclase.platot  format "->>>>,>>9" column-label "Venda"
    ttsclase.acfprod format ">>>>9" column-label "Out"
    ttsclase.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"

    ttsclase.medven   column-label "DiaM" format ">>>>>9"
    ttsclase.tktmed   column-label "TktM" format ">>>9"
    ttsclase.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>>9"
    with frame f-sclase
        width 80
        centered 
        7 down 
        row if par-vencod = 0 then 17 else 18

        no-box no-label
        overlay.

form header v-titpro /*vheader*/
     with frame f-produ.
form        
    ttprodu.nome format "x(10)" column-label "Estabel." 
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttprodu.cusmed  format "->>>>>9" column-label "CMV"
    ttprodu.margem column-label "Marg" format "->>9.9"
    ttprodu.platot  format "->>>>,>>9" column-label "Venda"
    ttprodu.acfprod format ">>>>9" column-label "Fin"
    ttprodu.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"
    ttprodu.medven   column-label "Med.Dia" format ">>>>9"
    ttprodu.medproj column-label "Proj" format ">>>9"
    v-percproj column-label "%" format ">>9"
    with frame f-produ
        width 80
        centered 
        16 down 
        row 8
        no-box  no-label
        overlay.

form header v-titpro /*vheader*/
     with frame f-fabri.
form        
    ttfabri.nome format "x(16)" column-label "Estabel." 
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttfabri.cusmed  format "->>>>>9" column-label "CMV"
    ttfabri.margem column-label "Marg" format "->>9.9"
    ttfabri.platot  format "->>>>,>>9" column-label "Venda"
    ttfabri.acfprod format ">>>>9" column-label "Fin"
    ttfabri.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"
    ttfabri.medven   column-label "Med.Dia" format ">>,>>9"
    ttfabri.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>9"
    with frame f-fabri
        width 80
        centered 
        16 down 
        row 8
        no-box  no-label
        overlay.

/*        
form
    ttclase.clacod
    clase.clanom    format "x(18)" 
    ttclase.qtd     column-label "Qtd" format "->>9" 
    ttclase.pladia  format "->>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttclase.platot  format "->,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-clase
        centered
        down 
        title v-titcla.
       
form
    ttsclase.clacod
    sclase.clanom    format "x(18)" 
    ttsclase.qtd        column-label "Qtd"   format "->>9"    
    ttsclase.pladia  column-label "Vnd.Dia" format "->>>,>>9.99" 
    v-perdia         format "->>9.99" column-label "% Dia" 
    ttsclase.platot  format "->,>>9.99" column-label "Vnd.Acum"
    v-perc           format "->>9.99" column-label "% Acum" 
    with frame f-sclase
        centered
        down 
        title v-titscla.
*/
form
    par-etbcod  label  "Lj"
    estab.etbnom no-label format "x(15)" 
    vdti     label "Dt.Inic"
    vdtf     label "Dt.Fim"
    vhora    label "H"
    with frame f-etb
        centered
        1 down side-labels title "Dados Iniciais"
        color white/bronw row 4 width 80.

        find func where func.funcod = par-vencod no-lock no-error.
        if avail func
        then vheader = "*** VENDEDOR " +
                    func.funnom .
            find first ttsetor where ttsetor.etbcod = par-etbcod and
                                     ttsetor.vencod = par-vencod no-error.
            if not avail ttsetor
            then do :       
                run calcvnw2.
                /*{calcv101.i}.*/
            end.    
            clear frame f-opcao all.
            hide frame f-opcao.
            repeat :
                if par-etbcod <> 999
                then
                    find first estab where estab.etbcod = par-etbcod no-lock.
            
                assign an-seeid = -1 an-recid = -1 an-seerec = ?
                v-titset  = "SETORES DA LOJA " + 
                    if par-etbcod <> 999
                    then string(estab.etbnom) else "EMPRESA"
                v-totger = 0 v-totdia = 0.
                /*********************
                for each ttsetor where ttsetor.etbcod = par-etbcod:
                    assign  v-totdia = v-totdia + ttsetor.pladia
                            v-totger = v-totger + ttsetor.platot.
                end.    
                *********************/
                hide frame f-mostr1.
                
                {anbrowse.i &File   = ttsetor 
                            &CField = ttsetor.nome 
                            &color  = write/cyan 
                            &ofield = "ttsetor.platot ttsetor.nome ttsetor.metlj ttsetor.cusmed  v-perc ttsetor.margem ttsetor.medven ttsetor.medproj ttsetor.acfprod  v-percproj"
                            &Where = " ttsetor.etbcod = par-etbcod and
                                       ttsetor.vencod = par-vencod " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                assign v-perc = ttsetor.platot * 100 / ttsetor.metlj. 
                assign v-percproj = ttsetor.medproj * 100 / ttsetor.metlj. 
                "
                            &AftSelect1 = "p-setor = ttsetor.setcod. 
                                       clear frame f-setor all no-pause.
                                       display ttsetor.platot 
                                               ttsetor.nome 
                                               ttsetor.metlj 
                                               ttsetor.cusmed  
                                               v-perc 
                                               ttsetor.margem 
                                               ttsetor.medven 
                                               ttsetor.medproj 
                                               ttsetor.acfprod  
                                               v-percproj 
                                               with frame f-setor.
                                       leave keys-loop. "
                            &otherkeys1 = "perfopro.i"
                            &LockType = "use-index valor" 
                            &Form = " frame f-setor" 
                        }.
        
                if keyfunction(lastkey) = "END-ERROR"
                then do: 
                    hide frame f-setor no-pause. 
                    leave.
                end.                        
            
                repeat :
                    find first setor where setor.setcod = p-setor no-lock
                       no-error.
                    if not avail setor
                    then do:
                         message "Setor " p-setor "nao cadastrado"
                                    view-as alert-box.
                         return.
                         end.
                    
                    if par-etbcod <> 999
                    then
                    find first estab where estab.etbcod = par-etbcod no-lock.
            
                    assign an-seeid = -1 an-recid = -1 an-seerec = ?
                        v-titgru  = "GRUPOS DO SETOR " + 
                                string(setor.setnom)  + " DA LOJA " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom)  else "EMPRESA"
                        v-totdia = 0 v-totger = 0.        
                    pause 0.
                    {anbrowse.i &File   = ttgrupo 
                            &CField = ttgrupo.nome 
                            &color  = write/cyan 
                            &ofield = 
"ttgrupo.platot ttgrupo.nome ttgrupo.metlj ttgrupo.cusmed  v-perc ttgrupo.margem ttgrupo.medven ttgrupo.medproj ttgrupo.acfprod  v-percproj"
                            &Where = " ttgrupo.etbcod = par-etbcod and
                                       ttgrupo.setcod = p-setor" 
                            &NonCharacter = /* 
                            &Aftfnd = "
                assign v-perc = ttgrupo.platot * 100 / ttgrupo.metlj. 
                assign v-percproj = ttgrupo.medproj * 100 / ttgrupo.metlj. 
                
                "
                            &AftSelect1 = " p-grupo = ttgrupo.grupo-clacod. 
                                   clear frame f-grupo all no-pause.
                    display ttgrupo.platot 
                            ttgrupo.nome 
                            ttgrupo.metlj 
                            ttgrupo.cusmed  
                            v-perc 
                            ttgrupo.margem 
                            ttgrupo.medven 
                            ttgrupo.medproj 
                            ttgrupo.acfprod  
                            v-percproj                            
                            with frame f-grupo.
                                   leave keys-loop. "
                            &LockType = "use-index valor" 
                            &Form = " frame f-grupo" 
                        }.                    
                     
                    if keyfunction(lastkey) = "END-ERROR"
                    then do: 
                        hide frame f-grupo no-pause. 
                        leave.
                    end.
                    repeat :
                        find first grupo where grupo.clacod = p-grupo no-lock.
                        if par-etbcod <> 999
                        then
                        find first estab where estab.etbcod = par-etbcod
                                                no-lock.
        
                        assign an-seeid = -1 an-recid = -1 an-seerec = ?
                                v-titcla  = "CLASSES DO GRUPO " + 
                                    string(grupo.clanom) + " DA LOJA " + 
                                    if par-etbcod <> 999
                                    then string(estab.etbnom) else "EMPRESA"
                                v-totdia = 0 v-totger = 0.        
                        /*
                        for each ttclase where ttclase.etbcod = par-etbcod 
                                           and ttclase.clasup = p-grupo :
                            assign v-totdia = v-totdia + ttclase.pladia
                            v-totger = v-totger + ttclase.platot.
                        end.    
                        */
                        /**/
                        pause 0.
                        {anbrowse.i &File   = ttclase 
                            &CField = ttclase.nome 
                            &color  = write/cyan 
                            &ofield = 
"ttclase.platot ttclase.nome ttclase.metlj ttclase.cusmed  v-perc ttclase.margem ttclase.medven ttclase.medproj ttclase.acfprod  v-percproj"
                            &Where = "  ttclase.etbcod = par-etbcod and
                                        ttclase.setcod = p-setor   and
                                        ttclase.grupo-clacod = p-grupo" 
                            &NonCharacter = /* 
                            &Aftfnd = "
                assign v-perc = ttclase.platot * 100 / ttclase.metlj. 
                assign v-percproj = ttclase.medproj * 100 / ttclase.metlj. 
                
                "
                            &AftSelect1 = " p-clase = ttclase.clase-clacod. 
                                   clear frame f-clase all no-pause.
                    display ttclase.platot    
                            ttclase.nome  
                            ttclase.metlj 
                            ttclase.cusmed  
                            v-perc 
                            ttclase.margem 
                            ttclase.medven 
                            ttclase.medproj 
                            ttclase.acfprod  
                            v-percproj 
                            with frame f-clase.
                                   leave keys-loop. "
                            &LockType = "use-index platot" 
                            &Form = " frame f-clase" 
                        }.                    

                        /**/
                        
                        if keyfunction(lastkey) = "END-ERROR" 
                        then do:  
                            hide frame f-clase no-pause.  
                            leave. 
                        end.
                        repeat :
                            find first clase where clase.clacod = p-clase 
                                       no-lock no-error.
                            if par-etbcod <> 999
                            then
                            find first estab where estab.etbcod = par-etbcod 
                                        no-lock.
        
                            assign an-seeid = -1 an-recid = -1 an-seerec = ?
                                v-titscla  = "SUBCLASSES DA CLASSE " + 
                                string(clase.clanom) + " DA LOJA " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                               v-totdia = 0 v-totger = 0.
                            /*
                            for each ttsclase where ttsclase.etbcod = par-etbcod 
                                              and ttsclase.clasup = p-clase :
                        assign v-totdia = v-totdia + ttsclase.pladia
                                v-totger = v-totger + ttsclase.platot.
                            end.    
                            */
                            /**/
                            pause 0.
                        {anbrowse.i &File   = ttsclase 
                            &CField = ttsclase.nome 
                            &color  = write/cyan 
                            &ofield = 
"ttsclase.platot ttsclase.nome ttsclase.metlj ttsclase.cusmed  v-perc ttsclase.margem ttsclase.medven ttsclase.medproj ttsclase.acfprod  v-percproj"
                            &Where = "  ttsclase.etbcod = par-etbcod and
                                        ttsclase.setcod = p-setor   and
                                        ttsclase.grupo-clacod = p-grupo and
                                        ttsclase.clase-clacod = p-clase
                                        " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                assign v-perc = ttsclase.platot * 100 / ttsclase.metlj. 
                assign v-percproj = ttsclase.medproj * 100 / ttsclase.metlj. 
                
                "
                            &AftSelect1 = " p-sclase = ttsclase.sclase-clacod. 
                                   leave keys-loop. "
                            &LockType = "use-index platot" 
                            &Form = " frame f-sclase" 
                        }.                    

                             /***/
                            
                            if keyfunction(lastkey) = "END-ERROR"
                            then do: 
                                hide frame f-sclase no-pause. 
                                leave.
                            end.

                            disp vfapro with frame f-esc 1 down
                                 centered color with/black no-label 
                                 overlay.
                            choose field vfapro with frame f-esc.

                            if frame-index = 1
                            then do:
                            l1:
                            repeat :
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if par-etbcod <> 999
                                then
                                find first estab where 
                                           estab.etbcod = par-etbcod no-lock.
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "PRODUTOS DA SUBCLASSE " + 
                                    string(clase.clanom) + " DA LOJA " + 
                                    (if par-etbcod <> 999
                                    then string(estab.etbnom) else "EMPRESA")
                                    .
                                    assign
                                    v-totdia = 0 v-totger = 0.
                                /*
                                for each ttprodu where ttprodu.etbcod = par-etbcod
                                           and ttprodu.clacod = sclase.clacod:
                              assign v-totdia = v-totdia + ttprodu.pladia
                                    v-totger = v-totger + ttprodu.platot.
                                end.    
                                */
                                /*********
                                *******/
                                    pause 0.
                        {anbrowse.i &File   = ttprodu 
                            &CField = ttprodu.nome 
                            &color  = write/cyan 
                            &ofield = 
"ttprodu.platot ttprodu.nome ttprodu.metlj ttprodu.cusmed  v-perc ttprodu.~margem ttprodu.medven ttprodu.medproj ttprodu.acfprod  v-percproj"
                            &Where = "  ttprodu.etbcod = par-etbcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase and
                                        ttprodu.sclase-clacod = p-sclase
                                        " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                assign v-perc = ttprodu.platot * 100 / ttprodu.metlj. 
                assign v-percproj = ttprodu.medproj * 100 / ttprodu.metlj. 
                
                "
                            &LockType = "use-index platot" 
                            &Form = " frame f-produ" 
                        }.                    

                                if keyfunction(lastkey) = "END-ERROR"
                                then do:
                                    hide frame f-produ no-pause.
                                    leave l1.
                                end.
                            end.
                            end.
                            else do:
                            l2:
                            repeat :
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if par-etbcod <> 999
                                then
                                find first estab where 
                                           estab.etbcod = par-etbcod no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "FABRICANTES DA SUBCLASSE " + 
                                    string(clase.clanom) + " DA LOJA " + 
                                    if par-etbcod <> 999
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                            /*************                            
                                for each ttprodu where ttprodu.etbcod = par-etbcod
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
                            tt-fabri.platot = tt-fabri.platot + ttprodu.platot
                            tt-fabri.qtd    = tt-fabri.qtd    + ttprodu.qtd
                            tt-fabri.pladia = tt-fabri.pladia + ttprodu.pladia.
                                    assign 
                                        v-totdia = v-totdia + ttprodu.pladia
                                        v-totger = v-totger + ttprodu.platot.
                                end.    
                                          ****************/
                                     pause 0.
                        {anbrowse.i &File   = ttfabri 
                            &CField = ttfabri.nome 
                            &color  = write/cyan 
                            &ofield = 
"ttfabri.platot ttfabri.nome ttfabri.metlj ttfabri.cusmed  v-perc ttfabri.margem ttfabri.medven ttfabri.medproj ttfabri.acfprod  v-percproj"
                            &Where = "  ttfabri.etbcod = par-etbcod and
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase and
                                        ttfabri.sclase-clacod = p-sclase
                                        " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                assign v-perc = ttfabri.platot * 100 / ttfabri.metlj. 
                assign v-percproj = ttfabri.medproj * 100 / ttfabri.metlj. 
                
                "
                            &LockType = "use-index platot" 
                            &Form = " frame f-fabri" 
                        }.                    

                                if keyfunction(lastkey) = "END-ERROR"
                                then do:
                                    hide frame f-fabri no-pause.
                                    leave l2.
                                end.
                           end.

                            end.
                            hide frame f-esc no-pause.
                        end.
                    end.  
                end.        
            end. 


PROCEDURE calcvnw2.
/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : calcvnw2.i
***** Diretorio                    : movim
***** Autor                        : Andre
***** Descri‡ao Abreviada da Funcao: Include Performance de Vendas
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
def var vloop as int.
def var vmens as char.
def var vmens2 as char.

vmens  = " - PROCESSANDO - ".
vmens2 = " C U S T O M    *    *    *    *    *    *    *    *    *    *    *"
+ "   *    *".
/*"Fique FELIZ se demorar, pois suas vendas estao ELEVADAS!  ".*/


/*
if vdtf - vdti < 5
then vmens = vmens + " 1 Minuto +/- ".
else if vdtf - vdti < 10
     then vmens = vmens + " 2 Minutos +/- ".
     else if vdtf - vdti < 20
          then vmens = vmens + " 3 Minutos +/- ".
          else vmens = vmens + " 4 Minutos +/- ".
          */
def var vtime  as int.
vtime = time.
vmens  = trim(vmens) + fill(" ",80 - length(vmens)).

vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .


def var vdata as date.
def var vconta as int.

v-totalzao = 0.
for each tipmov where tipmov.movtvenda = yes 
        no-lock.
for each estab where
        (if par-etbcod <> 999 then estab.etbcod = par-etbcod else true)
        no-lock.
do vdata = vdti to vdtf.

for each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = estab.etbcod
                 /*
                 (if vetbcod > 0
                                     then vetbcod else plani.etbcod) 
                                     */
                 and plani.pladat = vdata
                 and plani.notsit = "F" no-lock.
    /*find first estab where estab.clfcod = plani.emite no-lock no-error.
    if not avail estab then
    find first estab where estab.etbcod = plani.etbcod 
                      no-lock.
      */   
         
    if par-vencod = 0 
      then.
      else if par-vencod = plani.vencod
           then.
           else next.
           
     for each movim of plani no-lock. 
                find produ where produ.procod = movim.procod no-lock .
                find sclase where sclase.clacod = produ.clacod no-lock.
                find clase where clase.clacod = sclase.clasup no-lock.
                find first grupo where grupo.clacod = clase.clasup 
                            no-lock no-error. 
                find first setor where setor.setcod = sclase.setcod no-lock .                   find fabri of produ no-lock.
        vconta = vconta + 1.

                /* MENSAGEM NA TELA */
                    vloop = vloop + 1.
                    if vloop mod 50 = 0
                    then do:
                        put screen color messages  row 15  column 1 vmens.
                        vmens = substring(vmens,2,78) +
                                substring(vmens,1,1).

                    end.
                    if vloop > 199
                    then do:
                        put screen color normal    row 16  column 1 vmens2.
                        put screen color messages  row 17  column 15
                        " Decorridos : " + string(time - vtime,"HH:MM:SS")
                               + " Minutos    - Lidos " +
                               string(vconta,"zzzzz9") + " Registros ".
                        
                        vmens2 = substring(vmens2,2,78) +
                                substring(vmens2,1,1).
                        vloop = 0.
                    end.

        
        if vconta mod 50 = 0
        then do:         
        /*
        pause 0.
        disp "Processando .."
             plani.pladat
             estab.etbnom
             with frame f-mostr 1 down overlay
                row 10 centered no-labels color white/black.
        */
        end.
                   
        /****** gerando historico de lojas ***********/
        
        aux-i = 0.    
        repeat.
            aux-i = aux-i + 1.
            if aux-i > 1 and
               par-etbcod <> 999
            then leave.
            if aux-i > 2
            then leave.
            if aux-i = 1
            then aux-etbcod = plani.etbcod.
            else aux-etbcod = 999.
            /*
            find first ttloja where ttloja.etbcod = aux-etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign 
                    ttloja.etbcod = aux-etbcod.
                    ttloja.nome   = if aux-etbcod = 999 then "GERAL"
                                    else estab.etbnom.
                    ttloja.metlj  = v-total.
                for each bestab where
                    if aux-etbcod = 999
                    then true
                    else bestab.etbcod = aux-etbcod
                    no-lock.
                    
                    run calcmeta (output v-total).

                    ttloja.metlj = ttloja.metlj + v-total.
                end.
            end. 
            */
            vplatot     = (movim.movpc * movim.movqtm)  - movim.movdes.
            vacfprod    = movim.movacf.
            /*
            ttloja.platot = ttloja.platot + (if tipmov.movtdev 
                                             then - (vplatot) 
                                             else vplatot).
            ttloja.acfprod = ttloja.acfprod + (if tipmov.movtdev 
                                             then - (vacfprod) 
                                             else vacfprod). 
            */
            /*  setor */
            find first ttsetor where 
                    ttsetor.etbcod = aux-etbcod and
                    ttsetor.vencod = par-vencod and
                    ttsetor.setcod = setor.setcod 
                no-error.
            if not avail ttsetor
            then do:
                create ttsetor.
                assign 
                    ttsetor.etbcod = aux-etbcod
                    ttsetor.vencod = par-vencod
                    ttsetor.setcod = setor.setcod
                    ttsetor.nome   = setor.setnom.
                    ttsetor.metlj  = 0.
            end. 
            
            ttsetor.platot = ttsetor.platot + (if tipmov.movtdev 
                                             then - (vplatot) 
                                             else vplatot).
            ttsetor.medven  = ttsetor.platot / vdiasatu.
            ttsetor.qtdnota = 0. 
            ttsetor.tktmed = 0.
            ttsetor.acfprod = ttsetor.acfprod + (if tipmov.movtdev 
                                             then - (vacfprod) 
                                             else vacfprod). 
                /*
                ttloja.cusmed = ttloja.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                */
                ttsetor.cusmed = ttsetor.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                            
            /*
            ttloja.margem = 
                   (ttloja.platot - ttloja.cusmed) / ttloja.platot * 100.
            */ 
            ttsetor.margem = 
                   (ttsetor.platot - ttsetor.cusmed) / 
                   ttsetor.platot * 100.                
            /*  grupo */
            find first ttgrupo where 
                    ttgrupo.etbcod = aux-etbcod and
                    ttgrupo.vencod = par-vencod and
                    ttgrupo.setcod = setor.setcod and
                    ttgrupo.grupo-clacod = grupo.clacod
                no-error.
            if not avail ttgrupo
            then do:
                create ttgrupo.
                assign 
                    ttgrupo.etbcod = aux-etbcod
                    ttgrupo.vencod = par-vencod
                    ttgrupo.setcod = setor.setcod
                    ttgrupo.grupo-clacod = grupo.clacod
                    ttgrupo.nome   = grupo.clanom
                    ttgrupo.metlj  = 0.
            end. 
            
            ttgrupo.platot = ttgrupo.platot + (if tipmov.movtdev 
                                             then - (vplatot) 
                                             else vplatot).
            ttgrupo.qtdnota = 0.
            ttgrupo.medven  = ttgrupo.platot / vdiasatu.
            ttgrupo.tktmed = 0.
            ttgrupo.acfprod = ttgrupo.acfprod + (if tipmov.movtdev 
                                             then - (vacfprod) 
                                             else vacfprod). 
                /*
                ttloja.cusmed = ttloja.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                */
                ttgrupo.cusmed = ttgrupo.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                            
            /*
            ttloja.margem = 
                   (ttloja.platot - ttloja.cusmed) / ttloja.platot * 100.
            */ 
            ttgrupo.margem = 
                   (ttgrupo.platot - ttgrupo.cusmed) / 
                   ttgrupo.platot * 100.
            /*  clase */
            find first ttclase where 
                    ttclase.etbcod       = aux-etbcod and
                    ttclase.setcod       = setor.setcod and
                    ttclase.grupo-clacod = grupo.clacod and
                    ttclase.clase-clacod = clase.clacod
                no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign 
                    ttclase.etbcod          = aux-etbcod
                    ttclase.setcod          = setor.setcod
                    ttclase.grupo-clacod    = grupo.clacod
                    ttclase.clase-clacod    = clase.clacod
                    ttclase.nome            = clase.clanom
                    ttclase.metlj           = 0.
            end. 
            
            ttclase.platot = ttclase.platot + (if tipmov.movtdev 
                                             then - (vplatot) 
                                             else vplatot).
            ttclase.qtdnota = 0.
            ttclase.medven  = ttclase.platot / vdiasatu.
            ttclase.tktmed = 0.
            ttclase.acfprod = ttclase.acfprod + (if tipmov.movtdev 
                                             then - (vacfprod) 
                                             else vacfprod). 
                /*
                ttloja.cusmed = ttloja.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                */
                ttclase.cusmed = ttclase.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                            
            /*
            ttloja.margem = 
                   (ttloja.platot - ttloja.cusmed) / ttloja.platot * 100.
            */ 
            ttclase.margem = 
                   (ttclase.platot - ttclase.cusmed) / 
                   ttclase.platot * 100.
            /*  sub-clase */
            find first ttsclase where 
                    ttsclase.etbcod        = aux-etbcod and
                    ttsclase.setcod        = setor.setcod and
                    ttsclase.grupo-clacod  = grupo.clacod and
                    ttsclase.clase-clacod  = clase.clacod and
                    ttsclase.sclase-clacod = sclase.clacod
                                    no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign 
                    ttsclase.etbcod          = aux-etbcod
                    ttsclase.setcod          = setor.setcod
                    ttsclase.grupo-clacod    = grupo.clacod
                    ttsclase.clase-clacod    = clase.clacod
                    ttsclase.sclase-clacod   = sclase.clacod
                    ttsclase.nome            = sclase.clanom
                    ttsclase.metlj           = 0.
            end. 
            ttsclase.qtdnota = 0.
            ttsclase.platot = ttsclase.platot + (if tipmov.movtdev 
                                             then - (vplatot) 
                                             else vplatot).
            ttsclase.medven  = ttsclase.platot / vdiasatu.
            ttsclase.tktmed = 0.
            ttsclase.acfprod = ttsclase.acfprod + (if tipmov.movtdev 
                                             then - (vacfprod) 
                                             else vacfprod). 
                /*
                ttloja.cusmed = ttloja.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                */
                ttsclase.cusmed = ttsclase.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                            
            /*
            ttloja.margem = 
                   (ttloja.platot - ttloja.cusmed) / ttloja.platot * 100.
            */ 
            ttsclase.margem = 
                   (ttsclase.platot - ttsclase.cusmed) / 
                   ttsclase.platot * 100.
        
            /*  produto */
            find first ttprodu where 
                    ttprodu.etbcod        = aux-etbcod and
                    ttprodu.setcod        = setor.setcod and
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
                    ttprodu.setcod          = setor.setcod
                    ttprodu.grupo-clacod    = grupo.clacod
                    ttprodu.clase-clacod    = clase.clacod
                    ttprodu.sclase-clacod   = sclase.clacod
                    ttprodu.procod          = produ.procod
                    ttprodu.nome            = produ.pronom
                    ttprodu.metlj           = 0.
            end. 
            
            ttprodu.platot = ttprodu.platot + (if tipmov.movtdev 
                                             then - (vplatot) 
                                             else vplatot).
            ttprodu.acfprod = ttprodu.acfprod + (if tipmov.movtdev 
                                             then - (vacfprod) 
                                             else vacfprod). 
                /*
                ttloja.cusmed = ttloja.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                */
                ttprodu.cusmed = ttprodu.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                            
            /*
            ttloja.margem = 
                   (ttloja.platot - ttloja.cusmed) / ttloja.platot * 100.
            */ 
            ttprodu.margem = 
                   (ttprodu.platot - ttprodu.cusmed) / 
                   ttprodu.platot * 100.
            /*  fabricante */
            find first ttfabri where 
                    ttfabri.etbcod        = aux-etbcod and
                    ttfabri.setcod        = setor.setcod and
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
                    ttfabri.setcod          = setor.setcod
                    ttfabri.grupo-clacod    = grupo.clacod
                    ttfabri.clase-clacod    = clase.clacod
                    ttfabri.sclase-clacod   = sclase.clacod
                    ttfabri.fabcod          = produ.fabcod
                    ttfabri.nome            = fabri.fabnom
                    ttfabri.metlj           = 0.
            end. 
            
            ttfabri.platot = ttfabri.platot + (if tipmov.movtdev 
                                             then - (vplatot) 
                                             else vplatot).
            ttfabri.medven  = ttfabri.platot / vdiasatu.
            ttfabri.tktmed = 0.
            ttfabri.acfprod = ttfabri.acfprod + (if tipmov.movtdev 
                                             then - (vacfprod) 
                                             else vacfprod). 
                /*
                ttloja.cusmed = ttloja.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                */
                ttfabri.cusmed = ttfabri.cusmed + 
                            if tipmov.movtdev 
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                            
            /*
            ttloja.margem = 
                   (ttloja.platot - ttloja.cusmed) / ttloja.platot * 100.
            */ 
            ttfabri.margem = 
                   (ttfabri.platot - ttfabri.cusmed) / 
                   ttfabri.platot * 100.
        
        
         
        
                     
        end.    
    end.
end.
end.
end.
end.
hide frame f-mostr no-pause.

        /* apaga mensagem na tela */
                                put screen color messages  row 17  column 15
                        " Decorridos : " + string(time - vtime,"HH:MM:SS")
                               + " Minutos    - Lidos " +
                               string(vconta,"zzzzz9") + " Registros ".

        pause 1 no-message.
        put screen row 15  column 1 fill(" ",80).
        put screen row 16  column 1 fill(" ",80).
        put screen row 17  column 1 fill(" ",80).


end procedure.

