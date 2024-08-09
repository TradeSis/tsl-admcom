/*
    Titulos pagos com novacao
*/

{admcab.i}
{setbrw.i}

def var vtipocxa as char.
def var vmodcod  as char. 
def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.
def var vetbcod like estab.etbcod.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vjuro as dec.

def temp-table tt-nov no-undo
    field etbcod like estab.etbcod
    field tipocxa as char format "x(3)" column-label "CXA"
    field modcod  like titulo.modcod
    field data as date
    field valor as dec
    field juro as dec
    field cont as int
    index i1 is unique primary data etbcod tipocxa modcod.

def var vtotal as dec.
def var vcont as int init 0.

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

def var vval-carteira as dec.                                
                                
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
    
assign vmod-sel = "  ".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
end.
      
display vmod-sel format "x(40)" no-label with frame f-per.

update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
    with frame f-per.

def var dLoopDate as date.

for each estab where
             (if vetbcod > 0
              then estab.etbcod = vetbcod else true)
              no-lock:
    if vetbcod > 900 then next.
    
    disp estab.etbcod label "Filial" 
        with frame f-sho row 10 no-box color message width 80 side-label.
        
    pause 0.
        
    do dLoopDate = vdti to vdtf:          
        disp dLoopDate label "Data" with frame f-sho.
        pause 0.
        
        vtotal = 0.
        vjuro = 0.
        for each tt-modalidade-selec,
            each titulo where
                 titulo.etbcobra = estab.etbcod and
                 titulo.titdtpag = dLoopDate and
                 titulo.modcod = tt-modalidade-selec.modcod and
                 titulo.moecod = "NOV" no-lock:

                 
            if v-feirao-nome-limpo
            then do:
                run filtro-feiraonl (output sresp).
                if not sresp
                then next.
            end.
                  vtotal = /*vtotal +*/ titulo.titvlcob.
            vjuro  = /*vjuro  +*/ titulo.titjuro.
            vcont  = /*vcont  +*/ 1.

            vtipocxa = if titulo.cxacod = ? or 
                          titulo.cxacod = 0 
                       then string(titulo.etbcobra,"999") 
                       else if titulo.cxacod >= 30 or  
                               titulo.etbcod = 140 
                            then "P2K" 
                            else "ADM".
            
            vmodcod = titulo.modcod.
            if vetbcod = 0 
            then do:
                vtipocxa = "".
                vmodcod  = "".
            end.    
                                                                      
            find first tt-nov where tt-nov.data = DLoopDate and
                                    tt-nov.etbcod = 0 and
                                    tt-nov.tipocxa = vtipocxa and
                                    tt-nov.modcod = vmodcod 
                                    no-error.
            if not avail tt-nov
            then do:
                create tt-nov.
                tt-nov.etbcod = 0.
                tt-nov.data = dLoopDate.    
                tt-nov.tipocxa = vtipocxa.
                tt-nov.modcod = vmodcod.
            end.
            tt-nov.valor = tt-nov.valor + vtotal.
            tt-nov.cont  = tt-nov.cont + 1.
                
            find first tt-nov where 
                                tt-nov.data = dLoopDate and
                                tt-nov.etbcod = estab.etbcod and
                                tt-nov.tipocxa = vtipocxa and
                                tt-nov.modcod = vmodcod

                                no-error.
            if not avail tt-nov
            then do:
                create tt-nov.
                tt-nov.data = dLoopDate.
                tt-nov.etbcod = estab.etbcod.    
                tt-nov.tipocxa = vtipocxa.
                tt-nov.modcod = vmodcod.
                
            end.
            tt-nov.valor = tt-nov.valor + vtotal.
            tt-nov.juro  = tt-nov.juro + vjuro.
            tt-nov.cont  = tt-nov.cont + 1.
                
            find first tt-nov where tt-nov.data = ? and
                                tt-nov.etbcod = estab.etbcod and
                                tt-nov.tipocxa = vtipocxa and
                                tt-nov.modcod = vmodcod

                                no-error.
            if not avail tt-nov
            then do:
                create tt-nov.
                tt-nov.data = ?.
                tt-nov.etbcod = estab.etbcod.    
                tt-nov.tipocxa = vtipocxa.
                tt-nov.modcod = vmodcod.
                
            end.
            tt-nov.valor = tt-nov.valor + vtotal.
            tt-nov.juro  = tt-nov.juro  + vjuro.
            tt-nov.cont  = tt-nov.cont  + 1.
        end.
    end.
    vcont = 0.
end.

def var varquivo as char.
varquivo = "/admcom/relat/rec-moe-nov" + string(mtime).

{mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""rec-moe-nov""
        &Nom-Sis   = """SISTEMA CONTABIL/FISCAL"""
        &Tit-Rel   = """ CLIENTES "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "210"
        &Form      = "frame f-cabcab"}

disp with frame f-per.

for each tt-nov where 
        tt-nov.data = ? and
        tt-nov.etbcod < 900 
        no-lock
        break by tt-nov.etbcod
              by tt-nov.tipocxa
              by tt-nov.modcod.
    find estab where estab.etbcod = tt-nov.etbcod no-lock.
    disp tt-nov.etbcod column-label "Estab."
         estab.etbnom column-label "Filial"
         tt-nov.tipocxa
         tt-nov.modcod
         
         tt-nov.valor(total)  format ">>>,>>>,>>9.99" column-label "Total (R$)"
         tt-nov.juro(total)   format ">>>,>>9.99" column-label "Juro P2K"
         tt-nov.cont(total) column-label "Total (qtd)"
         with frame f-disp down.
    down with frame f-disp.     
end.

output close.

run visurel.p(varquivo, "").


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
