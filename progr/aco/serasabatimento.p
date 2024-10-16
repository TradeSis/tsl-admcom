
/* Programa de carga */

for each serasacli no-lock.

    for each titulo where titulo.clifor = serasacli.clicod and titdtpag = ? and titdtven < today - 60 no-lock.
        if (titulo.modcod = "CRE" and titulo.tpcontrato = "") or titulo.modcod = "CP1" or titulo.modcod = "CP2"
        then.
        else next.
        if titulo.titsit = "LIB"
        then.
        else next.
        /* se chegar aqui, é porque esta elegivel */
        leave.       
    end.
    /* se passou vai para o arquivo */

    /* se não passou , tem que deletar do serasa cli */
    
end.
/* Gera arquivo para os não envidos */
/* saida /admcom/tmp/serasa/   */


