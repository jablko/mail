import sys, untwisted
from testify import *
from twisted.internet import reactor
from twisted.python import log
from untwisted import promise

def sdfg(cbl):
  log.startLogging(sys.stdout)

  # Test complete whether success or exception
  cbl().then(promise.promise()).then(lambda _: reactor.stop())

  reactor.callLater(2, reactor.stop)
  reactor.run()
