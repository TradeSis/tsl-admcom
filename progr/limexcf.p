{admcab.i}                                      

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha <> "score-drb"
then leave.

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
def var vcartao as logical format "Sim/Nao" initial no.
def var vvalor as dec format "->>>,>>>,>>9.99".
def var limite-cred-scor  as dec.
def var vdatat as date initial today.
def var vdti as date.
def var vdtf as date.


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
    /* vdti as date label "Periodo de" format "99/99/9999" at 1
     vdtf as date label "Ate" format "99/99/9999" */
     skip
     /*vcartao      label "Apenas Vendas C/Cartao Lebes   "*/
     skip
     vexibe       label "Apenas Vendas C/Limite Excedido"
     vvalor       label "Valor excedido acima de R$ "
     vdatat        label "Considerar parcelas com venc. anterior a data" format "99/99/9999"
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

vdti = today - 30.
vdtf = today.
update /*vdti vdtf /*vcartao*/ */  vexibe vvalor vdatat with frame f-1.
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
    
        for each plani where plani.etbcod = tt-estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat = vdata and
                         plani.emite  = tt-estab.etbcod 
                         /* and plani.serie  = "V" */
                         no-lock :

        /* if plani.crecod = 1  then next.  /* Somente vendas não a Vista */ */
            if vcartao = yes
            then do:
                 if not (plani.notobs[1] matches "*CARTAO-LEBES*")
                 then next.
            end.
            find first autoriz where autoriz.etbcod = plani.etbcod and
                       autoriz.data = plani.pladat and
                       autoriz.motivo = "LIMITE EXCEDIDO" and                                           autoriz.clicod = plani.desti
                       no-lock no-error.
                       
                                   
            if vexibe  = yes and vcartao = no and  not avail autoriz then next.
            
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
           if v-dis-venda = 0 then next.
           assign v-dis-venda = v-dis-venda - 
           (if plani.biss <> 0 then plani.biss
                                 else plani.platot).
            
           find clien where clien.clicod = plani.desti no-lock no-error.
           
           find totcli where totcli.empcod = clien.clicod no-lock no-error.
           if not avail totcli then next.
           
           if vetbcod <> 0 then do:
            if totcli.totcli <> vetbcod then next. 
           end.
           
           find cpclien where cpclien.clicod = totcli.empcod no-lock no-error.
           if avail cpclien
           then dt-altcad = date(acha("DATA",cpclien.var-char20)).
           find contnf where contnf.etbcod = plani.etbcod and
                              contnf.placod = plani.placod no-lock
                              no-error.
           if not avail contnf
           then next.                  
           find contrato where contrato.contnum = contnf.contnum 
                    no-lock no-error .
           find func where func.etbcod = autoriz.etbcod and
                            func.funcod = autoriz.funcod no-lock no-error.
                            
                            
           if vvalor <> 0 then do:
           
                if v-dis-venda < 0 then do:
                    if (contrato.vltotal + v-dis-venda) < vvalor then next.
                end.
                else do:    
                    if (contrato.vltotal - v-dis-venda) < vvalor then next.
                end.    
           end.
            
           if vexibe = yes then do:
              if v-dis-venda < 0 then do:
                    if (contrato.vltotal + v-dis-venda) <  0 then next.
                end.
                else do:    
                    if (contrato.vltotal - v-dis-venda) < 0 then next.
                end.    
           end. 
             
           assign vpagas  = 0
                  qtd-15  =0.
                      
           for each titulo where 
                   /* titulo.empcod = 19
                and titulo.titnat = no
                and titulo.modcod = "CRE"
                and titulo.etbcod = plani.etbcod 
                and*/  titulo.clifor = clien.clicod no-lock:
                    
                if vdatat <> ? and titulo.titdtpag = ? then do:
                    if titulo.titdtven > vdatat then next.
                end.
                
                if titulo.modcod = "DEV" or
                   titulo.modcod = "BON" or
                   titulo.modcod = "CHP"
                then next.
                
                if titulo.titpar <> 0 then do:
                    if titulo.titsit = "LIB"
                    then do:
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
                 ( if v-dis-venda < 0
                 then (contrato.vltotal + v-dis-venda) 
                 else (contrato.vltotal - v-dis-venda)) column-label
                 "Diferenca!Vl.Contr-Lim.Ven"
                    format "->>>,>>9.99"        
                 func.funnom when avail func  column-label "Autorizado Por"
                        format "x(20)"
                 limite-cred-scor column-label "Limite !Cartao" format "->>>,>>9.99"
                 ((qtd-15 * 100) / vpagas) column-label " % Pg." format ">>>>9.99%"
                 vpagas   column-label "Qtd. ! Pagas" format "9999"
                 with frame f2 down width 180.
        end.                 
    end.
end. 
                            

    output close.

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
    
     
    
    
