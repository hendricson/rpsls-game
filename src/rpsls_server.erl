-module(rpsls_server).

-export([response/2]).

response(200 ,Str) ->
    B = iolist_to_binary(Str),
    iolist_to_binary(io_lib:fwrite("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: ~p\r\n\r\n~s", [size(B), B]));

response(404 ,Str) ->
    B = iolist_to_binary(Str),
    iolist_to_binary(io_lib:fwrite("HTTP/1.1 404 Not Found\r\nContent-Type: text/html\r\nContent-Length: ~p\r\n\r\n~s", [size(B), B])).
