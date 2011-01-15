def equal(actual, expected):
  equal = expected == actual

  print 'PASS' if equal else 'FAIL "%s" "%s"' % (actual, expected)

  return equal
