def ok(condition, actual):
  print 'PASS' if condition else 'FAIL "%s"' actual

  return condition

def equal(actual, expected):
  condition = expected == actual

  print 'PASS' if condition else 'FAIL "%s" "%s"' % (actual, expected)

  return condition
