{admcab.i}

def temp-table tt-bonus
    field etbcod like estab.etbcod
    field clifor like clien.clicod
    field numero like plani.numero
    field pladat like plani.pladat
    field platot like plani.platot
    field descprod like plani.descprod
    field vlserv like plani.vlserv
    field biss like plani.biss
    field acrescimo as dec
    field vcheqp as dec
    field vblackfd as dec
    index i1 etbcod pladat
    .
    
def var vblackfriday  as dec.
def var vi as int.
def var vetbcod1 like estab.etbcod.
def var vetbcod2 like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vqcheqp as int.
def var vvcheqp as dec.
def var vbonus as dec.

update vetbcod1 label "Filial de"
       vetbcod2 label "Ate"          skip
       vdti label "Periodo de"
       vdtf label "Ate"
       with frame f1 side-label width 80.

def var vindex as int.
def var vesc as char extent 2 format "x(15)"
    init["ANALITICO","SINTETICO"].
disp vesc with frame f-esc 1 down centered side-label no-label.
choose field vesc with frame f-esc.
vindex = frame-index.

format "Aguarde processamento... "
    with frame f-disp width 80 color message no-box.

for each estab where estab.etbcod >= vetbcod1 and
                     estab.etbcod <= vetbcod2 no-lock:
    disp estab.etbcod with frame f-disp no-label.
    pause 0.
    for each plani use-index pladat where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf no-lock:
        disp plani.numero format ">>>>>>>>9"
                         plani.pladat with frame f-disp.
        vqcheqp = 0.
        vvcheqp = 0.
        vblackfriday = 0.
        vbonus = 0.
        if acha("BLACK-FRIDAY",plani.notobs[1]) <> ?
        then do:
            vblackfriday = dec(entry(2,(acha("BLACK-FRIDAY",plani.notobs[1])),
                ";")) / 2.
        end.
        if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
        then do:
            vqcheqp = int(acha("QTDCHQUTILIZADO",plani.notobs[3])).
            do vi = 1 to vqcheqp:
                vvcheqp = vvcheqp +
                dec(acha("VALCHQPRESENTEUTILIZACAO" +
                                string(vi),plani.notobs[3])).
            end.
            if vvcheqp = ? then vvcheqp = 0.
        end.    
        if plani.descprod > vblackfriday
        then vbonus = plani.descprod - vblackfriday.
        else if plani.descprod = vblackfriday
            then vbonus = 0.
            else vbonus = plani.descprod.

        if acha("BONUSCRM",plani.notobs[1]) <> ?
        then vbonus = dec(acha("BONUSCRM",plani.notobs[1])).
        
        if plani.vlserv > 0 or
           vvcheqp > 0 or
           vblackfriday > 0 or
           vbonus  > 0
        then do:   
            if vindex = 1
            then do:
            create tt-bonus.
            assign
                tt-bonus.etbcod = plani.etbcod
                tt-bonus.clifor = plani.desti
                tt-bonus.numero = plani.numero
                tt-bonus.pladat = plani.pladat
                tt-bonus.platot = plani.platot
                tt-bonus.descprod = vbonus
                tt-bonus.biss = plani.biss
                tt-bonus.vlserv = plani.vlserv
                tt-bonus.vcheqp = vvcheqp
                tt-bonus.vblackfd = vblackfriday
                .
            if plani.crecod = 2
            then                
                tt-bonus.acrescimo = plani.biss - (plani.platot - plani.vlserv
                    - vbonus - vblackfriday - vvcheqp)
                .
            end.
            else do:
                find first tt-bonus where
                           tt-bonus.etbcod = plani.etbcod
                           no-error.
                if not avail tt-bonus
                then do:
                    create tt-bonus.
                    tt-bonus.etbcod = plani.etbcod.
                end.
                assign
                    tt-bonus.platot = tt-bonus.platot + plani.platot
                    tt-bonus.descprod = tt-bonus.descprod + vbonus
                    tt-bonus.biss = tt-bonus.biss + plani.biss
                    tt-bonus.vlserv = tt-bonus.vlserv + plani.vlserv
                    tt-bonus.vcheqp = tt-bonus.vcheqp + vvcheqp
                    tt-bonus.vblackfd = tt-bonus.vblackfd + vblackfriday
                    .
                if plani.crecod = 2
                then                
                    tt-bonus.acrescimo = tt-bonus.acrescimo + (plani.biss - 
                        (plani.platot - plani.vlserv - vbonus - vblackfriday
                        - vvcheqp))
                    .
           
            end.
        end.
    end.
end.
def var vclinom like clien.clinom.
def var varquivo as char.
varquivo = "/admcom/relat/venddescontobonus." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA CONTABILIDADE"""
            &Tit-Rel   = """RELATORIO "" + VESC[VINDEX] +
                            "" COM DESCONTO NO PAGAMENTO OU NO CONTRATO """
            &Width     = "150"
            &Form      = "frame f-cabcab"}
disp with frame f1.
for each tt-bonus.
    find clien where clien.clicod = tt-bonus.clifor no-lock no-error.
    vclinom = "".
    if avail clien 
    then vclinom = clien.clinom.
        
    disp tt-bonus.etbcod column-label "Filial"
         tt-bonus.clifor when vindex = 1 column-label "Codigo!Cliente"
         vclinom    when vindex = 1 
         column-label "Nome!Cliente" format "x(30)"
         tt-bonus.numero when vindex = 1 column-label "Numero!venda"
            format ">>>>>>>>9"
         tt-bonus.pladat when vindex = 1 column-label "Data!Emissao"
         tt-bonus.platot(total) column-label "Total!Venda"
         tt-bonus.descprod(total) column-label "Valor!Bonus"
         tt-bonus.vcheqp(total)   column-label "Cheque!Presente"
         tt-bonus.vblackfd(total) column-label "Black!Friday"
         tt-bonus.vlserv(total)   column-label "Valor!Troca"
         tt-bonus.biss(total)     column-label "Valor!Contrato"
         tt-bonus.acrescimo(total) column-label "Acrescimo!Plano"
         with frame ff down width 170
         .
end.

output close.

run visurel.p(varquivo,"").