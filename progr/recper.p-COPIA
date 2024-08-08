{admcab.i}

{setbrw.i}

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def var vdtpag like titulo.titdtpag.
def var vetbcod like estab.etbcod.
def stream stela.

def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".

def var vdtveni    as date format "99/99/9999".
def var vdtvenf    as date format "99/99/9999".

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vtotjur like plani.platot.
def var vtotpre like plani.platot.
def stream stela.
def var vdata like plani.pladat.
def var varquivo as char.

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
    
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.

    display vmod-sel format "x(40)" no-label with frame f-dep.

    update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
           with frame f-dep.

    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rel01." + string(time).
    else varquivo = "l:\relat\rel01." + string(time).
    
    output stream stela to terminal.
        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""recper""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """RECEBIMENTO POR PERIODO - Periodo: "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        vtotpre = 0.
        vtotjur = 0.
                                 
        do vdtpag = vdti to vdtf:                         
        for each tt-modalidade-selec,
        
            each titulo use-index titdtpag
                    where titulo.empcod = 19           and
                          titulo.titnat = no           and
                          titulo.modcod = tt-modalidade-selec.modcod and
                          titulo.titsit = "PAG"        and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtpag = vdtpag     no-lock.

            if titulo.titdtven >= vdtveni   and 
               titulo.titdtven <= vdtvenf 
            then.
            else next.

/***
            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
***/
            if fin.titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.
                                                
            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
                            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            {filtro-feiraonl.i}

            display stream stela
                    titulo.etbcod
                    titulo.titdtpag
                    vtotpre
                    vtotjur with frame f-1 centered row 10.
            
            pause 0.
            
            assign vtotpre = vtotpre + titulo.titvlcob
                   vtotjur = vtotjur + titulo.titjuro.
         
        end.
        end.
         
        display estab.etbcod  column-label "Filial"
                vtotpre(total) column-label "Total!Prestacoes"
                vtotjur(total) column-label "Total!Juros"
                (vtotpre + vtotjur)(total) format "->>>,>>>,>>9.99"
                                       column-label "Total!Receb." 
                             with frame f-down down width 200.
    end.
    output close.
    output stream stela close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
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

