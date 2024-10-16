DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
def output param    varquivo-return as char.
DEF OUTPUT PARAM    vpdf          AS CHAR.
{tsr/tsrelat.i}
{api/acentos.i}

{admcab.i}
{setbrw.i} 

DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field etbcod      AS int
    FIELD dti         AS char
    FIELD dtf         AS char.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
if not avail ttparametros then return.

def temp-table tt-contrato like contrato
    field vlparcelas as dec
    field vlorigem   as dec
    field qtdpar     as int.

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

                                                           
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.        
end.
find first tt-modalidade-padrao where
                   tt-modalidade-padrao.modcod = "CPN" no-error.
if not avail tt-modalidade-padrao
then do:
    create tt-modalidade-padrao.
    tt-modalidade-padrao.modcod = "CPN".
end. 
        
create tt-modalidade-selec.
assign tt-modalidade-selec.modcod = "CPN".
 
//assign vmod-sel = "  ".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
end.
display vmod-sel format "x(40)" no-label with frame f1.    
 
def var vdata as date.
def var val-orig as dec.
def var vtotal as dec.
def buffer ntitulo for titulo.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".

if ttparametros.dtf BEGINS "#" then do:
    vdtf = calculadata(ttparametros.dtf,TODAY).
end.
ELSE DO:
    vdtf = convertedata(ttparametros.dtf).
END.
if ttparametros.dti BEGINS "#" then do:
    vdti = calculadata(ttparametros.dti,TODAY).
end.
ELSE DO:
    vdti  = convertedata(ttparametros.dti).
END.

do vdata = vdti to vdtf:
    for each tt-modalidade-selec no-lock:
        for each contrato where dtinicial = vdata and
                 contrato.modcod = tt-modalidade-selec.modcod
                 no-lock.
            find first tt-contrato where
                       tt-contrato.contnum = contrato.contnum no-error.
            if not avail tt-contrato
            then do:
                create tt-contrato.
                buffer-copy contrato to tt-contrato.
            end.    
                       
            for each titulo where 
                     titulo.clifor = contrato.clicod and
                     titulo.titnum = string(contrato.contnum) and
                     titulo.titpar > 0 
                     no-lock.
                tt-contrato.vlparcelas = tt-contrato.vlparcelas +
                            titulo.titvlcob.
                tt-contrato.qtdpar = tt-contrato.qtdpar + 1.
            end.
            val-orig = 0.
            for each tit_novacao where ger_contnum = contrato.contnum no-lock.
                find first ntitulo where
                           ntitulo.empcod = ori_empcod and
                           ntitulo.titnat = ori_titnat and
                           ntitulo.modcod = ori_modcod and
                           ntitulo.etbcod = ori_etbcod and
                           ntitulo.clifor = ori_CliFor and
                           ntitulo.titnum = ori_titnum and
                           ntitulo.titpar = ori_titpar and
                           ntitulo.titdtemi = ori_titdtemi
                           no-lock no-error.
                if ntitulo.titvlpag < ntitulo.titvlcob
                then tt-contrato.vlorigem = tt-contrato.vlorigem +
                            ntitulo.titvlpag.
                else tt-contrato.vlorigem = tt-contrato.vlorigem +
                            ntitulo.titvlcob.
            end.
        end.
    end.        
end.

if AVAIL tsrelat then do:
    varquivo = replace(RemoveAcento(tsrelat.nomerel)," ","") +
    "-ID" + STRING(tsrelat.idrelat) + "-" +  
        STRING(TODAY,"99999999") +
        replace(STRING(TIME,"HH:MM:SS"),":","").
end.
ELSE DO:
    varquivo = "relcpn-" + STRING(TODAY,"99999999") +
                    replace(STRING(TIME,"HH:MM:SS"),":","").
END.

{mdadmcab.i 
                &Saida     = "VALUE(vdir + varquivo + """.txt""")"  
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""relcpn"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """ NOVACOES CREDITO PESSOAL""" 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

 
for each tt-contrato:
    disp tt-contrato.etbcod        column-label "Filial"
         tt-contrato.clicod        column-label "Cliente"
                format ">>>>>>>>>9"
         tt-contrato.contnum       column-label "Contrato"
                format ">>>>>>>>>9"
         tt-contrato.dtinicial     column-label "Emissao"
         tt-contrato.qtdpar        column-label "Quantidade!Parcelas"
         tt-contrato.vltotal(total)       column-label "Valor!Contrato"
                format ">,>>>,>>9.99"
         tt-contrato.vlparcelas(total)    column-label "Valor!Parcelas"
                format ">,>>>,>>9.99"
         tt-contrato.vlentra(total)       column-label "Entrada"
                format ">>>,>>9.99"
         tt-contrato.vlseguro(total)      column-label "Seguro"
         tt-contrato.vlorigem(total)      column-label "Valor!Origem"
                format ">,>>>,>>9.99"
         tt-contrato.vltotal - tt-contrato.vlorigem (total) 
                format "->>>,>>9.99"
         column-label "Valor!Renda"
         with frame f-disp down width 150
         .
end.         
         
output close.

/* run visurel.p(varquivo,""). */


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
