/*diSp searcH("wfaglis.p") format "x(30)".*/

{admcab.i}

def shared temp-table tt-clifor
        field clfcod        like clifor.clfcod
        field ranking       as int
        field medven        as dec
        field maxven        as dec
        field freq          as int
        index freq     freq asc
                       medven asc
                       maxven asc 
        index clifor   clfcod asc
        index maxven   maxven desc
        index rankink ranking asc.


def var vmodelo as char.
def var vopcional as char.
def var i as int.
def var vendereco       like clifor.endereco label "Endereco".
def var vbairro         like clifor.bairro.
def var vcep            as   char.
def var vcidade          like clifor.cidade.
def var vufecod          as   char.
def var vclfnom           like clifor.clfnom.
def var vsobreclfnom      like clifor.clfnom.

def var vfone-res       like clifor.fone label "Fone Res.".
def var vfone-cel       like clifor.fone label "Celular".
def var vfone           like clifor.fone label "Fone".
def var vemail          as   char format "x(50)" label "E-Mail".

find first tt-clifor no-lock no-error.
if not avail tt-clifor then do:
    message "Nenhum Agente Comercial Selecionado". 
    pause 2 no-message.
    leave.
end.

varqsai = "../impress/mktlis" + string(time,"999999").
                        
    {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""MKTLIS""
        &Nom-Sis   = """SISTEMA MARKETING"""
        &Tit-Rel   = """RELACAO DE CLIENTES"""
        &Width     = "130"
        &Form      = "frame f-cabcab"}

for each tt-clifor use-index maxven no-lock,
    clifor where clifor.clfcod = tt-clifor.clfcod no-lock
                            break by maxven desc.
    find cpfis of clifor no-lock no-error.
    vclfnom = "".
    do i = 1 to 100.
        if substr(clifor.clfnom,i,1) = "" then leave.
        vclfnom = vclfnom + substr(clifor.clfnom,i,1).
    end.
    assign vsobreclfnom = substr(clifor.clfnom,length(vclfnom) + 2,100).

    assign vendereco =  trim(clifor.endereco + "," +
                             clifor.numero   + " " +
                             clifor.compl)
           vbairro    = clifor.bairro
           vcep       = clifor.cep
           vcidade     = clifor.cidade
           vufecod     = clifor.ufecod
           vfone      = clifor.fone.
    form
         clifor.clfnom     column-label "Nome" format "x(30)"
         with down no-box frame flin.
    display
         clifor.clfcod      
         clifor.clfnom    
         vfone
         tt-clifor.ranking   column-label "Ranking" format ">>>>9"
         tt-clifor.maxven    column-label "Total"
         tt-clifor.freq      column-label "Freq"
         tt-clifor.medven    column-label "Media"
          with frame flin width 130.
end.

output close.
