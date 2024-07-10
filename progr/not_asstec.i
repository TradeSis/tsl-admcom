form
    tt-asstec.etbcod colon 11 label "Filial"
    tt-asstec.oscod  colon 40
    asstec.datexp

    tt-asstec.pladat colon 11 label "Data Venda"
                              validate (tt-asstec.pladat <> ?, "")
    tt-asstec.planum colon 40 label "Numero Venda"
                              validate (tt-asstec.planum > 0, "")
    fil-venda label "Filial Venda"

    tt-asstec.clicod colon 11 label "Cliente" format ">>>>>>>>>9"
                     validate(true,"")
    clien.clinom     format "x(30)" no-label
    asstec_aux.valor_campo no-label format "x(20)"
    
    tt-asstec.procod colon 11
    com.produ.pronom     no-label format "x(30)"
    vconfinado       colon 67 label "Confinado?"

    tt-asstec.apaser format "x(15)" colon 11
    v-imei-cel-aux   colon 45 label "IMEI Cel." format "x(20)"
    v-cel-doa-aux    label "DOA" format "Sim/Nao"

    tt-asstec.proobs  colon 11 label "Obs.Prod."
    tt-asstec.defeito colon 11
    tt-asstec.reincid colon 12
    tt-asstec.osobs   colon 11 label "Obs.OS"

    tt-asstec.forcod colon 11 label "Cod.Assis"
    forne.fornom     no-label  format "x(20)"
    forne.forfone    label "Fone"

    asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
    asstec.dtenvass colon 60 label "Dt.Envio Assistencia" 
    asstec.dtretass colon 25 label "Dt.Retirada Assistencia"
    asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 

    atu-estab.etbcod            colon 11 label "Loj Atual"
    atu-estab.etbnom            no-label

    etiqmov.etmovnom            colon 11 label "Prox Seq"
    asstec.nftnum

    with frame f-etiq overlay row 5 width 80 side-labels
         title "Ordem de Servico " + etiqope.etopenom.

