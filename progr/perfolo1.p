/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : convgenw.p
*******************************************************************************/

{admcab.i }

{anset.i}.

def var vi as int.
def var aux-i as int.
def var aux-etbcod like estab.etbcod.

def var varqsai as char.

def buffer bbestab for estab.

def var vcont as int.
def var vdiastot as int.
def new shared var vdiasatu as int.
def buffer bestab for estab.
def var vplatot like plani.platot.
 def var vacfprod like plani.acfprod.
 
def var vdia as int.
def var vmes as int format "99".
def var vano as int format "9999".
def var vmesfim as int.
def var vanofim as int.
def var vdiafim as int.

def var v-totcom    as dec.
def var v-ttmet     like metven.metval. /* vlmeta. */
DEF VAR v-totperc   AS DEC.
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
def new shared      var vdti        as date format "99/99/9999" no-undo.
def new shared      var vdtf        as date format "99/99/9999" no-undo.
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
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field etbcod    like plani.etbcod
    field cusmed    like estoq.estcusto /*produ.procmed*/
    field margem    as dec format "->>9.99"
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm  as dec
    index loja     is unique etbcod 
    index platot  is primary platot desc.

def new shared temp-table ttvendedor
    field etbcod    like plani.etbcod
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like estoq.estcusto /*produ.procmed*/
    field margem    as dec format "->>9.99"
    field numseq    as int
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm    as dec

    index loja     is unique etbcod asc vencod asc 
    index platot  is primary platot desc.

def new shared temp-table ttsetor 
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like estoq.estcusto /*produ.procmed*/
    field margem    as dec format "->>9.99"
    field numseq    as int
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm    as dec
    index setor     etbcod vencod setcod 
    index valor     platot desc.

    
def new shared temp-table ttgrupo
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
    field cusmed    like estoq.estcusto /*produ.procmed*/
    field margem    as dec format "->>9.99"
    field numseq    as int
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm    as dec

    index grupo     etbcod vencod setcod grupo-clacod 
    index valor     platot desc.

/******************
def new shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like movim.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field vlmeta    like metven.vlmeta
    field vlmdia    like metven.vlmeta
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
    
def new shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like movim.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def new shared temp-table ttprodu
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    index produ     procod etbcod clacod
    index valor     platot desc.
    
def new shared temp-table ttclase 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

def new shared temp-table ttsclase 
    field platot    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index sclase    etbcod clacod.
************/

form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    clase.clatipo /*setcod*/ 
    /*setor.setnom*/
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

/********
form
    ttvend.numseq   column-label "Rk" format ">>9" 
    help " F8= Imprime "
    ttvend.funcod   column-label "Cod" format ">>9"
    func.funnom    format "x(18)" 
    ttvend.qtd     column-label "Qtd" format ">>>9" 
    ttvend.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    ttvend.vlmdia  format ">>9.99" column-label "Met.Dia"
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvend.platot  format "->>,>>9.99"  column-label "Vnd.Acum" 
    ttvend.vlmeta  format ">>,>>9.99" column-label "Met.Acum"
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vend
        centered
        down 
        title v-titven.
        
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
        down 
        title v-titvenpro.
*************/
 
form

    ttloja.nome format "x(10)" column-label "Estabel." 
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttloja.cusmed  format "->>>>>9" column-label "CMV"
    ttloja.margem column-label "Marg" format "->>9.9"
    ttloja.platot  format "->>>>,>>9" column-label "Venda"
    ttloja.acfprod format ">>>>9" column-label "Out"
    ttloja.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"
    ttloja.medven   column-label "DiaM" format ">>>>>9"
    ttloja.tktmed   column-label "TktM" format ">>>9"
    ttloja.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>>9"
    with frame f-lojas
        width 80
        centered
        15 down 
        row 5
        no-box
        overlay.
        /*
        title " VENDAS POR LOJA ".
          */

 
form                    
    ttvendedor.vencod column-label "Cod"
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttvendedor.nome format "x(10)" column-label "Vendedor." 
    ttvendedor.cusmed  format "->>>>>9" column-label "CMV"
    ttvendedor.margem column-label "Marg" format "->>9.9"
    ttvendedor.platot  format "->>>>,>>9" column-label "Venda"
    ttvendedor.acfprod format ">>>>9" column-label "Fin"
    ttvendedor.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"
    ttvendedor.medven   column-label "Med.Dia" format ">>,>>9"
    ttvendedor.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>9"
    with frame f-vendedor
        width 80
        centered
        15 down 
        row 5
        no-box
        overlay.
        /*
        title " VENDAS POR LOJA ".
          */

  
/**
form
    ttloja.etbcod
    bbestab.etbnom  format "x(20)" 
    ttloja.metlj  column-label "Meta da Loja" format "->,>>>,>>9.99"
    ttloja.cusmed  format "->>>,>>9.99" column-label "CMV"
    v-perdia
    ttloja.platot  format "->>>,>>9.99" column-label "Vnd.Acum"
    v-perc 
    with frame f-lojaimp
        width 180 
        centered
        down
        no-box.**/
form
    ttloja.nome    format "x(25)" column-label "Estabelecimento" 
    ttloja.cusmed  format "->,>>>,>>9.99" column-label "CMV"
    ttloja.margem  column-label "Marg" format "->>9.9"
    ttloja.platot  format "->,>>>,>>9.99" column-label "Venda"
    ttloja.acfprod format ">>,>>9.99" column-label "Outros"
    ttloja.metlj    column-label "Meta" format ">,>>>,>>9.99" 
    v-perc column-label "%" format ">>9.9"
    ttloja.medven   column-label "DiaM" format ">>>,>>9.99"
    ttloja.tktmed   column-label "TktM" format ">,>>9.99"
    ttloja.medproj  column-label "Proj" format ">,>>>,>>9.99"
    v-percproj      column-label "%" format ">>>>9"
    with frame f-lojaimp
        width 180 
        centered
        down
        no-box.

/********
form
    ttsetor.setcod
    setor.setnom    format "x(15)" 
    ttsetor.metset    format "->>>,>>9.99" column-label "Meta Setor"
    ttsetor.qtd     format ">>>9"  column-label "Qtd"
    ttsetor.pladia  format "->,>>9.99" column-label "Vnd.Dia"
    v-perdia        format "->.99" column-label "% Dia" 
    ttsetor.platot  format "->>>,>>9.99" column-label "Vnd.Acum" 
    v-perc          format "-9.99" column-label "% Acum" 
    with frame f-setor 
        centered
        width 80
        color white/green
        down  overlay
        title v-titset.
        
form
    ttgrupo.clacod
    clase.clanom    format "x(17)" 
    ttgrupo.qtd     format ">>>9" column-label "Qtd"
    ttgrupo.pladia  format "->,>>9.99" column-label "Vnd.Dia"
    v-perdia        column-label "% Dia"    format "->>9.99"
    ttgrupo.platot  format "->,>>9.99" column-label "Vnd.Acum" 
    v-perc          column-label "% Acum" format "->>9.99" 
    with frame f-grupo
        centered
        down 
        title v-titgru.
        
form
    ttprodu.procod  column-label "Cod" 
    produ.nomabr    format "x(13)" 
    produ.tamcod    column-label "Tam" format "x(3)" 
    ttprodu.qtd     format ">>9" column-label "Qtd" 
    v-perdev  format ">9.99" column-label "% Dev"  
    ttprodu.pladia  format "->>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    ttprodu.platot  format "->>>9.99"    column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-produ
        centered
        down 
        title v-titpro.
        
form
    ttclase.clacod
    clase.clanom    format "x(18)" 
    ttclase.qtd     column-label "Qtd" format ">>>9" 
    ttclase.pladia  format ">>>,>>9.99" column-label "Vnd.Dia" 
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
    ttsclase.qtd        column-label "Qtd"   format ">>>9"    
    ttsclase.pladia  column-label "Vnd.Dia" format "->,>>9.99" 
    v-perdia         column-label "% Dia" 
    ttsclase.platot  format "->,>>9.99" column-label "Vnd.Acum"
    v-perc           column-label "% Acum" 
    with frame f-sclase
        centered
        down 
        title v-titscla.
*********/
        
form
    vetbcod  label  "Lj"
    bbestab.etbnom no-label format "x(8)" 
    vmes no-label space(0) "/" space(0) vano no-label
    
    vdti     label "De" format "99/99/9999"
    vdtf     label "A" format "99/99/9999"
/*    vhora    label "H" */
    vdiastot label "Dias Total" format "99"
    vdiasatu label "Atual" format "99"
    with frame f-etb
        centered
        1 down side-labels 
        row 3 width 80
        no-box.

def var v-opcao as char format "x(12)" extent 2 initial
    ["POR VENDEDOR","POR PRODUTOS"].
    
form
    v-opcao[1]  format "x(12)"
    v-opcao[2]  format "x(12)"
    with frame f-opcao
        centered 1 down no-labels overlay row 10 color white/green. 

{selestab.i vetbcod f-etb}

repeat:                         
    hide frame f-lojas no-pause.
    clear frame f-mat all.
    hide frame f-mat.
    /*
    for each ttvenpro : delete ttvenpro. end.
    for each ttvend : delete ttvend. end.
    for each ttprodu :  delete ttprodu. end.
    */
    for each ttloja :  delete ttloja. end.
    for each ttvendedor. delete ttvendedor. end.
    /*
    for each ttsetor : delete ttsetor. end.
    for each ttgrupo : delete ttgrupo. end.
    for each ttclase : delete ttclase. end. 
    for each ttsclase : delete ttsclase. end.
    */
   
    /**
    update  vetbcod with frame f-etb.
    ***/        
    /*
    if vetbcod = 0 
    then do :
        find first func where func.funcod = sfuncod no-lock.
        if func.admin 
        then do :
            disp "GERAL" @ bbestab.etbnom with frame f-etb.
        end.
        else do :
            bell. bell. bell.
            message "Funcionario nao Autorizado" .
            pause. clear frame f-etb all.
            next.
        end.
    end.
    else*/
    
    do :
        /***********
        find first func where func.funcod = sfuncod no-lock.
        if func.etbcod <> vetbcod and func.etbcod <> 0 
        then do :
            bell. bell. bell.
            message "Funcionario nao Autorizado".
            pause. clear frame f-etb all.
            next.
        end.
        *********/
        if vetbcod = 0
        then do:
                disp "GERAL" @ bbestab.etbnom with frame f-etb.
        end.
        else do:
            find bbestab where bbestab.etbcod = vetbcod no-lock.
            disp bbestab.etbnom with frame f-etb.
        end.
    end.    
    vmes = month(today).
    vano = year(today).

    update
        vmes vano with frame f-etb.
   
    assign vdti = date(vmes,01,vano)
           vdtf = today - 1. 
    vanofim      = vano + if vmes = 12                  
                          then 1                        
                          else 0.
    vmesfim      = if vmes = 12                         
                   then 1                               
                   else vmes + 1.                        
    vdtf         = date(vmesfim,01,vanofim) - 1.
    vdiafim      = day(vdtf).   
    if year(today) = year(vdtf) and
       month(today) = month(vdtf)
    then vdtf = today - 1.
    
    update  vdti  vdtf   with frame f-etb.
    vdia = day(vdtf).
    vdiastot = 0.
    vdiasatu = 0.
    do vcont = 1 to vdiafim. 
        /******
        if temdtextra(vetbcod, date(vmes, vcont, vano)) then
        next.
        ******/
/*
        if weekday(date(vmes,vcont,vano)) > 1 and /* Domingo */
           weekday(date(vmes,vcont,vano)) < 7     /* Sabado */       
        then do:                                                     
*/
            vDiasTot = vDiasTot + 1.                                 
            if vcont <= vdia
            then vdiasatu = vdiasatu + 1.                           
/*
         end.                                                         
*/
    end.                                                            
 
    disp vdiasatu vdiastot 
        with frame f-etb.
 
    run calcvnw2.

    hide frame f-mostr.
    for each ttloja .
        if ttloja.tktmed < 0 then ttloja.tktmed = 0.
        if ttloja.medproj < 0 then ttloja.medproj = 0.
        if ttloja.medven < 0 then ttloja.medven = 0.
    end.
    for each ttvendedor.
        if ttvendedor.tktmed < 0 then ttvendedor.tktmed = 0.
        if ttvendedor.medproj < 0 then ttvendedor.medproj = 0.
        if ttvendedor.medven < 0 then ttvendedor.medven = 0.
    end.        
           
    /*
    vhora = string(time,"hh:mm:ss").
    disp vhora with frame f-etb.
    */
    repeat :
        
        assign  an-seeid = -1 an-recid = -1 
                an-seerec = ? v-totdia = 0. v-totger = 0.
        
        {anbrowse.i
            &File   = ttloja
            &CField = ttloja.nome
            &color  = write/cyan
            &Ofield = "ttloja.platot ttloja.nome ttloja.metlj ttloja.cusmed v-~perc ttloja.margem ttloja.medven ttloja.tktmed ttloja.medproj ttloja.acfprod v-percproj "
            &Where = "ttloja.etbcod  = (if vetbcod = 0
                                        then ttloja.etbcod
                                        else vetbcod)"
            &NonCharacter = /*
            &Aftfnd = "
                assign v-perc = ttloja.platot * 100 / ttloja.metlj. 
                assign v-percproj = ttloja.medproj * 100 / ttloja.metlj. 
                
                "
            &otherkeys1 = "perfolo1.i"
            
            &AftSelect1 = "p-loja = ttloja.etbcod. 
                       leave keys-loop. "
            &LockType = "use-index platot" 
            &Form = " frame f-lojas" 
        }.

        if keyfunction(lastkey) = "END-ERROR"
        then leave.

        hide frame border  no-pause. 
        hide frame fescpos no-pause. 
        FORM 
            SPACE(3) 
            SKIP(8) 
            WITH FRAME border 
            ROW 10 column 47 
            WIDTH 19 NO-BOX OVERLAY COLOR MESSAGES. 
        view frame border. 
        pause 0. 
        display v-opcao
            with frame fescpos no-label 1 column 
                column 49 row 11 overlay. 
        choose field v-opcao with frame fescpos. 
        if v-opcao[frame-index] = "" 
        then undo. 
        hide frame fesqpos no-pause.
        hide frame border no-pause.
        clear frame f-lojas all no-pause.
        display 
                ttloja.platot 
                ttloja.nome 
                ttloja.metlj 
                ttloja.cusmed 
                v-perc 
                ttloja.margem 
                ttloja.medven 
                ttloja.tktmed
                ttloja.medproj 
                ttloja.acfprod 
                v-percproj
                with frame f-lojas.
        pause 0.
        if frame-index = 2 
        then do :
            run perfopro.p (input ttloja.etbcod,0).
        end.
        else do:
            run perfoven.p (recid(ttloja), 7).
            /*    
            assign  an-seeid = -1 an-recid = -1 
                    an-seerec = ? v-totdia = 0. v-totger = 0.

            {anbrowse.i
                &File   = ttvendedor
                &CField = ttvendedor.vencod
                &color  = write/cyan
            &Ofield = " ttvendedor.platot ttvendedor.nome ttvendedor.metlj ttve~~ndedor.cusmed 
            v-perc ttvendedor.margem ttvendedor.medven ttvendedor.medproj ttven~~dedor.acfprod v-percproj"
                &Where = "ttvendedor.etbcod  = p-loja"
                &NonCharacter = /**/
                &Aftfnd = "
                    assign v-perc = ttvendedor.platot * 100 / ttvendedor.metlj. 
                    assign v-percproj = ttvendedor.medproj * 100 / ttvendedor.m~~etlj. 
                
                "
                &AftSelect1 = "p-loja = ttvendedor.etbcod. 
                               p-vencod = ttvendedor.vencod.
                       leave keys-loop. "
                &LockType = "use-index platot" 
                &Form = " frame f-vendedor" 
            }.

            if keyfunction(lastkey) = "END-ERROR"
            then leave.
            */
            
            /*
            run ./convgen0.p.
            */
            
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

def var vmens as char.
def var vmens2 as char.

vmens  = "Sua selecao podera demorar".
vmens2 = " C U S T O M    *    *    *    *    *    *    *    *    *    *    *"
+ "   *    *".
/*"Fique FELIZ se demorar, pois suas vendas estao ELEVADAS!  ".*/



if vdtf - vdti < 5
then vmens = vmens + " 1 Minuto +/- ".
else if vdtf - vdti < 10
     then vmens = vmens + " 2 Minutos +/- ".
     else if vdtf - vdti < 20
          then vmens = vmens + " 3 Minutos +/- ".
          else vmens = vmens + " 4 Minutos +/- ".
def var vtime  as int.
vtime = time.
vmens  = trim(vmens) + fill(" ",80 - length(vmens)).
vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .


def var vdata as date format "99/99/9999".
def var vconta as int.
def var vloop as int.
v-totalzao = 0.

for each tipmov where tipmov.movtdc = 5 or tipmov.movtdc = 12 
        no-lock.
for each bbestab where
        (if vetbcod > 0 then bbestab.etbcod = vetbcod else true)
        no-lock.

    assign
        vdiastot = 0
        vdiasatu = 0.
    do vcont = 1 to vdiafim. 
        /**********************
        if temdtextra(bbestab.etbcod,  date(vmes, vcont, vano) )  
        then next.             
        ************************/                                      
        vDiasTot = vDiasTot + 1. 
        
        if vcont <= vdia
        then vdiasatu = vdiasatu + 1.                           
    
    end.                                                            

do vdata = vdti to vdtf.                /*
disp bbestab.etbcod tipmov.movtdc vdata format "99/99/9999". pause.*/
for each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = bbestab.etbcod
                 /*
                 (if vetbcod > 0
                                     then vetbcod else plani.etbcod) 
                                     */
                 and plani.pladat = vdata
     /*******    and plani.notsit = "F" *********/ no-lock.
    /*find first bbestab where bbestab.clfcod = plani.emite no-lock no-error.
    if not avail bbestab then
    find first bbestab where bbestab.etbcod = plani.etbcod 
                      no-lock.
      */      
         
        /*message plani.placod. pause.*/
        vconta = vconta + 1.
        /*
        if vconta mod 50 = 0
        then do:
        disp "Processando .."
             plani.pladat
             bbestab.etbnom
             with frame f-mostr 1 down 
                row 10 centered no-labels color white/black.
        
           */ 

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


                /*                 mensagem na tela */

 
             /*
        end.
               */    
        /****** gerando historico de lojas ***********/
        
        aux-i = 0.    
        repeat.
            aux-i = aux-i + 1.
            if aux-i > 1 and
               vetbcod <> 0
            then leave.
            if aux-i > 2
            then leave.
            if aux-i = 1
            then aux-etbcod = plani.etbcod.
            else aux-etbcod = 999.
            
            find first ttloja where ttloja.etbcod = aux-etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign 
                    ttloja.etbcod = aux-etbcod.
                    ttloja.nome   = if aux-etbcod = 999 then "GERAL"
                                    else (string(bbestab.etbcod,"zz9") 
                                            + "-" + bbestab.etbnom).
                    ttloja.metlj  = 0 /*v-total*/ .
                for each bestab where
                    if aux-etbcod = 999
                    then true
                    else bestab.etbcod = aux-etbcod
                    no-lock.
                    
                    run calcmeta (output v-total).

                    ttloja.metlj = ttloja.metlj + v-total.
                end.
            end. 
            vplatot     = plani.platot - plani.acfprod - plani.frete .
            vplatot     = plani.protot - plani.descprod +
                            plani.vlserv.
            vacfprod    = plani.acfprod + plani.frete.
            
            ttloja.qtdnota = ttloja.qtdnota + 1.
            
            ttloja.platot = ttloja.platot + (if plani.movtdc = 12
                                             /****tipmov.movtdev****/ 
                                             then - (vplatot) 
                                             else vplatot).
            ttloja.acfprod = ttloja.acfprod + (if plani.movtdc = 12
                                               /****tipmov.movtdev****/ 
                                             then - (vacfprod) 
                                             else vacfprod). 
            
            find first ttvendedor where 
                    ttvendedor.etbcod = aux-etbcod and
                    ttvendedor.vencod = plani.vencod
                no-error.
            if not avail ttvendedor
            then do:
                find func where func.funcod = plani.vencod no-lock no-error.
                create ttvendedor.
                assign 
                    ttvendedor.etbcod = aux-etbcod
                    ttvendedor.vencod = plani.vencod
                    ttvendedor.nome   = if not avail func
                                        then "VENDEDOR-" + string(plani.vencod)
                                        else (string(plani.vencod,"999") + "-" + func.funnom).
                    ttvendedor.metlj  = 0.

                for each bestab where
                    if aux-etbcod = 999
                    then true
                    else bestab.etbcod = aux-etbcod
                    no-lock.
                    
                    run calcmetavend (output v-total).

                    ttvendedor.metlj = ttvendedor.metlj + v-total.
                end.

            end. 
            ttvendedor.qtdnota = ttvendedor.qtdnota + 1.
            
            ttvendedor.platot = ttvendedor.platot + (if plani.movtdc = 12
                                                    /***tipmov.movtdev***/ 
                                             then - (vplatot) 
                                             else vplatot).
            ttvendedor.acfprod = ttvendedor.acfprod + (if plani.movtdc = 12
                                                    /***tipmov.movtdev***/ 
                                             then - (vacfprod) 
                                             else vacfprod). 
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod
                                 /****of plani****/ no-lock. 
                ttloja.qtditem = ttloja.qtditem + movim.movqtm.
                ttloja.movqtm  = ttloja.movqtm + movim.movqtm.
                ttvendedor.qtditem = ttvendedor.qtditem + movim.movqtm.
                ttvendedor.movqtm  = ttvendedor.movqtm + movim.movqtm.
                
                ttloja.cusmed = ttloja.cusmed + 
                            if plani.movtdc = 12 /******tipmov.movtdev ****/
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 

                ttvendedor.cusmed = ttvendedor.cusmed + 
                            if plani.movtdc = 12 /******tipmov.movtdev ****/
                            then -  (movim.movqtm * movim.movctm) 
                            else    (movim.movqtm * movim.movctm). 
                            
            end. 
            
            ttloja.medven = ttloja.platot / vdiasatu.
            ttvendedor.medven = ttvendedor.platot / vdiasatu.
            
            ttloja.tktmed = if ttloja.tktmed < 0
                            then 0
                            else ttloja.platot / ttloja.qtdnota.
            ttvendedor.tktmed = if ttvendedor.tktmed < 0
                                then 0 
                                else ttvendedor.platot / ttloja.qtdnota.
            
            
            ttloja.medproj = ttloja.platot +
                    (ttloja.medven * (vdiastot - vdiasatu)).
            
            ttvendedor.medproj = ttvendedor.platot +
                    (ttvendedor.medven * (vdiastot - vdiasatu)).
        

            ttloja.margem = 
                   (ttloja.platot - ttloja.cusmed) / ttloja.platot * 100.
             
            ttvendedor.margem = 
                   (ttvendedor.platot - ttvendedor.cusmed) / 
                   ttvendedor.platot * 100.
        
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
    
procedure calcmeta:    
def output parameter v-total as dec.
        v-total = 0. 
/**        for each metven where metven.etbcod = bestab.etbcod
                          and metven.dtcomp >= vdti
                          and metven.dtcomp <= vdtf
                          and metven.funcod = 0 
                          no-lock :
          
            assign
                v-total = v-total + metven.vlmeta.
        end.**/
end.


procedure calcmetavend:    

def output parameter v-total as dec.
        v-total = 0. 
/*        for each metven where metven.etbcod = bestab.etbcod
                          and metven.dtcomp >= vdti
                          and metven.dtcomp <= vdtf
                          and metven.funcod = plani.vencod 
                          no-lock :
          
            assign
                v-total = v-total + metven.vlmeta.
        end.*/

end procedure.

procedure calcmetag:    
        v-total = 0.
/*        for each metven where metven.dtcomp >= vdti
                          and metven.dtcomp <= vdtf
                          no-lock :
                      v-total = v-total + metven.vlmeta. 
        end.*/
        
end procedure.

                              
                          
    
    

                              