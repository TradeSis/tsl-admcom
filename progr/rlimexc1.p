{admcab.i}

{setbrw.i}

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

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

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha <> "score-drb"
then leave.

def stream stela.
output stream stela to terminal.
def temp-table tt-estab like estab.
def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.

def var v-dis-venda like plani.platot.
def var vpagas as int.
def var qtd-15 as int.
def var vdata as date .
def var vexibe  as logical format "Sim/Nao" initial yes.
def var vcartao as logical format "Sim/Nao" initial yes.
def var vvalor as dec format "->>>,>>>,>>9.99".
def var limite-cred-scor  as dec.
def var sal-aberto   like clien.limcrd.


FUNCTION limite-cred-scor return decimal
     ( input rec-clien as recid )   .
    def var vcalclim as dec.
    def var vpardias as dec.
    run callim-cred-scorp (input rec-clien,
                           output vcalclim).
 
    return vcalclim.
end function. 


form vetbcod like estab.etbcod label "Filial"
     estab.etbnom no-label
     vdti as date label "Periodo de" format "99/99/9999" at 1
     vdtf as date label "Ate" format "99/99/9999"
     skip
     vcartao      label "Apenas Vendas C/Cartao Lebes   "
     skip
     vexibe       label "Apenas Vendas C/Limite Excedido"
     vvalor       label "Valor excedido acima de R$ "
     with frame f-1 width 77 1 down centered side-label.


update vetbcod with frame f-1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom with frame f-1.
    create tt-estab.
    buffer-copy estab to tt-estab.
end.
else do:
    for each estab where estab.etbnom begins "DREBES-FIL" NO-LOCK:
        create tt-estab.
        buffer-copy estab to tt-estab.
    END.
end.

vdti = today.
vdtf = today.

update vdti vdtf vcartao vexibe vvalor with frame f-1.

assign sresp = false.
           
update skip
       sresp label "Seleciona Modalidades?     " 
       help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
       with side-label
       width 80 frame f-1.
              
if sresp
then do:
              
    bl_sel_filiais:
    repeat:
                   
        run p-seleciona-modal.
                                                      
        if keyfunction(lastkey) = "end-error"
        then do: 
            pause.
            leave bl_sel_filiais.
        end.   
                                                
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
      
display vmod-sel format "x(40)" no-label with frame f-1.

if vdti = ? or vdtf = ? or
vdti > vdtf
then undo.

    def var varquivo as char.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/lex" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\lex" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "132" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rlimexc1"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """  VENDA LIMITE EXCEDIDO/LIBERADO """ 
                &Width     = "132"
                &Form      = "frame f-cabcab"}

disp with frame f-1.

if vdti < 05/15/2009
then vdti = date(05,15,2009).

def var dt-altcad as date.

for each tt-estab no-lock:

        disp tt-estab.etbcod label "Filial"
         tt-estab.etbnom no-label
         with frame ff-1 width 80 1 down.

        do vdata = vdti to vdtf:
        disp stream stela tt-estab.etbcod vdata.
        pause 0.
        for each plani where plani.etbcod = tt-estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat = vdata and
                         plani.desti <> 1
                          
                          /*and
                         plani.emite  = tt-estab.etbcod 
                         and plani.serie  = "V" */
                         no-lock :

            if plani.desti = 1 then next.
            if vcartao = yes
            then do:
                 if not (plani.notobs[1] matches "*CARTAO-LEBES*")
                 then next.
            end.
            /*
            find first fin.autoriz where autoriz.etbcod = plani.etbcod and
                       autoriz.data = plani.pladat and
                       autoriz.motivo = "LIMITE EXCEDIDO" and                                           autoriz.clicod = plani.desti
                       no-lock no-error.
                       
                                   
            if vexibe  = yes and vcartao = no and  not avail autoriz then next.                                           
            */

            assign v-dis-venda = 0.
           
            /* antonio */
            if plani.notobs[1] matches "*LIMITE-DISPONIVEL*"
                  then do: 
                    assign v-dis-venda = dec(acha("LIMITE-DISPONIVEL",
                                            plani.notobs[1]))  - 
                          (if plani.biss <> 0 then plani.biss
                                           else plani.platot).
                    if v-dis-venda = ? 
                    then assign v-dis-venda = dec(acha("LIMITE-DISPONIVEL",   
                                                  plani.notobs[1])).                        end.
           /**/
           if vexibe and v-dis-venda = 0 then next.
           assign v-dis-venda = v-dis-venda - 
           (if plani.biss <> 0 then plani.biss
                                 else plani.platot).
            
           find clien where clien.clicod = plani.desti no-lock no-error.
           find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
           if avail cpclien
           then dt-altcad = date(acha("DATA",cpclien.var-char20)).
           find first fin.contnf where contnf.etbcod = plani.etbcod and
                              contnf.placod = plani.placod no-lock
                              no-error.
           if not avail contnf
           then next.                  
           find fin.contrato where contrato.contnum = contnf.contnum 
                    no-lock no-error .
                    
           release tt-modalidade-selec.
           find first tt-modalidade-selec
                where tt-modalidade-selec.modcod = fin.contrato.modcod
                                no-lock no-error.
                                
           if not avail tt-modalidade-selec
           then next.
                    
           /*
           find func where func.etbcod = autoriz.etbcod and
                            func.funcod = autoriz.funcod no-lock no-error.
             */               
                            
           /*if vvalor <> 0 then do:  29446
           
                if v-dis-venda < 0 then do:
                    if (contrato.vltotal + v-dis-venda) < vvalor then next.
                end.
                else do:    
                    if (contrato.vltotal - v-dis-venda) < vvalor then next.
                end.    
           end. 29446 */
            
           if vexibe = yes then do:
              if v-dis-venda < 0 then do:
                    if (contrato.vltotal + v-dis-venda) >  0 then next.
                end.
                else do:    
                    if (contrato.vltotal - v-dis-venda) > 0 then next.
                end.    
           end. 
           else if v-dis-venda < 0
                then v-dis-venda = 0.
             
           assign vpagas  = 0
                  qtd-15  =0
                  sal-aberto = 0.
                      
           for each fin.titulo where 
                   /* titulo.empcod = 19
                and titulo.titnat = no
                and titulo.modcod = "CRE"
                and titulo.etbcod = plani.etbcod 
                and*/  titulo.clifor = clien.clicod no-lock:
                    
                if titulo.modcod = "DEV" or
                   titulo.modcod = "BON" or
                   titulo.modcod = "CHP"
                then next.
                
                if titulo.titpar <> 0 then do:
                    if titulo.titsit = "LIB"
                    then do:
                    sal-aberto = sal-aberto + titulo.titvlcob.
                    /*parcela-aberta  = parcela-aberta + 1.
                    if titulo.titdtven < today
                    then do:
                        vencidas = vencidas + titulo.titvlcob.
                        if titulo.titdtven < maior-atraso
                        then maior-atraso = titulo.titdtven.
                    end.*/
                    end.
                    else vpagas = vpagas + 1.
                end.

               /* if titulo.titsit <> "LIB" then do: /*28235 E 29296*/
                    assign vpagas = vpagas + 1.
                end. */
                    
                if titulo.titpar <> 0 and titulo.titdtpag <> ?
                then do:
                    if (titulo.titdtpag - titulo.titdtven) <= 15
                    then qtd-15 = qtd-15 + 1.
                end.
           end.

            
           assign limite-cred-scor = limite-cred-scor(recid(clien)).
           find first credscor where credscor.clicod = clien.clicod no-lock no-error.
           if avail credscor
           then do:
    
                assign vpagas = vpagas + credscor.numpcp
                       qtd-15 = qtd-15 + credscor.numa15.

           end.
           
           if vvalor <> 0 then do:
              if sal-aberto - limite-cred-scor < vvalor then 
                next.
              /*if sal-aberto < vvalor then next.   29446 */
           end.

           
           
          disp  plani.pladat   column-label "Data" 
                plani.numero   column-label "Venda"     format ">>>>>>>>>9"
                plani.desti    column-label "Conta"     format ">>>>>>>>>>9" 
                clien.clinom when avail clien  no-label format "x(30)"
                contrato.contnum when avail contrato column-label "Contrato"
                                format ">>>>>>>>>>>9" 
                contrato.vltotal when avail contrato
                    column-label "Total!Contrato"   
                 /*   antonio - situacao anterior 
                 autoriz.valor3 column-label "Limite!Na Venda"
                    format "->>>,>>9.99"
                 */
                 v-dis-venda    column-label "Limite!Na Venda"
                    format "->>>,>>9.99"

                 /* Laureano - Alterado para atender ao chamado 29739 -                                10/02/2010 
                 (if v-dis-venda < 0
                 then (contrato.vltotal + v-dis-venda) 
                 else (contrato.vltotal - v-dis-venda))
                 */ 
                 (sal-aberto - limite-cred-scor)  column-label
                 "Diferenca!Vl.Contr-Lim.Ven"
                    format "->>>,>>9.99"        
                 /*
                 func.funnom when avail func  column-label "Autorizado Por"
                        format "x(20)"
                        */
                 limite-cred-scor column-label "Limite !Cartao" format "->>>,>>9.99"    
                 sal-aberto   label "Cred.Aberto"  format "->>>,>>9.99"
                 ((qtd-15 * 100) / vpagas) column-label " % Pg." format ">>>>9.99%"
                 vpagas   column-label "Qtd. ! Pagas" format "9999999"
                 with frame f2 down width 200.
        end.                 
    end.
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
    
procedure callim-cred-scorp: 

def input   parameter rec-clien  as recid.
def output  parameter vcalclimite as dec.

def var vcalclim as dec.
def var vpardias as dec.

vcalclim = 0.
vpardias = 0.

def var limite-disponivel as dec init 0.

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.
             
run calccredscore.p (input "",
                        input rec-clien,
                        output vcalclim,
                        output vpardias,
                        output limite-disponivel).

disconnect dragao. 
vcalclimite = vcalclim.

end procedure.    
    


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




    
