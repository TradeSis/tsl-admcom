/* helio 27062022 pacote de melhorias cobranca - 319608 */

def input param     pctmcod      as char.
def input parameter pcpf     as dec.
def input parameter pcontnum as int.
def input parameter petbcod  as int.
def input parameter pmodcod  as char.
def input parameter pclicod  as int.
def input parameter pprincipal as int.
def input param pnovafil as int.

def output parameter pok      as log.

def var pfilcod  as int.

{admcab.i}

def var vvalor as dec.
def var prec as recid.
def var vseqreg as int.

pok = no.


find first pdvtmov where pdvtmov.ctmcod = pctmcod no-lock.
 
find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
 
run fin/cmdinc.p (recid(cmon), recid(pdvtmov), output prec).

find pdvmov where recid(pdvmov) = prec no-lock.



do on error undo:

    find contrato where 
        contrato.contnum = pcontnum
          exclusive no-wait no-error.
    if avail contrato
    then do:
            contrato.clicod = pprincipal. 
            run Loga ("CONTRATO",
                      "CONTNUM",
                      string(pcontnum),
                      "CLICOD",
                      string(pclicod),
                      string(pprincipal)).
            if pnovafil > 0
            then do:
                pfilcod = contrato.etbcod.
                contrato.etbcod = pnovafil.
                
                run Loga ("CONTRATO",
                          "CONTNUM",
                          string(pcontnum),
                          "FILIAL",
                          string(pfilcod),
                          string(pnovafil)).
            end.                      
    end.
    for each titulo where   
            titulo.empcod = 19 and
            titulo.titnat = no and
            titulo.etbcod = petbcod and   
            titulo.clifor = pclicod and
            titulo.modcod = pmodcod and
            titulo.titnum = string(pcontnum) and
            titulo.titsit = "LIB" and
            titulo.titdtpag = ?
            exclusive.
        if titulo.contnum = ?
         then titulo.contnum = int(titulo.titnum).

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
            pdvdoc.hispaddesc        = "HIGIENIZACAO".

            pdvdoc.Valor             = titulo.titvlcob.
            pdvdoc.titvlcob          = titulo.titvlcob.

            vvalor = pdvdoc.valor.
            
            run fin/baixatitulo.p (recid(pdvdoc),
                                   recid(titulo)).

            titulo.clifor   = pprincipal.
            
            if pnovafil > 0
            then do:
                titulo.etbcod   = pnovafil. 
            end.
            
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
            pdvdoc.hispaddesc        = "HIGIENIZACAO".

            pdvdoc.Valor             = vvalor * -1.
            pdvdoc.titvlcob          = vvalor * -1.
        
            run fin/baixatitulo.p (recid(pdvdoc),
                                   recid(titulo)).


            titulo.titobs[2]    = titulo.titobs[2] + 
                           (if titulo.titobs[2] = ""
                            then ""
                            else "|") +
                        "ORIGINAL CLIEN=" + string(pclicod).        
                        
                        
            run Loga ("TITULO",
                      "CONTNUM,TITPAR",
                      string(pcontnum) + "," + 
                        string(titulo.titpar),
                      "CLIFOR",
                      string(pclicod),
                      string(pprincipal)).

            if pnovafil > 0
            then do:
                titulo.titobs[2]    = titulo.titobs[2] + 
                           (if titulo.titobs[2] = ""
                            then ""
                            else "|") +
                        "ORIGINAL FILIAL=" + string(pfilcod).        
            
                run Loga ("TITULO",
                          "CONTNUM,TITPAR",
                          string(pcontnum)+ "," + 
                        string(titulo.titpar),
                          "FILIAL",
                          string(pfilcod),
                          string(pnovafil)).
            end.                      

        pok = yes.                
            
    end.
    for each contnf where 
             contnf.etbcod  = petbcod and
             contnf.contnum = pcontnum:
        find first plani where 
                   plani.etbcod = contnf.etbcod and
                   plani.placod = contnf.placod no-error.
        if avail plani
        then do:
            for each movim where 
                                movim.etbcod = plani.etbcod and
                                movim.placod = plani.placod and
                                movim.movtdc = plani.movtdc and
                                movim.movdat = plani.pladat:
                    movim.desti = pprincipal.                                          end. 

                plani.desti = pprincipal.
                run Loga ("PLANI",
                      "ETBCOD,PLACOD",
                      string(petbcod) + "," + 
                        string(plani.placod),
                      "DESTI",
                      string(pclicod),
                      string(pprincipal)).
                
        end.
    end.                           
end.



procedure Loga.
def input param par-tabela as char.
def input param p-camposchave as char.
def input param p-dadoschave  as char.
def input param par-campo     as char.
def input param p-dadoori     as char.
def input param par-dadonovo  as char.


hide message no-pause.
message "Aguarde.... ".

do on error undo.
    find first neuclienhigie where
        neuclienhigie.cpfcnpj = pcpf and
        neuclienhigie.data    = today and
        neuclienhigie.hora    = time
    no-lock no-error.
  if avail neuclienhigie
  then pause 1 no-message.
  CREATE NEUCLIENhigie.
  ASSIGN
    NeuClienHigie.CpfCnpj     = pCpf
    NeuClienHigie.Data        = today
    NeuClienHigie.Hora        = time
    NeuClienHigie.TabelaAlt   = par-tabela
    NeuClienHigie.CamposChave = p-CamposChave
    NeuClienHigie.DadosChave  = p-DadosChave
    NeuClienHigie.CampoAlt    = par-campo
    NeuClienHigie.DadoOri     = p-DadoOri
    NeuClienHigie.DadoNovo    = par-DadoNovo.
END.

end procedure.