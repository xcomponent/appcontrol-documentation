# pycalc.py - perform some python calculation

import sys

def pycalc(arg1, arg2):
    """Return the product and division of the two arguments"""
    return arg1*arg2, arg1/arg2
        
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

# Command line argument
if len(sys.argv) != 3:
    print(f'Usage: {sys.argv[0]} <arg1> <arg2>')
    exit(-1)
arg1 = int(sys.argv[1])
arg2 = int(sys.argv[2])

try:
    prod, div = pycalc(arg1, arg2)
except ZeroDivisionError:
    print(f"""\
<appcontrol>
    {{
        'Message': 'pycalc: error, division by zero.',
    }}
</appcontrol>""")
    exit(1)

print(f"""\
<appcontrol>
    {{
        'Message': 'pycalc: success.',
        'OutputValues': {{
            'product': {prod},
            'division': {div},
         }}
    }}
</appcontrol>""")

exit(0)