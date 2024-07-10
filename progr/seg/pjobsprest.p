def var vdtini as date.
def var vdtfim as date.


def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.


{/admcom/progr/seg/segprest.i new}

vdtini = today - 1.
vdtfim = today.

run /admcom/progr/seg/pselsprest.p (input vdtini, input vdtfim).
run /admcom/progr/seg/pexpsprest.p (input "json", input vdtini, input vdtfim).

return.


