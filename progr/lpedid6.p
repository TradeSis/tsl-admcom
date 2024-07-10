
{admcab.i}

def input parameter par-rec as recid.

def buffer bforne for forne.
def buffer cprodu  for produ.
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


/*
varqsai = "../relat/lpedid" + string(pedid.pednum).
*/

                {mdadmcab.i
                    &Saida     = "printer"  /* value(varqsai)" */
                    &Page-Size = "64"
                    &Cond-Var  = "143"
                    &Page-Line = "66"
                    &Nom-Rel   = ""LPEDID6""
                    &Nom-Sis   = """SISTEMA COMERCIAL"""
                    &tit-rel   = """TRANSFERENCIA DA FABRICA - NRO. "" +
                                    STRING(pedid.pednum) + ""  "" +
                                    string(pedid.peddat,""99/99/9999"")"
                    &Width     = "143"
                    &Form      = "frame f-cabcab"}

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
                display
                    pedid.clfcod       label "Fornecedor   "  space(5)
                    c-clinom           no-label format "x(39)"
                    forne.forfon
                    forne.forfax skip
                    pedid.frecod    label "Transportador"
                    c-tranom           no-label skip
                    pedid.peddti format "99/99/9999"
                        label "Entrega     " space(5)    "a"
                    pedid.peddtf  format "99/99/9999"  no-label skip
                    crepl.crenom       label "Cond. Pagto  " space(5)
                    pedid.acrfin       label "Acresc. Finan. " colon 60
                    pedid.nfdes        label "Desc.Nota"  colon 85
                    pedid.dupdes       label "Desc.Duplic"  colon 110 skip(1)
                    skip fill("-",143) format "x(143)" skip
                        with side-labels with frame frel1 width 145.


                 find estab where estab.etbcod = pedid.etbcod.

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
 put
 "OBS:" at 22 skip.
put     "1)Favor informar OC no e-mail de solicitacao de agenda;" at 22 skip.
put     "2)Informar OC na Nota Fiscal" at 22 skip.
put     "3)Quantidade, avarias e precos divergentes serao devolvidos sem aviso previo."  at 22 skip(1).

                put skip fill("-",143) format "x(143)" skip.


                for each liped where liped.pedtdc = pedid.pedtdc and
                                     liped.etbcod = pedid.etbcod and
                                     liped.pednum = pedid.pednum no-lock.
                    find produ of liped no-lock.
                    find estoq where estoq.procod = produ.procod and
                                     estoq.etbcod = liped.etbcod
                                no-lock no-error.
                    disp space(20)
                         produ.procod
                         produ.pronom space(5)
                         liped.lipqtd
                         liped.lippreco column-label "Valor"
                         (liped.lippreco * liped.lipqtd)
                                        column-label "Valor Total"
                         estoq.estvenda when avail estoq column-label "Pr.Venda"
                         with frame f-rom width 143 down.
                    find estoq where estoq.procod = liped.procod and
                                     estoq.etbcod = liped.etbcod no-lock
                                                                      no-error.
                    vvlliq   =  vvlliq + (liped.lipqtd * liped.lippreco).
                    vvlmerc  = vvlmerc + (liped.lipqtd * liped.lippreco).
                    vqtdtot  = vqtdtot + liped.lipqtd.
                end.

                put skip(1) fill("-",143) format "x(143)" at 1 skip.

                disp "TOTAIS: " vqtdtot colon 35
                     vvlmerc colon 75
                     vvlliq  colon 115
                            with frame f-tot side-label no-box width 145.

                put skip fill("-",143) format "x(143)" at 1 skip.

                display "OBSERVACOES: "  skip
                        pedid.pedobs[1] skip
                        pedid.pedobs[2] skip
                        pedid.pedobs[3] skip
                        pedid.pedobs[4] skip
                        pedid.pedobs[5] skip
                        with frame fobsrel no-box width 143 no-label.

                put skip fill("-",143) format "x(143)" at 1 skip.

                /*find empre where empre.empcod = setbcod no-lock.*/
                display
                    skip (02)
                    "___________________________________"    colon 22
                    "___________________________________"    colon 90 skip
                    forne.fornom  no-label    colon 25
                    "COMPRADOR"             colon 95 skip
                    "REPRESENTANTE"          colon 25              skip(1)
                    with side-labels with frame frel2 width 143.
                output close.
                /*
                unix silent value("lp -s -dserial " + varqsai) .
                */
