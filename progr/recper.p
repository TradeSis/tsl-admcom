{admcab.i}

{setbrw.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    FIELD etbcod            AS INT
    FIELD pgdtinicial       AS DATE
    FIELD pgdtfinal         AS DATE
    FIELD pvdtinical        AS DATE
    FIELD pvdtfinal         AS DATE
    FIELD consultalp        AS LOG
    FIELD mod-sel           AS CHAR 
    FIELD considerarfeirao  AS LOG .
hentrada =  temp-table ttparametros:HANDLE.

/* variaveis usadas na tela para pedir parametros */ 
def var vetbcod                     like estab.etbcod.
def var vdti                        as date format "99/99/9999".
def var vdtf                        as date format "99/99/9999".
def var vdtveni                     as date format "99/99/9999".
def var vdtvenf                     as date format "99/99/9999".
def var v-consulta-parcelas-LP      as logical format "Sim/Nao" initial no.
def var v-feirao-nome-limpo         as log format "Sim/Nao" initial no.
def var vpdf                        as char no-undo.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
            
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.        
end.

repeat:
    update vetbcod  label "Filial" colon 25 with frame f-dep.
    if vetbcod = 0
    then display "GERAL" with frame f-dep.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f-dep.
    end.
    update skip
           vdti    label "Periodo de Pagamento"  colon 25
           vdtf  no-label    skip
           vdtveni label "Periodo de Vencimento" colon 25
           vdtvenf no-label skip
           v-consulta-parcelas-LP label "Considera apenas LP" colon 25
            help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"
                with frame f-dep centered side-label color blue/cyan row 4.
       
    assign sresp = false.
           
    update sresp label "Seleciona Modalidades?" colon 25
            help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80 frame f-dep.
              
    if sresp
    then do:              
        bl_sel_filiais:
        repeat:
            run p-seleciona-modal.
                                                      
            if keyfunction(lastkey) = "end-error"
            then leave bl_sel_filiais.
        end.
    end.
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end.
    
    assign vmod-sel = "".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + trim(tt-modalidade-selec.modcod) + ",".
    end.

    display vmod-sel format "x(40)" no-label with frame f-dep.

    update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
           with frame f-dep.

    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.
    
    CREATE ttparametros.
    ttparametros.etbcod = vetbcod.
    ttparametros.pgdtinicial = vdti.
    ttparametros.pgdtfinal = vdtf.
    ttparametros.pvdtinical = vdtveni.
    ttparametros.pvdtfinal = vdtvenf.
    ttparametros.consultalp = v-consulta-parcelas-LP.
    ttparametros.mod-sel = vmod-sel.
    ttparametros.considerarfeirao = v-feirao-nome-limpo. 
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN recper_run.p (INPUT  lcjsonentrada,
                      OUTPUT vpdf).
  
   
    message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
    
end.

procedure p-seleciona-modal:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.

