library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity gen_verify_data_tb is
end entity gen_verify_data_tb;

architecture simulation of gen_verify_data_tb is

   constant C_RATE_GEN    : integer := 7;
   constant C_RATE_VERIFY : integer := 4;

   constant C_CLK_PERIOD  : time := 10 ns;

   constant C_SIZE        : integer := 5;
   constant C_SEED        : integer := 1234567890;

   signal clk_s   : std_logic;
   signal valid_s : std_logic;
   signal ready_s : std_logic;
   signal data_s  : std_logic_vector(C_SIZE-1 downto 0);
   signal error_s : std_logic;

begin

   ------------------------------------------------------------------
   -- Clock generation
   ------------------------------------------------------------------

   p_clk : process
   begin
      clk_s <= '1', '0' after C_CLK_PERIOD/2;
      wait for C_CLK_PERIOD;
   end process;


   ------------------------------------------------------------------
   -- Generate stream of test data
   ------------------------------------------------------------------

   i_sim_gen_data : entity work.sim_gen_data
      generic map (
         G_RATE => C_RATE_GEN,
         G_SEED => C_SEED,
         G_SIZE => C_SIZE
      )
      port map (
         clk_i   => clk_s,
         valid_o => valid_s,
         ready_i => ready_s,
         data_o  => data_s
      ); -- i_sim_gen_data


   ------------------------------------------------------------------
   -- Verify stream of test data
   ------------------------------------------------------------------

   i_sim_verify_data : entity work.sim_verify_data
      generic map (
         G_RATE => C_RATE_VERIFY,
         G_SEED => C_SEED,
         G_SIZE => C_SIZE
      )
      port map (
         clk_i   => clk_s,
         valid_i => valid_s,
         ready_o => ready_s,
         data_i  => data_s,
         error_o => error_s
      ); -- i_sim_verify_data

end architecture simulation;

