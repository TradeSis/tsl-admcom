{admcab.i}
def input parameter p-rec as recid.
def buffer btitulo for titulo.
find fatudesp where recid(fatudesp) = p-rec no-lock no-error.
if not avail fatudesp
then return.
if fatudesp.situacao = "A"
        then do:
            sresp = no.
            Message "Confirma Liberar?" update sresp.
            if sresp
            then do :
                for each titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = yes and
                    /*titulo.modcod = fatudesp.modcod and
                    titulo.etbcod = fatudesp.etbcod and*/
                    titulo.clifor = fatudesp.clicod and
                    titulo.titnum = string(fatudesp.fatnum) 
                    no-lock.
                    
                    if titulo.titdtemi = fatudesp.inclusao and
                       titulo.titsit = "BLO"
                    then do :
                       find btitulo of titulo no-error.
                       if avail btitulo
                       then btitulo.titsit = "LIB".
                    end.        
                end. 
                for each titudesp where
                         titudesp.clifor = fatudesp.clicod and
                         titudesp.titnum = string(fatudesp.fatnum) and
                         titudesp.titdtemi = fatudesp.inclusao
                         :

                    titudesp.titsit = "LIB".
                end.
                for each tituctb where
                         tituctb.clifor = fatudesp.clicod and
                         tituctb.titnum = string(fatudesp.fatnum) and
                         tituctb.titdtemi = fatudesp.inclusao
                         :

                    tituctb.titsit = "LIB".
                end.   

                fatudesp.situacao = "F".
                create tbcntger.
                assign
                    tbcntger.tipo_cnt = 1
                    tbcntger.data_cnt = today
                    tbcntger.hora_cnt = time 
                    tbcntger.documento_cnt = "DESPESA"
                    tbcntger.tabela_cnt = "fatudesp"
                    tbcntger.id_tabela_cmt = recid(fatudesp)
                    tbcntger.dtinclu_cnt = today
                    tbcntger.int1 = setbcod
                    tbcntger.int2 = sfuncod
                    .          
            end.
        end.
