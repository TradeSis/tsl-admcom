{admcab.i}

def input parameter par-rec as recid.
def var vps-valor as char.
def var vhora as char format "x(5)".

def var esqpos1 as int.
def var esqcom1         as char format "x(14)" extent 5
            initial [" 1.Produtos ",
                     "",
                     " 3.Altera ",
                     "",
                     " 5.Imprime " ].

def buffer bestab            for estab.

def buffer cancelador for func.
def buffer bpedid  for pedid.
def buffer bforne for forne.
def var vok      as log.

find pedid where recid(pedid) = par-rec no-lock.
/***
def var vpeddat like proenoc.datentrega.
vpeddat = pedid.peddat.
for each proenoc of pedid no-lock by proenoc.datentrega desc.
    vpeddat = proenoc.datentrega.
end.
***/

form
    esqcom1
    with frame f-com1 row screen-lines no-labels column 1 centered no-box.

def var vprazo   as char format "x(60)".
def var vpedhora as char format "x(5)".
def new shared frame f-pedid1.

form
         forne.forcod      colon 15 label "Fornecedor"
         forne.fornom      no-label format "x(20)"
         pedid.pednum      colon 50
         pedid.regcod    colon 15 label "Local Entrega"
         pedid.pedtot    colon 50
         bestab.etbnom   no-label
         pedid.vencod    colon 15
         repre.repnom    no-label
         repre.fone      label "Fone"
         pedid.condat    colon 15
         pedid.peddti    colon 15 label "Prazo Entrega" format "99/99/9999"
         pedid.peddtf    label "A"                         format "99/99/9999"
         pedid.crecod    colon 15 label "Prazo de Pagto" format "9999"
         crepl.crenom    no-label
         pedid.comcod    colon 15 label "Comprador"
         compr.comnom                 no-label
         pedid.frecod    label "Transport." colon 15
         pedid.fobcif
         pedid.condes       label "Frete" 
         pedid.nfdes        colon 15 label "Desc.Nota"
         pedid.dupdes       label "Desc.Duplicata"
         pedid.ipides       label "% IPI" format ">9.99 %"
         pedid.acrfin       label "Acres.Financ" colon 15
    with frame f-pedid1 width 80  side-label row 3 centered overlay no-box.

form
         forne.forcgc      colon 11
         forne.forinest    colon 50 label "I.E" format "x(17)"
         forne.forrua      colon 11 label "Endereco"
         forne.fornum
         forne.forcomp
         forne.formunic   colon 11 label "Cidade"
         forne.ufecod   label "UF"
         forne.forcep      label "Cep"
         forne.forfone   colon 11 label "Fone"
    with frame f-pedid2 width 80  side-label row 14 centered overlay
            title " Fornecedor ".

form
    pedid.pedobs[1] format "x(75)"
    pedid.pedobs[2] format "x(75)"
    pedid.pedobs[3] format "x(75)"
    with frame f-pedidobs width 80 no-labels
                                row 19 centered overlay no-box.

/***
def var vvlverba    like liped.lipvrbpubl.
def var vpctverba   as dec.
def var vvldesc    like liped.lipvrbpubl.
def var vpctdesc   as dec.
form
        pedid.tipfrete    colon 11 space(5)
        pedid.frecod       format ">>>>>>>9"
        bforne.clfnom    format "x(25)" 
        
        pedid.indprzpagto colon 13 
        vprazo colon 13 label "Prazos" 
        vpctverba label "V.Propaganda" format ">>9.99%" colon 13

        vvlverba  no-label format "zzz,zz9.99"
        vpctdesc  label "Desconto"     format ">>9.99%" colon 13
        vvldesc   no-label format "zzz,zz9.99"
        with frame f-pedid2 width 80 side-label
                                row 7 centered overlay no-box.

form
        pedid.funcod-can label "Func"
        cancelador.funape format "x(13)" no-label
        pedid.data-can
        vhora no-label
        with frame f-cancel width 28 col 53 side-label
                                row 14 overlay title " Cancelamento ".
***/

find forne where forne.forcod = pedid.clfcod no-lock.
/***
find tipped of pedid no-lock.
assign
    vheader = 
              tipped.pedtnom + "  " .

vheader =  
    fill(" ",integer(string(truncate(((80 - length(vheader)) / 2),0),"999"))) +     vheader.

    find estab where 
                  estab.etbcod  = pedid.etbped no-lock no-error .
    find func where 
                    func.funcod = pedid.funcod no-lock no-error.
***/

assign
    esqpos1 = 1.
repeat:
    run mostra-dados.
   assign
/****
      esqcom1[2] = if pedid.sitped = "A"
                   then " 2.Prev.Pagto"
                   else " 2.Nota Fiscal"
      esqcom1[2] = " 2.Opcoes "
***/
      esqcom1[3] = if pedid.pedsit = no
                   then " 3.Altera "
                   else ""

      esqcom1[4] = if pedid.pedsit = no
                   then " 4.Finaliza " 
                   else /*if pedid.sitped = "P" 
                        then " 4.Cancela "
                        else*/ "".
    pause 0.
    display esqcom1 with frame f-com1.
        choose field esqcom1 with frame f-com1.
        esqpos1 = frame-index.

    if esqcom1[esqpos1] = " 1.Produtos "
    then do:
        hide frame f-com1   no-pause.
        hide frame f-tot no-pause.
        hide frame f-cancel no-pause.
        hide frame f-pedid2 no-pause. 
        find categoria of pedid no-lock no-error.
        if false /*avail categoria and categoria.grade*/
        then run co_ocpprop.p (recid(pedid)). 
        else run co_ocppro.p (input recid(pedid), ?).
        view frame f-pedid2.
        pause 0.
        view frame f-tot.
        view frame f-cancel.
        pause 0.
    end.
/***
    if esqcom1[esqpos1] = " 2.Opcoes"
    then do:
        hide frame f-tot no-pause.
        hide frame f-cancel no-pause.
        hide frame f-pedid2 no-pause.
        run co/ocopcao.p (recid(pedid)).
        view frame f-pedid2.
        view frame f-tot.
        view frame f-cancel.
    end.
***/
/***************** 
    if esqcom1[esqpos1] = " 2.Prev.Pagto"
    then do:
        hide frame f-tot no-pause.
        hide frame f-cancel no-pause.
        hide frame f-pedid2 no-pause.
        run co/prevoc.p (input recid(pedid), output vok).
        view frame f-pedid2.
        view frame f-tot.
        view frame f-cancel.
    end.
 
    if esqcom1[esqpos1] = " 2.Nota Fiscal "
    then do.
        hide frame f-tot no-pause.
        hide frame f-pedid1 no-pause.
        hide frame f-pedid2 no-pause.
        run co/ocproenocnf.p (recid(pedid), 0).
        view frame f-pedid1.
        view frame f-pedid2.
        view frame f-tot.
    end.
**************/

    if esqcom1[esqpos1] = " 3.Altera "
    then do on error undo with frame f-pedidobs :
       find current pedid.
       update pedid.pedobs[1] 
              pedid.pedobs[2]
              pedid.pedobs[3].
       find current pedid no-lock.
    end.
/***
    if esqcom1[esqpos1] = " 4.Cancela " /* Cancelamento de OC Pendente */
    then do:
        run co/occancela.p (recid(Pedid), ? ).
    end.
***/
    if esqcom1[esqpos1] = " 4.Finaliza "
    then do:
        sresp = no.
        message " Finaliza ORDEM DE COMPRA?" update sresp.
        if sresp
        then do.
            hide frame f-com1 no-pause.
            hide frame f-pedid2 no-pause.
            hide frame f-tot no-pause.
            hide frame f-cancel no-pause.
            run co_ocefet01.p (input recid(pedid)).
            view frame f-cancel.
            view frame f-tot.    
            view frame f-pedid2.
            view frame f-com1.
        end.
        run mostra-dados.
    end.
      
    if esqcom1[esqpos1] = " 5.Imprime "
    then do.
        find categoria of pedid no-lock.
        if categoria.grade
        then run lpedidmoda.p (recid(pedid)).
        else do.
            message "Escritorio/Fornecedor" update sresp  format "E/F".
            if sresp
            then run lpedid5.p (recid(pedid)).
            else run lpedid7.p (recid(pedid)).
        end.
    end.
end.
hide frame fforne       no-pause.
hide frame ftitulo      no-pause.
hide frame f-com1       no-pause.
hide frame fborder      no-pause.
hide frame feschis      no-pause.
hide frame f-pedid1     no-pause.
hide frame f-pedid2     no-pause.
hide frame fsin         no-pause.
hide frame fhicam       no-pause.
hide frame fextra2      no-pause.
hide frame fextra       no-pause.
hide frame f-tot    no-pause.

Procedure mostra-dados.

    def var i as int.
/***
    def var vqtdpend like proenoc.qtdmerca format "zz,zz9.99".
    def var vqtdentr like proenoc.qtdmerca format "zz,zz9.99".
    def var vqtdcanc like proenoc.qtdmerca format "zz,zz9.99".
    def var vqtdtot  like proenoc.qtdmerca format "zz,zz9.99" init 0.
***/
    def var vvlrpend like liped.lippreco   format "z,zzz,zz9.99" .
    def var vvlrentr like liped.lippreco   format "z,zzz,zz9.99".
    def var vvlrcanc like liped.lippreco   format "z,zzz,zz9.99".
    def var vvlrtot  like liped.lippreco   format "z,zzz,zz9.99".
    def var vvltotal like liped.lippreco   format "z,zzz,zz9.99".

/***
    vprazo = "".
    for each prevoc of pedid no-lock.
       if vprazo <> "" then
          vprazo = vprazo + "/".
       vprazo = vprazo + string(prevoc.datvcto - vpeddat).
    end.
    if vprazo <> "" then
       vprazo = vprazo + " dias a partir de " + 
                    string(vpeddat,"99/99/9999") + " (1a Entrega)".
***/

                find forne where forne.forcod = pedid.clfcod no-lock.
                find crepl where crepl.crecod = pedid.crecod no-lock.
                find bestab where bestab.etbcod = pedid.regcod no-lock.
                find compr where compr.comcod = pedid.comcod no-lock.
                find repre where repre.repcod = pedid.vencod no-lock.
    display 
                     forne.forcod
                     forne.fornom
                     pedid.pednum
                     pedid.regcod
                     pedid.pedtot
                     bestab.etbnom
                     pedid.vencod
                     repre.repnom
                     repre.fone
                     pedid.condat format "99/99/9999"
                     pedid.peddti format "99/99/9999"
                     pedid.peddtf format "99/99/9999"
                     pedid.crecod format "9999"
                     crepl.crenom
                     pedid.comcod
                     compr.comnom
                     pedid.frecod
                     pedid.fobcif
                     pedid.condes
                     pedid.nfdes
                     pedid.dupdes
                     pedid.ipides
                     pedid.acrfin
                     with frame f-pedid1.
                                                 
    color display message
            pedid.pednum
            pedid.pedtot
          with frame f-pedid1.

    disp
                     forne.forcgc
                     forne.forinest
                     forne.forrua
                     forne.fornum
                     forne.forcomp
                     forne.formunic
                     forne.ufecod
                     forne.forcep
                     forne.forfone
        with frame f-pedid2.
    pause 0.
    display pedid.pedobs[1]
            pedid.pedobs[2]
            pedid.pedobs[3]
        with frame f-pedidobs.
/***
    display
                            pedid.tipfrete
                            pedid.indprzpagto
                            vprazo 
                            with frame f-pedid2.

    if pedid.frecod > 0 then do.
        find bforne where bforne.clfcod = pedid.frecod no-lock no-error.
        disp pedid.frecod bforne.clfnom no-label with frame f-pedid2.
    end.

    if pedid.funcod-can > 0
    then do:
        find cancelador where 
                     cancelador.funcod = pedid.funcod-can no-lock.
        display pedid.funcod-can 
            cancelador.funape
            pedid.data-can
            string(pedid.hora-can,"hh:mm") @ vhora
            with frame f-cancel.
    end.

    /*
      Saldos
    */
    assign
        vqtdpend = 0
        vqtdentr = 0
        vqtdcanc = 0
        vvlrpend = 0
        vvlrentr = 0
        vvlrcanc = 0
        vvlverba = 0
        vvldesc  = 0
        vvltotal = 0.

    for each liped of pedid no-lock.
       vvlverba = vvlverba + liped.lipvrbpubl.
       vvldesc  = vvldesc  + liped.lipdes.
       vvltotal   = vvltotal   + (liped.lippreco * liped.lipqtd).
       for each proenoc of liped where proenoc.procod <> 0 no-lock.
          assign
             vqtdtot = vqtdtot + proenoc.qtdmerca
             vvlrtot = vvlrtot + (proenoc.qtdmerca * liped.lippreco).
          if proenoc.sitproenoc = "P" then
             assign
                vqtdpend = vqtdpend + proenoc.qtdmerca
                vvlrpend = vvlrpend + (proenoc.qtdmerca * liped.lippreco).
          else 
             if proenoc.sitproenoc = "C" or
                proenoc.sitproenoc = "E" then
                assign
                   vqtdentr = vqtdentr + proenoc.qtdmercaent
                   vvlrentr = vvlrentr + (proenoc.qtdmercaent * liped.lippreco)
                   vqtdcanc = vqtdcanc + proenoc.qtdmercacanc
                   vvlrcanc = vvlrcanc + (proenoc.qtdmercacanc *
                                          liped.lippreco).
       end.
    end.               
        pause 0.
    vpctverba = if vvlverba > 0 
                then (vvlverba * 100) / (vvltotal - vvldesc)
                else 0        .
    vpctdesc = if vvldesc > 0 
                then (vvldesc * 100) / (vvltotal)
                else 0        .
    display
                            pedid.tipfrete
                            pedid.indprzpagto
                            vprazo 
                            vvlverba
                            vpctverba
                            vvldesc
                            vpctdesc
                            with frame f-pedid2.

    disp "Quantidade" colon 15 space(10) "Preco" 
          with frame f-tot row 14 overlay width 52 title " Totais ".
    pause 0.

    if vqtdpend > 0 then
       disp "Pendente " colon 1
            vqtdpend (vqtdpend / vqtdtot * 100) format "zz9.99%"  
            vvlrpend (vvlrpend / vvlrtot * 100) format "zz9.99%"
            with frame f-tot no-labels. 
    pause 0.

    if vqtdentr > 0 then
       disp "Entregue " colon 1
            vqtdentr (vqtdentr / vqtdtot * 100) format "zz9.99%"   
            vvlrentr (vvlrentr / vvlrtot * 100) format "zz9.99%"
            with frame f-tot no-labels.
    pause 0.

    if vqtdcanc > 0 then
       disp "Cancelado" colon 1
            vqtdcanc (vqtdcanc / vqtdtot * 100) format "zz9.99%"  
            vvlrcanc (vvlrcanc / vvlrtot * 100) format "zz9.99%"
            with frame f-tot no-labels. 
    pause 0.

    disp "Total    " colon 1
         vqtdtot space(9) vvlrtot
         with frame f-tot no-labels. 
    pause 0.
***/
    
end procedure.
        