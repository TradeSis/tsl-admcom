{admcab.i}

def input  parameter par-rec as recid.
def input  parameter par-etiqueta as log.
def output parameter par-arqsai as char.

def var vsemipi like plani.platot.
def var vpreco  like plani.platot.

def buffer sclase for clase.

def var vestilo  as char format "x(30)".
def var vestacao as char format "x(15)".
def var vqtdtot         as int label "Qtd.Tot.".
def var vvlmerc         as dec label "Vl.Merc." format ">>>,>>9.99".
def var vvlliq          as dec label "Vl.Liq."  format ">>>,>>9.99".
def var vendereco       as char format "x(50)".
def var vpedtot         like pedid.pedtot.
def var vtot            like pedid.pedtot.
def var wtot            as i format ">>>9".
def var c-tranom        like forne.fornom format "x(35)".
def var c-frete         as char format "x(03)".

def temp-table wfpreco
    field itecod    like produ.itecod
    field lippreco  like liped.lippreco format ">>>9.99".

assign vqtdtot = 0
       vvlmerc = 0
       vvlliq  = 0.

find pedid where recid(pedid) = par-rec no-lock.

par-arqsai = "/admcom/relat/lpedid" + string(time) + ".txt".

output to value(par-arqsai).

find forne where forne.forcod = pedid.clfcod no-lock. 
find frete where frete.frecod = pedid.frecod no-lock no-error.
find crepl of pedid no-lock.

c-tranom  = if avail frete  then frete.frenom  else "". 
vendereco = trim(forne.forrua + ", " +
            string(forne.fornum) + " " + forne.forcomp).

put unformatted
    "DREBES & CIA.LTDA" at 30
    today at 65 format "99/99/9999"
    " " string(time, "hh:mm:ss")
    "<b>PEDIDO DE COMPRA " at 30 pedid.pednum "</b>"
    "Emissao: " at 65 pedid.peddat format "99/99/9999"
    skip(1).

display
    pedid.clfcod    colon 14 label "Fornecedor"
    forne.fornom    no-label
    forne.forfon    colon 14
    forne.forfax    label "Fax"
    pedid.frecod    colon 14 label "Transportador" 
    c-tranom        no-label
    pedid.condes    label "Frete" 
        pedid.peddti    colon 14 format "99/99/9999" label "Entrega"
        "a" pedid.peddtf    format "99/99/9999"  no-label
        crepl.crenom    colon 14 label "Cond.Pagto"
        pedid.acrfin    label "Acresc.Finan." colon 14
        pedid.nfdes     label "Desc.Nota"  /*colon 80 */
        pedid.dupdes    label "Desc.Duplic"  /*colon 100  */
        pedid.ipides    label "IPI" format ">9.99 %"
        skip(1) 
        with side-labels with frame frel1 width 147.

    find estab where estab.etbcod = pedid.etbcod no-lock.  
    disp space(5) "LOJA: " estab.etbnom no-label skip(1)
    with frame f-end no-box side-label width 130.

if pedid.etbcod <> 22
then put
    "OBS:"  skip
    "1)Favor informar OC no e-mail de solicitacao de agenda;"  skip
    "2)Informar OC na Nota Fiscal"  skip
    "3)Quantidade, avarias e precos divergentes serao devolvidos sem aviso previo."  skip(1).

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
        find estac where estac.etccod = produ.etccod no-lock no-error.
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
         produ.pronom no-label
         clase.clacod       at 1 label "Clase" when avail clase
         vestacao           label "Estacao"
         subcaract.carcod   label "Cod.Carac." when avail subcaract
         vestilo            label "Sub-Carac."
         skip
         liped.lipqtd  label "Qtd" format ">>>>9"
         (liped.lipqtd * (vpreco + (vpreco * (pedid.acrfin / 100)))) 
             label "Total" format ">>>,>>9.99"
         skip
         vsemipi label "Valor Sem IPI" format ">,>>>,>>9.99"
         (liped.lipqtd * vsemipi) label "Total Sem IPI"  format ">>>,>>9.99"
         (liped.lipqtd *  (vpreco - vsemipi) )
                                label "Valor IPI" format ">>>,>>9.99"
                         
         vpreco label "Valor Com IPI"
         (vpreco * liped.lipqtd) label "Total Com IPI" format ">>>,>>9.99"

         with frame f-rom1 width 100 down side-label no-box.

end.

put skip fill("_",90) format "x(90)" skip(1)
    "OBSERVACOES:" skip.

display
              pedid.pedobs[1] format "x(78)" skip 
              pedid.pedobs[2] format "x(78)" skip 
              pedid.pedobs[3] format "x(78)" skip 
              pedid.pedobs[4] format "x(78)" skip 
              pedid.pedobs[5] format "x(78)" skip
              with frame fobsrel no-box width 96 no-label.

if par-etiqueta
then put "Enviado arquivo de etiquetas" skip.

    put skip fill("_",90) format "x(90)" skip.

    display skip(2)
        "___________________________________" colon 5
        "___________________________________" colon 45
        forne.fornom no-label  colon 5
        "COMPRADOR"            colon 45
        "REPRESENTANTE"        colon 5
        with side-labels no-box with frame frel2 width 96.
output close.

