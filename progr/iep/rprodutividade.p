{admcab.i}
def input param ptitle as char.

def temp-table ttprodutividade no-undo
    field ativo         like titprotesto.ativo
    field situacao      like titprotesto.situacao
    field qtdremessa    as   int
    field titvlcob      like titprotparc.titvlcob column-label "nominal"
    field titvljur      like titprotparc.titvljur
    field vlcobrado     like titprotesto.vlcobrado column-label "cobrado"
    field vlcustasL      like titprotesto.vlcustas column-label "custas L"
    field vlcustasC      like titprotesto.vlcustas column-label "custas C"
    field perc          as dec format ">>>9.99%"
    index x is unique primary ativo asc situacao asc.

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

for each titprotremessa
    where   titprotremessa.operaCao = "IEPRO" and
            titprotremessa.dtinc >= wdti and titprotremessa.dtinc <= wdtf
    no-lock.
    for each titprotesto of titprotremessa no-lock.
        find first ttprodutividade where
            ttprodutividade.ativo       = titprotesto.ativo and
            ttprodutividade.situacao    = titprotesto.situacao 
            no-error.
        if not avail ttprodutividade
        then do:
            create ttprodutividade.
            ttprodutividade.ativo       = titprotesto.ativo.
            ttprodutividade.situacao    = titprotesto.situacao.
        end.
        ttprodutividade.qtdremessa = ttprodutividade.qtdremessa + 1.
        for each titprotparc of titprotesto no-lock.
            ttprodutividade.titvlcob = ttprodutividade.titvlcob + titprotparc.titvlcob.
            ttprodutividade.titvljur = ttprodutividade.titvljur + titprotparc.titvljur.
        end.
        ttprodutividade.VlCobrado = ttprodutividade.vlcobrado + titprotesto.vlcobrado.
        if titprotesto.pagacustas = yes /* L */
        then ttprodutividade.vlcustasL  = ttprodutividade.vlcustasL  + titprotesto.vlcustas.
        else ttprodutividade.vlcustasC  = ttprodutividade.vlcustasC  + titprotesto.vlcustas.
        
    end.
end.
def var tqtdremessa like ttprodutividade.qtdremessa.
def var tVlCobrado  like ttprodutividade.vlcobrado.
def var tvlcustasL  like ttprodutividade.vlcustasL.
def var tvlcustasC  like ttprodutividade.vlcustasC.
for each ttprodutividade.
    tqtdremessa = tqtdremessa + ttprodutividade.qtd.
    tVlCobrado  = tVlCobrado  + ttprodutividade.vlcobrado.
    tvlcustasL = tvlcustasL + ttprodutividade.vlcustasL.
    tvlcustasC = tvlcustasC + ttprodutividade.vlcustasC.    
end.    
def var varquivo as char.     
if vcsv 
then varquivo = "/admcom/relat/rprodutividade_" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
else varquivo = "/admcom/relat/rprodutividade_" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","") + ".txt".


if vcsv
then do:
    output to value(varquivo).
    put unformatted 
        "status" vcp
        "situacao" vcp
        "qtd contratos remessa" vcp
        "valor principal" vcp 
        "valor juros" vcp
        "valor cobrado princ+juro" vcp
        "valor custas Lebes" vcp
        "valor custas Cliente" vcp
        "perc" vcp
        skip.
        
        for each ttprodutividade
            break by ttprodutividade.ativo by ttprodutividade.situacao.
            ttprodutividade.perc = ttprodutividade.vlcobrado / tVlCobrado * 100.
            put unformatted
                ttprodutividade.ativo vcp 
                ttprodutividade.situacao vcp 
                ttprodutividade.qtdremessa vcp  
                trim(string(ttprodutividade.titvlcob,"->>>>>>>>>>>>>>>>9.99")) vcp
                trim(string(ttprodutividade.titvljur,"->>>>>>>>>>>>>>>>9.99")) vcp
                trim(string(ttprodutividade.vlcobrado,"->>>>>>>>>>>>>>>>9.99")) vcp
                trim(string(ttprodutividade.vlcustasL,"->>>>>>>>>>>>>>>>9.99")) vcp
                trim(string(ttprodutividade.vlcustasC,"->>>>>>>>>>>>>>>>9.99")) vcp
                trim(string(ttprodutividade.perc,"->>>>>>>>>>>>>>>>9.99")) vcp
                skip.
        end.
    output close.        
end.
else do:
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "0"
        &Nom-Rel   = """iep_rprodutividade"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = " caps(ptitle) + "" PERIODO DE "" +
                        STRING(WDTI) + "" A "" + STRING(WDTF)"
        &Width     = "120"
        &Form      = "frame f-cab"}
 


        for each ttprodutividade
            break by ttprodutividade.ativo by ttprodutividade.situacao.
            ttprodutividade.perc = ttprodutividade.vlcobrado / tVlCobrado * 100.
            disp ttprodutividade.ativo
                 ttprodutividade.situacao
                 ttprodutividade.qtdremessa column-label "qtd!contratos!remessa"

                        (total by ttprodutividade.ativo)
                 ttprodutividade.titvlcob format ">>>>>>9.99" column-label "valor!principal"
                        (total by ttprodutividade.ativo)
                 
                 ttprodutividade.titvljur format ">>>>>>9.99" column-label "valor!juros"
                            (total by ttprodutividade.ativo)
                 
                 ttprodutividade.vlcobrado format ">>>>>>9.99" column-label "valor!cobrado!princ+juro"

                        (total by ttprodutividade.ativo)
                 ttprodutividade.vlcustasL format ">>>>>>9.99" column-label "valor!custas!Lebes"
                    (total by ttprodutividade.ativo)
                 ttprodutividade.vlcustasC format ">>>>>>9.99"  column-label "valor!custas!Cliente"

                    (total by ttprodutividade.ativo)
                 ttprodutividade.perc
                 with width 120.
        end.    



    output close.
end. 
   
    message "gerado arquivo" varquivo.
if not vcsv
then  run visurel.p(varquivo,"").
else do on endkey undo.
    pause.
    end.


