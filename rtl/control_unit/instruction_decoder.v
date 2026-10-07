`timescale 1ns/1ps

// Connects the per-opcode modules and combines their control words.
module instruction_decoder (
    input  wire [7:0] opcode,
    output wire recognized,
    output wire [16:0] controls
);
    wire [17:0] nop_word, movi_word, mov_word, add_word, sub_word, cmp_word;
    wire [17:0] load_word, store_word, jmp_word, beq_word, bne_word;
    wire [17:0] in_word, out_word, halt_word;

    instruction_nop i_nop(
        .opcode(opcode), .decoded(nop_word)
    );
    instruction_movi i_movi(
        .opcode(opcode), .decoded(movi_word)
    );
    instruction_mov i_mov(
        .opcode(opcode), .decoded(mov_word)
    );
    instruction_add i_add(
        .opcode(opcode), .decoded(add_word)
    );
    instruction_sub i_sub(
        .opcode(opcode), .decoded(sub_word)
    );
    instruction_cmp i_cmp(
        .opcode(opcode), .decoded(cmp_word)
    );
    instruction_load i_load(
        .opcode(opcode), .decoded(load_word)
    );
    instruction_store i_store(
        .opcode(opcode), .decoded(store_word)
    );
    instruction_jmp i_jmp(
        .opcode(opcode), .decoded(jmp_word)
    );
    instruction_beq i_beq(
        .opcode(opcode), .decoded(beq_word)
    );
    instruction_bne i_bne(
        .opcode(opcode), .decoded(bne_word)
    );
    instruction_in i_in(
        .opcode(opcode), .decoded(in_word)
    );
    instruction_out i_out(
        .opcode(opcode), .decoded(out_word)
    );
    instruction_halt i_halt(
        .opcode(opcode), .decoded(halt_word)
    );

    wire [17:0] decoded = nop_word | movi_word | mov_word | add_word |
                          sub_word | cmp_word | load_word | store_word |
                          jmp_word | beq_word | bne_word | in_word |
                          out_word | halt_word;

    assign recognized = decoded[17];
    assign controls = decoded[16:0];
endmodule
