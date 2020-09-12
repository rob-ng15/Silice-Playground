--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:12:23 03/03/2012
-- Design Name:   
-- Module Name:   /home/ben/prog/PapilioForth/ise/main_tb.vhd
-- Project Name:  PapilioForth
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
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
 
ENTITY papilio_pro_j1_tb IS
END papilio_pro_j1_tb;
 
ARCHITECTURE behavior OF papilio_pro_j1_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT papilio_pro_j1
    PORT(
         clk_in : IN  std_logic;
         rx : IN  std_logic;
         tx : OUT  std_logic;
         wing : INOUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal rx : std_logic := '0';

 	--Outputs
   signal tx : std_logic;
   signal wing : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: papilio_pro_j1 PORT MAP (
          clk_in => clk_in,
          rx => rx,
          tx => tx,
          wing => wing
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_in_period*50;

      -- insert stimulus here 

      wait;
   end process;

END;
