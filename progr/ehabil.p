{admcab.i}

def buffer bfunc for func.
def var vdata as date format "99/99/9999".

def var    vop       as   log format "Habilitacao/Migracao".

def var    vclicod   like clien.clicod.
def var    vciccgc   like habil.ciccgc.
def var    vcelular  like habil.celular.
def var    vgercod   like habil.gercod.
def var    vvencod   like habil.vencod.
def var    vpmtcod   like habil.pmtcod.

/*repeat:*/
    
    update vciccgc  label "CPF......"    skip
           vcelular label "Celular.."
           with frame f-habil side-labels.

    find habil where habil.ciccgc  = vciccgc
                 and habil.celular = vcelular no-error.

    if not avail habil
    then do:
        message "Habilitacao nao Cadastrada".
        undo.
    end.
    else do:
    
        find first clien where clien.ciccgc = vciccgc no-lock no-error.

        if avail clien
        then vclicod = clien.clicod.
    
        find clien where clien.clicod = vclicod no-lock no-error.
    
        disp clien.clinom no-label with frame f-habil.

        disp clien.ciinsc label "RG......." space(3)
             clien.dtnasc label "Dt.Nasc"
             clien.pai    label "Pai......"
             clien.mae    label "Mae......" skip
             clien.fone   label "Telefone." space(17)
             clien.cep[1] label "Cep" skip
             clien.sexo   label "Sexo....." space(17)
             clien.estciv label "Est.Civil"  skip
             with frame f-habil.

        find estab where estab.etbcod = habil.etbcod no-lock no-error.
    
        disp habil.etbcod label "Loja....." estab.etbnom no-label skip
             with frame f-habil.

        vdata = habil.habdat.
        
        update vdata format "99/99/9999" label "Dt.Habil."
               with frame f-habil centered title " Habilitacao - Alteracao"
               row 5.
    
        if habil.gercod  = 1
        then vop = yes.
        else vop = no.
    
        update skip 
               vop     label "Operacao."
               help "[H] = Habilitacao [M] = Migracao "
               with frame f-habil  side-labels.

        vvencod = habil.vencod.

        find func where func.etbcod = habil.etbcod 
                    and func.funcod = vvencod no-lock no-error.
        if avail func
        then disp skip vvencod func.funnom no-label with frame f-habil.
        
        do on error undo:

            update vvencod label "Vendedor." with frame f-habil.
            find func where func.etbcod = habil.etbcod
                        and func.funcod = vvencod no-lock no-error.
            if not avail func
            then do:
                message "Vendedor nao Cadastrado".
                undo.
            end.  
            else disp func.funnom no-label with frame f-habil.
        
        end.
    
        message "Confirma os Dados Alterados?" update sresp.
        if sresp
        then do: 
           assign 
                  habil.habdat  = vdata
                  habil.vencod  = vvencod
                  habil.gercod  = (if vop = yes
                                   then 1
                                   else 2)
                  habil.exportado = no.
                  
           message "Habilitacao Alterada". pause 1 no-message.
        end.    
    end.    
    
/*end.    
*/