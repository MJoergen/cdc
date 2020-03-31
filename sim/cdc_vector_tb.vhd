library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity cdc_vector_tb is
   generic (
      G_SRC_CLK_PERIOD : integer;
      G_DST_CLK_PERIOD : integer;
      G_RATE_GEN       : integer;
      G_RATE_VERIFY    : integer
   );
end entity cdc_vector_tb;

architecture simulation of cdc_vector_tb is

   constant C_SIZE    : integer := 5;
   constant C_SEED    : integer := 1234567890;

   signal src_clk_s   : std_logic;
   signal src_valid_s : std_logic;
   signal src_ready_s : std_logic;
   signal src_data_s  : std_logic_vector(C_SIZE-1 downto 0);

   signal dst_clk_s   : std_logic;
   signal dst_valid_s : std_logic;
   signal dst_ready_s : std_logic;
   signal dst_data_s  : std_logic_vector(C_SIZE-1 downto 0);
   signal dst_error_s : std_logic;

begin

   ------------------------------------------------------------------
   -- Clock generation
   ------------------------------------------------------------------

   p_src_clk : process
   begin
      src_clk_s <= '1', '0' after G_SRC_CLK_PERIOD*0.5 ns;
      wait for G_SRC_CLK_PERIOD*1 ns;
   end process;

   p_dst_clk : process
   begin
      dst_clk_s <= '1', '0' after G_DST_CLK_PERIOD*0.5 ns;
      wait for G_DST_CLK_PERIOD*1 ns;
   end process;


   ------------------------------------------------------------------
   -- Generate stream of test data
   ------------------------------------------------------------------

   i_sim_gen_data : entity work.sim_gen_data
      generic map (
         G_RATE => G_RATE_GEN,
         G_SEED => C_SEED,
         G_SIZE => C_SIZE
      )
      port map (
         clk_i   => src_clk_s,
         valid_o => src_valid_s,
         ready_i => src_ready_s,
         data_o  => src_data_s
      ); -- i_sim_gen_data


   ------------------------------------------------------------------
   -- Instantiate DUT
   ------------------------------------------------------------------

   i_cdc_vector : entity work.cdc_vector
      generic map (
         G_SIZE => C_SIZE
      )
      port map (
         src_clk_i   => src_clk_s,
         src_valid_i => src_valid_s,
         src_ready_o => src_ready_s,
         src_data_i  => src_data_s,
         dst_clk_i   => dst_clk_s,
         dst_valid_o => dst_valid_s,
         dst_ready_i => dst_ready_s,
         dst_data_o  => dst_data_s
      ); -- i_cdc_vector


   ------------------------------------------------------------------
   -- Verify stream of test data
   ------------------------------------------------------------------

   i_sim_verify_data : entity work.sim_verify_data
      generic map (
         G_RATE => G_RATE_VERIFY,
         G_SEED => C_SEED,
         G_SIZE => C_SIZE
      )
      port map (
         clk_i   => dst_clk_s,
         valid_i => dst_valid_s,
         ready_o => dst_ready_s,
         data_i  => dst_data_s,
         error_o => dst_error_s
      ); -- i_sim_verify_data

   p_verify : process (dst_clk_s)
   begin
      if rising_edge(dst_clk_s) then
         assert dst_error_s = '0'
            report "Test FAILED"
               severity failure;
      end if;
   end process p_verify;

end architecture simulation;

