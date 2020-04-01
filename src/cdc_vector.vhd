library ieee;
use ieee.std_logic_1164.all;

-- This block is a simple one-deep asynchronous FIFO, which can be used
-- as a Clock Domain Crossing of a vector signal.

-- The handshaking protocol ensures that data is only transferred when
-- both valid and ready are asserted.

-- Note, the signal src_ready_o reflects the FIFOs ability to receive.
-- It does NOT reflect the status of the dst_ready_i signal.

-- When ingress data is received, src_ready_o goes low until the data has
-- been delivered to the egress side, then src_ready_o goes high again.

entity cdc_vector is
   generic (
      G_SIZE : integer
   );
   port (
      src_clk_i   : in  std_logic;
      src_valid_i : in  std_logic;
      src_ready_o : out std_logic;
      src_data_i  : in  std_logic_vector(G_SIZE-1 downto 0);

      dst_clk_i   : in  std_logic;
      dst_valid_o : out std_logic;
      dst_ready_i : in  std_logic;
      dst_data_o  : out std_logic_vector(G_SIZE-1 downto 0)
   );
end cdc_vector;

architecture structural of cdc_vector is

   signal src_decrement_s  : std_logic;
   signal src_fifo_data_r  : std_logic_vector(G_SIZE-1 downto 0);
   signal src_fifo_valid_d : std_logic;
   signal src_fifo_valid_r : std_logic := '0';
   signal src_increment_r  : std_logic;

   signal dst_decrement_s  : std_logic;
   signal dst_fifo_data_s  : std_logic_vector(G_SIZE-1 downto 0);
   signal dst_fifo_valid_r : std_logic := '0';
   signal dst_increment_s  : std_logic;

   -- Debug
   constant C_DEBUG_MODE                    : boolean := false;

   attribute mark_debug                     : boolean;
   attribute mark_debug of dst_data_o       : signal is C_DEBUG_MODE;
   attribute mark_debug of dst_decrement_s  : signal is C_DEBUG_MODE;
   attribute mark_debug of dst_fifo_data_s  : signal is C_DEBUG_MODE;
   attribute mark_debug of dst_fifo_valid_r : signal is C_DEBUG_MODE;
   attribute mark_debug of dst_increment_s  : signal is C_DEBUG_MODE;
   attribute mark_debug of dst_ready_i      : signal is C_DEBUG_MODE;
   attribute mark_debug of dst_valid_o      : signal is C_DEBUG_MODE;
   attribute mark_debug of src_data_i       : signal is C_DEBUG_MODE;
   attribute mark_debug of src_decrement_s  : signal is C_DEBUG_MODE;
   attribute mark_debug of src_fifo_data_r  : signal is C_DEBUG_MODE;
   attribute mark_debug of src_fifo_valid_d : signal is C_DEBUG_MODE;
   attribute mark_debug of src_fifo_valid_r : signal is C_DEBUG_MODE;
   attribute mark_debug of src_increment_r  : signal is C_DEBUG_MODE;
   attribute mark_debug of src_ready_o      : signal is C_DEBUG_MODE;
   attribute mark_debug of src_valid_i      : signal is C_DEBUG_MODE;

begin

   ------------------------------------------------------------------
   -- We can accept data into FIFO, if it is currently empty.
   ------------------------------------------------------------------

   src_ready_o <= not src_fifo_valid_r;


   ------------------------------------------------------------------
   -- Update FIFO
   ------------------------------------------------------------------

   p_src_fifo : process (src_clk_i)
   begin
      if rising_edge(src_clk_i) then
         -- Output has consumed the FIFO contents.
         if src_decrement_s = '1' then
            src_fifo_valid_r <= '0';
         end if;

         -- Store incoming data into FIFO
         if src_valid_i = '1' and src_ready_o = '1' then
            src_fifo_valid_r <= '1';
            src_fifo_data_r  <= src_data_i;
         end if;
      end if;
   end process p_src_fifo;


   ------------------------------------------------------------------
   -- Copy FIFO contents to dst clock domain
   ------------------------------------------------------------------

   i_cdc_fifo_data : entity work.cdc
      generic map (
         G_SIZE => G_SIZE
      )
      port map (
         src_clk_i => src_clk_i,
         src_dat_i => src_fifo_data_r,
         dst_clk_i => dst_clk_i,
         dst_dat_o => dst_fifo_data_s
      ); -- i_cdc_fifo_data


   ------------------------------------------------------------------
   -- Indicate transition in FIFO.
   -- src_increment_r is pulsed for one clock cycle only.
   ------------------------------------------------------------------

   p_increment : process (src_clk_i)
   begin
      if rising_edge(src_clk_i) then
         src_increment_r  <= src_fifo_valid_r and not src_fifo_valid_d;
         src_fifo_valid_d <= src_fifo_valid_r;
      end if;
   end process p_increment;


   ------------------------------------------------------------------
   -- Copy transition to dst clock domain as one pulse only.
   ------------------------------------------------------------------

   i_pulse_conv_increment : entity work.pulse_conv
      port map (
         src_clk_i   => src_clk_i,
         src_pulse_i => src_increment_r,
         dst_clk_i   => dst_clk_i,
         dst_pulse_o => dst_increment_s
      ); -- i_pulse_conv_increment


   ------------------------------------------------------------------
   -- State transition in dst clock domain.
   ------------------------------------------------------------------

   p_dst_fifo_valid : process (dst_clk_i)
   begin
      if rising_edge(dst_clk_i) then
         if dst_increment_s = '1' then
            dst_fifo_valid_r <= '1';
         end if;

         if dst_decrement_s = '1' then
            dst_fifo_valid_r <= '0';
         end if;
      end if;
   end process p_dst_fifo_valid;


   ------------------------------------------------------------------
   -- Present FIFO to output
   ------------------------------------------------------------------

   dst_valid_o <= dst_fifo_valid_r;
   dst_data_o  <= dst_fifo_data_s;


   ------------------------------------------------------------------
   -- Determine whether output consumes FIFO
   -- This is a pulse of one clock cycle only.
   ------------------------------------------------------------------

   dst_decrement_s <= dst_valid_o and dst_ready_i;


   ------------------------------------------------------------------
   -- Copy transition to src clock domain as one pulse only.
   ------------------------------------------------------------------

   i_pulse_conv_decrement : entity work.pulse_conv
      port map (
         src_clk_i   => dst_clk_i,
         src_pulse_i => dst_decrement_s,
         dst_clk_i   => src_clk_i,
         dst_pulse_o => src_decrement_s
      ); -- i_pulse_conv_decrement


end architecture structural;

