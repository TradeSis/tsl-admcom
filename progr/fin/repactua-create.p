{admcab.i}
/* Ajustado recpactua 08/07/2021 */ 
def input parameter p-clicod like clien.clicod.
def var vparcelas as int init 0.
def var vdtvalid as date.
def output parameter ret-ok as log.

def var psicred as recid.

def var prec as recid.
def var vtitpar as int.
def var vseqreg as int.

def var vday as int.
def var vmes as int.
def var vano as int.
def var vi as int.

def temp-table tj-titulo like titulo.

def shared temp-table tp-contrato no-undo like contrato
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char
     .
    
def shared temp-table tp-titulo no-undo like titulo
    field precid as recid
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.

def buffer b-tp-titulo for tp-titulo.

def new shared var vtot like titulo.titvlcob.

def var vtotal as dec.
def var vpend as dec.
def var vpago as dec.

def var vdtven as date.
vdtven = today.
def var lp-ok as log.
lp-ok = no.

for each tp-contrato where 
         tp-contrato.clicod = p-clicod and
         tp-contrato.exportado no-lock:
    assign vpend = 0 .
    vtot = vtot + tp-contrato.vlpendente.
    
    for each tp-titulo where
             tp-titulo.clifor = tp-contrato.clicod and
             tp-titulo.titnum = string(tp-contrato.contnum) and
             tp-titulo.titsit = "LIB"
             no-lock by tp-titulo.titpar :
        vpend = vpend + tp-titulo.titvlcob.
        tp-contrato.tpcontrato = tp-titulo.tpcontrato.
    end.
    if tp-contrato.vltotal > 0
    then vpago = vpago + (tp-contrato.vltotal - vpend).

    vi = vi + 1.

end.


def var vdia as int.
vdia = (today - vdtven).

def var valorparc as dec.
def var vtitdtven as date.

    
def var vokj as log.

repeat on error undo:

    if keyfunction(lastkey) = "END-ERROR"
    then leave.
    
         if vparcelas > 1
         then assign
              valorparc = vtot / (vparcelas).
            
    disp 
         vparcelas  format "zzzzzzzzzzzzz9" label "Quantidade de parcelas"
         vtot       format "zzz,zzz,zz9.99" label "  Valor da Repactuacao"
         valorparc  format "zzz,zzz,zz9.99" label "      Valor da Parcela"
         vdtvalid   format "99/99/9999"     label "      Primeira parcela"
         with frame f-ef 1 down centered  row 8 width 60
         title " Valores REPACTUACAO " side-labels.
         .
    
    if vparcelas = 0
    then update vparcelas validate(vparcelas >= 1 and /* helio 12042021 - trocado de > para >= 1 */
               vparcelas < 26, "Informe numero de parcelas entre 1 e 25.")
            with frame f-ef.
 
    
    if keyfunction(lastkey) = "END-ERROR"
    then next.

    disp vtot with frame f-ef.
             
    valorparc = vtot / vparcelas.
    
    disp valorparc  with frame f-ef.

    disp vdtvalid with frame f-ef.

    update vdtvalid with frame f-ef.
        
    if  vdtvalid = ? or
        vdtvalid < today 
    then do:
        bell.
        message color red/with
        "Problema na data de validade do acordo."
        view-as alert-box.
        undo.
    end.
            
    sresp = no.
    message "Confirma os valores do REPACTUACAO?" update sresp.
    if not sresp
    then do:
        ret-ok = no.
        leave.
    end.    
    else do:
        ret-ok = yes.
        leave.
    end.
end.
 
if keyfunction(lastkey) = "END-ERROR"
then do:
    ret-ok = no.
    return.
end.
if ret-ok = no
then return.




def var vint as int.
vint = 1.

find first pdvtmov where pdvtmov.ctmcod = "REP" no-lock.
 
find cmon where cmon.etbcod = setbcod and cmon.cxacod = 99 no-lock.
 
run fin/cmdinc.p (recid(cmon), recid(pdvtmov), output prec).

find pdvmov where recid(pdvmov) = prec no-lock.

def var vcontnum like geranum.contnum.

/* Gera Numero Contrato */

      do for geranum on error undo on endkey undo:
        find geranum where geranum.etbcod = 999 
            exclusive-lock 
            no-wait 
            no-error.
        if not avail geranum
        then do:
            if not locked geranum
            then do:
                create geranum.
                assign
                    geranum.etbcod  = 999
                    geranum.clicod  = 300000000
                    geranum.contnum = 300000000.
                vcontnum = geranum.contnum.    
                find current geranum no-lock.
            end.
            else do: /** LOCADO **/
            end.
        end.
        else do:
            geranum.contnum = geranum.contnum + 1. 
            find current geranum no-lock. 
            vcontnum = geranum.contnum.
        end.
      end.
    
def var par-etbcod as int.

do on error undo:

    find first  tp-contrato where 
         tp-contrato.clicod = p-clicod and
         tp-contrato.exportado no-lock.
    par-etbcod = tp-contrato.etbcod.     

        find first pdvforma where      
                 pdvforma.etbcod     = pdvmov.etbcod and
                 pdvforma.cmocod     = pdvmov.cmocod and
                 pdvforma.DataMov    = pdvmov.DataMov and
                 pdvforma.Sequencia  = pdvmov.Sequencia and
                 pdvforma.ctmcod     = pdvmov.ctmcod and
                 pdvforma.COO        = pdvmov.COO and
                 pdvforma.seqforma   = 1
                no-error.
        if not avail pdvforma 
        then do: 
            create pdvforma.
            assign
                pdvforma.etbcod     = pdvmov.etbcod
                pdvforma.DataMov    = pdvmov.DataMov
                pdvforma.cmocod     = pdvmov.cmocod
                pdvforma.COO        = pdvmov.COO
                pdvforma.Sequencia  = pdvmov.Sequencia
                pdvforma.ctmcod     = pdvmov.ctmcod 
                pdvforma.seqforma   = 1.
        end.                     

        find pdvtforma where pdvtforma.pdvtfcod = "93" no-lock.
        pdvforma.modcod       =  tp-contrato.modcod.
        pdvforma.pdvtfcod     = pdvtforma.pdvtfcod.
        pdvforma.fincod       = 0.
        pdvforma.valor_forma  = vtot.
        pdvforma.valor        = vtot.

        pdvforma.contnum      = string(vcontnum).
        pdvforma.clifor       = p-clicod.
        pdvforma.crecod       = 2.
            
        pdvforma.qtd_parcelas = vparcelas.
        pdvforma.valor_ACF    = vtot.
        pdvforma.valor        = vtot.


            find contrato where contrato.contnum  = int(pdvforma.contnum) exclusive no-error.
            if not avail contrato
            then do:
                create contrato.
                contrato.contnum       = int(pdvforma.contnum).
            end.     
            ASSIGN
              contrato.clicod        = p-clicod.
              contrato.dtinicial     = today.
              contrato.etbcod        = par-etbcod.
              contrato.vltotal       = vtot.
              contrato.vlentra       = 0.
              contrato.crecod        = pdvforma.fincod.
              contrato.vltaxa        = 0.
              contrato.modcod        = pdvforma.modcod /*ttcontrato.modalidade*/ .
              contrato.DtEfetiva     = today.
              contrato.VlIof         = 0.
              contrato.Cet           = 0.
              contrato.TxJuros       = 0.
              contrato.vlf_principal = vtot.
              contrato.vlf_acrescimo = 0.
              contrato.nro_parcelas  = vparcelas.
            
            /***https://trello.com/c/T4NcTb5w/33-contrato-repactuado
              contrato.tpcontrato    = "N".
              ***/
              contrato.tpcontrato    = tp-contrato.tpcontrato.
            /*** ***/
                
                run fin/sicrecontr_create.p (recid(pdvforma),
                                             contrato.contnum,
                                             output psicred).

                find sicred_contrato where recid(sicred_contrato) = psicred no-lock no-error.
        
                vday = day(vdtvalid).
                vmes = month(vdtvalid).
                vano = year(vdtvalid).
    
            do vtitpar = 1 to vparcelas: 
                    vtitdtven = date(vmes, 
                         IF VMES = 2 
                         THEN IF VDAY > 28 
                              THEN 28 
                              ELSE VDAY 
                         ELSE if VDAY > 30 
                              then 30 
                              else vday, 
                         vano).

                find first pdvmoeda where      
                     pdvmoeda.etbcod       = pdvmov.etbcod and
                     pdvmoeda.cmocod       = pdvmov.cmocod and
                     pdvmoeda.DataMov      = pdvmov.DataMov and
                     pdvmoeda.Sequencia    = pdvmov.Sequencia and
                     pdvmoeda.ctmcod       = pdvmov.ctmcod and
                     pdvmoeda.COO          = pdvmov.COO and
                     pdvmoeda.seqforma     = pdvforma.seqforma and
                     pdvmoeda.seqfp        = 1 and
                     pdvmoeda.titpar       = vtitpar
                    no-error.
                if not avail pdvmoeda
                then do: 
                    create pdvmoeda.
                    assign
                         pdvmoeda.etbcod       = pdvmov.etbcod
                         pdvmoeda.DataMov      = pdvmov.DataMov
                         pdvmoeda.cmocod       = pdvmov.cmocod
                         pdvmoeda.COO          = pdvmov.COO
                         pdvmoeda.Sequencia    = pdvmov.Sequencia
                         pdvmoeda.ctmcod       = pdvmov.ctmcod
                         pdvmoeda.seqforma     = pdvforma.seqforma
                         pdvmoeda.seqfp        = 1
                         pdvmoeda.titpar       = vtitpar.   
                end.                  
                assign
                    pdvmoeda.contrato_p2k = pdvforma.contnum.
                pdvmoeda.clifor = contrato.clicod.
                pdvmoeda.titnum = string(contrato.contnum).
                pdvmoeda.moecod = pdvforma.modcod.
                pdvmoeda.modcod = pdvforma.modcod.

                pdvmoeda.valor =  round(vtot / (vparcelas),2) .
                vtotal         = vtotal + pdvmoeda.valor.
                
                pdvmoeda.titdtven = vtitdtven.
        
                find first titulo where titulo.contnum = contrato.contnum and
                                  titulo.titpar  = pdvmoeda.titpar  
                        no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = pdvmoeda.modcod and
                    titulo.etbcod     = pdvmoeda.etbcod and
                    titulo.clifor     = pdvmoeda.clifor and
                    titulo.titnum     = pdvmoeda.titnum and 
                    titulo.titpar     = pdvmoeda.titpar and
                    titulo.titdtemi   = pdvmoeda.datamov
                    no-error.
                    if not avail titulo
                    then do:
                        create titulo. 
                        titulo.datexp = today.
                    end.           
                    titulo.contnum  = contrato.contnum. 
                    
                    assign            
                    titulo.empcod     = 19
                    titulo.titnat     = no
                    titulo.modcod     = pdvmoeda.modcod 
                    titulo.etbcod     = pdvmoeda.etbcod 
                    titulo.clifor     = pdvmoeda.clifor 
                    titulo.titnum     = pdvmoeda.titnum 
                    titulo.titpar     = pdvmoeda.titpar 
                    titulo.titdtemi   = pdvmoeda.datamov
                    titulo.titdtven   = pdvmoeda.titdtven.
                    titulo.titsit     = "LIB".
                end.        
                assign
                    titulo.titvlcob   = pdvmoeda.valor
                    titulo.titnumger  = pdvmoeda.contrato_p2k
                    titulo.tpcontrato = contrato.tpcontrato.
                assign
                    titulo.titdesc       = 0.
                    titulo.vlf_acrescimo = 0.
                    titulo.vlf_principal = pdvmoeda.valor.
                    
                titulo.cobcod = if avail sicred_contrato
                                then sicred_contrato.cobcod
                                else 1.
                       
            vmes = vmes + 1.
            if vmes > 12 
            then assign vano = vano + 1
                        vmes = 1.
        
        end.
       
        if vtotal < vtot
        then do:
            find pdvmoeda of pdvmov where pdvmoeda.titpar = 1.
            pdvmoeda.valor = pdvmoeda.valor + (vtot - vtotal).
            find titulo where titulo.contnum = int(pdvmoeda.contrato_p2k) and
                              titulo.titpar = pdvmoeda.titpar.
            titulo.titvlcob = pdvmoeda.valor.
        end.
        
        /* contrato fica na mesma filial da origem */
        for each titulo where titulo.contnum = contrato.contnum.
            titulo.etbcod = contrato.etbcod.
        end.              

    vseqreg = 0.
    for each tp-contrato where 
         tp-contrato.clicod = p-clicod and
         tp-contrato.exportado no-lock:
        for each tp-titulo where
             tp-titulo.clifor = tp-contrato.clicod and
             tp-titulo.titnum = string(tp-contrato.contnum) and
             tp-titulo.titsit = "LIB".
    
        find titulo where recid(titulo) =tp-titulo.precid.
        if titulo.contnum = ?
         then titulo.contnum = tp-contrato.contnum.
        
        vseqreg = vseqreg + 1.
        
        create pdvdoc.
          ASSIGN
            pdvdoc.etbcod            = pdvmov.etbcod
            pdvdoc.cmocod            = pdvmov.cmocod
            pdvdoc.DataMov           = pdvmov.DataMov
            pdvdoc.Sequencia         = pdvmov.Sequencia
            pdvdoc.ctmcod            = pdvmov.ctmcod
            pdvdoc.COO               = pdvmov.COO
            pdvdoc.seqreg            = vseqreg
            pdvdoc.CliFor            = titulo.CliFor
            pdvdoc.ContNum           = string(titulo.contnum)
            pdvdoc.titpar            = titulo.titpar
            pdvdoc.titdtven          = titulo.titdtven.

          ASSIGN
            pdvdoc.modcod            = titulo.modcod
            pdvdoc.Desconto_Tarifa   = 0
            pdvdoc.Valor_Encargo     = 0
            pdvdoc.hispaddesc        = "REPACTUACAO".

            pdvdoc.Valor             = titulo.titvlcob.
            pdvdoc.titvlcob          = titulo.titvlcob.
        
            run fin/baixatitulo.p (recid(pdvdoc),
                                   recid(titulo)).
        end.
    end.
end.


ret-ok = yes.

