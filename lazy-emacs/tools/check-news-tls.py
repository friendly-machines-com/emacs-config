#!/usr/bin/env python3
"""Verify the configured public NNTP server's STARTTLS and certificate.
No credentials or article/group commands are sent. Failure is reported, never
worked around by choosing plaintext. Run with a working network/CA environment.
"""
import socket
import ssl
host = 'news.gmane.io'
with socket.create_connection((host, 119), timeout=8) as connection:
    stream = connection.makefile('rb')
    greeting = stream.readline().decode(errors='replace').strip()
    print('Greeting:', greeting)
    connection.sendall(b'CAPABILITIES\r\n')
    response = stream.readline().decode(errors='replace').strip()
    if not response.startswith('101'):
        raise RuntimeError('Server did not provide NNTP capabilities: ' + response)
    capabilities = []
    while True:
        line = stream.readline()
        if not line:
            raise RuntimeError('Connection closed before capabilities completed')
        if line == b'.\r\n':
            break
        capabilities.append(line.decode().strip())
    if not any(line.upper().startswith('STARTTLS') for line in capabilities):
        raise RuntimeError('Server does not advertise STARTTLS; plaintext fallback refused')
    connection.sendall(b'STARTTLS\r\n')
    response = stream.readline().decode().strip()
    if not response.startswith('382'):
        raise RuntimeError('STARTTLS rejected: ' + response)
    stream.close()
    with ssl.create_default_context().wrap_socket(connection, server_hostname=host) as secure:
        print('TLS verified:', secure.version(), secure.cipher()[0])
