{admcab.i}

def var vdtini  as date format "99/99/9999" label "de".
def var vdtfim  as date format "99/99/9999" label "ate".
def var varqcsv as char format "x(60)" label "csv".


def var vt as int.
def var vi as int.
def var xtime as int.

def var vcp as char init ";".
def var vvlr_aberto as dec.
def var vfinanceira as log.
def var vdt_primvenc as date.
def var vqtd_parcelas as int.
def var vtpcontrato as char.
def var vcpf as char.
def var vemCartorio as log.

xtime = time.

def stream csvparcela.
 
/*  Todos emitidos a partir de 2016 ou com alguma parcela em aberto  */


update vdtini vdtfim 
    with frame f1 side-labels centered
    title "parcelas".

varqcsv = "/admcom/tmp/lidia/parcelas_" + string(today,"999999") + ".csv".


output stream csvparcela to value(varqcsv).
put stream csvparcela unformatted skip 
    "CPFCNPJ"
vcp "CODIGOCLIENTE"
vcp "CODIGOLOJA"
vcp "NUMEROCONTRATO"
vcp "SEQUENCIAL"
vcp "VALORPARCELA"
vcp "DATAVENCIMENTO"
vcp "DATAEMISSAO"
vcp "CODIGOCOBRANCA"
vcp "VALORPRINCIPAL"
vcp "VALORFINANCEIROACRESCIMO"
vcp "VALORSEGURO"
vcp "SITUACAO"
vcp "SALDO"
vcp "DATAPAGAMENTO"
vcp "emCartorio" 
vcp "tpContrato" 

 skip.

for each contrato  no-lock
        where contrato.dtinicial >= vdtini and contrato.dtinicial <= vdtfim
            by contrato.contnum.

        
    vvlr_aberto = 0.
    vfinanceira = no.
    vdt_primvenc = ?.
    vqtd_parcelas = 0.
    vtpcontrato = "".
    vt = vt + 1.    
    
    if vt mod 7000 = 0 or vt = 1
    then do:
        hide message no-pause.
        message "parcelas" today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") vt vi.
        pause 1 no-message.
    end.
    
    vcpf = ?.
    /*
    for each titulo where titulo.titnat = no and titulo.empcod = 19 and
            titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and
            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum)
            no-lock.
        if titulo.titpar > 0
        then do:
            vdt_primvenc = if vdt_primvenc = ? then titulo.titdtven else min(vdt_primvenc,titulo.titdtven).
            vqtd_parcelas = vqtd_parcelas + 1.
            if vtpcontrato = "" and titulo.tpcontrato <> ""
            then vtpcontrato = titulo.tpcontrato.
            find cobra of titulo no-lock.
            if cobra.sicred
            then vfinanceira  = yes.
        end.    
        else next. 
        if titulo.titsit = "LIB"
        then do: 
            find cobra of titulo no-lock.
            if cobra.sicred
            then vfinanceira  = yes.
            vvlr_aberto = vvlr_aberto + titulo.titvlcob.
        end.
    end.
    if (contrato.dtinicial < 01/01/2015 and vvlr_aberto > 0 ) or
        contrato.dtinicial >= 01/01/2015
    */
    if true
    then do:
    
            if vcpf = ?
            then do:
                find neuclien where neuclien.clicod = contrato.clicod no-lock no-error.
                if avail neuclien then do:
                    vcpf = trim(string(neuclien.cpf,">>>>>>>>>>>>>>>")).
                end.
                if vcpf = ?
                then do:
                    find clien where clien.clicod = contrato.clicod no-lock no-error.
                    if avail clien
                    then do:
                        vcpf = clien.ciccgc.
                    end.    
                end.
                if vcpf = ?
                then vcpf = "".
            end.
   
    
    vi = vi + 1.    
    for each titulo where titulo.titnat = no and titulo.empcod = 19 and
            titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and
            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum)
            no-lock
            by titulo.titpar.
            
        if titulo.titpar > 0
        then do:
            vdt_primvenc = if vdt_primvenc = ? then titulo.titdtven else min(vdt_primvenc,titulo.titdtven).
            vqtd_parcelas = vqtd_parcelas + 1.
            if vtpcontrato = "" and titulo.tpcontrato <> ""
            then vtpcontrato = titulo.tpcontrato.
            find cobra of titulo no-lock.
            if cobra.sicred
            then vfinanceira  = yes.
        end.    
        else next.
        
        
    /* helio #092022 - novos campos vi*/
    vemCartorio = no.       
      do on error undo:
        find first titprotparc where titprotparc.operacao = "IEPRO" and
                                     titprotparc.contnum  = int(titulo.titnum) and
                                     titprotparc.titpar   = titulo.titpar
            exclusive-lock no-wait no-error.
        if avail titprotparc
        then do:
            find titprotesto of titprotparc no-lock no-error.
            if avail titprotesto
            then do:
                if titprotesto.ativo = "" or
                   titprotesto.ativo = "ATIVO"
                then do:
                    if titprotparc.SitCslog = ""
                    then do:
                        titprotparc.sitCslog = "EM PROTESTO".
                        titprotparc.sitDtCslog = ?.
                        vemCartorio = yes.
                    end.    
                end.   
                else do:
                     if titprotparc.SitCslog <> ""
                     then do:
                        titprotparc.sitCslog = "".
                        titprotparc.sitDtCslog = ?.
                        vemCartorio = no.
                     end.
                end.
            end.     
        end.

    end. 
    
            vvlr_aberto = if titulo.titsit = "LIB"
                          then titulo.titvlcob
                          else 0.
                put stream csvparcela
                unformatted  
                        vcpf
                     vcp contrato.clicod
                     vcp contrato.etbcod
                     vcp contrato.contnum
                    vcp titulo.titpar
                    vcp trim(string(titulo.titvlcob,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99")) 
                    vcp  (string(year(titulo.titdtven),"9999") + "-" + 
                          string(month(titulo.titdtven),"99")   + "-" + 
                          string(day(titulo.titdtven),"99"))
                    
                    vcp  (string(year(contrato.dtinicial),"9999") + "-" + 
                          string(month(contrato.dtinicial),"99")   + "-" + 
                          string(day(contrato.dtinicial),"99"))
                    
                    vcp titulo.cobcod
                    vcp trim(string(titulo.titvlcob,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp trim(string(titulo.vlf_acrescimo,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp trim(string(titulo.titdesc,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp titulo.titsit
                    vcp trim(string(vvlr_aberto,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp (if titulo.titdtpag = ?
                         then ""
                         else (string(year(titulo.titdtpag),"9999") + "-" + string(month(titulo.titdtpag),"99")   + "-" + string(day(titulo.titdtpag),"99")))
                    vcp string(vemCartorio,"true/false")
                    vcp titulo.tpContrato    
                
                    skip.
            end.        
        end.

end.            
for each estab no-lock,
        each pdvtmov no-lock, 
        each pdvdoc where pdvdoc.ctmcod = pdvtmov.ctmcod and
             pdvdoc.pstatus = yes and 
             pdvdoc.etbcod = estab.etbcod and 
            pdvdoc.datamov >= vdtini and
            pdvdoc.datamov <= vdtfim 
            no-lock:
                find pdvmov of pdvdoc                      no-lock no-error.
                if not avail pdvmov then next.

            if contnum = ? then next.
            find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
            if not avail contrato
            then next.
            find first  titulo where
                titulo.empcod = 19 and titulo.titnat = no and titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                titulo.titnum = string(contrato.contnum) and
                 titulo.titpar = pdvdoc.titpar
                 no-lock no-error.
            if not avail titulo
             then next.
             
    vt = vt + 1.    
    if vt mod 5000 = 0 or vt = 1
    then do:
        hide message no-pause.
        message "movimentos" today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") vt vi.
        pause 1 no-message.
    end.

    vcpf = ?.
            if vcpf = ?
            then do:
                find neuclien where neuclien.clicod = contrato.clicod no-lock no-error.
                if avail neuclien then do:
                    vcpf = trim(string(neuclien.cpf,">>>>>>>>>>>>>>>")).
                end.
                if vcpf = ?
                then do:
                    find clien where clien.clicod = contrato.clicod no-lock no-error.
                    if avail clien
                    then do:
                        vcpf = clien.ciccgc.
                    end.    
                end.
                if vcpf = ?
                then vcpf = "".
            end.
            
                            vvlr_aberto = if titulo.titsit = "LIB"
                          then titulo.titvlcob
                          else 0.

                vemCartorio = no.
                put stream csvparcela
                unformatted  
                        vcpf
                     vcp contrato.clicod
                     vcp contrato.etbcod
                     vcp contrato.contnum
                    vcp titulo.titpar
                    vcp trim(string(titulo.titvlcob,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99")) 
                    vcp  (string(year(titulo.titdtven),"9999") + "-" + 
                          string(month(titulo.titdtven),"99")   + "-" + 
                          string(day(titulo.titdtven),"99"))
                    
                    vcp  (string(year(contrato.dtinicial),"9999") + "-" + 
                          string(month(contrato.dtinicial),"99")   + "-" + 
                          string(day(contrato.dtinicial),"99"))
                    
                    vcp titulo.cobcod
                    vcp trim(string(titulo.titvlcob,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp trim(string(titulo.vlf_acrescimo,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp trim(string(titulo.titdesc,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp titulo.titsit
                    vcp trim(string(vvlr_aberto,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))
                    vcp (if titulo.titdtpag = ?
                         then ""
                         else (string(year(titulo.titdtpag),"9999") + "-" + string(month(titulo.titdtpag),"99")   + "-" + string(day(titulo.titdtpag),"99")))
                    vcp string(vemCartorio,"true/false")
                    vcp titulo.tpContrato    
                
                    skip.

end.            



output stream csvparcela close.



message "arquivo" varqcsv "gerado.".
pause.

