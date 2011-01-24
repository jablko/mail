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

from twisted.internet import defer, protocol
from twisted.mail import smtp

class Message:
  def __init__(self):
    self.data = []

  def eomReceived(self):
    try:
      equal("\n".join(self.data) + "\n", self.item['data'])

    except KeyError:
      pass

    return defer.succeed(None)

  def lineReceived(self, line):
    self.data.append(line)

class Server(smtp.ESMTP):
  def __init__(self, *args, **kw):
    self.expect = []

    return smtp.ESMTP.__init__(self, *args, **kw)

  def do_UNKNOWN(self, rest):
    raise

  def receivedHeader(self, helo, origin, recipients):
    pass

  def validateFrom(self, helo, origin):
    self.item = self.expect.pop(0)

    try:
      equal(str(origin), self.item['from'])

    except KeyError:
      pass

    return origin

  def validateTo(self, user):
    try:
      equal(str(user), self.item['to'].pop(0))

    except KeyError:
      pass

    message = Message()
    message.item = self.item

    return lambda: message

# ESMTPFactory doesn't exist
class ServerFactory(smtp.SMTPFactory):
  protocol = []

  def buildProtocol(self, addr):
    return self.protocol.pop(0)

class Client(smtp.ESMTPClient):

  # Shortcut ESMTPClient.__init__(), no authentication or TLS
  def __init__(self, *args, **kw):
    self.message = []
    self.secret = None

    return smtp.SMTPClient.__init__(self, 'example.com', *args, **kw)

  def getMailData(self):
    return self.item['data']

  def getMailFrom(self):
    return self.item['from']

  def getMailTo(self):
    return self.item['to']

  def smtpState_from(self, code, resp):
    self.item = self.message.pop(0)

    return smtp.ESMTPClient.smtpState_from(self, code, resp)

  def smtpState_msgSent(self, code, resp):
    if self.message:
      self._from = None
      self.toAddressesResult = []

      return self.smtpState_from(code, resp)

    # No more messages to send
    self._disconnectFromServer()

class ClientFactory(protocol.ClientFactory):
  protocol = []

  def buildProtocol(self, addr):
    return self.protocol.pop(0)
