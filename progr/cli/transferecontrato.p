def input parameter pcpf     as dec.
def input parameter pcontnum as int.
def input parameter petbcod  as int.
def input parameter pmodcod  as char.
def input parameter pclicod  as int.
def input parameter pprincipal as int.
def output parameter pok      as log.

pok = no.

def buffer NOVO-titulo for titulo.

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


            TITULO.titobs[2]    = titulo.titobs[2] + 
                           (if titulo.titobs[2] = ""
                            then ""
                            else "|") +
                        "ORIGINAL CLIEN=" + string(pclicod).        
            

            find first NOVO-titulo where
                NOVO-titulo.empcod = 19 and
                NOVO-titulo.titnat = no and
                NOVO-titulo.etbcod = titulo.etbcod and   
                NOVO-titulo.clifor = pprincipal and
                NOVO-titulo.modcod = titulo.modcod and
                NOVO-titulo.titnum = titulo.titnum and
                NOVO-titulo.titpar = titulo.titpar
                exclusive no-error.      
                
            if not avail NOVO-titulo
            then do:
                create NOVO-titulo.
            end.    
            buffer-copy titulo except clifor titdtpag titsit
                        to NOVO-titulo.
            NOVO-titulo.titsit   = "LIB".
            NOVO-titulo.titdtpag = ?.
            NOVO-titulo.clifor   = pprincipal.


            TITULO.titdtpag     = TODAY.
            TITULO.titsit       = "EXC".
            TITULO.exportado    = yes.
            TITULO.titobs[2]    = titulo.titobs[2] + 
                           (if titulo.titobs[2] = ""
                            then ""
                            else "|") +
                        "TRANSFERIDO CLIEN=" + string(pprincipal).        

            run Loga ("TITULO",
                      "CONTNUM,TITPAR",
                      string(pcontnum) + "," + 
                        string(titulo.titpar),
                      "CLIFOR",
                      string(pclicod),
                      string(pprincipal)).
                
            
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