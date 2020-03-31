library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity sim_gen_data is
   generic (
      G_RATE : integer; -- From 1 to 16
      G_SEED : integer;
      G_SIZE : integer
   );
   port (
      clk_i   : in  std_logic;
      valid_o : out std_logic;
      ready_i : in  std_logic;
      data_o  : out std_logic_vector(G_SIZE-1 downto 0)
   );
end entity sim_gen_data;

architecture simulation of sim_gen_data is

   signal seed_r  : std_logic_vector(31 downto 0) := to_stdlogicvector(G_SEED, 32);

   signal cnt_r   : std_logic_vector(3 downto 0) := (others => '1');

begin

   p_gen_data : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if valid_o = '1' and ready_i = '1' then
            seed_r <= seed_r(30 downto 0) & (seed_r(31) xor seed_r(28));
            cnt_r  <= 15-to_stdlogicvector(G_RATE, 4);
         end if;

         if cnt_r /= 0 then
            cnt_r <= cnt_r - 1;
         end if;
      end if;
   end process p_gen_data;

   data_o  <= seed_r(G_SIZE-1 downto 0) when valid_o = '1' else (others => 'U');
   valid_o <= '0' when cnt_r /= 0 else '1';

end architecture simulation;

