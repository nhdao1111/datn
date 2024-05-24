module lfsr #(
  parameter LFSR_LENGTH     = 32   , 
  parameter LFSR_POLY       = 32'h8020_0003, 
  parameter LFSR_SEED       = 32'b1    
) 
(
  input                            clk         , // Clock signal
  input                            rst_n     , // Asynchronous reset, active LOW
  input                            set       , // set
  input                            shift      , // Enable
  input      [LFSR_LENGTH-1:0    ] lfsr_seed   , // LFSR seed
  output  logic   [LFSR_LENGTH-1:0    ] lfsr_state  , // LFSR state
  output logic                          done          // Done
);

  logic                               feedback    ;
  logic [LFSR_LENGTH-1:0            ] sum_feedback;
  logic [LFSR_LENGTH-1:0            ] lfsr_reg    ;

 
  
  always_ff @(posedge clk or negedge rst_n) begin : proc_
   if(~rst_n) begin
      done <= 0;
    end else begin
      if(shift)
        done <=1;
      else 
        done <= 0;
    end
  end

  

  genvar i;
  generate
    for (i = 1; i < LFSR_LENGTH; i++) begin : proc_sum_feedback
      if (LFSR_POLY & (1'b1 << i)) begin
        assign sum_feedback[i] = sum_feedback[i-1] ^ lfsr_reg[i];
      end
      else begin
        assign sum_feedback[i] = sum_feedback[i-1];
      end
    end : proc_sum_feedback
  endgenerate

  assign sum_feedback[0] = lfsr_reg[0];

  assign feedback = sum_feedback[LFSR_LENGTH-1];

  always_ff @(posedge clk or negedge rst_n) begin : proc_lfsr_reg
    if(~rst_n) begin
      lfsr_reg <= LFSR_SEED;
    end else begin
      if (set) begin
        lfsr_reg <= lfsr_seed;
      end else if (shift) begin
        lfsr_reg <= {feedback, lfsr_reg[LFSR_LENGTH-1:1]};
      end
      else 
        lfsr_reg <= lfsr_reg;
    end
  end

 

  assign lfsr_state = lfsr_reg;

endmodule : lfsr