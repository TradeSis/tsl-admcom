/* #1 25.06.2018 - helio TP 25424262  */
/*                       - Campo Limite CredScor eh o valor que esta gravado no momento da EMISSAO DA NOTA */
{admcab.i}

/*
def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha <> "score-drb"
then leave.
*/

def workfile wacum
    field mes as int format "99"
    field ano as int format "9999"
    field acum       like plani.platot.

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
    index dado1 numseq
    .
def var v-dis-venda like plani.platot.
def var vpagas as int.
def var qtd-15 as int.
def var vdata as date .
def var vexibe  as logical format "Sim/Nao" initial yes.
def var vcartao as logical format "Sim/Nao" initial yes.
def var vvalor as dec format "->>>,>>>,>>9.99".
def var limite-cred-scor  as dec.
def var sal-aberto   like clien.limcrd.
def buffer bclien for clien.

FUNCTION limite-cred-scor return decimal
     ( input rec-clien as recid )   .
    def var vcalclim as dec.
    def var vpardias as dec.
    
    /* #1 */
    vcalclim = 0.
    find bclien where recid(bclien) = rec-clien no-lock.
    find neuclien where neuclien.clicod = bclien.clicod no-lock no-error.
    if avail neuclien 
    then do:
        if neuclien.vlrlimite <> 0
        then vcalclim = neuclien.vlrlimite.
    end.    
    if vcalclim = 0
    then run callim-cred-scorp (input rec-clien,
                              output vcalclim).
    /* #1 */ 
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
if vdti = ? or vdtf = ? or
vdti > vdtf
then undo.

def temp-table tt-limite
    field clicod like clien.clicod
    field pladat like plani.pladat
    field platot like plani.platot
    field pate15 as dec
    field p16a45 as dec
    field parpag as int /* #1 */
    field limite as dec
    field CreAbe as dec
    field Maiacu as dec
    field Promes as dec
    field Profis as int
    field Renda  as dec
    field Nota   as int
    field pagas-base as dec
    index i1 clicod
    .

def var dt-altcad as date.

def var v-acum as dec.
def var qtd-45 as int.
def var qtd-46 as int.
def var proximo-mes as dec.
def var vdata1 as date.
def var vdata2 as date.

if month(today) = 12
then vdata1 = date(1,1,year(today) + 1).
else vdata1 = date(month(today) + 1,1,year(today)).

def var pagas-base as dec.

if month(vdata1) = 12
then vdata2 = date(1,1,year(vdata1) + 1) - 1.
else vdata2 = date(month(vdata1) + 1,1,year(vdata1)) - 1.
 
for each tt-estab no-lock:

    disp tt-estab.etbcod 
         tt-estab.etbnom 
         with frame ff-1 width 80 1 down no-label
         color message no-box.
    pause 0.

    do vdata = vdti to vdtf:
        disp vdata with frame ff-1.
        pause 0.
        for each plani where plani.etbcod = tt-estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat = vdata and
                         plani.desti <> 1
                         no-lock :

            if vcartao = yes
            then do:
                 if not (plani.notobs[1] matches "*CARTAO-LEBES*")
                 then next.
            end.

            assign v-dis-venda = 0.
            /* #1 */ limite-cred-scor = 0.
             
            if plani.notobs[1] matches "*LIMITE-DISPONIVEL*"
            then do: 
                    assign v-dis-venda = dec(acha("LIMITE-DISPONIVEL",
                                            plani.notobs[1]))  - 
                          (if plani.biss <> 0 then plani.biss
                                           else plani.platot).
                    if v-dis-venda = ? 
                    then assign v-dis-venda = dec(acha("LIMITE-DISPONIVEL",   
                                                  plani.notobs[1])).     
                                                        
                limite-cred-scor = dec(acha("LIMITE-CREDITO",plani.notobs[1])).
            end.
            /* #1 */ 
            find clien where clien.clicod = plani.desti no-lock no-error.
            
            if limite-cred-scor = 0
            then assign limite-cred-scor = limite-cred-scor(recid(clien)).
            /* #1 */
            
            
            if vexibe and v-dis-venda = 0 then next.
            assign v-dis-venda = v-dis-venda - 
                       (if plani.biss <> 0 then plani.biss
                                           else plani.platot).
            
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
            
            if vexibe = yes 
            then do:
                if v-dis-venda < 0 
                then do:
                    if (contrato.vltotal + v-dis-venda) >  0 then next.
                end.
                else do:    
                    if (contrato.vltotal - v-dis-venda) > 0 then next.
                end.    
            end. 
            else if v-dis-venda < 0
                 then v-dis-venda = 0.
             
            assign vpagas = 0
                    pagas-base = 0
                  qtd-15  = 0
                  qtd-45  = 0
                  qtd-46  = 0
                  v-acum = 0
                  sal-aberto = 0
                  proximo-mes = 0.
                      
            for each fin.titulo where 
                     titulo.clifor = clien.clicod no-lock:

                /* #1 */
                if titulo.titnat <> no then next.
                /* #1 */    
                if titulo.modcod = "DEV" or
                   titulo.modcod = "BON" or
                   titulo.modcod = "CHP"
                then next.
                
                if titulo.titpar <> 0 then do:
                    if titulo.titsit = "LIB"
                    then do:
                        sal-aberto = sal-aberto + titulo.titvlcob.
                        if titulo.titdtven >= vdata1 and
                           titulo.titdtven <= vdata2
                        then proximo-mes = proximo-mes + titulo.titvlcob.
                    end.    
                    else vpagas = vpagas + 1.
                end.

                if titulo.titpar <> 0 and titulo.titdtpag <> ?
                then do:
                    if (titulo.titdtpag - titulo.titdtven) <= 15
                    then qtd-15 = qtd-15 + 1.
                    if (titulo.titdtpag - titulo.titdtven) >= 16 and
                        (titulo.titdtpag - titulo.titdtven) <= 45
                    then qtd-45 = qtd-45 + 1.
                    if (titulo.titdtpag - titulo.titdtven) >= 46
                    then qtd-46 = qtd-46 + 1.

                find first wacum where 
                           wacum.mes = month(titulo.titdtpag) and
                           wacum.ano = year(titulo.titdtpag) no-error.
                if not avail wacum
                then do:
                    create wacum.
                    assign wacum.mes = month(titulo.titdtpag)
                           wacum.ano = year(titulo.titdtpag).
                end.
                wacum.acum = wacum.acum + titulo.titvlcob.
                end.
           end.
           for each wacum by wacum.acum:
               v-acum = wacum.acum.
           end.
           for each wacum: delete wacum. end.
           
           find first credscor where 
                        credscor.clicod = clien.clicod no-lock no-error.
           if avail credscor
           then  do:
                assign 
                    vpagas = vpagas + credscor.numpcp
                    qtd-15 = qtd-15 + credscor.numa15
                    qtd-45 = qtd-45 + credscor.numa16
                    qtd-46 = qtd-46 + credscor.numa45
                    .
                if credscor.valacu > v-acum
                then v-acum = credscor.valacu.
           end.
           if vvalor <> 0 
           then do:
              if sal-aberto - limite-cred-scor < vvalor then 
                next.
           end.
           pagas-base = vpagas.
           find first posicli where 
                      posicli.clicod = clien.clicod
                      no-lock no-error.
            if avail posicli
            then  vpagas = vpagas + posicli.qtdparpg
            .

           create tt-limite.
           assign
            tt-limite.clicod = clien.clicod
            tt-limite.pladat = plani.pladat
            tt-limite.platot = plani.platot
            tt-limite.pate15 = qtd-15
            tt-limite.p16a45 = qtd-45
            tt-limite.parpag = vpagas
            tt-limite.limite = limite-cred-scor
            tt-limite.CreAbe = sal-aberto
            tt-limite.Maiacu = v-acum
            tt-limite.Promes = proximo-mes
            tt-limite.Profis = cpclien.var-int4
            tt-limite.Renda  = clien.prorenda[1]
            tt-limite.Nota   = cpclien.var-int3 
            tt-limite.pagas-base = pagas-base.
            .
            
        end.
    end.
end.
output stream stela close.

def var varquivo as char.

varquivo = "/admcom/relat/rlimexc21-" + string(vdti,"99999999") + "-" +
                    string(vdtf,"99999999") + "." + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "160" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rlimexc21"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """  VENDA LIMITE EXCEDIDO/LIBERADO """ 
                &Width     = "160"
                &Form      = "frame f-cabcab"}

disp with frame f-1.


for each tt-limite no-lock:
    find clien where clien.clicod = tt-limite.clicod no-lock.
    disp tt-limite.clicod column-label "Codigo"
         clien.clinom format "x(20)" column-label "Nome" 
         tt-limite.pladat column-label "Data!Compra"
         tt-limite.platot column-label "Valor!Compra"
         (tt-limite.pate15 / tt-limite.pagas-base) * 100 column-label "%Ate15"
         (tt-limite.p16a45 / tt-limite.pagas-base) * 100 column-label "%de16a45"
         tt-limite.parpag column-label "Parcelas!Pagas"
         tt-limite.limite column-label "Limite"
         tt-limite.CreAbe column-label "Credito!Aberto"
         tt-limite.Maiacu column-label "Maior!Acumulo"
         tt-limite.Promes column-label "Proximo!Mes"
         tt-limite.Profis column-label "Profissao"       format ">>9"
         tt-limite.Renda  column-label "Renda"
         tt-limite.Nota   column-label "Nota"            format ">>9"
         with width 170
    .

end. 
                            
output close.

run visurel.p(varquivo,"").
    
procedure callim-cred-scorp: 

def input   parameter rec-clien  as recid.
def output  parameter vcalclimite as dec.

def var vcalclim as dec.
def var vpardias as dec.

vcalclim = 0.
vpardias = 0.

def var limite-disponivel as dec init 0.
/*
connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.
*/              
run calccredscore.p (input "",
                        input rec-clien,
                        output vcalclim,
                        output vpardias,
                        output limite-disponivel).

/*disconnect dragao. 
*/
vcalclimite = vcalclim.

end procedure.    
    
    
