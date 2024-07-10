{admcab.i}

def var recimp as recid.
def var fila as char.
def var varquivo as char.
def var vsemipi like plani.platot.
def var vpreco like plani.platot.
def input parameter par-rec as recid.

def buffer bforne for forne.
def buffer cprodu  for produ.
def buffer sclase for clase.
def var vestilo  as char format "x(30)".
def var vestacao as char format "x(15)".

def var i as int.
def var a as i.

def var vqtdtot         as int label "Qtd.Tot.".
def var vvlmerc         as dec label "Vl.Merc." format ">>>,>>9.99".
def var vvlliq          as dec label "Vl.Liq."  format ">>>,>>9.99".
def var vendereco       as char format "x(50)".
def var recin           as recid.
def var vrec2           as recid.
def var vpednum         like pedid.pednum initial 0.
def var vpedtot         like pedid.pedtot.
def var vtot            like pedid.pedtot.
def var vpar            like titulo.titpar.
def var vufecod         like unfed.ufecod.
def var wtot            as i format ">>>9".
def var wtotsom         like plani.platot.
def var c-clinom        like forne.fornom.
def var c-tranom        like forne.fornom format "x(35)".
def var c-frete         as char format "x(03)".
def buffer xpedid       for pedid.
def buffer xliped       for liped.
def var vtotdis         like liped.lipqtd label "Qtd.Dis.".
def temp-table wfpreco
    field itecod    like produ.itecod
    field lippreco  like liped.lippreco format ">>>9.99".

assign vqtdtot = 0
       vvlmerc = 0
       vvlliq  = 0.

find pedid where recid(pedid) = par-rec no-lock.

    if opsys = "unix" 
    then do: 
        varquivo = "/admcom/relat/lpedid" + string(time) + ".txt".
        sretorno = varquivo.

        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.    
    end.
    else assign fila = ""
                varquivo = "l:\relat\lped" + string(time).


if pedid.etbcod = 22
then do:
    {mdad.i
        &Saida     = "value(varquivo)" 
        &Page-Size = "64"
        &Cond-Var  = "143"
        &Page-Line = "66"
        &Nom-Rel   = ""LPEDID""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &tit-rel   = """TRANSFERENCIA FABRICA - NRO. "" +
                        STRING(pedid.pednum) + ""  "" +
                        string(pedid.peddat,""99/99/9999"")"
        &Width     = "143"
        &Form      = "frame f-cab22"}.
end.          
else do:

    {mdad.i
        &Saida     = "value(varquivo)"  
        &Page-Size = "64"
        &Cond-Var  = "147"
        &Page-Line = "66"
        &Nom-Rel   = ""LPEDID""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &tit-rel   = """PEDIDO DE COMPRA - NRO. "" +
                        STRING(pedid.pednum) + ""  "" +
                        string(pedid.peddat,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cabcab"}
end.      

find forne where forne.forcod = pedid.clfcod no-lock. 
c-clinom = forne.fornom.  
find frete where frete.frecod = pedid.frecod no-lock no-error.
c-tranom = if avail frete 
then frete.frenom 
else "". 
find crepl of pedid no-lock.
find modal of pedid no-lock. 
find func where func.etbcod = 990 and 
                func.funcod = pedid.vencod no-lock no-error.
vendereco = trim(forne.forrua + ", " +
            string(forne.fornum)  + " " + forne.forcomp).
display pedid.clfcod       label "Fornecedor   "  space(5)
        c-clinom           no-label format "x(39)"
        forne.forfon 
        forne.forfax    skip 
        pedid.frecod    label "Transportador" 
        c-tranom        no-label skip 
        pedid.condes    label "Frete" 
        pedid.peddti format "99/99/9999" label "Entrega     " space(5)    "a"
        pedid.peddtf  format "99/99/9999"  no-label skip
        crepl.crenom       label "Cond. Pagto  " space(5)
        pedid.acrfin       label "Acresc. Finan. " colon 60 
        pedid.nfdes        label "Desc.Nota"  colon 85 
        pedid.dupdes       label "Desc.Duplic"  colon 110  
        pedid.ipides       label "IPI" format ">9.99 %" skip(1) 
        skip fill("-",147) format "x(143)" skip 
            with side-labels with frame frel1 width 147.


    find estab where estab.etbcod = pedid.etbcod no-lock.  
    disp space(5) "LOJA:" space(2)  
    estab.etbnom no-label space(13)  
    /*"ENDERECO DE COBRANCA"  colon 90  
    estab.endereco no-label colon 13  
    "Av. Protasio Alves, 34 POA/RS" colon 90 skip  
    estab.munic no-label colon 13  
    estab.ufecod no-label colon 40  
    "Fone/Fax (051)331-6622" colon 90 skip  
    estab.etbcgc label "CGC" colon 16  
    estab.etbinsc label "Insc."*/ 
        with frame f-end no-box side-label width 130.


 put skip fill("-",143) format "x(143)" skip(1).

 if pedid.etbcod <> 22
 then put
      "OBS:" at 22 skip.
put     "1)Favor informar OC no e-mail de solicitacao de agenda;" at 22 skip.
put     "2)Informar OC na Nota Fiscal" at 22 skip.
put     "3)Quantidade, avarias e precos divergentes serao devolvidos sem aviso previo."  at 22 skip(1).

      put skip fill("-",143) format "x(143)" skip.


      for each liped where liped.pedtdc = pedid.pedtdc and
                           liped.etbcod = pedid.etbcod and
                           liped.pednum = pedid.pednum no-lock.
                    
        vsemipi = 0.
        vpreco = 0. 
        vsemipi = (liped.lippreco - (liped.lippreco * (pedid.nfdes / 100))).
                    
        vpreco = (liped.lippreco - (liped.lippreco * (pedid.nfdes / 100))).

        vpreco = (vpreco + (vpreco * (pedid.ipides / 100))).
                    
        find produ of liped no-lock.

        /* antonio - Sol 26337 */
        find first sclase 
              where sclase.clacod = produ.clacod no-lock no-error.
        find first clase 
             where clase.clacod = sclase.clasup no-lock no-error.
        vestacao = "".
        find estac where
               estac.etccod = produ.etccod no-lock no-error.
        if avail estac
        then vestacao = estac.etcnom.
        else vestacao = "".
        vestilo = "".
        find first procaract 
             where procaract.procod = produ.procod no-lock no-error.
        if avail procaract
        then do:
            find first subcaract where
                /* subcaract.carcod = 2 and */
                subcaract.subcar = procaract.subcod no-lock no-error.
            if avail subcaract
            then vestilo = subcaract.subdes.            
        end.
        /***/

        find estoq where estoq.procod = produ.procod and
                         estoq.etbcod = liped.etbcod no-lock no-error.
        
        disp produ.procod
             produ.pronom  format "x(40)"
             liped.lipqtd(total) column-label "Qtd" format ">>>>9"
             vsemipi(total) column-label "Valor!Sem IPI" format ">,>>>,>>9.99"
             (liped.lipqtd * vsemipi)(total) column-label "Total!Sem IPI" 
             format ">,>>>,>>9.99"
             (liped.lipqtd *  (vpreco - vsemipi) )(total) 
                                column-label "Valor!IPI" format ">,>>>,>>9.99"
                         
             vpreco(total) column-label "Valor!Com IPI"
             (vpreco * liped.lipqtd)(total) 
             column-label "Total!Com IPI" format ">,>>>,>>9.99"
             (liped.lipqtd * (vpreco + (vpreco * (pedid.acrfin / 100))))(total) 
             column-label "Total" format ">,>>>,>>9.99"
             /* antonio sol 26337 */
             clase.clacod       at 1 column-label "Clase" when avail clase
             vestacao           column-label "Estacao"
             subcaract.carcod   column-label "Cod.Carac." when avail subcaract
             vestilo            column-label "Sub-Carac."              
             /**/
             with frame f-rom1 width 153 down.

      end.
      put skip fill("-",153) format "x(153)" skip(1).


      display "OBSERVACOES: "  skip 
              pedid.pedobs[1] format "x(78)" skip 
              pedid.pedobs[2] format "x(78)" skip 
              pedid.pedobs[3] format "x(78)" skip 
              pedid.pedobs[4] format "x(78)" skip 
              pedid.pedobs[5] format "x(78)" skip
                        with frame fobsrel no-box width 143 no-label.

      put skip fill("-",143) format "x(143)" at 1 skip.

      display skip (02)
              "___________________________________"    colon 22
              "___________________________________"    colon 90 skip
              forne.fornom  no-label    colon 25
              "COMPRADOR"             colon 95 skip
              "REPRESENTANTE"          colon 25              skip(1)
                    with side-labels with frame frel2 width 143.
output close.

 
     
     if opsys = "unix"
     then do:
        sparam = SESSION:PARAMETER.
        if num-entries(sparam,";") > 1
        then sparam = entry(2,sparam,";").
 
        if sparam = "AniTA"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            os-command silent lpr value(fila + " " + varquivo).
        end.
     end.
     else do:
        
        {mrod.i}
        /* os-command silent type value(varquivo) > prn. */

     end.
     
