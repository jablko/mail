# Workaround, http://www.python.org/dev/peps/pep-3130/
config = { 'count': 0 }

def ok(condition, actual):
  config['count'] += 1

  print 'PASS' if condition else 'FAIL "%s"' % actual

  return condition

def equal(actual, expect):
  config['count'] += 1

  condition = expect == actual

  print 'PASS' if condition else 'FAIL "%s" "%s"' % (actual, expect)

  return condition

def expect(count):
  config['expect'] = count
