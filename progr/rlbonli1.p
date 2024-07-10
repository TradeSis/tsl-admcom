{admcab.i}

FUNCTION mesfim returns date(input par-data as date).

  return ((DATE(MONTH(par-data),28,YEAR(par-data)) + 4) -     DAY(DATE(MONTH(par-data),28,YEAR(par-data)) + 4)).

end function.

def temp-table tt-sel
    field etbcod like plani.etbcod 
    field clifor like plani.desti
    field qtdp    as int
    field qtdr    as int
    field valor  as dec
    index i1 etbcod clifor.

def new shared temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    
    index iclicod is primary unique clicod.
    
def var vok as log.    
    
def var vdti as date.
def var vdtf as date.

def var vcont as integer.

def var vetbi as char.
def var vetbf as char.

def var v-env-mail as char.
def var v-texto as char.

def var vdt-aux as date.

def var v-ok-email as logical.

def var vrelat as log format "Sim/Nao".
def var vacao as log format "Sim/Nao".

def stream str-txt.
                                                        
def var varquivo as character.                                                 
assign vdt-aux = mesfim(today) + 1.   
                                                    
assign vdtf = mesfim(vdt-aux)
       vdti = date(month(vdt-aux),01,year(vdt-aux)).
       
find last estab where estab.etbcod < 800 no-lock no-error. 

assign vetbi = "1"
       vetbf = string(estab.etbcod).
       
update vetbi label "Filial " format "x(4)"
       "      a "
       vetbf format "x(4)"no-label  skip
       vdti label "Periodo" format "99/99/9999"
       "a"
       vdtf format "99/99/9999" no-label skip
       
            with frame f-dat centered color blue/cyan row 8
                                 title " Periodo " side-labels.
                                    
if opsys = "UNIX"
then varquivo = "/admcom/relat/rlbonli1." + string(time).
else varquivo = "l:\relat\rlbonli1." + string(time).

repeat.
    vrelat = no . vacao = no.
    
    update vrelat label "Relatorio"
           vacao   label "Acao"
           with frame f-tipo 1 down centered row 10 side-label.
    
    if vrelat = no and vacao = no
    then leave.       
    if vrelat
    then do:
        
{mdad.i
    &Saida     = "value(varquivo)"
    &Page-Size = "0"
    &Cond-Var  = "120"
    &Page-Line = "0"
    &Nom-Rel   = ""RLBONLI1""
    &Nom-Sis   = """SISTEMA DE CRM"""
    &Tit-Rel   = """LISTAGEM DE BONUS NAO UTILIZADOS"""
    &Width     = "138"
    &Form      = "frame f-cabcab"}

disp with frame f-dat.

for each titulo where titulo.modcod = "BON"
                  and titulo.empcod = 19
                  and titulo.titnat   = yes
                  and titulo.titdtven >= vdti
                  and titulo.titdtven <= vdtf
                  and titulo.titsit = "LIB" no-lock,

    first clien where clien.clicod = titulo.clifor no-lock:

    if titulo.etbcod < integer(vetbi) or titulo.etbcod > integer(vetbf)
    then next.
    
    find first acao where acao.acaocod = int(titulo.titobs[1]) no-lock no-error.

    run pfval_mail2.p (input clien.zona, output v-ok-email).
                    
    if (not v-ok-email and (clien.fax = "" or clien.fax = ?)) or clien.zona = ?
    then next.

    display clien.clicod
            clien.clinom   format "x(30)"
            titulo.etbcod column-label "Fil"
            clien.zona format "x(30)" column-label "E-Mail"
            clien.fax format "x(14)" column-label "Celular"
            titulo.titvlcob  (total) column-label "Vl. Bonus"
            acao.acaocod when avail acao  format ">>>>>>9"
            acao.descricao when avail acao format "x(20)"
            titulo.titdtven
                                with frame f01 down width 160.
                            
end.
                            
output close.                            

if opsys = "UNIX"
then do:
    message "Arquivo gerado: " varquivo. pause.
                                           
    run visurel.p (input varquivo, input "").
        
end.    
else do:
    {mrod.i}
end.    
end. /* if vrelat */
leave.
end.


/*********/
if vacao
then do:
if connected ("crm")
then disconnect crm.

/*** Conectando Banco CRM no server CRM ***/
connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

               
if not connected ("crm")
then do:
    message "Nao foi possivel conectar o banco CRM. Avise o CPD.".
    pause.
    leave.
end.

run cria-tt-sel.

for each tt-sel :
    find clien where clien.clicod = tt-sel.clifor no-lock.
    create tt-cli.
    tt-cli.clicod = clien.clicod.
    tt-cli.clinom = clien.clinom.
end.    
run rfv000-brw.p.

if connected ("crm")
then disconnect crm.

end.

procedure cria-tt-sel.

for each titulo where titulo.modcod = "BON"
                  and titulo.empcod = 19
                  and titulo.titnat   = yes
                  and titulo.titdtven >= vdti
                  and titulo.titdtven <= vdtf
                  and titulo.titsit = "LIB" no-lock,

    first clien where clien.clicod = titulo.clifor no-lock:

    if titulo.etbcod < integer(vetbi) or titulo.etbcod > integer(vetbf)
    then next.
    
    find first acao where acao.acaocod = int(titulo.titobs[1]) no-lock no-error.

    run pfval_mail2.p (input clien.zona, output v-ok-email).
                    
    if (not v-ok-email and (clien.fax = "" or clien.fax = ?)) or clien.zona = ?
    then next.
    
    find first tt-sel where
                   tt-sel.etbcod = titulo.etbcobra  and
                   tt-sel.clifor = clien.clicod no-error.
    if not avail tt-sel
    then do:           
            create tt-sel.
            assign
                tt-sel.etbcod = titulo.etbcobra
                tt-sel.clifor = clien.clicod.
    end.
    tt-sel.qtdp = tt-sel.qtdp + 1.
    vok = no.
    for each contrato where 
             contrato.etbcod = estab.etbcod and
             contrato.clicod = titulo.clifor and
             contrato.dtinicial = titulo.titdtpag
             no-lock.
        vok = yes.
        tt-sel.valor = tt-sel.valor + contrato.vltotal + contrato.vlentra.
    
    end.
    if vok = yes
    then tt-sel.qtdr = tt-sel.qtdr + 1.

end.

end procedure.

