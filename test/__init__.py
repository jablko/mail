import sys, untwisted
from testify import *
from twisted.internet import reactor
from twisted.python import log
from untwisted import promise

def sdfg(callback):
  log.startLogging(sys.stdout)

  # Test complete whether success or exception
  callback().then(promise.promise()).then(lambda _: reactor.stop())

  reactor.callLater(3, reactor.stop)
  reactor.run()
