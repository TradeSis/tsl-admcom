def var hprevPagtoParcelaPeriodoEntrada as handle.
def var lcJsonSaida as longchar.
def var lokJson as log.

def var vdt as date. 
def var vcobnom like cobra.cobnom.

DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'prevPagtoParcelaPeriodo'
    FIELD chave as char     serialize-hidden  
    field dataExecucao  as date 
    index x is unique primary chave asc.

def temp-table tt-salcart no-undo serialize-name 'prevPagtoParcelaPeriodo'
    FIELD chave as char     serialize-hidden  
    field titdtven  like titulo.titdtven serialize-name 'dataPrevistaPagto'
    field cobnom    like cobra.cobnom    serialize-name 'carteira'
    field saldo     as dec format "->>>>>>>>>9.99" serialize-name 'valorPrevisto'
    index x is unique primary titdtven asc cobnom asc.


DEFINE DATASET prevPagtoParcelaPeriodoEntrada FOR ttstatus, tt-salcart
  DATA-RELATION for1 FOR ttstatus, tt-salcart         
    RELATION-FIELDS(ttstatus.chave,tt-salcart.chave) NESTED .

hprevPagtoParcelaPeriodoEntrada = DATASET prevPagtoParcelaPeriodoEntrada:HANDLE.

create ttstatus.
ttstatus.dataExecucao = today . /*string(year(today),"9999") +
                        string(month(today),"99")   +
                        string(day(today),"99"). */
                        
def var vi as int.
pause 0 before-hide.     
for each estab no-lock.
vi = 0.
for each modal where modal.modcod = "CRE" or
                     modal.modcod = "CP0" or
                     modal.modcod = "CP1" or
                     modal.modcod = "CP2" or
                     modal.modcod = "CPN"
                      no-lock.
for each titulo where titnat = no and titdtpag = ? 
        and titulo.etbcod = estab.etbcod 
        and titulo.modcod = modal.modcod
        no-lock.
    if titulo.titsit <> "LIB"
    then next.
    if titulo.titdtven = ?
    then next.
    
    vi = vi + 1.
    if vi = 1000 then leave.
     
    if titulo.titvlcob - titulo.titvlpag <= 0.01 or
       titulo.titvlcob - titulo.titvlpag = ?
    then next. 

    find cobra of titulo no-lock no-error.

    /*vdt = date(01,01,year(titulo.titdtven)).*/
    vdt = titulo.titdtven.             
    
    vcobnom = string(titulo.cobcod) + "-" + if avail cobra
                                            then cobra.cobnom
                                            else "?".
    
    find first tt-salcart 
        where 
            tt-salcart.titdtven = vdt and
            tt-salcart.cobnom   = vcobnom
            no-error.
    if not avail tt-salcart
    then do:
        create tt-salcart. 
        tt-salcart.titdtven = vdt.
        tt-salcart.cobnom = vcobnom.
    end.                  
    tt-salcart.saldo = tt-salcart.saldo + (titulo.titvlcob).
     
end.
end.
end.


lokJson = hprevPagtoParcelaPeriodoEntrada:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE) no-error.
if lokJson
then do: 
    
      create verusjsonout.
      ASSIGN
        verusjsonout.interface     = "prevPagtoParcelaPeriodo".
        verusjsonout.jsonStatus    = "NP".
        verusjsonout.dataIn        = today.
        verusjsonout.horaIn        = time.
    
        copy-lob from lcJsonSaida to verusjsonout.jsondados.
    
    
    hprevPagtoParcelaPeriodoEntrada:WRITE-JSON("FILE","prevPagtoParcelaPeriodoEntrada.json", true).
    
end.    
/*


for each tt-salcart.
    disp tt-salcart.
    disp tt-salcart.saldo (total).
end.
*/
