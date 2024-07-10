/* cmdman.p                     */
{cabec.i}

def var vvalor_encargo like pdvdoc.valor_encargo.
def var vjuro-ok   as   log.
def var vmotivo    as   char format "x(40)".
def var vfuncod    like func.funcod.

def input parameter par-pdvmov-recid as recid.
def input parameter par-pdvdoc-recid as recid.
def input parameter par-titulo-recid  as recid.
def input parameter par-openat           as log.
def input parameter par-operacao as char.

def var vnovo-hispad    as log.
def var vi              as int.
def buffer bpdvdoc     for pdvdoc.
def buffer tit-pdvmov  for pdvmov.
def buffer tit-pdvdoc  for pdvdoc.
def buffer bestab          for estab.

/*def var vsaldo like titulo.titvlcob label "Saldo" column-label "Saldo".*/
def var vvalor like pdvdoc.valor.
def var vsld-ant  like pdvdoc.valor.
def var vperc   as dec.
def var vmulta as dec init 0.

form
    titulo.titnum           colon  15 label "titulo" format "x(15)"
    titulo.titdtven
    titulo.titvlcob             colon  15 label "Saldo"
    vvalor    colon  45 label "Liquidar" format ">>>,>>9.99"
    titulo.cobcod           colon 15
    pdvdoc.valor_encargo    colon 45 label "Juros"
    pdvdoc.desconto    colon 45 label "Descontos"
    pdvdoc.hiscod colon 15 label "Historico"
        pdvdoc.hispaddesc no-label  
    with frame frecebe side-label row 12 color messages
         overlay  title " Liquidacao " centered.

form
    vvalor
    header " VALOR EM DINHEIRO "
        with frame fdinheiro row 9 color messages overlay centered no-labels.

def var vbarras as char format "x(44)".

form
    pdvdoc.modcod  colon 12 label "Modalidade"
    modal.modnom no-label
    estab.etbcod     colon 12 label "Estab"
    estab.etbnom     no-label
    clien.clicod    colon 12 label "Cliente"
    clien.clinom    no-label
    pdvdoc.datamov label "Referencia"  colon 12
"|----------------------------------------------------------------------------|"
"|" 
    pdvdoc.valor colon 12   label "Valor"             
                                                                "|" at 78
"|" pdvdoc.hiscod   colon 12   label "Historico"
    pdvdoc.hispaddesc no-label colon 25  format "x(40)"                "|" at 78
"|----------------------------------------------------------------------------|"
             with frame fconta row 7 overlay color message side-label
                        centered width 80.

find pdvmov where recid(pdvmov) = par-pdvmov-recid.
find pdvdoc where recid(pdvdoc) = par-pdvdoc-recid no-error.
find pdvtmov  of pdvmov no-lock.
find cmon    of pdvmov no-lock.

find cmtipo  of cmon    no-lock. 


pause 0.
if not avail pdvdoc
then do:
    find last bpdvdoc of pdvmov exclusive no-error.
    create pdvdoc.
        pdvdoc.etbcod            = pdvmov.etbcod.
        pdvdoc.cmocod            = pdvmov.cmocod.
        pdvdoc.DataMov           = pdvmov.DataMov.
        pdvdoc.Sequencia         = pdvmov.Sequencia.
        pdvdoc.ctmcod            = pdvmov.ctmcod.
        pdvdoc.COO               = pdvmov.COO.
        pdvdoc.seqreg            = if avail bpdvdoc
                                   then bpdvdoc.seqreg + 1
                                   else 1.
end.
else do:
    if pdvdoc.contnum <> ?
    then do:
        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                          titulo.titpar  = pdvdoc.titpar
            no-lock no-error.
        if not avail titulo 
        then do:   
            find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
            if avail contrato
            then do: 
                find titulo where
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.modcod = contrato.modcod and
                        titulo.titnum = pdvdoc.contnum and
                        titulo.titpar = pdvdoc.titpar and
                        titulo.titdtemi = contrato.dtinicial
                    no-lock no-error.
            end.
        end.                
        par-titulo-recid = recid(titulo).
    end.

end.

def var vsaldo-atual as dec .

if trim(entry(1,par-operacao)) = "manutencao"
then b: do with frame fconta on error undo.
    clear frame fconta all no-pause.

    do on error undo, retry on endkey undo, leave.

          do on error undo , retry on endkey undo b, retry b.
            pdvdoc.datamov = cmon.cxadt.
            display pdvdoc.datamov
                    pdvdoc.valor.

            if trim(entry(1,par-operacao)) <> "Manutencao"
            then  update pdvdoc.datamov
                    pdvdoc.valor 
                                     validate(pdvdoc.valor > 0, 
                                              "Valor igual a ZERO")
                    with frame fconta.

            disp
                pdvdoc.hispad
                pdvdoc.hispaddesc.

            vnovo-hispad = no.
            if pdvdoc.hispaddesc = ""
            then vnovo-hispad = yes.
            do on error undo.
                    update pdvdoc.hiscod.

                if pdvdoc.hiscod entered
                then if pdvdoc.hiscod <> 0
                     then vnovo-hispad = yes.
                if vnovo-hispad
                then do:
                    if pdvdoc.hiscod <> 0
                    then do:
                        find hispad of pdvdoc no-lock.
                        assign
                            pdvdoc.hispaddesc = "" /*hispad.hisdesc*/
                            .
                        update text(pdvdoc.hispaddesc)
                        /*
                            editing:
                                    do while vi < length(hispad.hispaddesc) + 1:
                                        apply keycode("cursor-right").
                                        vi = vi + 1.
                                    end.
                                readkey.
                                apply lastkey.
                                if go-pending
                                then leave.
                                else next.
                            end*/ .
                    end.
                    else do:
                        pdvdoc.hispaddesc = "".
                        update text(pdvdoc.hispaddesc).
                    end.
                end.
                if not vnovo-hispad 
                then do:
                    update text(pdvdoc.hispaddesc).
                end.
                if pdvdoc.hispaddesc = "" 
                then do:
                    message "Historico nao preenchidos".
                    undo.
                end.
                pause 0.
            end.
        end.
    end.
    leave.
end.

find titulo where recid(titulo) = par-titulo-recid no-lock no-error.
if avail titulo
then do with frame frecebe.
    find clien where clien.clicod =  titulo.clifor no-lock.
    find modal of titulo no-lock.
    find estab where /*estab.empcod = wempre.empcod and */
                    estab.etbcod = titulo.etbcod no-lock.
 
/*    if cmon.cmtcod = "EXT"
    then par-operacao = " Liquidacao ".
  */  
    assign
        pdvdoc.modcod = if pdvdoc.modcod = ""
                         then modal.modcod
                         else pdvdoc.modcod.
    if par-operacao <> " Liq. Total "
    then
        disp pdvdoc.modcod
             modal.modnom with frame fconta.
    if par-operacao <> " Liq. Total  "
    then
        disp clien.clicod
             clien.clinom            with frame fconta.
    pause 0.

        /*pdvdoc.etbcod       = estab.etbcod.*/
    /*vsaldo = if titulo.titvlcob - titulo.titvlpag < 0
             then 0
             else titulo.titvlcob - titulo.titvlpag.*/

             /*
    pdvdoc.valor_encargo = 0.
    pdvdoc.desconto = 0.
    */
    if pdvdoc.valor = 0
    then do:
        pdvdoc.valor        = titulo.titvlcob.
        pdvdoc.titvlcob     = titulo.titvlcob.
    end.    

    vvalor          = pdvdoc.valor.

    
    if par-operacao <> " Liq. Total  "
    then
        display
            {titnum.i}
            titulo.titdtven
            titulo.titvlcob
            titulo.cobcod
            pdvdoc.valor_encargo
            pdvdoc.desconto
            vvalor
            with frame frecebe.

    if par-operacao <> " Liq. Total   " /*and not avail titprog*/
    then do:
/***
        if titulo.titvljur > 0
        then do on error undo.
            pdvdoc.valor_encargo = titulo.titvljur.
            update pdvdoc.valor_encargo.
            if pdvdoc.valor_encargo entered
            then do. 
                run versenha.p ("valor_encargo", 
                                "Senha para Alteracao dos Juros", 
                                output sresp). 
                if not sresp 
                then undo.
                do on error undo.
                    update pdvdoc.cmopehis[3]   label "Motivo"
                               with frame fjustificativa
                                  no-box   centered
                                        row 19 overlay
                                             side-label . 
                    pdvdoc.cmopehis[2] = "JUROS ALTERADO".
                    if pdvdoc.cmopehis[3] = ""
                    then  undo.
                end.
            end.
        end.
        else***/ do.
            if today > titulo.titdtven 
            then do:
                /**
                run fbjuro.p (input titulo.cobcod,
                              input titulo.carcod,
                              input titulo.titnat,
                              input vsaldo,
                              input titulo.titdtven,
                              input today,
                              output vvalor,
                              output vperc) .

                run fin/fbmulta.p (input titulo.cobcod, 
                               input titulo.carcod, 
                               input titulo.titnat, 
                               input vsaldo , 
                               input titulo.titdtven, 
                               input today, 
                               output vmulta) .
                **/
                
                    assign
                        pdvdoc.valor_encargo = vvalor - titulo.titvlcob + vmulta
                        vvalor = titulo.titvlcob.

                vvalor_encargo = 0.
                vvalor_encargo = pdvdoc.valor_encargo.

                do on error undo.
                    /* estab.cdci = no loja esta bloqueada para alterar
                       juros */
                    update
                        pdvdoc.valor_encargo 
                                        when 
                                             lookup("JURO",titulo.titsit) > 0.
                end.
            end.
        end.
        do on error undo:
        update vvalor.
        
        /**if vvalor >= vsaldo and
           cmon.cmtcod = "EXT"
        then do:
            message "Soh eh Permitida Liquidacao Parcial".
            pause 2 no-message.
            undo.
        end.
        **/
        
        end.

        if vvalor > titulo.titvlcob
        then do:
            pdvdoc.valor_encargo = vvalor - titulo.titvlcob.
            vvalor = titulo.titvlcob.
            disp vvalor.
            update pdvdoc.valor_encargo.
        end.

        if titulo.titvldes > 0
        then do.
            pdvdoc.desconto = titulo.titvldes.
            update pdvdoc.desconto.
        end.
        if vvalor < titulo.titvlcob
        then do:
            run sys/message.p (input-output sresp,
                           input "P a g a m e n t o   P a r c i a l   ?",
                           input "A T E N C A O",
                           input "SIM",
                           input "NAO").
            if sresp = no
            then do:
                pdvdoc.desconto = titulo.titvlcob - vvalor.
                vvalor = titulo.titvlcob.
                disp vvalor.
                update pdvdoc.desconto.
            end.
            else do.
                pdvdoc.desconto = 0.

                if today > titulo.titdtven 
                then do:
                    /**
                    
                    /* Recalcular juros e multa para pagamento parcial */
                    run fbjuro.p (input titulo.cobcod,
                                  input titulo.carcod,
                                  input titulo.titnat,
                                  input vvalor,
                                  input titulo.titdtven,
                                  input today,
                                  output vvalor,
                                  output vperc).

                    run fin/fbmulta.p (input titulo.cobcod, 
                                   input titulo.carcod, 
                                   input titulo.titnat, 
                                   input vvalor, 
                                   input titulo.titdtven, 
                                   input today, 
                                   output vmulta).
                    **/
                    
                    pdvdoc.valor_encargo = vvalor - vvalor + vmulta.
                    update pdvdoc.valor_encargo.
                end.
            end.
        end.
        if pdvdoc.valor_encargo = 0 and
           pdvdoc.desconto = 0 and
           not (today > titulo.titdtven )
        then
            update
                pdvdoc.valor_encargo.
        
        
        pdvdoc.titvlcob = vvalor. 
        pdvdoc.valor    = vvalor + pdvdoc.valor_encargo - pdvdoc.desconto.
        /**
        if pdvdoc.cmopenat = yes
        then do:
               pdvdoc.modcoddesc             = if pdvdoc.desconto > 0
                                         then "DESCR"
                                         else "".
               pdvdoc.modcoddesc             = if pdvdoc.valor_encargo > 0
                                         then "JUROR"
                                         else pdvdoc.modcoddesc.
        end.
        else do:
               pdvdoc.modcoddesc             = if pdvdoc.desconto > 0
                                         then "DESCC"
                                         else "".
               pdvdoc.modcoddesc             = if pdvdoc.valor_encargo > 0
                                         then "JUROP"
                                         else pdvdoc.modcoddesc.
 
        end.
        **/
   
        /***/
            disp
                pdvdoc.hiscod
                pdvdoc.hispaddesc.

            vnovo-hispad = no.
            if pdvdoc.hispaddesc = ""
            then vnovo-hispad = yes.
            do on error undo.
                update pdvdoc.hiscod.
                if pdvdoc.hiscod entered
                then if pdvdoc.hiscod <> 0
                     then vnovo-hispad = yes.
                if vnovo-hispad
                then do:
                    if pdvdoc.hiscod <> 0
                    then do:
                        find hispad of pdvdoc no-lock.
                        assign
                            pdvdoc.hispaddesc = hispad.hisdes
                            .
                        update text(pdvdoc.hispaddesc)
                        
                            editing:
                                    do while vi < length(hispad.hisdes) + 1:
                                        apply keycode("cursor-right").
                                        vi = vi + 1.
                                    end.
                                readkey.
                                apply lastkey.
                                if go-pending
                                then leave.
                                else next.
                            end .
                    end.
                    else do:
                        update text(pdvdoc.hispaddesc).
                    end.
                end.
                if not vnovo-hispad 
                then do:
                    update text(pdvdoc.hispaddesc).
                end.
            end.
        /***/
    end.

    pause 0.
    if titulo.contnum = ?
    then do:
        find current titulo exclusive.
        titulo.contnum = int(titulo.titnum). 
    end.
    assign
        pdvdoc.contnum = string(titulo.contnum).
        pdvdoc.clifor  = titulo.clifor.      
        pdvdoc.titpar  = titulo.titpar.
        
        
end. 
hide frame fitnernet no-pause.


