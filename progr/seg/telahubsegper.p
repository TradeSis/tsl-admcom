{admcab.i}

def var pseguevenda as log.
def var pqtdvezes   as int.

{seg/defhubperfildin.i} 


find first ttsegprodu where ttsegprodu.procod = pprocod no-lock.
find first ttseguro   where ttseguro.id       = ttsegprodu.idseguro. 
find first ttperfil where ttperfil.id = ttseguro.PerfilTitularId no-error.

def var vnome as char format "x(35)".

update pcpf colon 15
    with frame fcab row 5 no-box color messages side-labels
    width 80.
    
find clien where clien.ciccgc = string(pcpf) no-lock no-error.
if avail clien
then do:
    vnome = clien.clinom.
    disp vnome no-label with frame fcab.
end.
else do:
    find clien where clien.ciccgc = string(pcpf,"99999999999") no-lock no-error.
    if avail clien
    then do:
        vnome = clien.clinom.
        disp vnome no-label with frame fcab.
    end.
    else do:
        run cpf.p (string(pcpf,"99999999999"), output sresp). 
        if not sresp 
        then do: 
            message "CPF INVALIDO" view-as alert-box. 
            undo. 
        end. 
    end.
end.    
    
    /*create ttcampos.
    ttcampos.id = "qteparcela".
    ttcampos.codigo = "qteparcela".
    create ttatributos.
    ttatributos.idpai=ttcampos.codigo.
    ttatributos.propriedade = "TIPO".
    ttatributos.valor = "NUMERICO".
**/

    for each ttcampos.
        if ttcampos.codigo =  "contratante.dadosPessoais.cpf" then ttcampos.conteudo = string(pcpf,"99999999999").
        if ttcampos.codigo =  "vendedor.id" then ttcampos.conteudo = string(pvencod).
        if ttcampos.codigo =  "vendedor.nome" then do:
            find first func where func.etbcod = setbcod and func.funcod = pvencod no-lock no-error.
            if avail func
            then ttcampos.conteudo = string(func.funnom).
        end.    
        if ttcampos.codigo =  "origemComercial.id" then ttcampos.conteudo = string(setbcod).
        if ttcampos.codigo =  "origemComercial.nome" then do:
                ttcampos.conteudo = "Filial " + string(setbcod,"9999").
        end.    
        
        
        if avail clien
        then do:
            if clien.dtnasc <> ?
            then
                if ttcampos.codigo =  "contratante.dadosPessoais.dataNascimento" then ttcampos.conteudo = 
                            string(year(clien.dtnasc),"9999") + "-" +
                                  string(month(clien.dtnasc),"99") + "-" +
                                  string(day(clien.dtnasc),"99").
            if ttcampos.codigo =  "contratante.dadosPessoais.nome" then ttcampos.conteudo = string(clien.clinom).
            if ttcampos.codigo =  "contratante.dadosPessoais.sexo" then ttcampos.conteudo =  trim(string(clien.sexo,"MASCULINO/FEMININO")). 
            if ttcampos.codigo =  "contratante.dadosPessoais.estadoCivil" then ttcampos.conteudo = "".
            if ttcampos.codigo =  "contratante.enderecos.logradouro" then ttcampos.conteudo = clien.endereco[1].
            if ttcampos.codigo =  "contratante.enderecos.numero" then ttcampos.conteudo = string(clien.numero[1]).
            if ttcampos.codigo =  "contratante.enderecos.complemento" then ttcampos.conteudo = clien.compl[1].
            if ttcampos.codigo =  "contratante.enderecos.bairro" then ttcampos.conteudo = clien.bairro[1].
            if ttcampos.codigo =  "contratante.enderecos.cidade" then ttcampos.conteudo = clien.cidade[1].
            if ttcampos.codigo =  "contratante.enderecos.estado" then ttcampos.conteudo = clien.ufecod[1].
            if ttcampos.codigo =  "contratante.enderecos.cep" then ttcampos.conteudo = string(int(clien.cep[1])) no-error.
            if length(clien.fone) = 10 or length(clien.fone) = 11
            then do:
                if ttcampos.codigo =  "contratante.contato.telefones.residencial.ddd" then ttcampos.conteudo = substring(string(clien.fone),1,2).
                if ttcampos.codigo =  "contratante.contato.telefones.residencial.numero" then ttcampos.conteudo  = substring(string(clien.fone),3).
            end.
            else do:
                if ttcampos.codigo =  "contratante.contato.telefones.celular.ddd" then ttcampos.conteudo = "".
                if ttcampos.codigo =  "contratante.contato.telefones.celular.numero" then ttcampos.conteudo = string(clien.entcidade[1]).
            end.
            
            if length(clien.entcidade[1]) = 11 or length(clien.entcidade[1]) = 10
            then do:
                if ttcampos.codigo =  "contratante.contato.telefones.celular.ddd" then ttcampos.conteudo    = substring(string(clien.entcidade[1]),1,2).
                if ttcampos.codigo =  "contratante.contato.telefones.celular.numero" then ttcampos.conteudo = substring(string(clien.entcidade[1]),3).
            end.
            else do:
                if ttcampos.codigo =  "contratante.contato.telefones.celular.ddd" then ttcampos.conteudo = "".
                if ttcampos.codigo =  "contratante.contato.telefones.celular.numero" then ttcampos.conteudo = string(clien.entcidade[1]).
            end.
            
            if ttcampos.codigo =  "itemSegurado.endereco.logradouro" then ttcampos.conteudo = clien.endereco[1].
            if ttcampos.codigo =  "itemSegurado.endereco.numero" then ttcampos.conteudo = string(clien.numero[1]).
            if ttcampos.codigo =  "itemSegurado.endereco.complemento" then ttcampos.conteudo = clien.compl[1].
            if ttcampos.codigo =  "itemSegurado.endereco.bairro" then ttcampos.conteudo = clien.bairro[1].
            if ttcampos.codigo =  "itemSegurado.endereco.cidade" then ttcampos.conteudo = clien.cidade[1].
            if ttcampos.codigo =  "itemSegurado.endereco.estado" then ttcampos.conteudo = clien.ufecod[1].
            if ttcampos.codigo =  "itemSegurado.endereco.cep" then ttcampos.conteudo = string(clien.cep[1]).
            /* 03/09/2021*/
            if ttcampos.codigo =  "contratante.dadosPessoais.rg.documento" then ttcampos.conteudo = string(clien.ciinsc).
            if ttcampos.codigo =  "contratante.contato.email" then ttcampos.conteudo = string(clien.zona).
            if ttcampos.codigo =  "contratante.dadosPessoais.nacionalidade" then ttcampos.conteudo = string(clien.nacion).
            
            def var cestcivil as char.
            cestcivil = if clien.estciv = 1 then "SOLTEIRO" else
                        if clien.estciv = 2 then "CASADO"   else 
                        if clien.estciv = 3 then "VIUVO"    else 
                        if clien.estciv = 4 then "DESQUITADO" else 
                        if clien.estciv = 5 then "DIVORCIADO" else 
                        if clien.estciv = 6 then "OUTROSo" 
                        else "OUTROS". 
            if ttcampos.codigo =  "contratante.dadosPessoais.estadoCivil" then ttcampos.conteudo = string(cestcivil).
                                                                                        
                                                                                        
        end.
    end. 


    if not avail clien
    then do:
        hide message no-pause.
        message "Cliente nao encontrato na base. Preencha o cadastro...".
    end.    

    pclicod = if avail clien then clien.clicod else 0.

    repeat:
        run seg/telahubsegdinam.p (output pseguevenda).
    
        if pseguevenda
        then do:

            run seg/simula.p (output pfincod, output pqtdvezes).
        
            if true /*pfincod <> 0*/
            then do:
                find finan where finan.fincod = pfincod no-lock no-error.
                if not avail finan 
                then do: 
                    undo.
                end.
                                                    
            message "Confirma fechamento venda, plano" pfincod finan.finnom update sresp.
                if not sresp
                then undo.
            
                run seg/fechaadesao.p (input pqtdvezes).
            
            end.    
        end.
        leave.
        
    end.        
