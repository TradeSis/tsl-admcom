/*
#1 - 31.08.2017 - Nova novacao - novo filtro de modaildades
#2 - 09/05/2018 - Helio - Nova Formatacao para Transferencia de Contas
                        - Ira Baixar o titulo Original 
                                (TITDTPAG=today e TITSIT=EXC)
                          e CRIAR NOVO titulo COM CLIFOR NOVO.        
*/
{admcab.i}


def var wcon        like contrato.contnum format ">>>>>>>>>9".
def var vclicod     like contrato.clicod  format ">>>>>>>>>9".
def var vnovo       like clien.clicod     format ">>>>>>>>>9".
def var vcontnum    like contrato.contnum format ">>>>>>>>>9".

/* #2 */
def var recatu2 as recid.
def var vcpf like neuclien.cpf.
def var vtitabe as int.
def new shared temp-table tt-clien no-undo
    field CPF like neuclien.cpf
    field NOVOCPF as char format "x(14)"  
    field CLICOD  like neuclien.clicod    init ?
    field DATEXP like clien.datexp format "99/99/9999"
    field reg as int    format ">>9"
    field regabe as int format ">>9"
    field regtit as int format ">>9"
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field marca    as log column-label "*" format "*/ " init yes
    index cpf is unique primary cpf asc clicod asc
    index regabe regabe asc.

def new shared temp-table tt-clicods no-undo
    field cpf like neuclien.cpf
    field clicod as int format ">>>>>>>>>>9" 
    field datexp like clien.datexp format "99/99/9999"
    field NOVOCPF as char format "x(14)"  
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field sittit   as char format "x(03)" label "Tit"
    index cpf is unique primary cpf asc clicod asc.
def new shared temp-table tt-contratos
    field contnum like contrato.contnum  format ">>>>>>>>>9"
    field etbcod  like contrato.etbcod
    field modcod  like contrato.modcod
    field CLICOD  like contrato.clicod
    field titpar    as int format ">9" label "Parc"
    field titparabe as int format ">9" column-label "Abe"
    field titvlcob  as dec format ">>>>>>9.99" label "Valor"
    field titvlabe  as dec format ">>>>>>9.99" column-label "Abe"
    field conectada as log format "Sim/   " column-label "Conec"
    field existente as log format "Sim/   " column-label "Exist".
    

    
/* #2 */
 
repeat:
    for each tt-clien.
        delete tt-clien.
    end.
    for each tt-clicods.
        delete tt-clicods.
    end.
    for each tt-contratos.
        delete tt-contratos.
    end.

    assign vcontnum = 0.
    update vcontnum colon 15                  
            with frame f1 side-label centered title "Contrato"
            row 3.
                                              
    find contrato where contrato.contnum = vcontnum NO-LOCK no-error.
    if not available contrato
    then do: 
        message "Contrato nao cadastrado".
        undo,retry.
    end.
    find clien where clien.clicod = contrato.clicod no-lock no-error.
    display contrato.modcod
            contrato.etbcod
            contrato.clicod label "Cliente" colon 15 format ">>>>>>>>>9"
            clien.ciccgc    colon 15 label "CPF" 
            clien.clinom       no-label
            contrato.dtinicial colon 15 format "99/99/9999"
                    label "Dt Emissao"
            contrato.vltotal
            with frame f1.
    vtitabe = 0.
    vnovo = 0.
    disp vnovo label "Novo Cliente"
                    with frame f2 side-label width 80 row 9
                    no-box color messages.
    for each titulo where titulo.titnum = string(contrato.contnum) and
                          titulo.etbcod = contrato.etbcod and
                          titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.clifor = contrato.clicod and
                          titulo.modcod = contrato.modcod and
                          titulo.titdtpag = ? and
                          titulo.titsit   = "LIB" 
                          no-lock.
        display titulo.etbcod 
                titulo.titnum
                titulo.modcod
                titulo.tpcontrato
                titulo.titpar
                titulo.titdtven 
                titulo.titvlcob 
                titulo.titsit

                with frame f3 9 down  title " Parcelas Aberto " centered
                row 10 retain 8.
        vtitabe = vtitabe + 1.                
    
    find first tt-contratos where
            tt-contratos.etbcod  = titulo.etbcod and
            tt-contratos.contnum = int(titulo.titnum) and
            tt-contratos.modcod  = titulo.modcod and
            tt-contratos.clicod  = titulo.clifor
            no-error.
    if not avail tt-contratos
    then do:
        create tt-contratos.
            tt-contratos.etbcod  = titulo.etbcod.
            tt-contratos.contnum = int(titulo.titnum).
            tt-contratos.modcod  = titulo.modcod.
            tt-contratos.clicod  = titulo.clifor.
    end.               
    tt-contratos.titpar    = tt-contratos.titpar   + 1.
    tt-contratos.titvlcob  = tt-contratos.titvlcob + titulo.titvlcob.
    tt-contratos.titparabe = tt-contratos.titparabe + 
                if titulo.titdtpag = ?
                then 1
                else 0.
    tt-contratos.titvlabe = tt-contratos.titvlabe + 
                if titulo.titdtpag = ?
                then titulo.titvlcob
                else 0.
 
    end.

    if contrato.modcod <> "CRE" /* #1 */
    then do.
        message "Somente contratos CRE" view-as alert-box.
        next.
    end.
    
    find first tt-contratos no-error.
    if not avail tt-contratos
    then do:
        message "Titulos do Contrato Nao Encontrado".
        pause.
        undo.
    end.
     
    vnovo = 0. 
    message "Informe Novo Cliente."    .
    update vnovo  
        with frame f2.
    find clien where clien.clicod = vnovo no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao cadastrado".
        undo, retry.
    end.
    disp clien.clinom no-label with frame f2.
    message "Confirma Alteracao de contrato?" update sresp.
    if sresp = no
    then undo, retry.
    
    
    
    
    /** #2
        logica desativada
    *for each contnf where contnf.etbcod  = contrato.etbcod and
                          contnf.contnum = contrato.contnum:
        find first plani where plani.etbcod = contrato.etbcod and
                               plani.placod = contnf.placod no-error.
        if avail plani
        then do:
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat:
                do transaction:
                    movim.desti = vnovo.
                end. 
            end.
            do transaction:
                plani.desti = vnovo.
            end.
        end.
    end.                           
    
    *for each titulo where titulo.titnum = string(contrato.contnum) and
                          titulo.etbcod = contrato.etbcod and
                          titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.clifor = contrato.clicod and
                          titulo.modcod = "CRE".
        do transaction:
            titulo.clifor = vnovo.
            titulo.exportado = no.
        end.
    *end.
    *do transaction:
        find current contrato.
        contrato.clicod = vnovo.
    *end.
    
    *repeat on endkey undo:
        run alt-filial.
        leave.
    *end.    
    **/
    
    /** #2 Nova Logica */ 
   
    create tt-clien.
    vcpf = dec(clien.ciccgc) no-error.
    if vcpf = ?
    then vcpf = 0.
    tt-clien.cpf = vcpf.
    tt-clien.novocpf = clien.ciccgc.
    tt-clien.clicod  = clien.clicod.
    tt-clien.reg     = 1.
    tt-clien.regabe  = if vtitabe > 0
                       then 1
                       else 0.
    tt-clien.regtit  = if vtitabe > 0
                       then 1
                       else 0.
    tt-clien.marca   = no.
    
    create tt-clicods.
    tt-clicods.cpf = tt-clien.cpf.
    tt-clicods.clicod = contrato.clicod.
    tt-clicods.sittit  = if vtitabe > 0
                         then "ABE"
                         else "".
    recatu2 = recid(tt-clien).

    /*run cli/manhigcontrato_v1801.p (input recid(tt-clicods)).*/
        /* em teste */
    run cli/manhigcontrato_v1902.p (input recid(tt-clicods)).
        /* em teste */
        
    for each tt-clien.
        delete tt-clien.
    end.
    for each tt-clicods.
        delete tt-clicods.
    end.
    for each tt-contratos.
        delete tt-contratos.
    end.
                            
     
    message "Alteracao de Contrato encerrada.".
end.


/* #2 DESATIVADO
    nao ira mais alterar nas lojas
    ira apenas alterar na matriz
    e a tabela titulo ira
    BAIXAR (titdtpag=today and titsit = "EXC") 
    e CRIAR titulo NOVO com o NOVO CLIEN
*procedure alt-filial:
    def var vfilial as int.
    def var vip as char.
    def var vstatus as char.
    
    message "Informe a Filial para conectar" update vfilial.
    
    if vfilial > 0
    then do:
    vip = "filial" + string(vfilial,"999").
    
    message "Conectando...>>>>>   " vip.
  
    if connected ("suporte")
    then disconnect suporte.
    
    connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja.
    connect com -H value(vip) -S sdrebcom -N tcp -ld comloja.
    if not connected ("finloja")   or
       not connected ("comloja") 
    then do:
        vstatus = "FALHA NA CONEXAO COM A FILIAL".
    end.
    else do:        
*    run altifil.p ( fin.contrato.etbcod, fin.contrato.contnum, 
                    vnovo, output vstatus ). 
    /*
    output to altifil.log.
        put today "   "  vip format "x(15)" skip   
            vstatus format "x(60)" skip
            .
    output close.
    */             
    if connected ("finloja")
    then disconnect finloja.
    if connected ("comloja")
    then disconnect comloja.
    end.
    message color red/with
        vstatus view-as alert-box.
    end.
    connect suporte -N tcp -S sdrebsup -H linux.
    
*end procedure.
#2 */


