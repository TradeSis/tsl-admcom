/* helio 14072022 - ajuste cpf */

{admcab.i}                         
def input param ptitle as char.

def var vcpf as char.
def temp-table ttrecebimento no-undo
    field situacao      like titprotesto.situacao
    field cpf           as char format "x(14)" column-label "CPF"
    field nossoNumero   like titprotesto.nossoNumero
    field qtdremessa    as   int column-label "qtd"
    field titvlcob      like titprotparc.titvlcob column-label "nominal"
    field titvljur      like titprotparc.titvljur
    field vlcobrado     like titprotesto.vlcobrado column-label "cobrado"
    field vlcustasL      like titprotesto.vlcustas column-label "custas L"
    field vlcustasC      like titprotesto.vlcustas column-label "custas C"
    field perc          as dec format ">>>9.99%"
    index x is unique primary situacao asc cpf asc nossoNumero asc.


def var vcsv as log format "Sim/Nao".
def var vcp as char init ";".

def var wdti as date format "99/99/9999".
def var wdtf as date format "99/99/9999".
wdti = today.
wdtf = today.
update 
     wdti    label "de"       colon 18  
     wdtf    label "a"       colon 35  
                    with side-labels width 80 frame f1
                    title ptitle.
update vcsv colon 18 label "gerar csv?"
    with frame f1 .


for each titprotesto where titprotesto.operacao = "IEPRO" and
                           titprotesto.ativo    = "BAIXADO" and
                           titprotesto.dtbaixa  >= wdti and
                           titprotesto.dtbaixa  <= wdtf
        no-lock.                         
        if titprotesto.situacao = "PAGO" or
           titprotesto.situacao = "PAGO CARTORIO"
        then.
        else next.
           
        find neuclien where neuclien.clicod = titprotesto.clicod no-lock no-error.
        if avail neuclien
        then do:
            vcpf = string(neuclien.cpf,">>>>>>>>>>>>>>").
        end.    
        else do:
            find clien where clien.clicod = titprotesto.clicod no-lock.
            vcpf = trim(clien.ciccgc).
        end.
            
            
        find first ttrecebimento where
            ttrecebimento.situacao    = titprotesto.situacao and
            ttrecebimento.cpf         = vcpf and
            ttrecebimento.nossonumero = titprotesto.nossonumero
            no-error.
        if not avail ttrecebimento
        then do:
            create ttrecebimento.
            ttrecebimento.situacao    = titprotesto.situacao.
            ttrecebimento.cpf         = vcpf.
            ttrecebimento.nossonumero = titprotesto.nossonumero.
            
        end.
        ttrecebimento.qtdremessa = ttrecebimento.qtdremessa + 1.
        for each titprotparc of titprotesto no-lock.
            ttrecebimento.titvlcob = ttrecebimento.titvlcob + titprotparc.titvlcob.
            ttrecebimento.titvljur = ttrecebimento.titvljur + titprotparc.titvljur.
        end.
        ttrecebimento.VlCobrado = ttrecebimento.vlcobrado + titprotesto.vlcobrado.
        if titprotesto.pagacustas = yes /* L */
        then ttrecebimento.vlcustasL  = ttrecebimento.vlcustasL  + titprotesto.vlcustas.
        else ttrecebimento.vlcustasC  = ttrecebimento.vlcustasC  + titprotesto.vlcustas.
        
end.
def var tqtdremessa like ttrecebimento.qtdremessa.
def var tVlCobrado  like ttrecebimento.vlcobrado.
def var tvlcustasL  like ttrecebimento.vlcustasL.
def var tvlcustasC  like ttrecebimento.vlcustasC.
for each ttrecebimento.
    tqtdremessa = tqtdremessa + ttrecebimento.qtd.
    tVlCobrado  = tVlCobrado  + ttrecebimento.vlcobrado.
    tvlcustasL = tvlcustasL + ttrecebimento.vlcustasL.
    tvlcustasC = tvlcustasC + ttrecebimento.vlcustasC.    
end.    
def var varquivo as char.     
if vcsv
then varquivo = "/admcom/relat/rrecebimento_" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
else varquivo = "/admcom/relat/rrecebimento_" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","") + ".txt".


if vcsv
then do:
    output to value(varquivo).
    put unformatted 
        "situacao" vcp
        "cpf" vcp
        "nosso Numero" vcp
        "qtd contratos remessa" vcp
        "valor principal" vcp 
        "valor juros" vcp
        "valor cobrado princ+juro" vcp
        "valor custas Lebes" vcp
        "valor custas Cliente" vcp
        "perc" vcp
        skip.
        for each ttrecebimento
            break by ttrecebimento.situacao.
            ttrecebimento.perc = ttrecebimento.vlcobrado / tVlCobrado * 100.

            put unformatted 
                 ttrecebimento.situacao vcp
                 trim(ttrecebimento.cpf) vcp
                 ttrecebimento.nossonumero vcp
                 ttrecebimento.qtdremessa  vcp
                 trim(string(ttrecebimento.titvlcob,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(ttrecebimento.titvljur,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(ttrecebimento.vlcobrado,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(ttrecebimento.vlcustasL,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(ttrecebimento.vlcustasC,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(ttrecebimento.perc,"->>>>>>>>>>>>>>>>9.99")) vcp
                skip.
        end.
    output close.        
end.
else do:

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = """iep_rrecebimentos"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = " caps(ptitle) + "" PERIODO DE "" +
                        STRING(WDTI) + "" A "" + STRING(WDTF)"
        &Width     = "100"
        &Form      = "frame f-cab"}
 


        for each ttrecebimento
            break by ttrecebimento.situacao.
            ttrecebimento.perc = ttrecebimento.vlcobrado / tVlCobrado * 100.
            disp 
                 ttrecebimento.situacao
                 ttrecebimento.cpf
                 ttrecebimento.nossonumero
                 ttrecebimento.qtdremessa   column-label "qtd!contratos!remessa"
                                    (total by ttrecebimento.situacao )
                 ttrecebimento.titvlcob  format ">>>>>>9.99" column-label "valor!principal"
                                            (total by ttrecebimento.situacao )
                 ttrecebimento.titvljur  format ">>>>>>9.99" column-label "valor!juros"
                                        (total by ttrecebimento.situacao )
                 ttrecebimento.vlcobrado format ">>>>>>9.99" column-label "valor!cobrado!princ+juro"
                                        (total by ttrecebimento.situacao )
                 ttrecebimento.vlcustasL format ">>>>>>9.99" column-label "valor!custas!Lebes"
                                        (total by ttrecebimento.situacao )
                 ttrecebimento.vlcustasC format ">>>>>>9.99"  column-label "valor!custas!Cliente"
                                    (total by ttrecebimento.situacao )
                 ttrecebimento.perc (total by ttrecebimento.situacao )


                 with width 200.
        end.    

    output close.
end.    
    message "gerado arquivo" varquivo.
if not vcsv
then     run visurel.p(varquivo,"").
else do on endkey undo, retry:
    pause.
end.
