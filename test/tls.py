import untwisted
from ctypes import byref, create_string_buffer
from gnutls.errors import OperationWouldBlock
from gnutls.library.constants import GNUTLS_CLIENT, GNUTLS_CRD_ANON
from gnutls.library.functions import gnutls_anon_allocate_client_credentials, gnutls_credentials_set, gnutls_handshake, gnutls_init, gnutls_priority_set_direct, gnutls_record_recv, gnutls_record_send, gnutls_transport_set_ptr
from gnutls.library.types import gnutls_anon_client_credentials_t, gnutls_session_t
from untwisted import promise

def startTls(transport):
  session = gnutls_session_t()
  gnutls_init(byref(session), GNUTLS_CLIENT)

  gnutls_priority_set_direct(session, 'PERFORMANCE:+ANON-DH', None)

  anoncred = gnutls_anon_client_credentials_t()
  gnutls_anon_allocate_client_credentials(byref(anoncred))
  gnutls_credentials_set(session, GNUTLS_CRD_ANON, anoncred)

  gnutls_transport_set_ptr(session, transport.socket.fileno())

  def callback():
    try:
      gnutls_handshake(session)

    except OperationWouldBlock:
      return

    del transport.doRead

    @untwisted.partial(setattr, transport.socket, 'recv')
    def _(size):
      data = create_string_buffer(size)
      size = gnutls_record_recv(session, data, size)

      return data[:size]

    transport.socket.send = lambda data: gnutls_record_send(session, str(data), len(data))

    asdf(None)

  asdf = promise.promise()

  transport.doRead = callback
  callback()

  return asdf
