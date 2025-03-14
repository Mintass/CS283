1. How does the remote client determine when a command's output is fully received from the server, and what techniques can be used to handle partial reads or ensure complete message transmission?

    > **Answer**: The client looks for an EOF character (`0x04`) at the end of received data. It keeps reading from the socket and accumulating data until it finds this special byte, which the server sends to mark the end of output. This approach handles situations where responses might be split across multiple `recv()` calls. Other options could include prefixing messages with their length or using different delimiter patterns.

2. This week's lecture on TCP explains that it is a reliable stream protocol rather than a message-oriented one. Since TCP does not preserve message boundaries, how should a networked shell protocol define and detect the beginning and end of a command sent over a TCP connection? What challenges arise if this is not handled correctly?

    > **Answer**: Since TCP is just a stream of bytes, your shell protocol defines its own message boundaries. Commands are sent as null-terminated strings, and responses end with an `EOF` character. Without proper framing, you'd face problems like incomplete commands, merged responses, endless waiting for more data, or buffer overflows. The protocol must ensure both sides agree on where messages start and end.

3. Describe the general differences between stateful and stateless protocols.

    > **Answer**: Stateful protocols maintain session information between requests - the server remembers client context and previous interactions. Your shell is stateful since it maintains connections and preserves working directory between commands. Stateless protocols don't retain client information - each request contains everything needed to process it, making them more resilient to failures but potentially less efficient for repeated interactions.

4. Our lecture this week stated that UDP is "unreliable". If that is the case, why would we ever use it?

    > **Answer**: UDP is used when speed matters more than perfect reliability. It offers lower latency and higher throughput by eliminating handshakes, acknowledgments and retransmissions. It's ideal for real-time applications like gaming, streaming and VoIP where fresh data is more valuable than ensuring every packet arrives. Sometimes it's better to get newer information quickly than wait for old data to be resent.

5. What interface/abstraction is provided by the operating system to enable applications to use network communications?

    > **Answer**: The socket interface. It abstracts network communications as file descriptors, letting applications send and receive data using familiar I/O patterns. Sockets hide the complexity of protocols, addressing schemes, and network hardware. Your shell relies on socket functions like `socket()`, `bind()`, `listen()`, `accept()`, `connect()`, `send()`, `recv()`, and `close()` to establish connections and transfer data.