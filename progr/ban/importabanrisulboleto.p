

def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.

run ban/importaboletoprocessa.p ("/admcom/tmp/boleto/banrisul/").

return.
