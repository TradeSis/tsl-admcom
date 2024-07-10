 /***
    Gerar PDF
***/

{pdf/pdf_inc.i}

def input parameter varqtxt as char.
def input parameter varqpdf as char.

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

/**
RUN pdf_rect2 ("Spdf", 5,715,525,70,0.5).
RUN pdf_rect2 ("Spdf", 5,645,525,70,0.5).
RUN pdf_rect2 ("Spdf", 5,625,525,20,0.5).
RUN pdf_rect2 ("Spdf", 5,585,525,40,0.5).
RUN pdf_load_image ("Spdf","ProSysLogo","/admcom/progr/logo-lebes2.jpg").
RUN pdf_place_image ("Spdf","ProSysLogo",10,70,135,55).
**/

RUN pdf_set_parameter("Spdf","UseTags","TRUE").
RUN pdf_set_parameter("Spdf","BoldFont","Courier-Bold").
RUN pdf_set_parameter("Spdf","DefaultFont","Courier").

def var varqpedid as char.
def var vlinha as char.
def var vct as int.
def var vwidth as int.

input from value(varqtxt).
repeat.
    import unformatted vlinha.
    vct = vct + 1.
    if vct > 1
    then do:
        if vlinha matches "*DREBES &*" and vct > 5
        then do:
            RUN pdf_new_page("Spdf").
            vct = 1.
        end. 
        if vct = 4
        then do:
            if length(vlinha) > 100
            then vlinha = trim(vlinha). 
            vlinha = "        " + vlinha.
        end.
        if vlinha begins "DREBES"
        then vlinha = "  " + vlinha.
        RUN pdf_text    ("Spdf", vlinha).    
        RUN pdf_skip("Spdf").
    end.
    if vlinha matches "*TOTAL*"
    then leave.
end.
input close.

RUN pdf_close("Spdf").

IF VALID-HANDLE(h_PDFinc) THEN
  DELETE PROCEDURE h_PDFinc.

