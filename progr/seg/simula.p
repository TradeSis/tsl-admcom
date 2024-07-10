{admcab.i}
def output param vfincod as int.
def output param vqtdvezes as int.

{seg/defhubperfildin.i}

find first ttsegprodu .
find first ttseguro .

def var vhostname as char.
input through hostname.
import vhostname.
input close.

    find first ttcampos where ttcampos.codigo =  "itemSegurado.quantidadeParcelas" no-error.
    vqtdvezes = if avail ttcampos
                then int(ttcampos.conteudo)
                else 0. 
    
    if vhostname = "SV-CA-DB-DEV" or 
       vhostname = "SV-CA-DB-QA" 
    then vfincod = 125.
    else do:
         run seg/simula_parcela_hubseg.p( 
            input pprocod,
            input vqtdvezes,
            output vfincod).
    end.
