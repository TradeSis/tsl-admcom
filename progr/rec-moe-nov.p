/*
    Titulos pagos com novacao
*/

{admcab.i}
{setbrw.i}

DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field etbcod                AS int
    field dtinicial             AS DATE
    field dtfinal               AS DATE
    field sel-mod               AS CHAR
    field considerarfeirao      AS LOG.
    
hentrada =  temp-table ttparametros:HANDLE.



/* variaveis usadas na tela para pedir parametros */    
def var vetbcod like estab.etbcod.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
 def var vmod-sel as char.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vpdf as char no-undo.
 

def var v-cont as integer.
def var v-cod as char.

form vetbcod label "Filial" colon 25
     estab.etbnom no-label
     vdti colon 25 format "99/99/9999" label "Periodo de"
     vdtf format "99/99/9999" label "Ate"
     with frame f-per 1 down width 80 side-label.

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

update vetbcod with frame f-per.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab then return.
    disp estab.etbnom with frame f-per.
end.
else disp "Todas as filiais" @ estab.etbnom with frame f-per.

update vdti vdtf with frame f-per.     
if vdti > vdtf or vdti = ? or vdtf = ?
then undo.
    
assign sresp = false.
update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80 frame f-per.
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
      
display vmod-sel format "x(40)" no-label with frame f-per.

update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
    with frame f-per.



CREATE ttparametros.
    ttparametros.etbcod   = vetbcod.
    ttparametros.dtinicial    = vdti.
    ttparametros.dtfinal      = vdtf. 
    ttparametros.sel-mod           = vmod-sel.
    ttparametros.considerarfeirao = v-feirao-nome-limpo.
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN rec-moe-nov_run.p (INPUT  lcjsonentrada,
                          OUTPUT vpdf).
   
    
    message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
   




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
            V-CONT ""FILIAIS                                   "".
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

end procedure.


procedure filtro-feiraonl.
    def output parameter par-ok as log init yes.

    def buffer nov-titulo for titulo.

    find first tit_novacao where
                        tit_novacao.ori_empcod = titulo.empcod and
                        tit_novacao.ori_titnat = titulo.titnat and
                        tit_novacao.ori_modcod = titulo.modcod and
                        tit_novacao.ori_etbcod = titulo.etbcod and
                        tit_novacao.ori_clifor = titulo.clifor and
                        tit_novacao.ori_titnum = titulo.titnum and
                        tit_novacao.ori_titpar = titulo.titpar and
                        tit_novacao.ori_titdtemi = titulo.titdtemi
                    no-lock no-error.
    if avail tit_novacao
    then do.
        find contrato where contrato.contnum = tit_novacao.ger_contnum
                      no-lock no-error.
        if avail contrato
        then do.
            find last nov-titulo where nov-titulo.empcod = 19
                               and nov-titulo.titnat = no
                               and nov-titulo.modcod = "CRE"
                               and nov-titulo.etbcod = contrato.etbcod
                               and nov-titulo.clifor = contrato.clicod
                               and nov-titulo.titnum = string(contrato.contnum)
                               no-lock no-error.
            if avail nov-titulo
            then
                if v-feirao-nome-limpo
                then
                    if acha("FEIRAO-NOME-LIMPO",nov-titulo.titobs[1]) = "SIM"
                    then .
                    else par-ok = no.
                else
                    if acha("FEIRAO-NOME-LIMPO",nov-titulo.titobs[1]) = "SIM"
                    then par-ok = no.
        end.
    end.

end procedure.
