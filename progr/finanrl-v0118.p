{admcab.i}
def temp-table tt-contrato like contrato
field qtdpar   as int
field valpar   as dec
field vloperacao  as dec
field vltfc      as dec
field sit as char format "x"
.
def temp-table tt-titulo like titulo
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.

def var vescolha as char extent 6 format "x(15)".
vescolha[1] = "CDC-Venda".
vescolha[2] = "CDC-Novacao".
vescolha[3] = "CP0-Sac Facil".
vescolha[4] = "CP1-Emprestimo".
vescolha[5] = "CPN-Novacao".
vescolha[6] = "GERAL".


def var vindex as int.
disp vescolha with frame f-esc 1 down no-label 1 column.
choose field vescolha with frame f-esc.
vindex = frame-index.

def var vetbcod like estab.etbcod.
def var vanalitico as log format "Sim/Nao".
def var vdata as date.
def var vdti as date.
def var vdtf as date.
def temp-table tt-estab 
    field etbcod like estab.etbcod
    .

update vetbcod label "Filial" with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    create tt-estab.
    tt-estab.etbcod = estab.etbcod.
end.
else do:
    for each estab where estab.etbnom begins "DREBES-FIL" NO-LOCK:
        create tt-estab.
        tt-estab.etbcod = estab.etbcod.
    end.
end.        
update vdti at 1 label "Periodo Financeira" format "99/99/9999"
       vdtf no-label format "99/99/9999"
       with frame f1 column 20  1 down side-label width 60.

if vdti = ? or vdtf = ? or vdti > vdtf
then undo.

update vanalitico at 1 label "Analitico" with frame f1.

if vindex = 1 or vindex = 2
then do:
do vdata = vdti to vdtf:
    for each lotefin where lotefin.datexp = vdata and
        lotefin.lottip = "inc" no-lock. 
        for each tt-estab:
            for each envfinan where 
                     envfinan.lotinc = lotefin.lotnum and
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit <> "RET"
                     no-lock.
                find contrato where contrato.contnum = int(envfinan.titnum)
                    no-lock no-error.
                if not avail contrato then next.
                find first tt-contrato where 
                    tt-contrato.contnum = contrato.contnum
                               no-error.
                if not avail tt-contrato
                then do:
                    create tt-contrato.
                    buffer-copy contrato to tt-contrato.
                    tt-contrato.vltotal = tt-contrato.vltotal -                                             tt-contrato.vlentra.
                    if envfinan.envsit = "CAN"
                    then tt-contrato.sit = "C".
                    run cal-tfc.
                    /*tt-contrato.vloperacao = tt-contrato.vloperacao -
                        (tt-contrato.vlentra + tt-contrato.vlseguro).
                        */
                end.
                find titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = envfinan.titpar
                      no-lock no-error.
                if not avail titulo /*or
                    (titulo.cobcod = 2 /*and contrato.banco <> 10*/)*/
                then delete tt-contrato.
                else do:
                    if  (vindex = 1 and titulo.tpcontrato = "") or
                        (vindex = 2 and titulo.tpcontrato = "L") or
                        (vindex = 2 and titulo.tpcontrato = "N")
                    then do:                    
                        find first tt-titulo of titulo no-error.
                        if not avail tt-titulo
                        then do:
                            create tt-titulo.
                            buffer-copy titulo to tt-titulo.       
                            assign
                                tt-contrato.vltotal = tt-contrato.vltotal
                                    - tt-titulo.titdes
                                tt-titulo.titvlcob = tt-titulo.titvlcob 
                                    - tt-titulo.titdes
                                tt-titulo.titvlpag = tt-titulo.titvlpag 
                                    - tt-titulo.titdes
                                tt-contrato.qtdpar = tt-contrato.qtdpar + 1
                                tt-contrato.valpar = tt-contrato.valpar +
                                   tt-titulo.titvlcob - tt-titulo.titdes
                                .
                        end.
                    end.
                    else delete tt-contrato.
                end.
            end.
        end.
    end.
end. 

end.
else if vindex = 3 or vindex = 4 or vindex = 5 
then do:
do vdata = vdti to vdtf:
for each tt-estab,
    each envfinan where envfinan.etbcod = tt-estab.etbcod and
                        envfinan.datexp = vdata and
                        envfinan.envsit <> "RET" no-lock.
    find contrato where contrato.contnum = int(envfinan.titnum)
                    no-lock no-error.
    if not avail contrato then next.
    
    if contrato.banco <> 13 and vindex <> 5
    then next.
    
    if (vindex = 3 and contrato.modcod = "CP0") or
       (vindex = 4 and contrato.modcod = "CP1") or
       (vindex = 5 and contrato.modcod = "CPN") 
    then do:
    
        find first tt-contrato where 
               tt-contrato.contnum = contrato.contnum
                               no-error.
        if not avail tt-contrato
        then do:
            create tt-contrato.
            buffer-copy contrato to tt-contrato.
            tt-contrato.vltotal = tt-contrato.vltotal - tt-contrato.vlentra.
            /***
            find first titulo where
                       titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = 0
                       no-lock no-error.
            if avail titulo
            then tt-contrato.vltotal = tt-contrato.vltotal - titulo.titvlcob.
            ****/
            
            run cal-tfc.
            /*tt-contrato.vloperacao = tt-contrato.vltotal - 
                  (tt-contrato.vliof + tt-contrato.vltfc + tt-contrato.vlseguro)
                                    .
            */

        end.
        find titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = contrato.modcod and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = envfinan.titpar
                      no-lock no-error.
        if not avail titulo or
            (titulo.cobcod = 2)
        then delete tt-contrato.
        else do:
            find first tt-titulo of titulo no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.        

                /*if tt-titulo.modcod = "CPN"
                then 
                assign
                    tt-contrato.vltotal = tt-contrato.vltotal
                                         /* - tt-contrato.vlentra*/
                    tt-titulo.titvlcob = tt-titulo.titvlcob 
                    tt-titulo.titvlpag = tt-titulo.titvlpag 
                    tt-contrato.valpar = tt-contrato.valpar +
                                            tt-titulo.titvlcob
                    .

                else*/ 
                assign
                    tt-contrato.vltotal = tt-contrato.vltotal 
                    tt-titulo.titvlcob = tt-titulo.titvlcob 
                    tt-titulo.titvlpag = tt-titulo.titvlpag 
                    tt-contrato.valpar = tt-contrato.valpar +
                                            tt-titulo.titvlcob
                    .
                 /*else tt-contrato.valpar = tt-contrato.valpar +
                            (tt-titulo.titvlcob - tt-titulo.titdes).
                   */         
                 tt-contrato.qtdpar = tt-contrato.qtdpar + 1.
                          
            end.
        end.
    end.
end.
end.
end.
else if vindex = 6
then do:
do vdata = vdti to vdtf:
    for each lotefin where lotefin.datexp = vdata and
        lotefin.lottip = "inc" no-lock. 
        for each tt-estab:
            for each envfinan where 
                     envfinan.lotinc = lotefin.lotnum and
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit <> "RET"
                     no-lock.
                find contrato where contrato.contnum = int(envfinan.titnum)
                    no-lock no-error.
                if not avail contrato then next.
                find first tt-contrato where 
                    tt-contrato.contnum = contrato.contnum
                               no-error.
                if not avail tt-contrato
                then do:
                    create tt-contrato.
                    buffer-copy contrato to tt-contrato.
                    if envfinan.envsit = "CAN"
                    then tt-contrato.sit = "C".
                    run cal-tfc.
                    /*tt-contrato.vloperacao = tt-contrato.vloperacao -
                        (tt-contrato.vlentra + tt-contrato.vlseguro).
                        */
                end.
                find titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = envfinan.titpar
                      no-lock no-error.
                if not avail titulo /*or
                    (titulo.cobcod = 2 /*and contrato.banco <> 10*/)*/
                then delete tt-contrato.
                else do:
                    if  (vindex = 6 and titulo.tpcontrato = "") or
                        (vindex = 6 and titulo.tpcontrato = "L") or
                        (vindex = 6 and titulo.tpcontrato = "N")
                    then do:    
                        if titulo.tpcontrato = "L" or
                           titulo.tpcontrato = "N"
                        then tt-contrato.modcod = "CREN".            
                        find first tt-titulo of titulo no-error.
                        if not avail tt-titulo
                        then do:
                            create tt-titulo.
                            buffer-copy titulo to tt-titulo.       
                            assign
                                tt-contrato.vltotal = tt-contrato.vltotal
                                    - tt-titulo.titdes
                                tt-titulo.titvlcob = tt-titulo.titvlcob 
                                    - tt-titulo.titdes
                                tt-titulo.titvlpag = tt-titulo.titvlpag 
                                    - tt-titulo.titdes
                                tt-contrato.qtdpar = tt-contrato.qtdpar + 1
                                tt-contrato.valpar = tt-contrato.valpar +
                                   tt-titulo.titvlcob - tt-titulo.titdes
                                .
                        end.
                    end.
                    else delete tt-contrato.
                end.
            end.
        end.
    end.
end. 
do vdata = vdti to vdtf:
for each tt-estab,
    each envfinan where envfinan.etbcod = tt-estab.etbcod and
                        envfinan.datexp = vdata and
                        envfinan.envsit <> "RET" no-lock.
    find contrato where contrato.contnum = int(envfinan.titnum)
                    no-lock no-error.
    if not avail contrato then next.
    
    if contrato.banco <> 13 and vindex <> 5
    then next.
    
    if (vindex = 6 and contrato.modcod = "CP0") or
       (vindex = 6 and contrato.modcod = "CP1") or
       (vindex = 6 and contrato.modcod = "CPN") 
    then do:
    
        find first tt-contrato where 
               tt-contrato.contnum = contrato.contnum
                               no-error.
        if not avail tt-contrato
        then do:
            create tt-contrato.
            buffer-copy contrato to tt-contrato.
            
            /***
            find first titulo where
                       titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = 0
                       no-lock no-error.
            if avail titulo
            then tt-contrato.vltotal = tt-contrato.vltotal - titulo.titvlcob.
            ****/
            
            run cal-tfc.
            /*tt-contrato.vloperacao = tt-contrato.vltotal - 
                  (tt-contrato.vliof + tt-contrato.vltfc + tt-contrato.vlseguro)
                                    .
            */

        end.
        find titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = contrato.modcod and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = envfinan.titpar
                      no-lock no-error.
        if not avail titulo or
            (titulo.cobcod = 2)
        then delete tt-contrato.
        else do:
            find first tt-titulo of titulo no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.        

                /*if tt-titulo.modcod = "CPN"
                then*/ 
                assign
                    tt-contrato.vltotal = tt-contrato.vltotal 
                    tt-titulo.titvlcob = tt-titulo.titvlcob 
                    tt-titulo.titvlpag = tt-titulo.titvlpag 
                    tt-contrato.valpar = tt-contrato.valpar +
                                            tt-titulo.titvlcob
                    .
                 /*else tt-contrato.valpar = tt-contrato.valpar +
                            (tt-titulo.titvlcob - tt-titulo.titdes).
                   */         
                 tt-contrato.qtdpar = tt-contrato.qtdpar + 1.
                          
            end.
        end.
    end.
end.
end.
end.

form with frame ff.
def var vtotal as dec.
def var vtotal-con as dec.
def var vtotal-ent as dec.
def var vtotal-seg as dec.
def var vtotal-par as dec.
def var vtotal-ope as dec.
def var vtotal-iof as dec.
def var vtotal-tfc as dec.
def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/import/financeira/finanre1." + string(time).
else varquivo = "l:~\relat\finanre1." + string(time).

{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""finanre1"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO/CONTABIL""" 
                &Tit-Rel   = """ CONTRATOS FINANCEIRA "" + vescolha[vindex] " 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

DISP with frame f1.
def var vqtd-con as int.
for each tt-estab:
for each tt-contrato where tt-contrato.etbcod = tt-estab.etbcod no-lock:
    find clien where clien.clicod = tt-contrato.clicod no-lock.
    vqtd-con = vqtd-con + 1.
    disp     
             tt-contrato.etbcod column-label "Fil"
             tt-contrato.clicod  format ">>>>>>>>>9"
             clien.clinom   format "x(10)"
             tt-contrato.contnum     format ">>>>>>>>>9"
             tt-contrato.sit no-label
             tt-contrato.dtinicial  format "99/99/99"
                         column-label "Emissao"
             tt-contrato.vltotal    format ">>,>>>,>>9.99"
             tt-contrato.vlentra    format ">>>,>>9.99"
                         column-label "Entrada"
             tt-contrato.qtdpar     format ">>9"
                         column-label "Qtd.Par"
             tt-contrato.valpar     format "->,>>>,>>9.99"
                         column-label "Valor parcelas"
             tt-contrato.vlseguro     format ">>>,>>9.99"
                            column-label "Seguro"
             tt-contrato.vliof      format ">>>,>>9.99"
                            column-label "IOF"
             tt-contrato.vltfc        format ">>>,>>9.99"
                            column-label "TFC"
             tt-contrato.vloperacao    format ">>,>>>,>>9.99"
                            column-label "Venda"
             vqtd-con column-label "Quant." format ">>>>>>9"
             tt-contrato.modcod column-label "Pro" format "x(4)"
             with frame ff width 210 down
             .
    vtotal = 0.
    if vanalitico
    then do:
    for each tt-titulo where 
             tt-titulo.clifor = clien.clicod and
             tt-titulo.titnum = string(tt-contrato.contnum)
             no-lock by tt-titulo.titpar :
        disp tt-titulo.titpar
             tt-titulo.titdtven format "99/99/99"
             tt-titulo.titvlcob format ">>,>>9.99"
             tt-titulo.titdtpag format "99/99/99"
             tt-titulo.titvlpag when tt-titulo.titvlpag <> 0
                    format ">>,>>9.99"
             with frame ff 
             .
        vtotal = vtotal + tt-titulo.titvlcob.
        down with frame ff.
    end. 
    put fill("-",130) format "x(120)" skip.            
    disp    "TOTAL " @ tt-titulo.titdtven
            vtotal @ tt-titulo.titvlcob with frame ff.
    down with frame ff.
    put fill("=",130) format "x(120)" skip.
    end.
    else down with frame ff.
    vtotal-con = vtotal-con + tt-contrato.vltotal.
    vtotal-ent = vtotal-ent + tt-contrato.vlentra.
    vtotal-seg = vtotal-seg + tt-contrato.vlseguro.
    vtotal-par = vtotal-par + tt-contrato.valpar.
    vtotal-ope = vtotal-ope + tt-contrato.vloperacao.
    vtotal-iof = vtotal-iof + tt-contrato.vliof.
    vtotal-tfc = vtotal-tfc + tt-contrato.vltfc.
end.
disp "TOTAL GERAL" @ CLIEN.CLINOM
     vtotal-ope @ tt-contrato.vloperacao
     vtotal-iof @ tt-contrato.vliof
     vtotal-tfc @ tt-contrato.vltfc
     vtotal-con @ tt-contrato.vltotal
     vtotal-ent @ tt-contrato.vlentra
     vtotal-seg @ tt-contrato.vlseguro
     vtotal-par @ tt-contrato.valpar
     vqtd-con
     with frame ff.
end.     
put skip(2).
output close.     

def var varqcsv as char.
varqcsv = varquivo + ".csv".
sresp = no.
message "Gerar arquivo CSV ?" update sresp.
if sresp
then do:
    
    output to value(varqcsv).
    put
"Filial;Cliente;Nome;Contrato;;Emissao;Valor Contrato;Entrada;Qtd.Parcelas;"
"Valor parcelas;Seguro;IOF;TFC;Valor Origem;Quantidade;Parcela;"
"DataVencimento;Valor Cobrado;DataPagamento;ValorPago;Produto" 
skip.

    vqtd-con = 0.
    vtotal-con = 0.
    for each tt-estab:
        for each tt-contrato where 
            tt-contrato.etbcod = tt-estab.etbcod no-lock:
            find clien where clien.clicod = tt-contrato.clicod no-lock.
            vqtd-con = vqtd-con + 1.
            
            put unformat  
                 tt-contrato.etbcod 
                 ";"
                 tt-contrato.clicod    format ">>>>>>>>>9"
                 ";"
                 clien.clinom   format "x(20)"
                 ";"
                 tt-contrato.contnum   format ">>>>>>>>>9"
                 ";"
                 tt-contrato.sit
                 ";"
                 tt-contrato.dtinicial  format "99/99/99"
                 ";"
                 replace(string(tt-contrato.vltotal,">>>>>>>9.99"),".",",")
                 ";"
                 replace(string(tt-contrato.vlentra,">>>>>>9.99"),".",",")
                 ";"
                 tt-contrato.qtdpar format ">>>9"
                 ";"
                 replace(string(tt-contrato.valpar,"->>>>>>9.99"),".",",")
                 ";"
                 replace(string(tt-contrato.vlseguro,">>>>>>9.99"),".",",")
                 ";"
                 replace(string(tt-contrato.vliof,">>>>>>9.99"),".",",")
                 ";"
                 replace(string(tt-contrato.vltfc,">>>>>>9.99"),".",",")
                 ";"
                 replace(string(tt-contrato.vloperacao,">>>>>>>9.99"),".",",")
                 ";"
                 vqtd-con  format ">>>>>>9"
                 ";"
                 tt-contrato.modcod
                 ";"
                 .
                                                                       
            vtotal = 0.
            if vanalitico
            then do:
                for each tt-titulo where 
                    tt-titulo.clifor = clien.clicod and
                    tt-titulo.titnum = string(tt-contrato.contnum)
                    no-lock by tt-titulo.titpar :
                    put unformat ";;;;;;;;;;;;;;"
                        tt-titulo.titpar
                        ";"
                        tt-titulo.titdtven format "99/99/99"
                        ";"
                        replace(string(tt-titulo.titvlcob,">>>>9.99"),".",",")
                        ";"
                        tt-titulo.titdtpag format "99/99/99"
                        ";"
                        replace(string(tt-titulo.titvlpag,">>>>9.99"),".",",")
                        .
                    vtotal = vtotal + tt-titulo.titvlcob.
                end. 
            end.
            put skip.
            vtotal-con = vtotal-con + tt-contrato.vltotal.
        end.
    end.
    output close.
    
    message color red/with
    "Arquivo gerado " varqcsv
    view-as alert-box.
    
end.

if opsys = "UNIX"       
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.
 
procedure cal-tfc:
    
    def buffer ntitulo for titulo.
    def var vchepres as dec.
    def var vi as int.
    
    find first contnf where contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                             no-lock no-error.
    if avail contnf 
    then do:
        find first plani use-index pladat 
                    where plani.movtdc = 5 and
                          plani.etbcod = contrato.etbcod and
                          plani.pladat = contrato.dtinicial and
                          plani.placod = contnf.placod and
                          plani.dest   = contrato.clicod no-lock no-error.
        if not avail plani then
        find first plani  
                    where plani.movtdc = 5 and
                          plani.etbcod = contrato.etbcod and
                          plani.placod = contnf.placod and
                          plani.dest   = contrato.clicod no-lock no-error.
 
        if avail plani
        then do:
     
            vchepres = 0.
            if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
            then do vi = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
                vchepres = vchepres +  dec(acha("VALCHQPRESENTEUTILIZACAO" + 
                            string(vi),plani.notobs[3])) .
            end. 
            
            tt-contrato.vloperacao = plani.platot -
                          (plani.vlserv + plani.descprod + vchepres
                          + tt-contrato.vlentra + tt-contrato.vlseguro).

            for each movim where movim.etbcod = plani.etbcod
                    and movim.placod = plani.placod
                    and movim.movtdc = plani.movtdc
                    and movim.movdat = plani.pladat
                                   no-lock.
                      

                release profin.
      
      
                find first profin where profin.procod = movim.procod
                                   no-lock no-error.
        
                if avail profin
                then do:
                    tt-contrato.vltfc = 
                        (movim.movpc * movim.movqtm) - movim.movctm.
      
                    if tt-contrato.vltfc = ? then tt-contrato.vltfc = 0.
          
                    if movim.movctm <> ?
                    then tt-contrato.vloperacao = movim.movctm.
                    else tt-contrato.vloperacao = movim.movpc.
                end.                 
            end.
        end.
    end.            
        else do:
            for each tit_novacao where ger_contnum = contrato.contnum no-lock.
                find first ntitulo where
                           ntitulo.empcod = tit_novacao.ori_empcod and
                           ntitulo.titnat = tit_novacao.ori_titnat and
                           ntitulo.modcod = tit_novacao.ori_modcod and
                           ntitulo.etbcod = tit_novacao.ori_etbcod and
                           ntitulo.clifor = tit_novacao.ori_CliFor and
                           ntitulo.titnum = tit_novacao.ori_titnum and
                           ntitulo.titpar = tit_novacao.ori_titpar and
                           ntitulo.titdtemi = tit_novacao.ori_titdtemi
                           no-lock no-error.
                if avail ntitulo and ntitulo.titvlpag < ntitulo.titvlcob
                then tt-contrato.vloperacao = tt-contrato.vloperacao +
                                            ntitulo.titvlpag.
                else tt-contrato.vloperacao = tt-contrato.vloperacao +
                                            tit_novacao.ori_titvlcob.    
            end.
        end.
end procedure.
