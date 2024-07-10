/* CONFAGE.xml */

def input param p-arquivo   as char.
def input param p-diretorio as char.

DEFINE VARIABLE hPDS    AS HANDLE  NO-UNDO.
DEFINE VARIABLE lReturn AS LOGICAL NO-UNDO.

DEFINE TEMP-TABLE NFe NO-UNDO 
    FIELD CHAVE as char serialize-hidden.

DEFINE TEMP-TABLE infNFe NO-UNDO 
    FIELD CHAVE as char serialize-hidden.
    
DEFINE TEMP-TABLE ide NO-UNDO 
    FIELD CHAVE as char serialize-hidden
    field cUF   as char
    field cNF   as char format "x(12)" 
    field natOp as char format "x(40)"
    field mod   as char                
    field serie as char
    field nNF   as char format "x(12)"
    field dhEmi as char format "x(10)"
    field tpNF  as char
    field idDest    as char
    field cMunFG    as char
    field tpImp as char
    field tpEmis    as char
    field cDV   as char
    field tpAmb as char
    field finNFe    as char
    field indFinal  as char
    field indPres   as char
    field procEmi   as char
    field verProc   as char.

def temp-table emit no-undo
    FIELD   CHAVE as char serialize-hidden
    field   CNPJ    as char format "x(14)"
    field   xNome   as char format "x(40)".
def temp-table dest no-undo
    FIELD   CHAVE as char serialize-hidden
    field   CNPJ    as char format "x(14)"
    field   xNome   as char format "x(40)".
def temp-table det no-undo
    field CHAVE as char    serialize-hidden.
def temp-table     prod no-undo
    field CHAVE as char serialize-hidden
    field cProd as char format "x(12)"
    field cEAN  as char format "x(20)"
    field xProd as char format "x(30)"    
    field qCom  as char format "x(12)"
    field vProd as char format "x(14)".
    
    
DEFINE DATASET nfeProc FOR NFe, infNFe, ide, emit, dest , det, prod.


    hPDS = DATASET nfeProc:HANDLE.

    hide message no-pause.
/*    message p-diretorio + "/" + p-arquivo.*/

    
    lReturn = hPDS:READ-XML ("FILE",p-diretorio + "/" + p-arquivo, "EMPTY",
                             ?, no). 

find first ide no-error.
output to value("/admcom/tmp/edi/csv/NOTA_" + ide.cNF + ".txt").
    
            for each ide.
                disp ide
                 except chave cuf mod tpnf iddest tpimp tpemis cdv tpamb finnfe indfinal indpres procemi         cmunfg .
            end.
                for each emit.
                    disp emit
                    except chave
                    with title "Emitente" no-underline col 5.
                end.
                for each dest.
                    disp dest
                    except chave
                                        with title "Destinatario" no-underline col 5.

                end.                
                for each prod.
                    disp prod
                    except chave
                                        with title "Produtos" no-underline col 10.

                    end.
output close.                
