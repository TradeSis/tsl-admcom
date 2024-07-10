/* Lote Access Atualizacao cadastral da Lebes para Access */
{admcab.i}

def input-output parameter par-lotcre as recid.
def input parameter par-lotcretp as recid.
def input parameter par-tipo     as char.

def var vdtini      as date format "99/99/9999".
def var vdtfim      as date format "99/99/9999".
def var vdata       as date.
def var vselecao    as char.
def var vetbcod     like estab.etbcod.
def var vvlrtitulo as dec.
def var varquivo as char.
def buffer bestab for estab.

find lotcretp where recid(lotcretp) = par-lotcretp no-lock.


if par-tipo = " selecao "
then do.
    
    do on error undo, retry:
          update vdtini to 34  label "Data Inicial"
                 vdtfim label "Data Final" with frame f1 side-label width 80.
          if  vdtini > vdtfim
          then do:
                message color red/with 
                "Data inválida" view-as alert-box.
                undo.
          end.
    end.
    
    vselecao = string(vdtini) + " a " + string(vdtfim) .

    for each lotcreag no-lock, 
    first cpclien where cpclien.clicod = lotcreag.clfcod and 
                        cpclien.datalt >= vdtini and 
                        cpclien.datalt <= vdtfim
                        no-lock.
        
        find clien of cpclien where clien.dtcad <> cpclien.datalt no-lock.
        for each lotcretit where lotcretit.ltcrecod = lotcreag.ltcrecod and
                           lotcretit.clfcod   = lotcreag.clfcod and
                           lotcretit.spcretorno = "acionamento de cobranca"
                           no-lock.
                                          
            /*acionamento de cobranca filtra apenas os titulos que tiveram                  retorno da access*/               
                                          
            find titulo where                                
                    titulo.empcod = wempre.empcod                   
                    and titulo.titnat = no               
                    and titulo.modcod = "CRE"            
                    and titulo.modcod = lotcretit.modcod 
                    and titulo.etbcod = lotcretit.etbcod 
                    and titulo.clifor = lotcreag.clfcod 
                    and titulo.titnum = lotcretit.titnum 
                    and titulo.titpar = lotcretit.titpar 
                    and titulo.cobcod = 11 /*ACCESS*/
                    no-lock no-error.                             
                    
            if not avail titulo then next.

            if par-lotcre = ?
            then do.
                run lotcria.p (input recid(lotcretp), output par-lotcre).
                do on error undo.
                    find lotcre where recid(lotcre) = par-lotcre exclusive.
                    lotcre.ltselecao = vselecao.
                end.
                find current lotcre no-lock.
            end.
                    
            run lotagcria.p (input par-lotcre,
                         input recid(titulo)).
            run lottitc.p   (input par-lotcre,
                         input recid(titulo),
                         ?,
                         "" /* por cliente, sitcli.titnum = "" */).
        end. /*lotcretit*/
        
    end. /*lotcreag*/

end. /*par-tipo*/
    
if par-lotcre <> ?
then run value(lotcretp.valida + ".p") (input par-lotcre).

