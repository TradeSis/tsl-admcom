{admcab.i}

def buffer bfunc for func.

/*def var    vop       as   log format "Habilitacao/Migracao".*/
def var vop as char format "x(11)".

def var    vclicod   like clien.clicod.
def var    vciccgc   like habil.ciccgc.
def var    vcelular  like habil.celular.
def var    vgercod   like habil.gercod.
def var    vvencod   like habil.vencod.
def var    vpmtcod   like habil.pmtcod.

repeat:
    
    update vcelular label "Celular.." 
           with frame f-habil centered side-labels
                              title " CONSULTA HABILITACAO ". 
    if vcelular = ""
    then do:
        message "Informe o numero do celular.".
        undo.
    end.

    find first habil use-index icelular 
        where habil.celular = vcelular no-lock no-error.
    if avail habil
    then do:                            
        find func where func.etbcod = habil.etbcod
                    and func.funcod = habil.vencod no-lock no-error.
        find first clien where clien.ciccgc = habil.ciccgc /*
                         clien.clicod = 1033176712*/ no-lock no-error.

        vop = "".
        
        if habil.gercod = 1
        then vop = /*yes.*/ "Habilitacao".
        
        if habil.gercod = 2
        then vop = /*no.*/ "Migracao".
        
        if habil.gercod = 3
        then vop = "Cancelada".
        
        disp skip                 
             habil.etbcod label "Filial..." space(23)
             habil.habdat label "Dt.Habil" skip
             vop label "Operacao." skip
             habil.ciccgc label "CPF......"
             clien.clinom no-label
             clien.ciinsc label "RG......." space(3)
             clien.dtnasc label "Dt.Nasc"
             clien.pai    label "Pai......"
             clien.mae    label "Mae......" skip
             clien.fone   label "Telefone." space(17)
             clien.cep[1] label "Cep" skip
             clien.sexo   label "Sexo....."  space(17)
             clien.estciv label "Est.Civil" skip
             habil.vencod label "Vendedor."
             func.funnom no-label when avail func skip
             habil.procod label "Produto.." space(24)
             habil.habval 
             skip
             habil.tipviv label "Promocao." skip
             habil.codviv label "Plano...."  format ">>>9"
             with frame f-habil.

    end.
end.    
