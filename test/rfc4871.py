from qwer import *
from untwisted import rfc5234, rfc5322

ALNUMPUNC = qwer('(?:', rfc5234.ALPHA, '|', rfc5234.DIGIT, '|_)')
tagName = qwer(rfc5234.ALPHA, '(?:', ALNUMPUNC, ')*')

# EXCLAMATION to TILDE except SEMICOLON
VALCHAR = qwer('[!-:<-~]')

tval = qwer('(?:', VALCHAR, ')+')

# WSP and FWS prohibited at beginning and end
tagValue = qwer('(?:', tval, '(?:(?:', rfc5234.WSP, '|', rfc5322.FWS, ')+', tval, ')*)?')

tagSpec = qwer('(?:', rfc5322.FWS, ')?', tagName, '(?:', rfc5322.FWS, ')?=(?:', rfc5322.FWS, ')?', tagValue, '(?:', rfc5322.FWS, ')?')
tagList = qwer(tagSpec, '(?:;', tagSpec, ')*;?')
