{admcab.i}

def input param pqtdvezes   as int.

def var pidPropostaAdesaoLebes as char.
def var par-rec as recid.

def var pseguevenda as log.
def var vfincod as int.
{seg/defhubperfildin.i} 

find first ttsegprodu where ttsegprodu.procod = pprocod no-lock.
find first ttseguro   where ttseguro.id       = ttsegprodu.idseguro. 
find first ttperfil where ttperfil.id = ttseguro.PerfilTitularId no-error.

for each ttadesao.
    delete ttadesao.
end.    
for each ttrespostas.
    delete ttrespostas.
end.
    

        create ttadesao.
        ttadesao.codigoLoja     = string(setbcod).
        ttadesao.dataTransacao  = string(year(today),"9999") + "-" +
                                  string(month(today),"99") + "-" +
                                  string(day(today),"99").
        ttadesao.canal          = "PDV".
        ttadesao.id             = ttseguro.id.
        ttadesao.modalidade     = "A_VISTA".
        ttadesao.CPF            = string(pcpf).
        
        for each ttcampos where ttcampos.idPAI = ttseguro.id.
            create ttrespostas.
            ttrespostas.idPai           = ttcampos.idPai.
            ttrespostas.campoCodigo     = ttcampos.codigo.
            ttrespostas.valor           = ttcampos.conteudo.
        end.
        
        
        
    pidPropostaAdesaoLebes = ?.
    
    run api/segbuscaadesao.p (output pidPropostaAdesaoLebes).

    if pidPropostaAdesaoLebes <> ?
    then do:
        find first ttproposta.
        ttproposta.valorTotal     = ttseguro.coberturaValor * if pqtdvezes > 0 then 1 else pqtdvezes.
        ttproposta.cpf            = pcpf.
        for each ttrespostas:
            if ttrespostas.campocodigo =  "contratante.dadosPessoais.nome" 
                then ttproposta.clinom = ttrespostas.valor.
            if ttrespostas.campocodigo =  "contratante.enderecos.logradouro" 
                then ttproposta.endereco = ttrespostas.valor.
            if ttrespostas.campocodigo =  "contratante.enderecos.numero" 
                then ttproposta.numero = ttrespostas.valor.
            if ttrespostas.campocodigo =  "contratante.enderecos.complemento" 
                then ttproposta.compl = ttrespostas.valor.
            if ttrespostas.campocodigo =  "contratante.enderecos.bairro" 
                then ttproposta.bairro = ttrespostas.valor.
            if ttrespostas.campocodigo =  "contratante.enderecos.cidade" 
                then ttproposta.cidade = ttrespostas.valor.
            if ttrespostas.campocodigo =  "contratante.enderecos.estado" 
                then ttproposta.ufecod = ttrespostas.valor.
            if ttrespostas.campocodigo =  "contratante.enderecos.cep" 
                then ttproposta.cep = ttrespostas.valor.
        end.
        
        find finan where finan.fincod = pfincod no-lock.
        find clien where clien.clicod = pclicod no-lock no-error.
        run seg/gerpre.p    (recid(finan),recid(clien),output par-rec).
        run seg/pedidop2k.p (par-rec).
        find plani where recid(plani) = par-rec no-lock.
        message color red/with 
            skip "PREVENDA GERADA" 
            skip(2) "PROPOSTA ADESAO" pidPropostaAdesaoLebes skip(1)
            skip "RESGATE P2K:" string(plani.numero) 
            skip(1) view-as alert-box title "". 
    
    end.
    else do:
        message "ocorreu um problema...".
        pause 1.
    end.
    
            
            

    
    
