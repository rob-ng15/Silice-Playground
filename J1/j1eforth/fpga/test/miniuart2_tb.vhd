--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:48:15 12/20/2014
-- Design Name:   
-- Module Name:   /mnt/hgfs/Projects/j1eforth/vhdl/test/miniuart2_tb.vhd
-- Project Name:  papilio-pro-forth
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MINIUART2
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY miniuart2_tb IS
END miniuart2_tb;
 
ARCHITECTURE behavior OF miniuart2_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MINIUART2
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         rx : IN  std_logic;
         tx : OUT  std_logic;
         io_rd : IN  std_logic;
         io_wr : IN  std_logic;
         io_addr : IN  std_logic;
         io_din : IN  std_logic_vector(15 downto 0);
         io_dout : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal rx : std_logic := '0';
   signal io_rd : std_logic := '0';
   signal io_wr : std_logic := '0';
   signal io_addr : std_logic := '0';
   signal io_din : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal tx : std_logic;
   signal io_dout : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns; -- 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MINIUART2 PORT MAP (
          clk => clk,
          rst => rst,
          rx => rx,
          tx => tx,
          io_rd => io_rd,
          io_wr => io_wr,
          io_addr => io_addr,
          io_din => io_din,
          io_dout => io_dout
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*5;
		
		rst <= '1';
		
		wait for clk_period*3;
		
		rst <= '0';
		
      wait for clk_period*3;
		
      -- insert stimulus here 
	   io_din <= X"002A";
       io_addr <= '1';
       io_wr <= '1';
		
		wait for clk_period;
		
		io_addr <= '0';
		io_din <= X"0000";
		io_wr <= '0';
		
      wait;
   end process;

END;
