interface memory_if();
    logic wen, ren;
    logic ready;
    logic [7:0] addr, rdata, wdata;

    modport request(
        input ready, rdata,
        output wen, ren, addr, wdata
    );

    modport response(
        input wen, ren, addr, wdata,
        output ready, rdata
    );

endinterface