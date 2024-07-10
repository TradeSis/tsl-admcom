def input param ptitle as char.
{admcab.i}

def var vcp as char init ",".

def var vcli as int.  
def var vdtini  as date format "99/99/9999" label "periodo de".
def var vdtfim  as date format "99/99/9999" label "ate".

def var vvlrlimite as dec.
def var vvctolimite as date.
def var vcomprometido as dec.
def var vcomprometido-principal as dec.
def var vcomprometido-hubseg as dec.
def var vsaldoLimite as dec.
def buffer xtitulo for titulo.
def var vtotparcelas as int.
def var vtotpagas as int.
def var vpercpagas as dec.

{neuro/achahash.i}
{neuro/varcomportamento.i}
def var vetbcod         as int format ">>9" label "filial".
def var vfiltradtcad     as log format "Sim/Nao" label "filtra data de cadastro?".

    
update vetbcod colon 30
       vfiltradtcad colon 30
       with frame fcab centered
       row 4 side-labels title ptitle.

if vfiltradtcad
then  update vdtini colon 30 vdtfim
    with frame fcab.
    
   def var varq as char format "x(78)".
   varq = "/admcom/relat/" + "clientes_limites_" + string(vetbcod) + "_" +
                             (if vdtini <> ? and vdtfim <> ?
                              then    (string(vdtini,"99999999") + string(vdtfim,"99999999"))
                              else "") + 
                             "_"   + string(today,"999999")  + replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de saida".
    
hide message no-pause.
message "pesquisando clientes...".
output to value(varq).

put unformatted 
    "codigoCliente," 
    "CPF," 
    "Nome cliente," 
    "Limite Total," 
    "Limite Total Utilizado," 
    "Limite Total Util. Principal,"
    "Limite Total Disponível," 
    "Percentual de Pagamento (parcelas/qtd parcelas pagas)," 
    "qtd total de Parcelas Pagas,"
    skip.

for each clien where clien.etbcad = vetbcod and if vfiltradtcad then (clien.dtcad >= vdtini and clien.dtcad <= vdtfim) else true no-lock.

    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.    
    
    
    vvlrlimite = 0.
    vvctolimite = ?.
    vcomprometido = 0.
    
    vsaldoLimite = 0.
    vvctolimite = if avail neuclien then neuclien.vctolimite else ?.
    vcomprometido-hubseg = 0.    
    

    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)". 

    var-propriedades = "".
    
    run neuro/comportamento.p (clien.clicod,?,output var-propriedades).

    do il = 1 to num-entries(var-propriedades,"#") with down.
    
        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).
        if vcampo = "LIMITE"    then vvlrlimite = dec(r1).
        
        if vcampo = "LIMITETOMPR" then vcomprometido-principal = dec(r1).
        if vcampo = "LIMITETOMHUBSEG" then vcomprometido-hubseg = dec(r1).
        
        
        if vcampo = "LIMITETOM"  then vcomprometido = dec(r1). 
        
    end.
    vcomprometido-principal = vcomprometido-principal - vcomprometido-hubseg.
    vsaldoLimite = vvlrlimite - (vcomprometido-principal).

    
    
    if vvctolimite < today or vvctolimite = ? or
        vsaldoLimite < 0
    then do:
        vvlrlimite   = 0.
        vsaldoLimite = 0.
    end.     
    
    
    for each contrato where contrato.clicod = clien.clicod no-lock,
        each xtitulo where xtitulo.empcod = 19        and
                           xtitulo.titnat = no        and
                           xtitulo.modcod = contrato.modcod and
                           xtitulo.etbcod = contrato.etbcod and
                           xtitulo.clifor = contrato.clicod and
                           xtitulo.titnum = string(contrato.contnum)
                           no-lock:
        if xtitulo.titsit = "LIB"        or
           xtitulo.titsit = "PAG"
        then do:
            vtotParcelas = vtotParcelas + 1.
        end.

        if xtitulo.titsit = "PAG"        
        then do:
            vtotPagas = vtotPagas + 1.
        end.
    end. 
    
    vpercPagas = vtotPagas / vtotParcelas * 100.
    
    put unformatted
        clien.clicod vcp
        trim(string(if avail neuclien then neuclien.cpf else dec(clien.ciccgc),">>>99999999999")) vcp
        clien.clinom vcp
        trim(string(vvlrlimite,"->>>>>>>>>>>>>>>>>9.99")) vcp
        trim(string(vcomprometido,"->>>>>>>>>>>>>>>>>9.99")) vcp
        trim(string(vcomprometido-principal,"->>>>>>>>>>>>>>>>>9.99")) vcp
        trim(string(vsaldoLimite,"->>>>>>>>>>>>>>>>>9.99")) vcp
        trim(string(vpercPagas,"->>>>>>>>>>>>>>>>>9.99")) vcp
        trim(string(vtotPagas,"->>>>>>>>>>>>>>>>>9")) vcp
        skip.        
end.    

output close.
