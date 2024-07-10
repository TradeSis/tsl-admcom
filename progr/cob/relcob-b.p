{admcab.i}


def input param par-rec as recid.
    

def var vordem as char format "x(20)" extent 4
        initial [" 1. NOME     ",
                 " 2. RUA      ",
                 " 3. BAIRRO   ",
                 " 4. CIDADE   "].

def var ii as int.
    
def new shared temp-table tt-extrato no-undo
    field rec as recid
    field ord as int
    
    field rua     like clien.endereco[1]
    field bairro  like clien.bairro[1]
    field cidade  like clien.cidade[1]
    
    index ind-1 ord
    
    index i-rua     rua
    index i-bairro  bairro
    index i-cidade  cidade.


def var vdata like cobranca.cobgera initial today.

def temp-table tt-cobranca no-undo
    field rec as recid
    field nome    like clien.clinom
    
    index cliente nome.
    
def var tot-vencer  like plani.platot format ">,>>>,>>9.99".
def var tot-vencido like plani.platot format ">>,>>>,>>9.99".
def var tot-saldo   like plani.platot format ">>,>>>,>>9.99".
def var tot-cli     as int.
def var cob-tot     as int extent 3.


def buffer bcobranca for cobranca.
def stream stela.
def var vpdf as char no-undo.

def var vnomearquivo as char.
def var varquivo as char format "x(20)".
def var saldo-vencer like plani.platot.
def var saldo-vencido like plani.platot.

def var vetbcod like estab.etbcod.
def var vcobcod like cobfil.cobcod.

find cobdata where recid(cobdata) = par-rec no-lock.
find cobfil of cobdata no-lock.
vcobcod = cobdata.cobcod.
vetbcod = cobdata.etbcod.

    for each tt-extrato:
        delete tt-extrato.
    end.

    vnomearquivo = "relcob_" + string(vetbcod) + "_" + string(vcobcod) + "_" + replace(string(time,"HH:MM:SS"),":","").
    if opsys = "UNIX"
    then varquivo = "../relat/" + vnomearquivo + ".txt".
    else varquivo = "l:~\relat~\" + vnomearquivo.
    
    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""relcob""
            &Nom-Sis   = """SISTEMA DE COBRANCA"""
            &Tit-Rel   = """COBRADOR:  "" +
                            string(cobdata.cobcod,""999"") + ""  "" +
                            string(cobfil.cobnom,""x(20)"") + "" Filial: "" +
                            string(cobfil.etbcod,""999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    cob-tot[01] = 0.
    cob-tot[02] = 0.
    cob-tot[03] = 0.
    for each cobranca of cobdata no-lock:
        if cobcod = 99
        then next.
        if cobeta = 0
        then next.
        cob-tot[cobranca.cobeta] = cob-tot[cobranca.cobeta] + 1.
    end.
    
        
    for each tt-cobranca.
        
        delete tt-cobranca.
        
    end.
        
    
    
    for each cobranca of cobdata no-lock.

         find clien where clien.clicod = cobranca.clicod no-lock no-error.
         if not avail clien
         then next.
         
         create tt-cobranca.
         assign tt-cobranca.rec  = recid(cobranca)
                tt-cobranca.nome = clien.clinom.
                
    end.


    
    
    ii = 0.
    for each tt-cobranca use-index cliente:
    
        find cobranca where recid(cobranca) = tt-cobranca.rec no-lock.
        
        saldo-vencer = 0.
        saldo-vencido = 0.

        for each fin.titulo where fin.titulo.clifor = cobranca.clicod no-lock:

            if fin.titulo.titsit = "LIB"
            then do:
                if fin.titulo.titdtven >= today
                then saldo-vencer = saldo-vencer + fin.titulo.titvlcob.
                if fin.titulo.titdtven < today
                then saldo-vencido = saldo-vencido + fin.titulo.titvlcob.
            end.
            output stream stela to terminal.
                display stream stela
                        fin.titulo.clifor
                        fin.titulo.titnum
                        fin.titulo.titpar with frame ff side-label 1 down.
                pause 0.
            output stream stela close.
        end. 
        
        
        

        if saldo-vencido = 0
        then next.
                 
        find clien where clien.clicod = cobranca.clicod no-lock.
        display clien.clicod
                clien.clinom
                clien.fone
                cobranca.cobgera column-label "Data Gerada"
                cobranca.cobatr column-label "Dias!Atraso"
                saldo-vencer  format ">,>>>,>>9.99"
                            column-label "Saldo!Vencer"
                saldo-vencido format ">,>>>,>>9.99"
                            column-label "Saldo!Vencido"
                (saldo-vencer + saldo-vencido)
                              format ">,>>>,>>9.99"
                        column-label "Saldo!Total"
                        with frame f2 down width 200.
        
        tot-vencer  = tot-vencer + saldo-vencer.
        tot-vencido = tot-vencido + saldo-vencido.
        tot-saldo   = saldo-vencer + saldo-vencido.
        tot-cli     = tot-cli + 1.
    
             
        find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
        if not avail tt-extrato 
        then do: 
            ii = ii + 1.
            create tt-extrato. 
            assign tt-extrato.rec = recid(clien) 
                   tt-extrato.ord = ii
                   
                   tt-extrato.rua    = clien.endereco[1]
                   tt-extrato.bairro = clien.bairro[1]
                   tt-extrato.cidade = clien.cidade[1].
                                      
        end.

 
    
    end.
    
    put skip fill("-",130) format "x(130)"
        tot-vencer                   to 84
        tot-vencido
        tot-saldo
        tot-cli                       skip
        fill("-",130) format "x(130)" skip.

    assign tot-vencer  = 0
           tot-vencido = 0
           tot-saldo   = 0
           tot-cli     = 0.

     
    
    
    output close.
    
    if sremoto /* #3 */
    then do:
        run pdfout.p (input varquivo,
                  input "/admcom/kbase/pdfout/",
                  input vnomearquivo + ".pdf",
                  input "Portrait",
                  input 7.4,
                  input 1,
                  output vpdf).
    end.
    else 
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo , "").
        varquivo = "l:~\relat~\" + substr(varquivo,10,15).
        message skip "Arquivo gerado: " varquivo view-as alert-box.
    end.
 
    
    
    
    message "Deseja imprimir extratos" update sresp.
    if sresp 
    then do:
        def var v-ord as char.            

        display skip(1)
                vordem[1] skip
                vordem[2] skip
                vordem[3] skip
                vordem[4] 
                skip(1)
                with frame f-ordem no-label centered row 7 overlay
                                    title " Ordenacao ".

        choose field vordem auto-return with frame f-ordem.   

        if frame-index = 1
        then v-ord = "nome".
        else
        if frame-index = 2
        then v-ord = "rua".
        else
        if frame-index = 3
        then v-ord = "bairro".
        else
        if frame-index = 4
        then v-ord = "cidade".

        run cob/extrato5.p (input v-ord).

    end.


