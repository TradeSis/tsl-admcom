{admcab.i}

def input parameter par-rec as recid.

def var vuser     as char.
def var vaspas    as char.
def var vcomando  as char.
def var vassunto  as char.
def var varqtexto as char.
def var varqzip   as char.
def var varqpdf   as char.
def var varqpedid as char.
def var vct       as int.
def var vlinha    as char.
def var vemail    like forne.email.
def var vemail2   like forne.email.
def var vetiqueta like sresp init yes.
def var vdir      as char.

def temp-table wetique
    field wrec as recid
    field wqtd as int.

find pedid where recid(pedid) = par-rec no-lock.
find forne where forne.forcod = pedid.clfcod no-lock.

assign
    vuser   = lower(userid("com"))
    vemail  = forne.email
    vemail2 = "pedidos.moda@lebes.com.br".

message "ROTINA ESTA EM PRODUCAO: E-MAIL ***SERA*** ENVIADO AO FORNECEDOR"
        view-as alert-box.

disp
    vuser     label "Usuario" colon 17 format "x(30)"
    forne.forcod colon 17
    forne.fornom no-label
    vemail    colon 17
    vemail2   colon 17 label "CC"
    vetiqueta colon 17 label "Emitir etiqueta?"
    with frame f-forne side-label centered.

update
    vemail  validate (length(vemail) > 10, "E-mail invalido")
/***
    vemail2 validate (length(vemail2) > 15, "E-mail invalido")
***/
    vetiqueta
    with frame f-forne.

/***
    Relatorio
***/
run lpedid_mail.p (par-rec, vetiqueta, output varqpedid).

/***
    Etiquetas
etinv02a.p
***/

if vetiqueta
then do.
    find pedid where recid(pedid) = par-rec no-lock.
    for each liped of pedid no-lock.
        find produ of liped no-lock.
        create wetique.
        assign wetique.wrec = recid(produ)
               wetique.wqtd = liped.lipqtd.
    end.

    assign
        vdir    = "/admcom/zebra/" + vuser + "/".
        varqzip = "lebes" + string(pedid.pednum) + ".zip".

    /* Criar usuario */
    if search(vdir + "zipa.sh") = ?
    then do.
        unix silent value ("mkdir " + vdir).
        /***unix silent value("cp /admcom/zebra/P*.EXE " + vdir).***/
        unix silent value("cp /admcom/zebra/LEBES.GRF " + vdir).
        unix silent value("cp /admcom/zebra/uzipa-mail.eti " + vdir).
    end.
    /* */

    unix silent value("rm -f " + vdir + "eti-lebes.bat").
    unix silent value("rm -f " + vdir + "eti-lebes.eti").
    unix silent value("rm -f " + vdir + "c*").
    unix silent value("rm -f " + vdir + varqzip).
    unix silent value("rm -f " + vdir + "*.ZIP").
    unix silent value("rm -f " + vdir + "*.zip").
    unix silent value("rm -f " + vdir + "*.pdf").

    output to value(vdir + "zipa.sh").
    put unformatted
        "cd " vdir skip
        "zip -q --password lebes lebes.zip c* *.eti *.GRF" /*PKUNZIP.EXE*/ skip
        "zip -q " varqzip " lebes.zip" skip.
    output close.
    unix silent value("chmod 777 " + vdir + "zipa.sh").
    
    for each wetique no-lock:
        run etinv02b.p (wetique.wrec,
                        wetique.wqtd,
                        "",
                        vuser).
    end.
    unix silent value(vdir + "zipa.sh").
end.

/***
    Corpo do e-mail
***/
varqtexto = "/admcom/relat/email" + string(time).
output to value(varqtexto).
put unformatted
    "Segue em anexo pedido de compra de Drebes e Cia Ltda" skip(1)
    "Pedido nro." pedid.pednum skip
    "Data: " pedid.peddat skip.
output close.

/***
    Gerar PDF
***/

{pdf/pdf_inc.i}

varqpdf = vdir + "lebes" + string(pedid.pednum) + ".pdf".

RUN pdf_new ("Spdf", varqpdf).
RUN pdf_new_page("Spdf").

/***
RUN pdf_set_parameter("Spdf","Compress","TRUE"). 
***/


/*
/* Set Page Header procedure */
pdf_PageHeader ("Spdf",
                THIS-PROCEDURE:HANDLE,
                "PageHeader").
*/
/***
/* Set Page Header procedure */
pdf_PageFooter ("Spdf",
                THIS-PROCEDURE:HANDLE,
                "PageFooter").
***/
RUN pdf_set_LeftMargin("Spdf",20).
RUN pdf_set_BottomMargin("Spdf",50).


RUN pdf_rect2 ("Spdf", 5,715,525,70,0.5).
RUN pdf_rect2 ("Spdf", 5,645,525,70,0.5).
RUN pdf_rect2 ("Spdf", 5,625,525,20,0.5).
RUN pdf_rect2 ("Spdf", 5,585,525,40,0.5).
RUN pdf_load_image ("Spdf","ProSysLogo","/admcom/progr/logo-lebes2.jpg").
RUN pdf_place_image ("Spdf","ProSysLogo",10,70,155,55).

RUN pdf_set_parameter("Spdf","UseTags","TRUE").
RUN pdf_set_parameter("Spdf","BoldFont","Courier-Bold").
RUN pdf_set_parameter("Spdf","DefaultFont","Courier").


input from value(varqpedid).
repeat.
    import unformatted vlinha.
    vct = vct + 1.

    RUN pdf_text    ("Spdf", vlinha).    
/*
    RUN pdf_text_at ("Spdf", vlinha,10).
*/
    RUN pdf_skip("Spdf").
end.

RUN pdf_close("Spdf").

IF VALID-HANDLE(h_PDFinc) THEN
  DELETE PROCEDURE h_PDFinc.

/***
    Enviar e-mail
***/

find pedid where recid(pedid) = par-rec no-lock.
find forne where forne.forcod = pedid.clfcod no-lock.

vaspas   = chr(34).
vassunto = "Ordem de Compra n." + string(pedid.pednum) + 
           " - Drebes e Cia Ltda - " + forne.fornom.

/* E-mail ao fornecedor */
unix silent value(
    "echo | mutt -s " + 
    vaspas + vassunto + vaspas +
    " -a " + varqpdf   +
    (if vetiqueta then " -a " + vdir + varqzip else "") +
    (if vemail2 <> "" then " -c " + vemail2 else "") +
    " -i " + varqtexto +
    " -- " + vemail ).

/* E-mail interno */
unix silent value(
    "echo | mutt -s " + 
    vaspas + vassunto + vaspas +
    " -a " + varqpdf   +
    " -i " + varqtexto +
    " -- " + vemail2 ).

/***
    Copia do zip e pdf
***/
if vetiqueta
then unix silent value("cp " + vdir + varqzip + " /admcom/zebra/Pedidos/").

unix silent value("cp " + varqpdf + " /admcom/zebra/Pedidos/").


/***
PROCEDURE PageFooter:

/*-----------------------------------------------------------------------------

  Purpose:  Procedure to Print Page Footer -- on all pages.
  -----------------------------------------------------------------------------*/
    /* Set Footer Font Size and Colour */
/***
    RUN pdf_set_font ("Spdf","Courier-Bold",10.0).  
    RUN pdf_text_color ("Spdf",0.0,.0,.0).
    RUN pdf_skip ("Spdf").
    RUN pdf_set_dash ("Spdf",1,0).
    RUN pdf_line ("Spdf", 
                  pdf_LeftMargin("Spdf"), 
                  pdf_TextY("Spdf") - 5, 
                  pdf_PageWidth("Spdf") - 20 , 
                  pdf_TextY("Spdf") - 5, 1).
    RUN pdf_skip ("Spdf").
    RUN pdf_skip ("Spdf").
***/
    RUN pdf_text_to ("Spdf", "Pagina: " + STRING(pdf_page("Spdf")) + " de " + 
                    pdf_TotalPages("Spdf"), 110).

END. /* PageFooter */
***/
