{admcab.i}

def shared temp-table tt-titulo like fin.titulo.

def shared temp-table tt-extrato 
    field rec as recid
    field ord as int
        index ind-1 ord.

def stream stela.
def var xx as int.
def var yy as int.

def var i as int.
def var vclicod     like clien.clicod.
def var vsit as log format "PAGO/ABERTO".
def var vacum as dec.

def var vndtven as date.
def var vndia as int.
def var vncond as char extent 5.
def var vnalor_cobrado as dec extent 5.
def var vnalor_novacao as dec extent 5.
def var vtotal as dec.

disp "Gerando extrato... Aguarde!"
    with frame f-av 1 down no-label centered row 12.
pause 0.    

def var varquivo as char.
def var vjuro as dec.
def var vdias as int.

if opsys = "UNIX"
then varquivo = "/admcom/relat/extrato" + string(time) + ".txt".
else varquivo = "l:\relat\extrato" + string(time) + ".txt" .

{mdadmcab.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""extrato2""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """EXTRATO DO CLIENTE""" 
            &Width     = "140"
            &Form      = "frame f-cabcab"}

for each tt-extrato use-index ind-1:
    find clien where recid(clien) = tt-extrato.rec no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao Cadastrado".
        undo, retry.
    end.
    
    output stream stela to terminal.                         
            disp stream stela "Processando...    " clien.clicod  no-label
                    with frame ffff centered .
            pause 0.
    output stream stela close.     

    display clien.clicod at 10
             clien.clinom at 10
             clien.ciccgc at 10
             clien.proemp[1]   label "Empresa     "     at 80
             clien.endereco[1] label "Rua         "     at 10 
             clien.protel[1]   label "Telefone    "     at 80
             clien.numero[1]   label "Numero      "     at 10
             clien.proprof[1]  label "Profissao   "     at 80
             clien.compl[1]    label "Compl.      "     at 10 
             clien.prorenda[1] label "Renda mensal"     at 80
             clien.bairro[1]   label "Bairro      "     at 10 
             clien.endereco[2] label "Rua         "     at 80
             clien.cidade[1]   label "Cidade      "     at 10
             clien.numero[2]   label "Numero      "     at 80
             clien.fone        label "Fone        "     at 10
             clien.compl[2]    label "Compl.      "     at 80
             clien.bairro[2]   label "Bairro      "     at 80
             clien.cidade[2]   label "Cidade      "     at 80
                with frame f02 width 200 no-box side-label.
     
                              
    display clien.refnome                            at 10
            clien.conjuge  when clien.estciv = 2 at 80
            clien.endereco[4] label "Rua"        at 10
            clien.proemp[2] label "Empresa"  when clien.estciv = 2 at 80
            clien.numero[4]   label "Numero"         at 10
            clien.protel[2] label "Telefone"  when clien.estciv = 2 at 80

            clien.compl[4]    label "Complemento"    at 10
            clien.proprof[2] label "Profissao" when clien.estciv = 2 at 80

            clien.bairro[4]   label "Bairro"         at 10
            clien.endereco[3] label "Rua" when clien.estciv = 2  at 80

            clien.cidade[4]   label "Cidade"         at 10
            clien.numero[3] label "Numero" when clien.estciv = 2  at 80
            clien.reftel   at 10
            clien.compl[3] label "Complemento" when clien.estciv = 2  at 80
            clien.bairro[3] label "Bairro" when clien.estciv = 2     at 80 
            clien.cidade[3] label "Cidade" when clien.estciv = 2      at 80
                with  width 200 frame fpess side-label. 
    
    
    /* Simula novacao */

    assign
        vndtven = ?
        vndia = 0
        vncond = ""
        vnalor_cobrado = 0
        vnalor_novacao = 0.
        
    run novacaox.p (input  clien.clicod,
                    input  setbcod,
                    output vndtven,
                    output vndia,
                    output vncond,
                    output vnalor_cobrado,
                    output vnalor_novacao).
                          
                           
    disp vndtven   label "Maior Atraso"   at 10 skip
         vndia     label "Dias de atraso" at 10 skip(1)
         vncond[1] label "Plano" at 10
         vncond[2] label "Plano" at 65 skip
         vnalor_cobrado[1]       at 17 label "Valor Cobrado...."
         vnalor_novacao[2]       at 72 label "Novacao Calculada" skip
         vnalor_novacao[1]       at 17 label "Novacao Calculada" skip(1)
         vncond[3] label "Plano" at 10
         vncond[4] label "Plano" at 65 skip
         vnalor_novacao[3]       at 17 label "Novacao Calculada"
         vnalor_novacao[4]       at 72 label "Novacao Calculada" skip(1)
         vncond[5] label "Plano" at 10
         vnalor_novacao[5]       at 17 label "Novacao Calculada"
         with width 200 frame f-plano side-label title "CONDICOES".
    
    for each tt-titulo use-index iclicod where
                        tt-titulo.clifor     = clien.clicod and
                        tt-titulo.titnat     = no           
                                            no-lock by tt-titulo.titdtven
                                                    by tt-titulo.titnum
                                                    by tt-titulo.titpar.
        if tt-titulo.titsit = "PAG"
        then next.
        vtotal = 0.
        vjuro = 0.
        vdias = 0.

        if tt-titulo.titdtven < today
        then do:
            vdias = today - tt-titulo.titdtven.
            if vdias > 1766
            then vdias = 1766.
 
            {sel-tabjur.i tt-titulo.etbcod vdias}
        
            if not avail fin.tabjur
            then do:
                /*
                message "Fator para" today - tt-titulo.titdtven
                        "dias de atraso, nao cadastrado".
                pause 0.
                */
            end.
            else assign vjuro  = 
                    (tt-titulo.titvlcob * fin.tabjur.fator) - tt-titulo.titvlcob
                   vtotal = tt-titulo.titvlcob + vjuro
                   vdias  = today - tt-titulo.titdtven.
        end.
        else vtotal = tt-titulo.titvlcob.
        vacum = vacum + vtotal.
        
        display tt-titulo.etbcod
                tt-titulo.titnum
                tt-titulo.titpar
                tt-titulo.titdtven format "99/99/9999"
                vdias           when vdias > 0 column-label "Atraso"
                format "->>>9"
                tt-titulo.titvlcob column-label "Principal "   (total)
                    format "->,>>>,>>9.99"
                vjuro           column-label "Juro"         (total)
                    format "->,>>>,>>9.99"
                vtotal          column-label "Total"        (total)
                    format "->>,>>>,>>9.99"
                space(3)
                vacum           column-label "Acumulador"
                    format "->>>,>>>,>>9.99"
                    with frame flin down width 140 no-box.
    end.        
    page.
     
end.
    
output close.

message color red/with
    "Arquivo de extrato gerado: " varquivo
    view-as alert-box.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
{mrod.i}
end.
 