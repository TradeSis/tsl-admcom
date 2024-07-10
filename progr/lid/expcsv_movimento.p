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
def var vsequencialmovim as int.

xtime = time.


update vdtini vdtfim 
    with frame f1 side-labels centered
    title "movimentos".

varqcsv = "/admcom/tmp/lidia/movimento_" + string(today,"999999") + ".csv".


def stream csvmovimento.
output stream csvmovimento to value(varqcsv).
put stream csvmovimento unformatted skip 
 "CPFCNPJ"
vcp "CODIGOCLIENTE"
vcp "CODIGOLOJA"
vcp "NUMEROCONTRATO"
vcp "SEQUENCIAL"
vcp "DATAHORABAIXA"
vcp "SEQUENCIALMOVIM"
vcp "CODIGOLOJAMOVIM"
vcp "TIPOBAIXA"
vcp "VALORBAIXAPRINCIPAL"
vcp "VALORBAIXAJUROSATRASO"
vcp "VALORBAIXATOTAL"
skip.


for each estab no-lock,
        each pdvtmov where pdvtmov.pagamento = yes no-lock, /* helio 26042023 - 
                                                    VALOR DIVERGENTE DE PARCELA TABELA CREDIARIO_PARCELA_MOVIMENTO */
        
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
            
            vsequencialmovim = 0.            

                vsequencialmovim = vsequencialmovim + 1.                                                                            
                put stream csvmovimento
                    unformatted  
                     vcpf
                     vcp contrato.clicod
                     vcp contrato.etbcod
                     vcp contrato.contnum
                    vcp titulo.titpar
                    vcp  string(year(pdvmov.datamov),"9999") + "-" + 
                         string(month(pdvmov.datamov),"99")   + "-" + 
                         string(day(pdvmov.datamov),"99") + " " +
                         string(pdvmov.horamov,"HH:MM:SS")
                    vcp string(vsequencialmovim)
                    vcp string(pdvdoc.etbcod)   
                    vcp pdvdoc.ctmcod
                    vcp trim(string(pdvdoc.titvlcob,"->>>>>>>>>>>>>9.99"))
                    vcp trim(string(pdvdoc.valor_encargo,"->>>>>>>>>>>>>9.99"))
                    vcp trim(string(pdvdoc.valor,"->>>>>>>>>>>>>9.99"))
                    skip.
end.            

output stream csvmovimento close.



message "arquivo" varqcsv "gerado.".
pause.


