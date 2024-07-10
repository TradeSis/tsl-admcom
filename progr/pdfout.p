/*----------------------------------------------------------------
 Programa..: pdfout.p
 Autor.....: Rafael A. (Kbase)
 Descricao.: Programa que converte arquivos texto em arquivos PDF
 Utilizacao: run pdfout.p (
             input 'arquivo de entrada',
             input 'diretorio de saida',
             input 'nome arquivo saida',
             input 'orientacao: Landscape/Portrait',
             input 'tamanho fonte',
             input copia: 1- Nao/2- Sim,
             output variavelRetorno
             ).
             
             inserir nova pagina:
             "<page>"
             
 Fontes uso: liscqh.p, lisbon01.p, edit-arq.p, imptra_l.p,
             cre02_a.p, cre03_a.p, extrato2.p, cre_02_lp.p,
             cre03_lp.p, extrato3.p, relmontlj.p, respla.p,
             glo03.p, anaven2.p, imp_dev2.p,
 Alterações: 04/03/2015 - Criacao - Rafael A. (Kbase)
----------------------------------------------------------------*/

/* Exemplo de uso:------------------------------------------------
run pdfout.p (input varquivo,
              input "/usr/admcom/kbase/pdfout/",
              input "lischq-" + string(time) + ".pdf",
              input "Portrait",
              input 6.0,
              input 1,
              output vpdf).
              
message ("Arquivo " + vpdf + " gerado com sucesso!").
----------------------------------------------------------------*/                  
/*{admcab.i}*/

def new global shared var sremoto       as log.
def new global shared var setbcod       as int.

{/admcom/progr/pdf/pdf_inc.i}

def input  param p-arq      as char no-undo.
def input  param vdir       as char no-undo.
def input  param p-arqpdf   as char no-undo.
def input  param vorient    as char no-undo.
def input  param vtamfonte  as dec  no-undo.
def input  param vCopia     as int  no-undo.
def output param p-nome-pdf as char no-undo.

def        var   varqpdf    as char no-undo.  
def        var   vlinha     as char no-undo.
def        var   vcont      as int  no-undo.
def        var   vLMargin   as int  no-undo.
def        var   vContLinha as int  no-undo.

varqpdf = vdir + p-arqpdf.

RUN pdf_new ("Spdf", varqpdf).

RUN pdf_set_Orientation ("Spdf", vorient).

RUN pdf_new_page("Spdf").

RUN pdf_set_parameter("Spdf","DefaultFont","Courier").
RUN pdf_set_font("Spdf","Courier", vtamfonte).

do vcont = 1 to vCopia:
    input from value(p-arq).
    
    vContLinha = 0.
    
    repeat.
        import unformatted vlinha.
        vContLinha = vContLinha + 1.
        /*
        if vCopia > 1 and vContLinha > 5 then
            RUN pdf_set_font("Spdf","Courier", 10.0).
        */                 
        if (vlinha = "<page>") then
            RUN pdf_new_page("Spdf").
        else
            RUN pdf_text("Spdf", vlinha).

        RUN pdf_skip("Spdf").
    end.
    if vCopia > 1 and vcont < vCopia then do:
        RUN pdf_set_font("Spdf","Courier", vtamfonte).
        
        /* escreve linha separacao */
        RUN pdf_skip("Spdf").
        
        vLMargin = pdf_LeftMargin("Spdf").
        RUN pdf_set_LeftMargin("Spdf", 1).
        
        RUN pdf_text("Spdf", "Copia da Loja").                
        RUN pdf_skip("Spdf").
        
        RUN pdf_set_LeftMargin("Spdf", vLMargin).
                                                       
        RUN pdf_text("Spdf", fill("- ", 100)).
        RUN pdf_skip("Spdf").
                      
        RUN pdf_text("Spdf", "Copia do SSC").
        RUN pdf_skipn("Spdf", 2).
    end.
end.
RUN pdf_close("Spdf").

p-nome-pdf = p-arqpdf.

IF VALID-HANDLE(h_PDFinc) THEN
    DELETE PROCEDURE h_PDFinc.

/* enviar arquivos para as loja */
if sremoto
then do.
    unix silent value("mv " + vdir + p-arqpdf +
                       " /admcom/relat-loja/filial" + string(setbcod,"999") +
                       "/relat").
    message "Arquivo" p-arqpdf "gerado com sucesso!" view-as alert-box.
end.
