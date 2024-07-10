def var vconta as int format ">>>>>>9"  label "Contagem".

def var vi as int.
def var vchar as char.
def var vint as int.
def var xvlpag as dec.
def var vtitvlpag as dec.
def var vclifor as int.

def  shared temp-table tt-resumo no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field vlcobrado     as dec label "Vlr Documento"
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa"
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
                by banboleto.dtpagamento desc. 
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

        if banboleto.dtpagamento = ? and
           banboleto.dtbaixa     = ?
        then next.

        if par-banco
        then if par-bancod <> banboleto.bancod
             then next.
 
    vconta = vconta + 1.
    
    if  vconta < 10 or vconta mod 100 = 0 then    
    disp vconta 
         banboleto.dtemissao format "99/99/9999"
         banboleto.dtvencimento  
         with centered side-labels 1 down.


    create tt-bolteds.
    tt-bolteds.boltedforma = "BOL".
    tt-bolteds.rec         = recid(banboleto) .
    tt-bolteds.bancod      = banboleto.bancod.
    tt-bolteds.bancart     = banboleto.bancart.
    tt-bolteds.chave       = string(banboleto.nossonumero).
    tt-bolteds.vlcobrado    = banboleto.vlcobrado.
    tt-bolteds.vlpagamento = banboleto.vlpagamento.
    tt-bolteds.vltaxa      = banboleto.vlservico.
        vclifor         = banboleto.clifor.
        vtitvlpag = 0.
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
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
            end.
            if banbolorigem.tabelaorigem = "TITULO"
            then do:
                run cria-contrato (banboleto.clifor,
                                   int(entry(1,banbolorigem.dadosorigem)),
                                   int(entry(2,banbolorigem.dadosorigem)),
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
    tt-resumo.vlcobrado   = tt-resumo.vlcobrado   + banboleto.vlcobrado.
    tt-resumo.vlpagamento = tt-resumo.vlpagamento + banboleto.vlpagamento.
    tt-resumo.vltitpag = tt-resumo.vltitpag + vtitvlpag.
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
                                   output xvlpag).
                vtitvlpag = vtitvlpag + xvlpag.
            end.
            if banaviorigem.tabelaorigem = "TITULO"
            then do:
                run cria-contrato (banavisopag.clifor,
                                   int(entry(1,banaviorigem.dadosorigem)),
                                   int(entry(2,banaviorigem.dadosorigem)),
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
def output param par-titvlpag as dec.

find contrato where contrato.contnum = vcontnum no-lock.
for each titulo where 
        titulo.empcod = 19 and titulo.titnat = no and
        titulo.etbcod = contrato.etbcod and
        titulo.modcod = contrato.modcod and
        titulo.clifor = vcLICOD and
        titulo.titnum = string(contrato.contnum) and
        titulo.titpar = vtitpar
        no-lock.

        par-titvlpag = titulo.titvlpag.

end.

end procedure.




hide message no-pause.
message "Aguarde, Fazendo Estatisticas...".
