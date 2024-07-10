def input parameter p-recid as recid.
def var vpag as log.

find NF_Serv_Capa where recid(NF_Serv_Capa) = p-recid no-error.
if avail NF_Serv_Capa
then do:
    find first fatudesp where fatudesp.etbcod = int(NF_Serv_Capa.Cod_Estab) and
                    fatudesp.clicod = int(NF_Serv_Capa.Cod_Parceiro) and
                    fatudesp.fatnum = int(NF_Serv_Capa.Num_Docto)
                    no-lock no-error.
    if avail fatudesp
    then do:
        vpag = no.
        for each  titulo where titulo.empcod   = 19 and
                            titulo.titnat   = yes       and
                            titulo.modcod   = fatudesp.modcod and
                            titulo.etbcod   = fatudesp.etbcod  and
                            titulo.clifor   = fatudesp.clicod  and
                            titulo.titnum   = string(fatudesp.fatnum)
                            no-lock:
            if  titulo.titsit = "CON" or
                titulo.titsit = "PAG"
            then do:
                vpag = yes.
                leave.
            end.
        end.   
        if vpag = yes
        then do:
            message color red/with
            "Impossivel excluir documento." skip
            "Existe parcela confirmada ou paga." skip
            "Entrar em contato com setor financeiro."
            view-as alert-box. 
            return.
        end.
    end.
        
    for each    NF_Serv_itens where 
            NF_Serv_Itens.Num_Docto = NF_Serv_Capa.Num_Docto and
            NF_Serv_Itens.Num_Serie = NF_Serv_Capa.Num_Serie and
            NF_Serv_Itens.Data_Emissao = NF_Serv_Capa.Data_Emissao and
            NF_Serv_Itens.Tipo_Operacao = NF_Serv_Capa.Tipo_Operacao and
            NF_Serv_Itens.Cod_Modelo = NF_Serv_Capa.Cod_Modelo 
            :

        for each    NF_Serv_Imposto_Ret where
                NF_Serv_Imposto_Ret.Num_Docto = NF_Serv_Itens.Num_Docto and
                NF_Serv_Imposto_Ret.Num_Serie = NF_Serv_Itens.Num_Serie and
                NF_Serv_Imposto_Ret.Data_Emissao = 
                                    NF_Serv_Itens.Data_Emissao and
                NF_Serv_Imposto_Ret.Tipo_Operacao = 
                                    NF_Serv_Itens.Tipo_Operacao and
                NF_Serv_Imposto_Ret.Cod_Modelo = NF_Serv_Itens.Cod_Modelo and
                NF_Serv_Imposto_Ret.Cod_Item = NF_Serv_Itens.Cod_Item 
                :
            delete NF_Serv_Imposto_Ret.        
        end.         
        
        for each    NF_Serv_Item_Proc where
                NF_Serv_Item_Proc.Num_Docto = NF_Serv_Itens.Num_Docto and
                NF_Serv_Item_Proc.Num_Serie = NF_Serv_Itens.Num_Serie and
                NF_Serv_Item_Proc.Data_Emissao = NF_Serv_Itens.Data_Emissao and
                NF_Serv_Item_Proc.Tipo_Operacao = 
                                        NF_Serv_Itens.Tipo_Operacao and
                NF_Serv_Item_Proc.Cod_Modelo = NF_Serv_Itens.Cod_Modelo and
                NF_Serv_Item_Proc.Cod_Item = NF_Serv_Itens.Cod_Item 
                :
            delete NF_Serv_Item_Proc.
        end.

        for each    NF_Serv_CPG where
                NF_Serv_CPG.Num_Docto = NF_Serv_Itens.Num_Docto and
                NF_Serv_CPG.Num_Serie = NF_Serv_Itens.Num_Serie and
                NF_Serv_CPG.Data_Emissao = NF_Serv_Itens.Data_Emissao and
                NF_Serv_CPG.Tipo_Operacao = NF_Serv_Itens.Tipo_Operacao and
                NF_Serv_CPG.Cod_Modelo = NF_Serv_Itens.Cod_Modelo and
                NF_Serv_CPG.Cod_Item =  NF_Serv_Itens.Cod_Item
                : 
            delete NF_Serv_CPG.         
        end.
        delete NF_Serv_Itens.
    end.                                       
    find first fatudesp where fatudesp.etbcod = int(NF_Serv_Capa.Cod_Estab) and
                    fatudesp.clicod = int(NF_Serv_Capa.Cod_Parceiro) and
                    fatudesp.fatnum = int(NF_Serv_Capa.Num_Docto)
                     no-error.
    if avail fatudesp
    then do:
        for each  titulo where titulo.empcod   = 19 and
                            titulo.titnat   = yes       and
                            titulo.modcod   = fatudesp.modcod and
                            titulo.etbcod   = fatudesp.etbcod  and
                            titulo.clifor   = fatudesp.clicod  and
                            titulo.titnum   = string(fatudesp.fatnum)
                            :
            delete titulo.
        end.                        
        for each  titudesp where titudesp.empcod   = 19 and
                            titudesp.titnat   = yes       and
                            titudesp.modcod   = fatudesp.modcod and
                            titudesp.etbcod   = fatudesp.etbcod  and
                            titudesp.clifor   = fatudesp.clicod  and
                            titudesp.titnum   = string(fatudesp.fatnum)
                            :
            delete titudesp.
        end.  
        for each  tituctb where tituctb.empcod   = 19 and
                            tituctb.titnat   = yes       and
                            tituctb.modcod   = fatudesp.modcod and
                            tituctb.etbcod   = fatudesp.etbcod  and
                            tituctb.clifor   = fatudesp.clicod  and
                            tituctb.titnum   = string(fatudesp.fatnum)
                            :
            delete tituctb.                    
        end. 
        delete fatudesp.
    end.
    delete NF_Serv_Capa.
end.