/* helio 28022022 - iepro */
def var vconta as int format ">>>>>>9"  label "Contagem".

def var vi as int.
def var vchar as char.
def var vint as int.
def var xvlpag as dec.
def var xvlcustas as dec.
def var vtitvlpag as dec.
def var vtitvlrcustas as dec.
def var vclifor as int.

def  shared temp-table tt-resumo no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field vlcobrado     as dec label "Vlr Documento"
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa"
    field titvlrcustas   as dec label "Vlr Custas"
    field vltaxa        as dec label "Vlr Taxa".

def  shared temp-table tt-bolteds no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field rec     as recid
    field Chave   as char format "x(20)"
    field vlcobrado     as dec label "Vlr Documento"
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa"
    field titvlrcustas   as dec label "Vlr Custas"
    field vltaxa        as dec label "Vlr Taxa".

def  shared var pchoose as char label "Forma".

def  shared var par-pagamento as log format "Sim/Nao" 
        label "Filtra Periodo Pagamento" init yes.
def  shared var par-dtpagini as date format "99/99/9999" label "de".
def  shared var par-dtpagfim as date format "99/99/9999" label "ate".


def  shared var par-banco  as log format "Sim/Nao" label "Filtra Banco"
    init no.
def  shared var par-numban as int format ">>>9" label "Banco".
def  shared var par-bancod as int format ">>>9" label "Banco".



    
def  shared var par-carteira  as log format "Sim/Nao" 
        label "Filtra Carteira" init no.
def  shared var par-bancart as int format ">>9" label "Carteira".
if par-pagamento
then do:
    if pchoose = "BOL" or pchoose = "GER"
    then do: 
        for each banboleto 
            where banboleto.dtpagamento >= par-dtpagini and
                  banboleto.dtpagamento <= par-dtpagfim
            no-lock
                by banboleto.dtpagamento desc
                on error undo, return. 
            run processa_boleto.
        end.
    end.
    if pchoose = "TED" or pchoose = "GER"
    then do: 
        for each banavisopag
            where banavisopag.dtemissao >= par-dtpagini and
                  banavisopag.dtemissao <= par-dtpagfim
            no-lock
                by banavisopag.dtpagamento desc.
    
            run processa_ted.
        end.
    end.        
end.
else do:
    if pchoose = "BOL" or pchoose = "GER"
    then do: 
        for each banboleto 
            no-lock
                by banboleto.dtpagamento desc. 
            run     processa_boleto.
        end.
    end.
    if pchoose = "TED" or pchoose = "GER"
    then do: 
        for each banavisopag
            no-lock
                by banavisopag.dtpagamento desc.
            run processa_ted.
        end.
    end.        
end.

procedure processa_boleto.

        if banboleto.dtpagamento = ? 
        then next.

        if par-banco
        then if par-bancod <> banboleto.bancod
             then next.
 
    vconta = vconta + 1.
    
    if  vconta < 10 or vconta mod 100 = 0 then    
    disp vconta 
         banboleto.dtemissao format "99/99/9999"
         banboleto.dtvencimento  
         banboleto.dtpagamento
         with centered side-labels 1 down.

    find last banbolorigem of banboleto no-lock no-error.
    
    create tt-bolteds.
    tt-bolteds.boltedforma = /*if banbolorigem.tabelaorigem = "CYBACPARCELA" then "NCY" else*/ "BOL".
    tt-bolteds.rec         = recid(banboleto) .
    tt-bolteds.bancod      = banboleto.bancod.
    tt-bolteds.bancart     = banboleto.bancart.
    tt-bolteds.chave       = string(banboleto.nossonumero).
    tt-bolteds.vlcobrado    = banboleto.vlcobrado.
    tt-bolteds.vlpagamento = banboleto.vlpagamento.
    tt-bolteds.vltaxa      = banboleto.vlservico.
        vclifor         = banboleto.clifor.
        vtitvlpag = 0.
        vtitvlrcustas = 0.
        for each banbolorigem of banboleto no-lock.
            if banbolorigem.tabelaorigem = "CYBACPARCELA"
            then do:
                find cybacparcela where 
                        cybacparcela.idacordo =                                  int(entry(1,banbolorigem.dadosOrigem)) and
                        cybacparcela.parcela  = 
                                int(entry(2,banbolorigem.dadosOrigem))
                     no-lock.
                find cybacordo of cybacparcela no-lock. 
                run cria-contrato (cybacordo.clifor,
                                   cybacparcela.contnum,
                                   cybacparcela.parcela,
                                   banboleto.dtpagamento,
                                  "BAIXA ENTRADA ACORDO CYB " + string(cybacordo.idacordo) + " BOLETO " + string(banboleto.nossonumero) ,
                                   output xvlcustas,
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
                vtitvlrcustas = vtitvlrcustas + xvlcustas.
            end.
            if banbolorigem.tabelaorigem = "api/acordo,negociacaoboleto"
            then do:
                find aoacparcela where 
                        aoacparcela.idacordo =                                  int(entry(1,banbolorigem.dadosOrigem)) and
                        aoacparcela.parcela  = 
                                int(entry(2,banbolorigem.dadosOrigem))
                     no-lock.
                find aoacordo of aoacparcela no-lock. 
                run cria-contrato (aoacordo.clifor,
                                   aoacparcela.contnum,
                                   aoacparcela.parcela,
                                       banboleto.dtpagamento,
                                   "BAIXA ENTRADA ACORDO ao " + string(aoacordo.idacordo)  + " BOLETO " + string(banboleto.nossonumero) ,
                                   output xvlcustas,
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
                vtitvlrcustas = vtitvlrcustas + xvlcustas.
            end.
            
            
            if banbolorigem.tabelaOrigem = "titulo" or (banbolorigem.tabelaOrigem = ? and banBolOrigem.ChaveOrigem  = "contnum,titpar")
            then do:
                run cria-contrato (banboleto.clifor,
                                   int(entry(1,banbolorigem.dadosorigem)),
                                   int(entry(2,banbolorigem.dadosorigem)),
                                   banboleto.dtpagamento,
                                   "BAIXA DE BOLETO " + string(banboleto.nossonumero) ,
                                   output xvlcustas,
                                   
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
                vtitvlrcustas = vtitvlrcustas + xvlcustas.
                
            end.
            if banbolorigem.tabelaorigem = "promessa" or (banbolorigem.tabelaOrigem = ? and  banbolorigem.ChaveOrigem = "idacordo,contnum,parcela") 
            then do:
                run cria-contrato (banboleto.clifor,
                                   int(entry(2,banbolorigem.dadosorigem)),
                                   int(entry(3,banbolorigem.dadosorigem)),
                                   banboleto.dtpagamento,
                                   "BAIXA DE BOLETO ACORDO CSL " + string(int(entry(1,banbolorigem.dadosorigem))),
                                   output xvlcustas,
                                   
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
                vtitvlrcustas = vtitvlrcustas + xvlcustas.
                
            end.
            
             
        end.

    tt-bolteds.vltitpag = vtitvlpag.
    tt-bolteds.titvlrcustas = vtitvlrcustas.
      
    find first tt-resumo where
        tt-resumo.boltedforma = tt-bolteds.boltedforma and
        tt-resumo.bancod      = tt-bolteds.bancod      and
        tt-resumo.bancart     = tt-bolteds.bancart
        no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.boltedforma = tt-bolteds.boltedforma.
        tt-resumo.bancod      = tt-bolteds.bancod     .
        tt-resumo.bancart     = tt-bolteds.bancart    .
    end.     
    tt-resumo.vlcobrado   = tt-resumo.vlcobrado   + banboleto.vlcobrado.
    tt-resumo.vlpagamento = tt-resumo.vlpagamento + banboleto.vlpagamento.
    tt-resumo.vltitpag = tt-resumo.vltitpag + vtitvlpag.
    tt-resumo.titvlrcustas = tt-resumo.titvlrcustas + vtitvlrcustas.
    
    tt-resumo.vltaxa = tt-resumo.vltaxa + banboleto.vlservico.
 
end procedure.



procedure processa_ted.
    
        if par-banco
        then if par-bancod <> banavisopag.bancod
             then next.
 
    vconta = vconta + 1.
    
    if  vconta < 10 or vconta mod 100 = 0 then    
    disp vconta 
         banavisopag.dtemissao format "99/99/9999"
         banavisopag.dtvencimento  
         with centered side-labels 1 down.


    create tt-bolteds.
    tt-bolteds.boltedforma = "TED".
    tt-bolteds.rec         = recid(banavisopag) .
    tt-bolteds.bancod      = banavisopag.bancod.
    tt-bolteds.bancart     = banavisopag.bancart.
    tt-bolteds.chave       = string(banavisopag.cdoperacao).
    tt-bolteds.vlcobrado    = banavisopag.vlcobrado.
    tt-bolteds.vlpagamento = banavisopag.vlcobrado /*pagamento.*/ .
   
        vclifor         = banavisopag.clifor.
        vtitvlpag = 0.
        for each banaviorigem of banavisopag no-lock.
            if banbolorigem.tabelaorigem = "CYBACPARCELA"
            then do:
                find cybacparcela where 
                        cybacparcela.idacordo =                                                                    int(entry(1,banbolorigem.dadosOrigem)) and
                        cybacparcela.parcela  = 
                                int(entry(2,banbolorigem.dadosOrigem))
                     no-lock.
                find cybacordo of cybacparcela no-lock.
                run cria-contrato (cybacordo.clifor,
                                   cybacparcela.contnum,
                                   cybacparcela.parcela,
                                   output xvlcustas,
                                   
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
            end.
            if banaviorigem.tabelaorigem = "TITULO"
            then do:
                run cria-contrato (banavisopag.clifor,
                                   int(entry(1,banaviorigem.dadosorigem)),
                                   int(entry(2,banaviorigem.dadosorigem)),
                                   output xvlcustas,
                                   
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
            end. 
        end.

    tt-bolteds.vltitpag = vtitvlpag.


    find first tt-resumo where
        tt-resumo.boltedforma = tt-bolteds.boltedforma and
        tt-resumo.bancod      = tt-bolteds.bancod      and
        tt-resumo.bancart     = tt-bolteds.bancart
        no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.boltedforma = tt-bolteds.boltedforma.
        tt-resumo.bancod      = tt-bolteds.bancod     .
        tt-resumo.bancart     = tt-bolteds.bancart    .
    end.     
    tt-resumo.vlcobrado   = tt-resumo.vlcobrado   + banavisopag.vlcobrado.
    tt-resumo.vlpagamento = tt-resumo.vlpagamento + 
                            banavisopag.vlcobrado. /*vlpagamento.*/
    tt-resumo.vltitpag = tt-resumo.vltitpag + vtitvlpag.
    
end procedure.

 
procedure cria-contrato. 
def input param vclicod  as int.
def input param vcontnum as int.
def input param vtitpar  as int.
def input param par-datamov as date.
def input param par-hispaddesc as char.
def output param par-titvlrcustas as dec.

def output param par-titvlpag as dec.

find contrato where contrato.contnum = vcontnum no-lock.
for each titulo where 
        titulo.empcod = 19 and titulo.titnat = no and
        titulo.etbcod = contrato.etbcod and
        titulo.modcod = contrato.modcod and
        titulo.clifor = contrato.clicod and
        titulo.titnum = string(contrato.contnum) and
        titulo.titpar = vtitpar
        no-lock.
    for each pdvdoc where pdvdoc.contnum = titulo.titnum and
                          pdvdoc.titpar  = titulo.titpar and
                          pdvdoc.datamov = par-datamov   and
                          pdvdoc.pstatus = yes and  
                          pdvdoc.hispaddesc   = par-hispaddesc
                          no-lock.
        par-titvlpag = par-titvlpag + pdvdoc.valor.
        par-titvlrcustas = par-titvlrcustas + pdvdoc.titvlrcustas.
   end.
end.

end procedure.




hide message no-pause.
message "Aguarde, Fazendo Estatisticas...".
